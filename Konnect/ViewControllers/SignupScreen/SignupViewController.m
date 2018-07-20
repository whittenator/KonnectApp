//
//  SignupViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 18/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "SignupViewController.h"
#import "VerificationViewController.h"
#import "SideViewController.h"
#import "SubscriptionViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "KN_User.h"
#import "Singlton.h"
#import "LoginViewController.h"
#import "AWSSNS.h"
#import "KN_ClaimYourBusiness.h"
@interface SignupViewController ()<LGSideMenuDelegate,UIWebViewDelegate,UITextFieldDelegate>
{
    AppDelegate *delegate;
    UIViewController *viewSignup;
    NSMutableArray *dicUserList;
    NSMutableDictionary *dicSaveDetail;
    NSString *strUserId;
    NSString *strEndPointARN;
    NSString *htmlFile;
    NSString* htmlString;
    NSMutableArray *dicClaimMyBusines;
    CGFloat animatedDistance;
}
@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    act.hidden = YES;
    [self LoadWebviewWithData];
    delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    UIWindow *windows = [[UIApplication sharedApplication].delegate window];
    viewSignup = windows.rootViewController;
    
    txtFirstName.delegate = self;
    
    btnTermCondition.titleLabel.numberOfLines = 0;
    //For the textField Padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtEmail.leftView = paddingView;
    txtEmail.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingViewPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtPassword.leftView = paddingViewPassword;
    txtPassword.leftViewMode = UITextFieldViewModeAlways;
    UIView *confirmPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtConfrmPassword.leftView = confirmPassword;
    txtConfrmPassword.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *PeddingFirstName = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtFirstName.leftView = PeddingFirstName;
    txtFirstName.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *PeddingLastName = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtLastName.leftView = PeddingLastName;
    txtLastName.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *PeddingPhoneNumber = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtPhoneNumber.leftView = PeddingPhoneNumber;
    txtPhoneNumber.leftViewMode = UITextFieldViewModeAlways;
    
    //For the swipe gesture
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
    
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568)
    {
        imglogoYCoordinate.constant = 75;
        layoutHeightPassword.constant = 35;
        layoutHeightConfirmPassowrd.constant = 35;
        layoutHeightEmail.constant = 35;
        signupHeight.constant = 35;
    }
    
    delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];;
    // Do any additional setup after loading the view.
}

-(void)LoadWebviewWithData
{
  htmlFile = [[NSBundle mainBundle] pathForResource:@"KonnectPrivacyPolicy" ofType:@"html"];
   htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
  webViewTermsNPolicy.delegate = self;
    [webViewTermsNPolicy loadHTMLString:htmlString baseURL: [[NSBundle mainBundle] bundleURL]];
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

#pragma mark -  Navigation
//Navigation segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    
    
     if ([[segue identifier] isEqualToString:@"SubscriptionScreen"])
     {
           SubscriptionViewController *vc = [segue destinationViewController];
         
     }
}

#pragma mark - IBAction Method

- (IBAction)actionSegment:(UISegmentedControl *)sender {
    
    if(sender.selectedSegmentIndex == 0)
    {
         htmlFile = [[NSBundle mainBundle] pathForResource:@"KonnectPrivacyPolicy" ofType:@"html"];
        [self LoadWebViewWithString];
    }
    else
    {
        htmlFile = [[NSBundle mainBundle] pathForResource:@"KonnectTermsNpolicy" ofType:@"html"];
       [self LoadWebViewWithString];
    }
}

-(void)LoadWebViewWithString
{
     htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
 [webViewTermsNPolicy loadHTMLString:htmlString baseURL: [[NSBundle mainBundle] bundleURL]];
}

- (IBAction)clickTermsAndCondition:(id)sender {
    viewTermsNPolicy.hidden = NO;
    btnTermCondition.selected=!btnTermCondition.selected;
    
    if (btnTermCondition.selected) {
        
        [btnTermCondition setSelected:YES];
    }
    else
    {
        [btnTermCondition setSelected:NO];
    }
}

