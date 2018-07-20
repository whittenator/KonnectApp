//
//  LoginViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 13/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "LoginViewController.h"
#import "VOHomeViewController.h"
#import "MenuViewController.h"
#import "SlideMenuController.h"
#import "MainViewController.h"
#import "LGSideMenuController.h"
#import "SideViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AWSS3/AWSS3.h>
#import "AWSLambda/AWSLambda.h"
#import "UIImageView+WebCache.h"
#import "KN_User.h"
#import "KN_Notification.h"
#import "KN_VenueProfileSetup.h"
#import "KN_ClaimYourBusiness.h"
#import "SubscriptionViewController.h"

#define BTN_LOGIN  0
#define BTN_FACEBOOK  1

@interface LoginViewController ()<LGSideMenuDelegate>
{
    UIViewController *viewLogin;
    AppDelegate *delegate;
    BOOL isEMailVerified;
    NSMutableArray *dicUserList;
    NSMutableDictionary *dictUser;
    NSMutableArray *dicProfileDetails;
    NSMutableArray *arrVenueDetails;
    NSMutableDictionary *dicProfileSetup;
    NSMutableDictionary *dictUserDetails;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dictUserDetails = [[NSMutableDictionary alloc]init];
    dictUserDetails  = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"];
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
    arrVenueDetails = [[NSMutableArray alloc]init];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIWindow *windows = [[UIApplication sharedApplication].delegate window];
    viewLogin = windows.rootViewController;
    
    //For the Swipe Gesture
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];
    
    //For the textField Padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtEmail.leftView = paddingView;
    txtEmail.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingViewPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtPassword.leftView = paddingViewPassword;
    txtPassword.leftViewMode = UITextFieldViewModeAlways;
    
    if ([_strLoginType isEqualToString:@"User"]||[[[NSUserDefaults standardUserDefaults]valueForKey:@"UserType"]isEqualToString:@"User"])
    {
        if (screenBounds.size.height == 568)
        {
            yCordinate.constant = 40;
            yCordinateSignUp.constant = 25;
            yCordinateOrlogin.constant = 20;
            yCordinatefacebook.constant = 20;
            EmailTextHeight.constant = 35;
            loginHeight.constant = 35;
            PasswordTextHeight.constant = 35;
        }
        else
            yCordinate.constant = 70;
        imgLogo.hidden = NO;
        btnFacebook.hidden = NO;
        if ([[Singlton sharedManager] getLoginAndSignUpStatus]&&[delegate.strLoginType isEqualToString:@"User"])
        {
           [self performSegueWithIdentifier:@"MainScreen" sender:self];
        }
    }
    else {
        if (screenBounds.size.height == 568)
        {
            yCordinate.constant = 80;
            EmailTextHeight.constant = 35;
            loginHeight.constant = 35;
            PasswordTextHeight.constant = 35;
        }else
            yCordinate.constant = 123;
        imgOrLogin.hidden = YES;
        btnFacebook.hidden = YES;
        
        if(dictUserDetails != nil){
            if([dictUserDetails valueForKey:@"isFirstTimeLogin"] != nil) {
                if([[dictUserDetails valueForKey:@"isFirstTimeLogin"] isEqualToString:@"YES"]){
                    [self performSegueWithIdentifier:@"SubscriptionScreen" sender:self];
                }
                else if ([[Singlton sharedManager] getLoginAndSignUpStatus] && [delegate.strLoginType isEqualToString:@"VenueUser"]){
                    [self performSegueWithIdentifier:@"VenueScreen" sender:self];
                }
            }
        }
    }
}


#pragma mark - ----------Touches event------------
//Implement for hide keyborad on touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [txtEmail resignFirstResponder];
        [txtPassword resignFirstResponder];
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

