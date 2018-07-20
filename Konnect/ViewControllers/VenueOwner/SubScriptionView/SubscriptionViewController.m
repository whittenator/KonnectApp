//
//  SubscriptionViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 25/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "SubscriptionViewController.h"
#import "MainViewController.h"
#import "KN_Subscription.h"
#import "ProfileSetupViewController.h"
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"
#import "BraintreeUI.h"
#import "AWSLambda/AWSLambda.h"
#import "KN_Payment.h"
#import "KN_SavedCards.h"
#import "SideViewController.h"
#define BTN_FOR1MONTH 0
#define BTN_FOR12MONTH 1
#define BTN_BACK 2
#define kPayPalEnvironment PayPalEnvironmentNoNetwork
@interface SubscriptionViewController ()<LGSideMenuDelegate>
{
     NSMutableDictionary *dicUserData;
     NSString *strPlanType;
     NSString *clientToken;
     NSString *strPalnAmount;
      BTDropInController *dropIn;
}

@end

@implementation SubscriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dicUserData  = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"];
    
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568)
        yImageLogo.constant = 60;
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if ([_strChangePaln isEqualToString:@"ChangePaln"]||[_strChangePaln isEqualToString:@"ChangePaymentMethod"]) {
        btnBack.hidden = NO;
    }
    [self CallLambdaFuncForClientToken];
}

#pragma mark - Flipside View Controller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"pushSettings"]) {
        [[segue destinationViewController] setDelegate:(id)self];
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
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Method
-(IBAction)clickButton:(UIButton *)sender
{
    
    UIButton * btnSelected = (UIButton *) sender;
    
    switch (btnSelected.tag) {
            
        case BTN_FOR1MONTH:
        {
            
            strPlanType = @"ForMonth";
            [btnFor1Month setBackgroundColor:[UIColor colorWithRed:62/255.0 green:143/255.0 blue:182/255.0 alpha:1.0]];
            [btnFor12Month setBackgroundColor:[UIColor colorWithRed:83/255.0 green:186/255.0 blue:231/255.0 alpha:1.0]];
            strPalnAmount = Monthly;
            if ([_strChangePaln isEqualToString:@"ChangePaln"]) {
                
                
                [self CallLambdaFuncForChangeSubscription];
            }
            else{
                
                [self showAlertView:@"Do you want to become a subscribed user?" withTag:0];
            }
           
            
        }
            break;
        case BTN_FOR12MONTH:
        {
            strPlanType = @"ForYear";
            [btnFor1Month setBackgroundColor:[UIColor colorWithRed:83/255.0 green:186/255.0 blue:231/255.0 alpha:1.0]];
            [btnFor12Month setBackgroundColor:[UIColor colorWithRed:62/255.0 green:143/255.0 blue:182/255.0 alpha:1.0]];
            strPalnAmount = Yearly;
            if ([_strChangePaln isEqualToString:@"ChangePaln"]) {
                
                [self CallLambdaFuncForChangeSubscription];
            }
            else{
                
                [self showAlertView:@"Do you want to become a subscribed user?" withTag:1];
              
            }
           
        }
            break;
        case BTN_BACK:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        break;
        default:
            break;
    }
}

#pragma mark - AWS Methods
-(void)SaveSubscriptionData

{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSString *Id = [NSString stringWithFormat:@"%@%f",[dicUserData valueForKey:@"UserId"],timeInSeconds];
    
    
    KN_Subscription *SubscriptionDetail = [KN_Subscription new];
    SubscriptionDetail.Id = Id;
    SubscriptionDetail.UserId = [dicUserData valueForKey:@"UserId"];
    SubscriptionDetail.StartDate = [NSString stringWithFormat:@"%f",timeInSeconds];
    SubscriptionDetail.EndDate = [NSString stringWithFormat:@"%f",timeInSeconds];
    SubscriptionDetail.PlanType = strPlanType;
    SubscriptionDetail.CreatedAt = NumberCreatedAt;
    SubscriptionDetail.UpdatedAt = NumberCreatedAt;
  
    
    [[dynamoDBObjectMapper save:SubscriptionDetail]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             //Do something with the result.
             NSLog(@"Task result: %@",task.result);
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 [self performSegueWithIdentifier:@"SubscriptionToProfile" sender:self];
             });
             
         }
         return nil;
     }];
    
}
#pragma mark - AWS Methods
-(void)SavePaymentSubscriptionData