- (IBAction)clickSignUp:(id)sender {
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
         [[Singlton sharedManager] alert:viewSignup title:Alert message:InternetCheck];
    }
    else
    {
    if ([[Singlton sharedManager]check_null_data:txtEmail.text]) {
        
        [[Singlton sharedManager] alert:viewSignup title:Alert message:Eamil_Alert];
        
    }
    else if  (![[Singlton sharedManager] validEmail:txtEmail.text])
    {
        [[Singlton sharedManager] alert:viewSignup title:Alert message:ValidEmail_Alert];
        
    }
    else if ([[Singlton sharedManager]check_null_data:txtPassword.text])
    {
        [[Singlton sharedManager] alert:viewSignup title:Alert message:Password_Alert];
    }
    else if ([txtPassword.text length] < 8)
    {
        [[Singlton sharedManager] alert:viewSignup title:Alert message:PasswordCharacters_Alert];
        
    }
    else if ([[Singlton sharedManager] check_null_data:txtConfrmPassword.text])
    {
        [[Singlton sharedManager] alert:viewSignup title:Alert message:ConfirmPassword_Alert];
    }
    else if (![txtPassword.text isEqualToString:txtConfrmPassword.text])
    {
        [[Singlton sharedManager] alert:viewSignup title:Alert message:PasswordMatch_Alert];
    }
    else if ([delegate.strLoginType isEqualToString:@"VenueUser"])
    {
        if ([[Singlton sharedManager] check_null_data:txtFirstName.text])
        {
            [[Singlton sharedManager] alert:viewSignup title:Alert message:FirstName];
        }
        else if ([[Singlton sharedManager] check_null_data:txtLastName.text])
        {
            [[Singlton sharedManager] alert:viewSignup title:Alert message:LastName];
        }
        else if ([[Singlton sharedManager] check_null_data:txtPhoneNumber.text])
        {
            [[Singlton sharedManager] alert:viewSignup title:Alert message:ContactNumber];
        }
        else if (![btnTermCondition isSelected])
        {
            [[Singlton sharedManager] alert:viewSignup title:Alert message:AcceptTermsCondotion_Alert];
        }
        else
        {
            [self.view endEditing:YES];
            [self ChekAlreadyExistEmail];
        }
    }
    else if (![btnTermCondition isSelected])
    {
        [[Singlton sharedManager] alert:viewSignup title:Alert message:AcceptTermsCondotion_Alert];
    }
    else
    {
        [self.view endEditing:YES];
        [self ChekAlreadyExistEmail];
    }
}
}