- (IBAction)clickButtons:(id)sender {
    
    UIButton * btnSelected = (UIButton *) sender;
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    switch (btnSelected.tag) {
            
        case BTN_LOGIN:
        {
            if ([[Singlton sharedManager]check_null_data:txtEmail.text]) {
                [[Singlton sharedManager] alert:viewLogin title:Alert message:Eamil_Alert];
            }
            else if ([[Singlton sharedManager]check_null_data:txtPassword.text])
            {
                [[Singlton sharedManager] alert:viewLogin title:Alert message:Password_Alert];
            }
            else
            {
                [self.view endEditing:YES];
                [self LoginWithEmailAndPassword];
            }
        }
            break;
        case BTN_FACEBOOK:
        {
            [self callFBLogin];
        }
            break;
        default:
            break;
    }
}

#pragma mark -  AWS Methods
-(void)LoginWithEmailAndPassword
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    //     code to fetch data
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper load:[KN_User class] hashKey:[[Singlton sharedManager] getMD5Checksum:txtEmail.text] rangeKey:nil]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
              [[Singlton sharedManager]killHUD];
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 KN_User *UserDtial = task.result;
                 //Do UserDtial with the result.
                 self.view.userInteractionEnabled = YES;
                 
                  [[Singlton sharedManager]killHUD];
                 NSString *emailVerify = [NSString stringWithFormat:@"%@",[UserDtial valueForKey:@"EmailVerification"]];
                 NSString *strPassword = [UserDtial valueForKey:@"Password"];
                 NSString *Md5Password = [[Singlton sharedManager] getMD5Checksum:txtPassword.text];
                 
                 if (![[UserDtial valueForKey:@"Email"]isEqualToString:txtEmail.text]) {
                     self.view.userInteractionEnabled = YES;
                     [[Singlton sharedManager] alert:viewLogin title:Message message:IncorrectEmailIdPassword];
                 }
                 else if (![strPassword isEqualToString:Md5Password]){
                     self.view.userInteractionEnabled = YES;
                     [[Singlton sharedManager] alert:viewLogin title:Message message:IncorrectEmailIdPassword];
                 }
                 else if ([[UserDtial valueForKey:@"UserType"]isEqualToString:@"User"])
                 {
                    dictUser = [[NSMutableDictionary alloc]init];
                        dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                        dispatch_async(queue1, ^{
                                 [[Singlton sharedManager] SettingANSForPushNotification:[UserDtial valueForKey:@"UserId"] AndEmailId:[UserDtial valueForKey:@"Email"]];
                        });
                     
                          if ([emailVerify isEqualToString:@"0"])
                          {
                              [[NSNotificationCenter defaultCenter] addObserver:self
                                                                       selector:@selector(Verifiymail:)name:@"CallEmailVerify"
                                                                         object:nil];
                              [[Singlton sharedManager] alert:viewLogin title:Alert message:VerifyEmail email:txtEmail.text];
                          }
                          else if([delegate.strLoginType isEqualToString:[UserDtial valueForKey:@"UserType"]])
                          {
                               [[Singlton sharedManager] setLoginAndSignUpStatus:YES];
                              dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                              dispatch_async(queue2, ^{
                                  [self GetAllNotifications:[UserDtial valueForKey:@"UserId"]];
                              });
                              [dictUser setObject:[UserDtial valueForKey:@"Email"] forKey:@"Email"];
                              [dictUser setObject:[UserDtial valueForKey:@"EmailVerification"] forKey:@"EmailVerification"];
                              [dictUser setObject:[UserDtial valueForKey:@"PushEnabled"] forKey:@"PushEnabled"];
                              [dictUser setObject:[UserDtial valueForKey:@"SubscriptionStatus"] forKey:@"SubscriptionStatus"];
                              [dictUser setObject:[UserDtial valueForKey:@"VerificationCode"] forKey:@"VerificationCode"];
                              [dictUser setObject:[UserDtial valueForKey:@"UserId"] forKey:@"UserId"];
                              [dictUser setObject:[UserDtial valueForKey:@"Firstname"] forKey:@"firstName"];
                              [dictUser setObject:[UserDtial valueForKey:@"Lastname"] forKey:@"lastName"];
                              [dictUser setObject:[UserDtial valueForKey:@"UserImage"] forKey:@"UserImage"];
                              [dictUser setObject:[UserDtial valueForKey:@"HomeLocation"] forKey:@"HomeLocation"];
                              NSArray *arrayFollower = [[UserDtial valueForKey:@"Followers"] allObjects];
                              NSArray *arrayFollowing = [[UserDtial valueForKey:@"Following"] allObjects];
                              [dictUser setObject:arrayFollower forKey:@"Followers"];
                              [dictUser setObject:arrayFollowing forKey:@"Following"];
                              [dictUser setObject:@"NO" forKey:@"fblogin"];
                              [[NSUserDefaults standardUserDefaults]setObject:[UserDtial valueForKey:@"isFirstTimeLogin"] forKey:@"isFirstTimeLogin"];
                              [[NSUserDefaults standardUserDefaults] setObject:dictUser forKey:@"loginUser"];
                              [Singlton sharedManager].strComingFromVenueOwnerCommentScreen = nil;
                              [self performSegueWithIdentifier:@"MainScreen" sender:self];
                          }
                          else{
                             [[Singlton sharedManager] alert:viewLogin title:Alert message:@"Venue Owner email id is incorrect"];
                          }
                }
                else if ([[UserDtial valueForKey:@"UserType"]isEqualToString:@"VenueUser"])
                {
                     dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                     dispatch_async(queue1, ^{
                         [[Singlton sharedManager] SettingANSForPushNotification:[UserDtial valueForKey:@"UserId"] AndEmailId:[UserDtial valueForKey:@"Email"]];
                     });
                     [Singlton sharedManager].strComingFromVenueOwnerCommentScreen = nil;
                     [Singlton sharedManager].dictVenueEventDetailInfo = nil;
                    if ([emailVerify isEqualToString:@"0"])
                    {
                        [[NSNotificationCenter defaultCenter] addObserver:self
                                                                 selector:@selector(Verifiymail:)name:@"CallEmailVerify"
                                                                   object:nil];
                        [[Singlton sharedManager] alert:viewLogin title:Alert message:VerifyEmail email:txtEmail.text];
                    }
                    else if([delegate.strLoginType isEqualToString:[UserDtial valueForKey:@"UserType"]])
                    {
                                [[Singlton sharedManager]killHUD];
                                self.view.userInteractionEnabled = YES;
                                [[Singlton sharedManager] setLoginAndSignUpStatus:YES];
                                dictUser = [[NSMutableDictionary alloc]init];
                                [dictUser setObject:[UserDtial valueForKey:@"Email"] forKey:@"Email"];
                                [dictUser setObject:[UserDtial valueForKey:@"EmailVerification"] forKey:@"EmailVerification"];
                                [dictUser setObject:[UserDtial valueForKey:@"PushEnabled"] forKey:@"PushEnabled"];
                                [dictUser setObject:[UserDtial valueForKey:@"SubscriptionStatus"] forKey:@"SubscriptionStatus"];
                                [dictUser setObject:[UserDtial valueForKey:@"VerificationCode"] forKey:@"VerificationCode"];
                                [dictUser setObject:[UserDtial valueForKey:@"UserId"] forKey:@"UserId"];
                                [dictUser setObject:[UserDtial valueForKey:@"isFirstTimeLogin"] forKey:@"isFirstTimeLogin"];
                                NSArray *arrayFollower = [[UserDtial valueForKey:@"Followers"] allObjects];
                                NSArray *arrayFollowing = [[UserDtial valueForKey:@"Following"] allObjects];
                                [dictUser setObject:arrayFollower forKey:@"Followers"];
                                [dictUser setObject:arrayFollowing forKey:@"Following"];
                                [[NSUserDefaults standardUserDefaults] setObject:dictUser forKey:@"UserDetail"];
                                [self FetchVenueProfile];
                    }
                    else
                    {
                            [[Singlton sharedManager] alert:viewLogin title:Alert message:@"Consumer email id is incorrect"];
                    }
                 }
             });
         }
         else if([task.result isKindOfClass:[NSNull class]])
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 [[Singlton sharedManager] alert:viewLogin title:Message message:IncorrectEmailIdPassword];
             });
         }
         else if(task.result  == nil)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 [[Singlton sharedManager] alert:viewLogin title:Message message:IncorrectEmailIdPassword];
             });
         }
         return nil;
     }];
    
}

