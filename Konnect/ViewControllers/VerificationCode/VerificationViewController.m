//
//  VerificationViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 18/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VerificationViewController.h"
#import "LoginViewController.h"
#import "SubscriptionViewController.h"
#import "SideViewController.h"
#import "SignupViewController.h"
#import "KN_VenueProfileSetup.h"
#import <AWSS3/AWSS3.h>
@interface VerificationViewController ()<UITextFieldDelegate,LGSideMenuDelegate>
{
    UIViewController *viewCode;
    AppDelegate *delegate;
    NSMutableArray *arrCheckVerificationCode;
    NSMutableDictionary *dicProfileSetup;
}
@end

@implementation VerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtVerificationFieldCode.leftView = paddingView;
    txtVerificationFieldCode.leftViewMode = UITextFieldViewModeAlways;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568)
    {
        heightContimueBtn.constant = 35;
        heightVerificationField.constant = 35;
        yCoordinateImage.constant = 70;
    }
    arrCheckVerificationCode = [[NSMutableArray alloc]init];
    txtVerificationFieldCode.delegate = self;
    
    arrCheckVerificationCode = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
}

#pragma mark -  UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger totLength= [textField.text length] + [string length] - range.length;
    if (totLength >12)
        return NO;
    else
        return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -  Navigation
//Navigation segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"VenueLogin"])
    {
        // Get reference to the destination view controller
        LoginViewController *vc = [segue destinationViewController];
        vc.strLoginType = delegate.strLoginType;
    }
    else if ([[segue identifier] isEqualToString:@"SignupProcess"])
    {
        // Get reference to the destination view controller
      //  SignupViewController *vc = [segue destinationViewController];
      
    }
   
    
}
#pragma mark - IBaction Method

- (IBAction)clickContinueButton:(id)sender {
    if ([[Singlton sharedManager]check_null_data:txtVerificationFieldCode.text]) {
        
        [[Singlton sharedManager] alert:self title:Alert message:Verification_Code];
    }
    else
    {
         [self.view endEditing:YES];
         [self checkVerificationCode];
    }
}
- (IBAction)clickLoginNow:(id)sender {
    
    [self performSegueWithIdentifier:@"VenueLogin" sender:self];
}

#pragma mark - ----------Touches event------------
//Implement for hide keyborad on touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [txtVerificationFieldCode resignFirstResponder];
    }
}
#pragma mark - Custome Method
-(void)checkVerificationCode
{
     dispatch_async(dispatch_get_main_queue(), ^{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
     });
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"VerificationCode"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : txtVerificationFieldCode.text
                                                 };
    [[dynamoDBObjectMapper scan:[KN_VenueProfileSetup class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]showHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 arrCheckVerificationCode= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueProfileSetup *venueProfile in paginatedOutput.items) {
                     [arrCheckVerificationCode addObject:venueProfile];
                 }
                 if (arrCheckVerificationCode.count>0) {

                     if([[[arrCheckVerificationCode valueForKey:@"isProfileSetupCompleted"]objectAtIndex:0] isEqualToString:@"YES"])
                     {
                         [[Singlton sharedManager]killHUD];
                         self.view.userInteractionEnabled = YES;
                         [[Singlton sharedManager] alert:self title:Alert message:@"This verification code is used for other Venue Owner."];
                     }
                     else{
                         [[Singlton sharedManager]killHUD];
                         self.view.userInteractionEnabled = YES;
                         dicProfileSetup = [[NSMutableDictionary alloc]init];
                         [dicProfileSetup setValue:[[arrCheckVerificationCode valueForKey:@"Address"]objectAtIndex:0] forKey:@"Address"];;
                         [dicProfileSetup setValue:[[arrCheckVerificationCode valueForKey:@"EndTime"]objectAtIndex:0] forKey:@"EndTime"];
                         [dicProfileSetup setValue:[[arrCheckVerificationCode valueForKey:@"Id"]objectAtIndex:0] forKey:@"Id"];
                         [dicProfileSetup setValue:[[arrCheckVerificationCode valueForKey:@"Latitude"]objectAtIndex:0] forKey:@"Latitude"];
                         [dicProfileSetup setValue:[[arrCheckVerificationCode valueForKey:@"Longitude"]objectAtIndex:0] forKey:@"Longitude"];
                         [dicProfileSetup setValue:[[arrCheckVerificationCode valueForKey:@"Name"]objectAtIndex:0] forKey:@"Name"];
                         [dicProfileSetup setValue:[[arrCheckVerificationCode valueForKey:@"PhoneNumber"]objectAtIndex:0] forKey:@"PhoneNumber"];
                         
                         [dicProfileSetup setValue:[[arrCheckVerificationCode valueForKey:@"StartTime"]objectAtIndex:0] forKey:@"StartTime"];
                         [[NSUserDefaults standardUserDefaults]setObject:dicProfileSetup forKey:@"VenueProfileData"];
                         
                         [self performSegueWithIdentifier:@"SignupProcess" sender:self];
                         //HomeLocation
                     }
                 }
                 else
                 {
                     [[Singlton sharedManager]killHUD];
                     self.view.userInteractionEnabled = YES;
                    [[Singlton sharedManager] alert:self title:Alert message:@"Your verification code is wrong"];
                 }
             });
             
         }
         
         return nil;
         
     }];
}

@end