- (IBAction)clickAlreadyAccount:(id)sender {
    
    if([delegate.strLoginType isEqualToString:@"VenueUser"]){
        for (UIViewController *controller in self.navigationController.viewControllers) {
            
            //Do not forget to import AnOldViewController.h
            if ([controller isKindOfClass:[LoginViewController class]])
                [self.navigationController popToViewController:controller
                                                      animated:YES];
        }
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionHideView:(id)sender {
      viewTermsNPolicy.hidden = YES;
}
#pragma mark - UITextField Delagtes Method

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    CGRect viewFrame;
    
    viewFrame= self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    

    if (textField == txtEmail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self FetchClaimMyBusinessUserData];
        });
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
        static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
        static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
        static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
        static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 230;
        static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 216;
        
        CGRect textFieldRect;
        CGRect viewRect;
        
        textFieldRect =[self.view.window convertRect:textField.bounds fromView:textField];
        viewRect =[self.view.window convertRect:self.view.bounds fromView:self.view];
        
        CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
        CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
        CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
        CGFloat heightFraction = numerator / denominator;
        
        if (heightFraction < 0.0)
        {
            heightFraction = 0.0;
        }
        else if (heightFraction > 1.0)
        {
            heightFraction = 0.9;
        }
        
        UIInterfaceOrientation orientation =[[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait ||orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
        }
        else
        {
            animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
        }
        
        CGRect viewFrame;
        
        viewFrame= self.view.frame;
        viewFrame.origin.y -= animatedDistance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        
        [UIView commitAnimations];
}
#pragma mark - AWS Methods
-(void)ChekAlreadyExistEmail
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
         }
       
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 dicUserList= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_User *chat in paginatedOutput.items) {
                     
                     [dicUserList addObject:chat];
                     
                 }
                 if (dicUserList.count>0) {
                     
                     if ([[dicUserList valueForKey:@"Email"]objectAtIndex:0] == nil || [[dicUserList valueForKey:@"Email"]objectAtIndex:0] == (id)[NSNull null]) {
                         
                         [self SaveUserdata];
                         //[self SettingANSForPushNotification];
                     }
                     else
                     {
                         
                          [[Singlton sharedManager]killHUD];
                         self.view.userInteractionEnabled = YES;
                         [[Singlton sharedManager] alert:self title:Message message:@"Email-id already exist"];
                         
                     }
                 }
                 else
                 {
                     [self SaveUserdata];
                    //  [self SettingANSForPushNotification];
                 }
                
                 
                 
             });
             
         }
         
         return nil;
         
     }];
}
-(void)SaveUserdata
{
        self.view.userInteractionEnabled = NO;
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        
        NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
        NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
        
        int VerificationCode = arc4random() % 10000;
       strUserId = [[Singlton sharedManager] getMD5Checksum:txtEmail.text];
        KN_User *UserDetail = [KN_User new];
        UserDetail.UserId = strUserId;
        UserDetail.Email = txtEmail.text ;
        UserDetail.Password = [[Singlton sharedManager] getMD5Checksum:txtPassword.text];
        UserDetail.VerificationCode = [NSString stringWithFormat:@"%d",VerificationCode];
        UserDetail.UserType =  delegate.strLoginType;
        UserDetail.EmailVerification = [NSNumber numberWithBool:NO];  //[NSNumber numberWithBool:NO];
        UserDetail.CreatedAt = NumberCreatedAt;
        UserDetail.UpdatedAt = NumberCreatedAt;
        UserDetail.DeviceToken = [Singlton sharedManager].strDeviceToken;
        UserDetail.PushEnabled = [NSNumber numberWithBool:YES];
        UserDetail.SubscriptionStatus = [NSNumber numberWithBool:NO];
        UserDetail.FBLogin =[NSNumber numberWithBool:NO];
        if (![delegate.strLoginType isEqualToString:@"VenueUser"])
        {
            UserDetail.Firstname = @"NA";
            UserDetail.Lastname = @"NA";
            UserDetail.PhoneNumber = @"NA";
        }
        else
        {
            UserDetail.Firstname = txtFirstName.text;
            UserDetail.Lastname = txtLastName.text;
            UserDetail.PhoneNumber = txtPhoneNumber.text;
            UserDetail.VenueConnectDate = [NSNumber numberWithInt:timeInSeconds];
        }
        UserDetail.Latitude = @"NA";
        UserDetail.Longitude = @"NA";
        UserDetail.UserImage = @"NA";
        UserDetail.HomeLocation = @"NA";
        UserDetail.FBProfilePicChanged =@"YES";
        UserDetail.isFirstTimeLogin = @"YES";
        UserDetail.Followers = [NSSet setWithObject:@"NA"];
        UserDetail.Following = [NSSet setWithObject:@"NA"];
        UserDetail.EndPointARN = strEndPointARN;
        [[dynamoDBObjectMapper save:UserDetail]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                   [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 NSLog(@"The request failed. Error: [%@]", task.error);
                 [[Singlton sharedManager] alert:self title:Message message:@"please try again"];
             }
             if (task.result) {
                 
                 //Do something with the result.
                 NSLog(@"Task result: %@",task.result);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [[Singlton sharedManager]killHUD];
                     self.view.userInteractionEnabled = YES;
                     [[Singlton sharedManager] setLoginAndSignUpStatus:YES];
                      dicSaveDetail = [[NSMutableDictionary alloc]init];
                     [dicSaveDetail setValue:txtEmail.text forKey:@"Email"];
                     [dicSaveDetail setValue:txtPassword.text forKey:@"Password"];
                     [dicSaveDetail setValue:[[Singlton sharedManager] getMD5Checksum:txtEmail.text] forKey:@"UserId"];
                     [dicSaveDetail setValue:delegate.strLoginType forKey:@"UserType"];
                     [dicSaveDetail setValue:[Singlton sharedManager].strDeviceToken forKey:@"DeviceToken"];
                     [dicSaveDetail setValue:@"Yes" forKey:@"PushEnabled"];
                     [dicSaveDetail setValue:@"No" forKey:@"SubscriptionStatus"];
                     [dicSaveDetail setValue:@"Yes" forKey:@"EmailVerification"];
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     [defaults setObject:dicSaveDetail forKey:@"UserDetail"];
                     if ([delegate.strLoginType isEqualToString:@"User"]) {
                          [self.navigationController popViewControllerAnimated:YES];
                        [[Singlton sharedManager] alert:viewSignup title:Message message:@"Please check your email-id for verification."];
                     }
                    else  if ([delegate.strLoginType isEqualToString:@"VenueUser"]) {
                        
                        for (UIViewController *controller in self.navigationController.viewControllers) {
                            
                            //Do not forget to import AnOldViewController.h
                            if ([controller isKindOfClass:[LoginViewController class]]) {
                                
                                [self.navigationController popToViewController:controller
                                                                      animated:YES];
                                [[Singlton sharedManager] alert:viewSignup title:Message message:@"Please check your email-id for verification."];
                                break;
                            }
                        }
                     }
                 });
             }
             return nil;
         }];
        
    }