-(void)GetAllNotifications:(NSString *)strLoginUserId
{
    [[Singlton sharedManager]showHUD];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"NotificationTo"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" :strLoginUserId
                                                 };
    [[dynamoDBObjectMapper scan:[KN_Notification class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 [Singlton sharedManager].arrNotifications = [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_Notification *chat in paginatedOutput.items)
                 {
                     
                     [[Singlton sharedManager].arrNotifications addObject:chat.dictionaryValue];
                     
                 }//NotificationTo
                 
             });
             
         }
         
         return nil;
         
     }];
}
-(void)GettingKonnectVenues
{
    [[Singlton sharedManager]showHUD];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    
    [[dynamoDBObjectMapper scan:[KN_VenueProfileSetup class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
              [self performSegueWithIdentifier:@"MainScreen" sender:self];
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             [[Singlton sharedManager]killHUD];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [Singlton sharedManager].arrKonnectVenues = [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueProfileSetup *chat in paginatedOutput.items)
                 {
                     [[Singlton sharedManager].arrKonnectVenues addObject:chat.dictionaryValue];
                 }
                 
                  [self performSegueWithIdentifier:@"MainScreen" sender:self];
             });
             
         }
         
         return nil;
         
     }];
    
    
}

- (void) Verifiymail:(NSNotification *) notification
{
    NSLog(@"Resend Caklled");
    [self callLambdaVerifyMail];
    
    
}
-(void)callFBLogin{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions: @[@"public_profile",@"email"]
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
            NSLog(@"fetched user: %@",result);
             [self getFacebookProfileInfo];
         }
     }];
}
-(void)getFacebookProfileInfo {
    
    if ([FBSDKAccessToken currentAccessToken])
    {
        NSLog(@"Token is available : %@",[[FBSDKAccessToken currentAccessToken]tokenString]);
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, first_name, last_name, picture.type(large), email, birthday, location ,hometown"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error)
             {
                 [self checkFBLogin:result];
             }
             else
             {
             }
             }];
        
    }
    
}
        
