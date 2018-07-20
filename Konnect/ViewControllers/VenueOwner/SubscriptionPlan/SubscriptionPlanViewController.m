//
//  SubscriptionPlanViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "SubscriptionPlanViewController.h"
#import "SubscriptionViewController.h"
#import "AWSLambda/AWSLambda.h"
@interface SubscriptionPlanViewController ()
{
    NSMutableDictionary *dicUserData;
}
@end

@implementation SubscriptionPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dicUserData  = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"];
    
    
    if (IS_IPHONE_5) {
        
        yLogoPosition.constant = 30;
        ySubscriptiontext.constant = 30;
    }
   
}
-(void)viewWillAppear:(BOOL)animated
{
    [self CallLambdaFuncForGetSubscriptionDate];
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction Method
-(IBAction)clickCancelButtopn:(id)sender
{
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Alert"
                                                                  message:@"Are you sure want to cancel your Subscription plan"
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
    {
        [self CallLambdaFuncForCancelSubscription];
    }];
    
    UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"No"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
    {
        /** What we write here???????? **/
        NSLog(@"you pressed No, thanks button");
        // call method whatever u need
    }];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(IBAction)clickChangePalnBtn:(id)sender
{
    SubscriptionViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"SubscriptionViewController"];
    VC.strChangePaln = @"ChangePaln";
    [self.navigationController pushViewController:VC animated:NO];
}
-(IBAction)clickChangePaymentMethod:(id)sender
{
    SubscriptionViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"SubscriptionViewController"];
    VC.strChangePaln = @"ChangePaymentMethod";
    [self.navigationController pushViewController:VC animated:NO];
}

#pragma mark - AWS Method
-(void)CallLambdaFuncForCancelSubscription
{
    [[Singlton sharedManager]showHUD];
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    NSDictionary *parameters = @{@"RequestCode":@"cancel_subscription",@"UserId":[dicUserData valueForKey:@"UserId"]
                                 
                                 };
    
    [[lambdaInvoker invokeFunction:[UserMode isEqualToString:@"Test"] ? @"KON_braintreePayments":@"KONProd_braintreePayments"
                        JSONObject:parameters] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                 self.view.userInteractionEnabled = YES;
                 [[Singlton sharedManager]killHUD];
            });
            
            NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            NSLog(@"Result: %@", task.result);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.view.userInteractionEnabled = YES;
                [self CallLambdaFuncForGetSubscriptionDate];
                
            });
        }
        return nil;
    }];
}
-(void)CallLambdaFuncForGetSubscriptionDate
{
    [[Singlton sharedManager]showHUD];
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    NSDictionary *parameters = @{@"RequestCode":@"get_subscription_date",@"UserId":[dicUserData valueForKey:@"UserId"]
                                 
                                 };
    
    [[lambdaInvoker invokeFunction:[UserMode isEqualToString:@"Test"] ? @"KON_braintreePayments":@"KONProd_braintreePayments"
                        JSONObject:parameters] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
         
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Singlton sharedManager]killHUD];
                self.view.userInteractionEnabled = YES;
                
                UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Message"
                                                                              message:@"Please reactive your subscription plan."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Ok"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action)
                                            {
                                                SubscriptionViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"SubscriptionViewController"];
                                                VC.strChangePaln = @"CancelPlanRenew";
                                                [self.navigationController pushViewController:VC animated:NO];
                                            }];
                
               
                
                [alert addAction:yesButton];
                
                
                [self presentViewController:alert animated:YES completion:nil];
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
                NSString *strPlan  = [jsonOutput valueForKey:@"PlanId"];
                if ([strPlan isEqualToString:@"KonnectAnnual2018"]) {
                    lblPlan.text = @"$140";
                    lblPlanMonthOrYear.text = @"/ Year";
                }
                else
                {
                    lblPlan.text = @"$15";
                    lblPlanMonthOrYear.text = @"/ Month";
                    
                }
               
                NSString *PlanStartDate = [jsonOutput valueForKey:@"PlanStartDate"];
                NSDate *datePlanStart = [NSDate dateWithTimeIntervalSince1970:[PlanStartDate intValue]];
                NSDateFormatter *Df = [[NSDateFormatter alloc] init];
                [Df setDateFormat:@"MMMM d,yyyy hh:mm a"];
                NSString *resultString = [Df stringFromDate:datePlanStart];
                lblStartFrom.text = [NSString stringWithFormat:@"Subscription start from: %@",resultString];
                
                if ([[NSDate date] compare:datePlanStart] == NSOrderedDescending) {
                    lblStartFrom.hidden = YES;
                } else if ([[NSDate date] compare:datePlanStart] == NSOrderedAscending) {
                    lblStartFrom.hidden = NO;
                } else {
                    NSLog(@"dates are the same");
                }
                
            });
        }
        return nil;
    }];
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