-(void) SettingANSForPushNotification
{
//    AWSSNSCreatePlatformEndpointInput *endPointInput = [[AWSSNSCreatePlatformEndpointInput alloc] init];
//    endPointInput.platformApplicationArn = AWSSNSARN;
//    endPointInput.token = [Singlton sharedManager].strDeviceToken;
//    endPointInput.customUserData = txtEmail.text;
//    [endPointInput.attributes setValue:@"true" forKey:@"Enabled"];
//    AWSSNS *sns = [AWSSNS defaultSNS];
//    [[sns createPlatformEndpoint:endPointInput] continueWithBlock:^id(AWSTask *task) {
//        if(task.error != nil)
//        {
//            NSLog(@"%@", task.error);
//        }
//        else
//        {
//            NSLog(@"success!");
//           strEndPointARN = [task.result valueForKey:@"endpointArn"];
//            [self SaveUserdata];
//            
//            
//        }
//        return nil;
//    }];
}
-(void)FetchClaimMyBusinessUserData
{
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
    [[dynamoDBObjectMapper scan:[KN_ClaimYourBusiness class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.view.userInteractionEnabled = YES;
                 dicClaimMyBusines= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_ClaimYourBusiness *chat in paginatedOutput.items) {
                     
                     [dicClaimMyBusines addObject:chat];
                     
                 }
                 if (dicClaimMyBusines.count>0) {
                  
                        dispatch_async(dispatch_get_main_queue(), ^{
                     txtFirstName.text = [[dicClaimMyBusines valueForKey:@"Firstname"]objectAtIndex:0];
                     txtLastName.text = [[dicClaimMyBusines valueForKey:@"Lastname"]objectAtIndex:0];
                     txtPhoneNumber.text = [[dicClaimMyBusines valueForKey:@"PhoneNumber"]objectAtIndex:0];
                        });
                 }
                 else
                 {
                     self.view.userInteractionEnabled = YES;
                     [[Singlton sharedManager]killHUD];
                 }
                 
             });
         }
         return nil;
     }];
}
@end
