//
//  TransectionViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 16/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "TransectionViewController.h"
#import "TransectionTableViewCell.h"
#import "MainViewController.h"
#import "AWSLambda/AWSLambda.h"
@interface TransectionViewController ()
{
    NSMutableDictionary *dicUserData;
    NSMutableArray *arrayTransactionHistroy;
}
@end

@implementation TransectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrayTransactionHistroy = [[NSMutableArray alloc]init];
    dicUserData  = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"];
    
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
    _tblTransection.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self CallLambdaFuncForGetSubscriptionDetails];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
      return arrayTransactionHistroy.count;;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    return 70;
    
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
        static NSString *CellIdentifier = @"Cell";
        TransectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[TransectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    
    NSNumber *NumberDate = [[arrayTransactionHistroy valueForKey:@"createdAt"]objectAtIndex:indexPath.row];
    NSDate *dateStart = [NSDate dateWithTimeIntervalSince1970:[NumberDate integerValue]];
    NSDateFormatter *Df = [[NSDateFormatter alloc] init];
    [Df setDateFormat:@"MMMM d,yyyy hh:mm a"];
    NSString *resultString = [Df stringFromDate:dateStart];
    cell.lblTransectionDate.text = resultString;
    NSString *strPlan  = [[arrayTransactionHistroy valueForKey:@"planId"]objectAtIndex:indexPath.row];
    if ([strPlan isEqualToString:@"Dollar140Yearly"]) {
         cell.lblTransectionName.text = @"$140";
         cell.lblTansectionBookEvent.text = @"FOR 1 YEAR";
    }
    else
    {
        cell.lblTransectionName.text = @"$15";
        cell.lblTansectionBookEvent.text = @"FOR 1 MONTH";
        
    }
     
     //NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[arrayTransactionHistroy valueForKey:@""]objectAtIndex:0]];
    
        return cell;
}

#pragma mark - IBAction Method
-(IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)CallLambdaFuncForGetSubscriptionDetails
{
    [[Singlton sharedManager]showHUD];
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    NSDictionary *parameters = @{@"RequestCode":@"get_subscription_detail",@"UserId":[dicUserData valueForKey:@"UserId"]
                                 
                                 };
   
   
    [[lambdaInvoker invokeFunction: [UserMode isEqualToString:@"Test"] ? @"KON_braintreePayments":@"KONProd_braintreePayments"
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
                self.view.userInteractionEnabled = YES;
                NSString *stringJson =  task.result;
                NSData *data = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
                id jsonOutput = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                arrayTransactionHistroy = jsonOutput;
                if (arrayTransactionHistroy.count>0) {
                    
                     [_tblTransection reloadData];
                }
                else
                {
                    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Message"
                                                                                  message:@"Transaction history not found."
                                                                           preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Ok"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action)
                                                {
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }];
                    
                    
                    
                    [alert addAction:yesButton];
                    
                    
                    [self presentViewController:alert animated:YES completion:nil];
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