-(void)checkFBLogin:(NSDictionary *)info
{
   [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"Email"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [info valueForKey:@"email"]
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
                         
                         [self SaveUserdata:info];
                     }
                     else
                     {
                         
                        [[Singlton sharedManager]killHUD];
                        // [[SDImageCache sharedImageCache]clearMemory];
                        // [[SDImageCache sharedImageCache]clearDisk];
                         self.view.userInteractionEnabled = YES;
                         //HomeLocation
                         [[Singlton sharedManager] setLoginAndSignUpStatus:YES];
                         dictUser = [[NSMutableDictionary alloc]init];
                         [dictUser setObject:[info valueForKey:@"email"] forKey:@"Email"];
                         if ([[dicUserList valueForKey:@"HomeLocation"]objectAtIndex:0] == nil || [[dicUserList valueForKey:@"HomeLocation"]objectAtIndex:0] == (id)[NSNull null]) {
                             
                               [dictUser setObject:@"NA" forKey:@"HomeLocation"];
                         }
                         else
                         {
                         [dictUser setObject:[[dicUserList valueForKey:@"HomeLocation"]objectAtIndex:0] forKey:@"HomeLocation"];
                         }
                          dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                         dispatch_async(queue1, ^{
                             [[Singlton sharedManager] SettingANSForPushNotification:[[dicUserList valueForKey:@"UserId"]objectAtIndex:0] AndEmailId:[[dicUserList valueForKey:@"Email"]objectAtIndex:0]];
                         });
                         dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                         dispatch_async(queue2, ^{
                             [self GetAllNotifications:[[dicUserList valueForKey:@"UserId"]objectAtIndex:0]];
                         });
                         [dictUser setObject:[[dicUserList valueForKey:@"UserId"]objectAtIndex:0] forKey:@"UserId"];
                         [dictUser setObject:[info valueForKey:@"first_name"] forKey:@"firstName"];
                         [dictUser setObject:[info valueForKey:@"last_name"] forKey:@"lastName"];
                         [dictUser setObject:[[[info valueForKey:@"picture"]valueForKey:@"data"]valueForKey:@"url"] forKey:@"UserImage"];
                         [dictUser setObject:@"YES" forKey:@"fblogin"];
                         [dictUser setObject:[[dicUserList valueForKey:@"FBProfilePicChanged"]objectAtIndex:0] forKey:@"FBProfilePicChanged"];
                         NSArray *arrayFollower = [[[dicUserList valueForKey:@"Followers"]objectAtIndex:0] allObjects];
                         NSArray *arrayFollowing = [[[dicUserList valueForKey:@"Following"]objectAtIndex:0] allObjects];
                         [dictUser setObject:arrayFollower forKey:@"Followers"];
                         [dictUser setObject:arrayFollowing forKey:@"Following"];
                         [[NSUserDefaults standardUserDefaults] setObject:dictUser forKey:@"loginUser"];
                         [[NSUserDefaults standardUserDefaults]setValue:[[dicUserList valueForKey:@"isFirstTimeLogin"]objectAtIndex:0] forKey:@"isFirstTimeLogin"];
                          //[self GettingKonnectVenues];
                        [self performSegueWithIdentifier:@"MainScreen" sender:self];
                     }
                 }
                 else
                 {
                     [self SaveUserdata:info];
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
}