{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSString *Id = [NSString stringWithFormat:@"%@%f",[dicUserData valueForKey:@"UserId"],timeInSeconds];
    
    
    KN_Payment *SubscriptionDetail = [KN_Payment new];
    SubscriptionDetail.Id = @"8845a805280c89a9723508cb86c8e1ee";
    SubscriptionDetail.UserId = @"viraj@simpalm.com1517581854.109152";
    SubscriptionDetail.PaymentType = @"Single";
    SubscriptionDetail.PurchaseDescrption = @"Subcription";
    SubscriptionDetail.Amount = @"$140";;
    SubscriptionDetail.CreatedAt = NumberCreatedAt;
    SubscriptionDetail.UpdatedAt = NumberCreatedAt;
    
    
    [[dynamoDBObjectMapper save:SubscriptionDetail]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             //Do something with the result.
             NSLog(@"Task result: %@",task.result);
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 [self SaveCardData];
             });
             
         }
         return nil;
     }];
    
}
-(void)SaveCardData
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSString *Id = [NSString stringWithFormat:@"%@%f",[dicUserData valueForKey:@"UserId"],timeInSeconds];
    
    
    KN_SavedCards *SubscriptionDetail = [KN_SavedCards new];
    SubscriptionDetail.Id = @"8845a805280c89a9723508cb86c8e1ee";
    SubscriptionDetail.UserId = @"viraj@simpalm.com1517581854.109152";
    SubscriptionDetail.LastFour = @"1120";
    SubscriptionDetail.CreatedAt = NumberCreatedAt;
    SubscriptionDetail.UpdatedAt = NumberCreatedAt;
    
    
    [[dynamoDBObjectMapper save:SubscriptionDetail]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             //Do something with the result.
             NSLog(@"Task result: %@",task.result);
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 
             });
         }
         return nil;
     }];
    
}
-(void)UpdateUserFirstTime
{
     dispatch_async(dispatch_get_main_queue(), ^{
         self.view.userInteractionEnabled = NO;
     });
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
    AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    
    hashKeyValue.S = [dicUserData valueForKey:@"UserId"];
    updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_User" : @"User";
    updateInput.key = @{ @"UserId" : hashKeyValue };
    
    //********************* FirstTimeLogin
    AWSDynamoDBAttributeValue *newFirstNameValue = [AWSDynamoDBAttributeValue new];
    newFirstNameValue.S = @"NO";
    AWSDynamoDBAttributeValueUpdate *valueUpdateForFirstName = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateForFirstName.value = newFirstNameValue;
    valueUpdateForFirstName.action = AWSDynamoDBAttributeActionPut;
    
    AWSDynamoDBAttributeValue *newSubscriptionValue = [AWSDynamoDBAttributeValue new];
    newSubscriptionValue.BOOLEAN = [NSNumber numberWithBool:YES];
    
    AWSDynamoDBAttributeValueUpdate *valueUpdateForSubsCription = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateForSubsCription.value = newSubscriptionValue;
    valueUpdateForSubsCription.action = AWSDynamoDBAttributeActionPut;
    
    
    updateInput.attributeUpdates = @{@"isFirstTimeLogin": valueUpdateForFirstName,@"SubscriptionStatus": valueUpdateForSubsCription};
    updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
    
    [[dynamoDB updateItem:updateInput]continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            // NSLog(@"The request failed. Error: [%@]", task.error);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
            });
        }
        if (task.result) {
            //Do something with result.
            dispatch_async(dispatch_get_main_queue(), ^{
                //  [self getLoginUser];
                self.view.userInteractionEnabled = YES;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [[RefreshUserData sharedInstance]refreshUserDataByEmail:[dicUserData valueForKey:@"Email"]];
                });
            });
        }
        return nil;
    }];
}

