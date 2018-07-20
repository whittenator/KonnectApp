//
//  NonKonnectViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 03/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "NonKonnectViewController.h"
#import "ClaimYourBusinessViewController.h"
#import "MainViewController.h"
#import "AsyncImageView.h"
#import "KN_ClaimYourBusiness.h"
@interface NonKonnectViewController ()

@end

@implementation NonKonnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _btnClaimYourBusiness.userInteractionEnabled = YES;
    _btnClaimYourBusiness.enabled = YES;
    // Do any additional setup after loading the view.
    if([[Singlton sharedManager].dictVenueInfo valueForKey:@"photos"])
    {
        NSString *strPhoto = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?photoreference=%@&sensor=false&maxheight=300&maxwidth=1000&key=%@",[[[[Singlton sharedManager].dictVenueInfo valueForKey:@"photos"] objectAtIndex:0] valueForKey:@"photo_reference"],GoogleApiKey];
        [_imgNonKonnectScreen setImageURL:[NSURL URLWithString:strPhoto]];
    }
   
    _lblImgTitle.text = [[Singlton sharedManager].dictVenueInfo valueForKey:@"name"];
    [self GetRestaurantTime];
    //[self CheckIfVenueAlreadyExistClaimForBusiness];
}

-(void)CheckIfVenueAlreadyExistClaimForBusiness
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"VenueId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
   
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_ClaimYourBusiness class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
             _btnClaimYourBusiness.userInteractionEnabled = NO;
             _btnClaimYourBusiness.enabled = NO;
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
               NSMutableArray  *dicUserList= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_ClaimYourBusiness *chat in paginatedOutput.items) {
                     
                     [dicUserList addObject:chat];
                     
                 }
                  [[Singlton sharedManager]killHUD];
                   self.view.userInteractionEnabled = YES;
                 if (dicUserList.count>0)
                 {
                     _btnClaimYourBusiness.userInteractionEnabled = NO;
                     _btnClaimYourBusiness.enabled = NO;
                     [[Singlton sharedManager] alert:self title:Message message:@"The claim business for this venue is already in process."];
                     
                 }
                 else
                 {
                     _btnClaimYourBusiness.userInteractionEnabled = YES;
                     _btnClaimYourBusiness.enabled = YES;
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
}

-(void)GetRestaurantTime
{
    [[Singlton sharedManager] showHUD];
    NSString *strRequestParams = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",[[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"],GoogleApiKey];
    strRequestParams = [strRequestParams stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
    NSURL *url = [NSURL URLWithString:strRequestParams];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    
    NSError *error;
    NSURLResponse *response;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!response) {
        // "Connection Error", "Failed to Connect to the Internet"
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Singlton sharedManager] killHUD];
        });
    }
    
    NSString *respString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] ;
    NSData *data = [respString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if(dict){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[Singlton sharedManager] killHUD];
            if([[dict valueForKey:@"status"]isEqualToString:@"INVALID_REQUEST"])
            {
                
            }
            else
            {
                if([[dict valueForKey:@"result"]valueForKey:@"opening_hours"])
                {
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] ;
                    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
                    NSArray *arrSpliTime;
                    NSArray *arrOpenWeekDays=[[[dict valueForKey:@"result"]valueForKey:@"opening_hours"]valueForKey:@"weekday_text"];
                    NSString *strDayWithOpeningHrs;
                    if([comps weekday]==1)
                    {
                        strDayWithOpeningHrs=[arrOpenWeekDays objectAtIndex:6];
                        arrSpliTime=[strDayWithOpeningHrs componentsSeparatedByString:@"Sunday:"];
                    }
                    else if([comps weekday]==2)
                    {
                        strDayWithOpeningHrs=[arrOpenWeekDays objectAtIndex:0];
                        arrSpliTime=[strDayWithOpeningHrs componentsSeparatedByString:@"Monday:"];
                    }
                    else  if([comps weekday]==3)
                    {
                        strDayWithOpeningHrs=[arrOpenWeekDays objectAtIndex:1];
                        arrSpliTime=[strDayWithOpeningHrs componentsSeparatedByString:@"Tuesday:"];
                    }
                    else if([comps weekday]==4)
                    {
                        strDayWithOpeningHrs=[arrOpenWeekDays objectAtIndex:2];
                        arrSpliTime=[strDayWithOpeningHrs componentsSeparatedByString:@"Wednesday:"];
                    }
                    else if([comps weekday]==5)
                    {
                        strDayWithOpeningHrs=[arrOpenWeekDays objectAtIndex:3];
                        arrSpliTime=[strDayWithOpeningHrs componentsSeparatedByString:@"Thursday:"];
                    }
                    else if([comps weekday]==6)
                    {
                        strDayWithOpeningHrs=[arrOpenWeekDays objectAtIndex:4];
                        arrSpliTime=[strDayWithOpeningHrs componentsSeparatedByString:@"Friday:"];
                    }
                    else if([comps weekday]==7)
                    {
                        strDayWithOpeningHrs=[arrOpenWeekDays objectAtIndex:5];
                        arrSpliTime=[strDayWithOpeningHrs componentsSeparatedByString:@"Saturday:"];
                    }
                    
                    NSLog(@"strDayWithOpeningHrs%@",arrSpliTime);
                   [Singlton sharedManager].strWorkingHours=[NSString stringWithFormat:@"%@",arrSpliTime[1]];
                    
                }
                else
                {
                    //[Singlton sharedManager].strWorkingHours = nil;
                }
            }
        });
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
-(void)viewWillAppear:(BOOL)animated
{
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
}
- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSave:(id)sender {
    ClaimYourBusinessViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ClaimYourBusinessViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