-(void)SaveUserdata:(NSDictionary *)info

{
    
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    
    //int VerificationCode = arc4random() % 10000;
    
    KN_User *UserDetail = [KN_User new];
    UserDetail.UserId = [[Singlton sharedManager] getMD5Checksum:[info valueForKey:@"email"]];
    UserDetail.Email = [info valueForKey:@"email"] ;
  
  
    UserDetail.UserId = [info valueForKey:@"id"];
    UserDetail.UserType =  delegate.strLoginType;
    UserDetail.EmailVerification =[NSNumber numberWithBool:YES];
     UserDetail.FBLogin =[NSNumber numberWithBool:YES];
    UserDetail.CreatedAt = NumberCreatedAt;
    UserDetail.UpdatedAt = NumberCreatedAt;
    UserDetail.DeviceToken = [Singlton sharedManager].strDeviceToken;
    UserDetail.PushEnabled = [NSNumber numberWithBool:YES];
    UserDetail.Firstname = [info valueForKey:@"first_name"];
    UserDetail.Lastname = [info valueForKey:@"last_name"];
    UserDetail.Latitude = @"NA";
    UserDetail.Longitude = @"NA";
    UserDetail.HomeLocation = [info valueForKey:@"homelocation"];
    UserDetail.FBProfilePicChanged = @"NO";
    UserDetail.UserImage = [[[info valueForKey:@"picture"]valueForKey:@"data"]valueForKey:@"url"];
    UserDetail.VerificationCode = @"12345";
    UserDetail.isFirstTimeLogin = @"YES";
    UserDetail.Followers = [NSSet setWithObject:@"NA"];
    UserDetail.Following = [NSSet setWithObject:@"NA"];
    [[dynamoDBObjectMapper save:UserDetail]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             //Do something with the result.
             NSLog(@"Task result: %@",task.result);
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                  [[Singlton sharedManager]killHUD];
                 
                 self.view.userInteractionEnabled = YES;
                  [[Singlton sharedManager] setLoginAndSignUpStatus:YES];
                 dictUser = [[NSMutableDictionary alloc]init];
                 [dictUser setObject:[info valueForKey:@"email"] forKey:@"Email"];
                [dictUser setObject:[info valueForKey:@"id"] forKey:@"UserId"];
                 [dictUser setObject:@"NA" forKey:@"HomeLocation"];
                 [dictUser setObject:[info valueForKey:@"first_name"] forKey:@"firstName"];
                 [dictUser setObject:[info valueForKey:@"last_name"] forKey:@"lastName"];
                 [dictUser setObject:[[[info valueForKey:@"picture"]valueForKey:@"data"]valueForKey:@"url"] forKey:@"UserImage"];
                 [dictUser setObject:@"YES" forKey:@"fblogin"];
                  [dictUser setObject:@"NO" forKey:@"FBProfilePicChanged"];
                 NSSet *Follower = [NSSet setWithObject:@"NA"];
                   NSSet *Following = [NSSet setWithObject:@"NA"];
                 NSArray *arrayFollower = [Follower allObjects];
                 NSArray *arrayFollowing = [Following allObjects];
                 [dictUser setObject:arrayFollower forKey:@"Followers"];
                 [dictUser setObject:arrayFollowing forKey:@"Following"];
                 [[NSUserDefaults standardUserDefaults] setObject:dictUser forKey:@"loginUser"];
                 [[NSUserDefaults standardUserDefaults]setValue:@"YES" forKey:@"isFirstTimeLogin"];
                 //[self GettingKonnectVenues];
                 [self performSegueWithIdentifier:@"MainScreen" sender:self];
             });
             
         }
         return nil;
     }];
    
}