- (void)showDropIn:(NSString *)clientTokenOrTokenizationKey {
    BTDropInRequest *request = [[BTDropInRequest alloc] init];
    request.amount = @"10";
    
      dropIn = [[BTDropInController alloc] initWithAuthorization:clientTokenOrTokenizationKey request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"ERROR");
        } else if (result.cancelled) {
            NSLog(@"CANCELLED");
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            
            NSLog(@"%@",result);
            //[self postNonceToServer:result.paymentMethod.nonce];
            if ([_strChangePaln isEqualToString:@"ChangePaymentMethod"])
                [self CallLambdaFuncForChangePaymentMethod:result.paymentMethod.nonce];
            else
                [self CallLambdaFuncForTransection:result.paymentMethod.nonce];
            // Use the BTDropInResult properties to update your UI
            // result.paymentOptionType
            // result.paymentMethod
            // result.paymentIcon
            // result.paymentDescription
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:dropIn animated:YES completion:nil];
    });
}
- (void)fetchExistingPaymentMethod:(NSString *)clientToken {
    [BTDropInResult fetchDropInResultForAuthorization:clientToken handler:^(BTDropInResult * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"ERROR");
        } else {
            
            NSLog(@"%@",result);
            
            // Use the BTDropInResult properties to update your UI
            // result.paymentOptionType
            // result.paymentMethod
            // result.paymentIcon
            // result.paymentDescription
        }
    }];
}
-(void)CallLambdaFuncForClientToken
{
     [[Singlton sharedManager]showHUD];
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    NSDictionary *parameters = @{@"RequestCode":@"client_token",@"UserId":[dicUserData valueForKey:@"UserId"]
                                 
                                 };
    
    [[lambdaInvoker invokeFunction:[UserMode isEqualToString:@"Test"] ? @"KON_braintreePayments":@"KONProd_braintreePayments"
                        JSONObject:parameters] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            self.view.userInteractionEnabled = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
            });
            NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            NSLog(@"Result: %@", task.result);
            dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                self.view.userInteractionEnabled = YES;
                NSString *stringJson =  task.result;
                NSData *data = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
                id jsonOutput = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                clientToken  = [[jsonOutput valueForKey:@"clientToken"]objectAtIndex:0];
                if ([_strChangePaln isEqualToString:@"ChangePaymentMethod"]) {
                    [self showDropIn:clientToken];
                }
            });
        }
        return nil;
    }];
}
-(void)CallLambdaFuncForTransection:(NSString*)nonceString
{
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    NSDictionary *parameters = @{@"RequestCode":@"subscribe_payment",@"NonceFromTheClient":nonceString,@"PlanId":strPalnAmount,@"UserId":[dicUserData valueForKey:@"UserId"]
         };
    
    [[lambdaInvoker invokeFunction:[UserMode isEqualToString:@"Test"] ? @"KON_braintreePayments":@"KONProd_braintreePayments"
                        JSONObject:parameters] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
           
            dispatch_async(dispatch_get_main_queue(), ^{
                 self.view.userInteractionEnabled = YES;
            });
            
            NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            NSLog(@"Result: %@", task.result);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.view.userInteractionEnabled = YES;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    [self UpdateUserFirstTime];
                });
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[Singlton sharedManager]killHUD];
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
                 if ([_strChangePaln isEqualToString:@"CancelPlanRenew"])
                    [self performSegueWithIdentifier:@"VenueScreen" sender:self];
                else
                    [self performSegueWithIdentifier:@"SubscriptionToProfile" sender:self];
            });
        }
        return nil;
    }];
}
-(void)CallLambdaFuncForChangeSubscription
{
    [[Singlton sharedManager]showHUD];
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    NSDictionary *parameters = @{@"RequestCode":@"change_subscription",@"PlanId":strPalnAmount,@"UserId":[dicUserData valueForKey:@"UserId"]
                                     //[dicUserData valueForKey:@"UserId"]
                                 
                                 };
    
    [[lambdaInvoker invokeFunction:[UserMode isEqualToString:@"Test"] ? @"KON_braintreePayments":@"KONProd_braintreePayments"
                        JSONObject:parameters] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
           
            dispatch_async(dispatch_get_main_queue(), ^{
                  [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
            });
            
            NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            NSLog(@"Result: %@", task.result);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Singlton sharedManager]killHUD];
                 [self dismissViewControllerAnimated:YES completion:nil];
                self.view.userInteractionEnabled = YES;
                UIAlertController * alert=[UIAlertController alertControllerWithTitle:Message
                                                                              message:ChangePlan
                                                                       preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action)
                                            {
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }];
                [alert addAction:yesButton];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        return nil;
    }];
}
-(void)CallLambdaFuncForChangePaymentMethod:(NSString*)nonceString
{
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    NSDictionary *parameters = @{@"RequestCode":@"change_payment_method",@"UserId":[dicUserData valueForKey:@"UserId"],@"NonceFromTheClient":nonceString
                                 
                                 };
    
    [[lambdaInvoker invokeFunction:[UserMode isEqualToString:@"Test"] ? @"KON_braintreePayments":@"KONProd_braintreePayments"
                        JSONObject:parameters] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
            });
            
            NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            NSLog(@"Result: %@", task.result);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
            });
        }
        return nil;
    }];
}

#pragma mark - Custom Method
-(void)showAlertView:(NSString *)strTextMessage withTag:(NSInteger) ButtonTag
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Message"
                                  message:strTextMessage
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* YesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                          if (ButtonTag == 0) {
                                                              
                                                              
                                                            [self showDropIn:clientToken];
                                                              
                                                              
                                                          }
                                                          else
                                                          {
                                                             
                                                            [self showDropIn:clientToken];
                                                              
                                                              
                                                          }
                                                    
                                                          
                                                          
                                                      }];
    UIAlertAction* NoAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];
    
    [alert addAction:YesAction];
    [alert addAction:NoAction];
    [self presentViewController:alert animated:YES completion:nil];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
