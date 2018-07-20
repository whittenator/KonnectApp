//
//  ForgotPasswordViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 13/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "AWSLambda/AWSLambda.h"
#import "KN_User.h"
@interface ForgotPasswordViewController ()
{
    UIViewController *viewForgot;
}
@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIWindow *windows = [[UIApplication sharedApplication].delegate window];
    viewForgot = windows.rootViewController;
    
     //For the textField Padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtEmail.leftView = paddingView;
    txtEmail.leftViewMode = UITextFieldViewModeAlways;
    // Do any additional setup after loading the view.
    
     //For the Swipe Gesture
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568)
    {
        emailHeight.constant = 35;
        continueHeight.constant = 35;
        yCoordinateImageLogo.constant = 70;
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -  Custome Methods
-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)clickBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickButton:(id)sender {
    
    if ([[Singlton sharedManager]check_null_data:txtEmail.text]) {
        
        [[Singlton sharedManager] alert:viewForgot title:Alert message:Eamil_Alert];
        
    }
    else if  (![[Singlton sharedManager] validEmail:txtEmail.text])
    {
        [[Singlton sharedManager] alert:viewForgot title:Alert message:ValidEmail_Alert];
        
    }
    else
    {
        [self checkIfEmailExists];
       
    }
    
}

-(void)checkIfEmailExists
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    //     code to fetch data
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"Email"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : txtEmail.text
                                                 };
    [[dynamoDBObjectMapper scan:[KN_User class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *dicUserList= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 for (KN_User *chat in paginatedOutput.items) {
                     
                     [dicUserList addObject:chat];
                     
                 }
                 if (dicUserList.count>0) {
                     
                     if ([[dicUserList valueForKey:@"Email"]objectAtIndex:0] == nil || [[dicUserList valueForKey:@"Email"]objectAtIndex:0] == (id)[NSNull null]) {
                         
                        [[Singlton sharedManager] alert:self title:Message message:@"The email entered doesn't exist. Try Again?"];
                     }
                     else
                     {
                         [self callLambdaForgotPassword];
                         
                     }
                 }
                 else
                 {
                     [[Singlton sharedManager] alert:self title:Message message:@"The email entered doesn't exist."];
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
}


-(void)callLambdaForgotPassword
{
    [[Singlton sharedManager] showHUD];
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    NSDictionary *parameters = @{@"email":txtEmail.text};
    
    [[lambdaInvoker invokeFunction:[UserMode isEqualToString:@"Test"] ? @"sendResetPasswordLink":@"KONProd_SendResetPasswordLink"
                        JSONObject:parameters] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
          
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Singlton sharedManager] killHUD];
                  self.view.userInteractionEnabled = YES;
            });
            
            NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            NSLog(@"Result: %@", task.result);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
                [[Singlton sharedManager] killHUD];
                 [self.navigationController popViewControllerAnimated:YES];
                 [[Singlton sharedManager] alert:viewForgot title:Alert message:@"Please check your email for reseting the password"];
               
            });
        }
        return nil;
    }];
}
@end