-(void)callLambdaVerifyMail
{
    NSString *strEmailUrl;
    
    if ([UserMode isEqualToString:@"Live"])
    {
        strEmailUrl = @"https://3v8mklo338.execute-api.us-east-1.amazonaws.com/Production/verifyemail";
    }
    else
    {
        strEmailUrl = @"https://wbuu2paita.execute-api.us-east-1.amazonaws.com/production/verifyemail";
    }
    //https://wbuu2paita.execute-api.us-east-1.amazonaws.com/production/verifyemail
    [[Singlton sharedManager] showHUD];
     AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
     NSDictionary *parameters = @{
     @"fromAddress":@"",
     @"toAddress":@[txtEmail.text],
     @"subject":@"Konnect: Verification Emaill",
     @"bodyTemplate":[NSString stringWithFormat:@"%@?email=%@&code=%@&userId=%@",strEmailUrl,txtEmail.text,[dictUser objectForKey:@"VerificationCode"],[dictUser objectForKey:@"UserId"]]
     };
    
     [[lambdaInvoker invokeFunction:@"sendMail"
     JSONObject:parameters] continueWithBlock:^id(AWSTask *task) {
     if (task.error) {
          self.view.userInteractionEnabled = YES;
     dispatch_async(dispatch_get_main_queue(), ^{
     [[Singlton sharedManager] killHUD];
     
     });
     
     NSLog(@"Error: %@", task.error);
     }
     if (task.result) {
         NSLog(@"Result: %@", task.result);
     dispatch_async(dispatch_get_main_queue(), ^{
          self.view.userInteractionEnabled = YES;
    [[Singlton sharedManager] killHUD];
     });
     }
     return nil;
     }];
}

-(void)FetchVenueProfile
{
    [[Singlton sharedManager]showHUD];
    NSMutableDictionary *dictVenueDetails = [[NSMutableDictionary alloc]init];
    dictVenueDetails = [[NSUserDefaults standardUserDefaults]valueForKey:@"VenueProfileData"];
    self.view.userInteractionEnabled = NO;
    if(dictVenueDetails != nil)
        [self fetchVenueProfileByVenueId:[dictVenueDetails valueForKey:@"Id"]];
    else
        [self fetchVenueProfileByUserId];
}

