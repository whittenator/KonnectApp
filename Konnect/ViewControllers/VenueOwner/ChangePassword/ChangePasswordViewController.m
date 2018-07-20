//
//  ChangePasswordViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 23/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "KN_User.h"
@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtPassword.leftView = paddingView;
    txtPassword.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingViewPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtConfirmPassword.leftView = paddingViewPassword;
    txtConfirmPassword.leftViewMode = UITextFieldViewModeAlways;
    
    NSLog(@"Viraj Dngre");
    
    // Do any additional setup after loading the view.
}

#pragma mark - ----------Touches event------------
//Implement for hide keyborad on touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        
        [txtConfirmPassword resignFirstResponder];
        [txtPassword resignFirstResponder];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma Mark - IBAction Method

- (IBAction)clickUpdate:(id)sender {
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    
    if ([[Singlton sharedManager]check_null_data:txtPassword.text]) {
        
        [[Singlton sharedManager] alert:self title:Alert message:Password_Alert];
    }
    else if ([txtPassword.text length] < 8)
    {
        [[Singlton sharedManager] alert:self title:Alert message:PasswordCharacters_Alert];
        
    }
    else if ([[Singlton sharedManager]check_null_data:txtConfirmPassword.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:ConfirmPassword_Alert];
    }
    else if (![txtPassword.text isEqualToString:txtConfirmPassword.text])
    {
          [[Singlton sharedManager] alert:self title:Alert message:PasswordMatch_Alert];
    }
    else
    {
        [self callChangePassword];
    }
    
}
-(void)callChangePassword
{
    [[Singlton sharedManager]showHUD];
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
    AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    NSDictionary *dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"]mutableCopy];
    hashKeyValue.S = [dictUserInfo valueForKey:@"UserId"];
    updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_User" : @"User";
    updateInput.key = @{ @"UserId" : hashKeyValue };
    
    AWSDynamoDBAttributeValue *newPrice8 = [AWSDynamoDBAttributeValue new];
    newPrice8.S = [[Singlton sharedManager] getMD5Checksum:txtPassword.text];
    
    //Updating Password for current User
    AWSDynamoDBAttributeValueUpdate *valueUpdate8 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate8.value = newPrice8;
    valueUpdate8.action = AWSDynamoDBAttributeActionPut;
    updateInput.attributeUpdates = @{@"Password":valueUpdate8};
    updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
    
    [[dynamoDB updateItem:updateInput]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 [[Singlton sharedManager] alert:self title:Message message:@"Please try again"];
                 self.view.userInteractionEnabled = YES;
             });
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"Updated");
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 [[Singlton sharedManager] alert:self title:Alert message:@"Passowrd has been updated successfully"];
             });
             
          }
         return nil;
     }];
    
}
- (IBAction)clickback:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