- (void)fetchVenueProfileByVenueId:(NSString*)venueId
{
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"Id"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" :venueId
                                                 };
    [[dynamoDBObjectMapper scan:[KN_VenueProfileSetup class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
         }
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 arrVenueDetails= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueProfileSetup *chat in paginatedOutput.items) {
                     [arrVenueDetails addObject:chat];
                 }
                 if (arrVenueDetails.count>0) {
                     
                     self.view.userInteractionEnabled = YES;
                     dicProfileSetup = [[NSMutableDictionary alloc]init];
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"Address"]objectAtIndex:0] forKey:@"Address"];;
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"EndTime"]objectAtIndex:0] forKey:@"EndTime"];
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"Id"]objectAtIndex:0] forKey:@"Id"];
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"Latitude"]objectAtIndex:0] forKey:@"Latitude"];
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"Longitude"]objectAtIndex:0] forKey:@"Longitude"];
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"Name"]objectAtIndex:0] forKey:@"Name"];
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"PhoneNumber"]objectAtIndex:0] forKey:@"PhoneNumber"];
                     
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"StartTime"]objectAtIndex:0] forKey:@"StartTime"];
                     [[NSUserDefaults standardUserDefaults]setObject:dicProfileSetup forKey:@"VenueProfileData"];
                     
                     if ([[dictUser valueForKey:@"isFirstTimeLogin"]isEqualToString:@"YES"])
                         [self performSegueWithIdentifier:@"SubscriptionScreen" sender:self];
                     else
                         [self performSegueWithIdentifier:@"VenueScreen" sender:self];
                 }
                 else
                 {
                     self.view.userInteractionEnabled = YES;
                     [[Singlton sharedManager]killHUD];
                     if ([[dictUser valueForKey:@"isFirstTimeLogin"]isEqualToString:@"YES"])
                         [self performSegueWithIdentifier:@"SubscriptionScreen" sender:self];
                     else
                         [self performSegueWithIdentifier:@"VenueScreen" sender:self];
                 }
             });
         }
         return nil;
     }];
}

- (void)fetchVenueProfileByUserId{
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"UserId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [[Singlton sharedManager] getMD5Checksum:txtEmail.text]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_VenueProfileSetup class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             //NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 arrVenueDetails= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueProfileSetup *chat in paginatedOutput.items) {
                     [arrVenueDetails addObject:chat];
                 }
                 if (arrVenueDetails.count>0) {
                     self.view.userInteractionEnabled = YES;
                     dicProfileSetup = [[NSMutableDictionary alloc]init];
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"Address"]objectAtIndex:0] forKey:@"Address"];;
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"EndTime"]objectAtIndex:0] forKey:@"EndTime"];
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"Id"]objectAtIndex:0] forKey:@"Id"];
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"Latitude"]objectAtIndex:0] forKey:@"Latitude"];
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"Longitude"]objectAtIndex:0] forKey:@"Longitude"];
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"Name"]objectAtIndex:0] forKey:@"Name"];
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"PhoneNumber"]objectAtIndex:0] forKey:@"PhoneNumber"];
                     
                     [dicProfileSetup setValue:[[arrVenueDetails valueForKey:@"StartTime"]objectAtIndex:0] forKey:@"StartTime"];
                     [[NSUserDefaults standardUserDefaults]setObject:dicProfileSetup forKey:@"VenueProfileData"];
                     
                     if ([[dictUser valueForKey:@"isFirstTimeLogin"]isEqualToString:@"YES"])
                         [self performSegueWithIdentifier:@"SubscriptionScreen" sender:self];
                     else
                         [self performSegueWithIdentifier:@"VenueScreen" sender:self];
                 }
                 else
                 {
                     self.view.userInteractionEnabled = YES;
                     [[Singlton sharedManager]killHUD];
                     [[Singlton sharedManager] alert:viewLogin title:Alert message:@"Venue Owner is not exist with Konnect."];
                 }
             });
         }
         return nil;
     }];
}

#pragma mark -  Navigation
//Navigation segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    
    if ([[segue identifier] isEqualToString:@"MainScreen"])
    {
        MainViewController *loginController = [[UIStoryboard storyboardWithName:@"Consumer" bundle:nil] instantiateViewControllerWithIdentifier:@"MainViewController"];
       UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    
        loginController.rootViewController = self;
        loginController.delegate = self;
        
        UIWindow *window = UIApplication.sharedApplication.delegate.window;
        window.rootViewController = navController;
       [self.navigationController setNavigationBarHidden:YES animated:NO];
        
//         [window makeKeyAndVisible];
      
    }
    else if ([[segue identifier] isEqualToString:@"VenueScreen"])
    {
        SideViewController *loginController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SideViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
        loginController.rootViewController = self;
        loginController.delegate = self;
       
        UIWindow *window = UIApplication.sharedApplication.delegate.window;
        window.rootViewController = navController;
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    else if ([[segue identifier] isEqualToString:@"SubscriptionScreen"])
    {
        SubscriptionViewController *vc = [segue destinationViewController];
        vc.StrSignupCheck = @"Signup";
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
