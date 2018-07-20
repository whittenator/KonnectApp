//
//  ConsumerVenueDetailVC.m
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//
//clickVenueImage:
#import "ConsumerVenueDetailVC.h"
#import "ConsumerVenueDetailCell/ConsumerVenueDetailCell.h"
#import "MainViewController.h"
#import "ConsumerChekInViewController.h"
#import "Singlton.h"
#import "AsyncImageView.h"
#import "KN_VenueRating.h"
#import "KN_VenueProfileSetup.h"
#import "KN_Event.h"
#import "VenueSpecialCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import <CoreLocation/CoreLocation.h>
#import "KN_VenueCheckIn.h"
#import "KN_User.h"
#import "ConsumerVenueEventDetailVC.h"
#import "ConsumerGalleryViewController.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#define BTN_BACK 0

@interface ConsumerVenueDetailVC ()<CLLocationManagerDelegate>
{
    NSMutableArray *arrImage;
    UIButton *btnImageBubble;
    CGRect screenBounds;
    NSMutableArray *arrImageSlider;
    NSMutableArray *arrVenueDetails;
    NSMutableArray *arrSpecialVenueImages;
    NSMutableArray *arrEventsForThisVenue;
    NSMutableArray *arrCheckInUser;
    NSMutableArray *arrUsers;
    float checkInRange;
    UIButton *btnChkIn;
    NSMutableDictionary *dictUserInfo;
    NSMutableDictionary *dictUserIds;
    UIScrollView  *scrollVie;
    UIView *viewEveContainer;
    BOOL isEventsExists;
}
@end

@implementation ConsumerVenueDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    isEventsExists = NO;
    printf("TRAVIS: YOU ARE SEEING THE EVENT DETAIL!\n");
    [self CallAddBUttonsAtBottomOfView];
    [self PlacingCheckInButton];
    arrEventsForThisVenue = [[NSMutableArray alloc]init];
    arrCheckInUser = [[NSMutableArray alloc]init];
    arrUsers = [[NSMutableArray alloc]init];
    dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
    
   
    //PageController Properties
    _imagePager.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    _imagePager.pageControl.pageIndicatorTintColor = [UIColor greenColor];
    _imagePager.slideshowTimeInterval = 5.5f;
    _imagePager.slideshowShouldCallScrollToDelegate = YES;
    _imagePager.delegate = self;
    _imagePager.dataSource = self;
    _rateStarView.userInteractionEnabled = false;
    _rateStarView.allowsHalfStars = YES;
   
    scrollView.scrollEnabled = YES;
    
    arrImage = [[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"checkin1"],[UIImage imageNamed:@"checkin2"],[UIImage imageNamed:@"checkin3"],[UIImage imageNamed:@"checkInCircleNo"],nil];
    //NSLog(@"%@",arrImage); //LOGS THE IMAGES IN THE CHECKED IN ARRAY
    if (IS_IPHONE_5)
    {
        btnBeer.frame = CGRectMake(btnBeer.frame.origin.x, btnBeer.frame.origin.y, btnBeer.frame.size.width, btnBeer.frame.size.height);
        btnNonVeg.frame = CGRectMake(btnNonVeg.frame.origin.x-12, btnNonVeg.frame.origin.y, btnNonVeg.frame.size.width, btnNonVeg.frame.size.height);
        btnDJ.frame = CGRectMake(btnDJ.frame.origin.x-32, btnDJ.frame.origin.y, btnDJ.frame.size.width, btnDJ.frame.size.height);
        btnFood.frame = CGRectMake(btnFood.frame.origin.x-55, btnFood.frame.origin.y, btnFood.frame.size.width, btnFood.frame.size.height);
        
    }
    arrVenueDetail = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"eventImage"],[UIImage imageNamed:@"eventImage"],[UIImage imageNamed:@"eventImage"],[UIImage imageNamed:@"eventImage"],[UIImage imageNamed:@"eventImage"],[UIImage imageNamed:@"eventImage"], nil];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    //[self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    [self GetAllEventsForVenue];
    [self FetchVenueProfile];
    
    NSArray *arryCheckAlready = [arrUsers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(UserId == %@)", [dictUserInfo valueForKey:@"UserId"]]];
    printf("TRAVIS: CHECK IN RANGE IS BELOW\n");
    printf("%f\n",checkInRange);
    NSLog(@"%@",arryCheckAlready);
    
    
}

-(void)deleteCheckedInUsers
{
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.limit = @10;
    
}

-(void)CallAddBUttonsAtBottomOfView
{
    UIButton *btnRateVenue,*btnGallery;
    if(IS_IPHONE_5)
    {
        //scrollVie.frame.size.height+scrollVie.frame.origin.y+5
        btnRateVenue = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 160, 60)];
        btnGallery = [[UIButton alloc]initWithFrame:CGRectMake(btnRateVenue.frame.origin.x+btnRateVenue.frame.size.width+1, self.view.frame.size.height-50, 160, 60)];
    }
    else if (IS_IPHONE_6)
    {
        btnRateVenue = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 187, 60)];
        btnGallery = [[UIButton alloc]initWithFrame:CGRectMake(btnRateVenue.frame.origin.x+btnRateVenue.frame.size.width+1, self.view.frame.size.height-50, 188, 60)];
    }
    else if (IS_IPHONE_6_PLUS)
    {
        btnRateVenue = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 206, 60)];
        btnGallery = [[UIButton alloc]initWithFrame:CGRectMake(btnRateVenue.frame.origin.x+btnRateVenue.frame.size.width+1, self.view.frame.size.height-50, 207, 60)];
    }
    [btnRateVenue setImage:[UIImage imageNamed:@"imgRateVenue"] forState:UIControlStateNormal];
    [btnRateVenue addTarget:self action:@selector(navigateToRatingVenue) forControlEvents:UIControlEventTouchUpInside];
    [btnGallery setImage:[UIImage imageNamed:@"imgGallery"] forState:UIControlStateNormal];
    [btnGallery addTarget:self action:@selector(navigateToGalleryVenue) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnGallery];
    [self.view bringSubviewToFront:btnGallery];
    [self.view addSubview:btnRateVenue];
    [self.view bringSubviewToFront:btnRateVenue];
    
}
#pragma mark - KIImagePager DataSource
- (NSArray *) arrayWithImages:(KIImagePager*)pager
{
    return arrImageSlider;
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image inPager:(KIImagePager *)pager
{
    return UIViewContentModeScaleAspectFill;
}

#pragma mark - KIImagePager Delegate
- (void) imagePager:(KIImagePager *)imagePager didScrollToIndex:(NSUInteger)index
{
    NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
}

- (void) imagePager:(KIImagePager *)imagePager didSelectImageAtIndex:(NSUInteger)index
{
    NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
}

#pragma mark - Getting average rating for Venue

-(void)GettingAVerageRatingForVenue
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    //     code to fetch data
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"VenueId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" :[[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_VenueRating class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 NSMutableArray   *arrAverageRateList= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueRating *chat in paginatedOutput.items)
                 {
                     [arrAverageRateList addObject:chat];
                     
                 }
                 if (arrAverageRateList.count>0) {
                     _rateStarView.allowsHalfStars = YES;
                     _rateStarView.value = [[arrAverageRateList valueForKeyPath:@"@avg.VenueRatingValue"] doubleValue];
                     for(int i =0; i< [Singlton sharedManager].arrKonnectVenues.count; i++)
                     {
                         if([[[[Singlton sharedManager].arrKonnectVenues objectAtIndex:i]valueForKey:@"Id"]isEqualToString:[[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"]])
                         {
                             NSMutableDictionary *dicTempInfo = [[[Singlton sharedManager].arrKonnectVenues objectAtIndex:i] mutableCopy];
                             NSLog(@"%@",dicTempInfo);
                             if([dicTempInfo valueForKey:@"averageRating"])
                             {
                                 [dicTempInfo setObject:[arrAverageRateList valueForKeyPath:@"@avg.VenueRatingValue"] forKey:@"averageRating"];
                             }
                             [dicTempInfo setObject:[arrAverageRateList valueForKeyPath:@"@avg.VenueRatingValue"] forKey:@"AverageRating"];
                             [[Singlton sharedManager].arrKonnectVenues replaceObjectAtIndex:i withObject:dicTempInfo];
                             break;
                             
                         }
                     }
                     
                     for(int i =0; i< [Singlton sharedManager].arrDataTempStorage.count; i++)
                     {
                         if([[[[Singlton sharedManager].arrDataTempStorage objectAtIndex:i]valueForKey:@"place_id"]isEqualToString:[[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"]])
                         {
                             NSMutableDictionary *dicTempInfo = [[[Singlton sharedManager].arrDataTempStorage objectAtIndex:i] mutableCopy];
                             NSLog(@"%@",dicTempInfo);
                             if([dicTempInfo valueForKey:@"averageRating"])
                             {
                                 [dicTempInfo setObject:[arrAverageRateList valueForKeyPath:@"@avg.VenueRatingValue"] forKey:@"averageRating"];
                             }
                             [dicTempInfo setObject:[arrAverageRateList valueForKeyPath:@"@avg.VenueRatingValue"] forKey:@"AverageRating"];
                             [[Singlton sharedManager].arrDataTempStorage replaceObjectAtIndex:i withObject:dicTempInfo];
                             break;
                             
                         }
                     }
                     
                 }
                 
             });
             
         }
         
         return nil;
         
     }];
}

#pragma mark - Get all Events for particular Venue

-(void)GetAllEventsForVenue
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"VenueId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_Event class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             //[self createScrollMenu];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 arrVenueDetails= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 
                 for (KN_Event *chat in paginatedOutput.items)
                 {
                     NSDate *Eventdate = [[Singlton sharedManager]convertStringToDate:[NSString stringWithFormat:@"%@ %@",[chat valueForKey:@"EventDate"],[chat valueForKey:@"EndTime"]]];
                     
                     
                     BOOL checkEventTimeandDate = [[Singlton sharedManager]DateChekDifference:[NSDate date] andDate:Eventdate];
                     
                     if (checkEventTimeandDate) {
                         
                         [arrEventsForThisVenue addObject:chat];
                         
                     }
                 }
                 
                 if (arrEventsForThisVenue.count>0) {
                     
                     self.view.userInteractionEnabled = YES;
                     //[self createScrollMenu];
                   isEventsExists = YES;
                     [self GettingAllReviewsCount];
                 }
                 else
                 {
                     self.view.userInteractionEnabled = YES;
                     // [self createScrollMenu];
                     [self GettingAllReviewsCount];
                     [[Singlton sharedManager]killHUD];
                     
                 }
                 
             });
             
         }
         
         return nil;
         
     }];
}

#pragma mark - Fetching Venue INfo from DB

-(void)FetchVenueProfile
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"Id"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_VenueProfileSetup class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
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
                     [self GettingAllReviewsCount];
                     [self SetVenueDetailInfo];
                     
                     NSString *strLat = [[arrVenueDetails valueForKey:@"Latitude"]objectAtIndex:0];
                     NSString *strLong = [[arrVenueDetails valueForKey:@"Longitude"]objectAtIndex:0];
                     
                     
                     CLLocation *OldLocation = [[CLLocation alloc] initWithLatitude:[[NSString stringWithFormat:@"%@", strLat] doubleValue] longitude:[[NSString stringWithFormat:@"%@", strLong] doubleValue]];
                     
                     CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                     
                     checkInRange= [newLocation distanceFromLocation:OldLocation];
                     
                     
                 }
                 else
                 {
                     self.view.userInteractionEnabled = YES;
                     [self GettingAllReviewsCount];
                     [[Singlton sharedManager]killHUD];
                     
                 }
                 
             });
             
         }
         
         return nil;
         
     }];
    
}

#pragma mark - Getting all Reviews count

-(void)GettingAllReviewsCount
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"VenueId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_VenueRating class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 NSMutableArray  *arrRating = [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueRating *chat in paginatedOutput.items) {
                     
                     [arrRating addObject:chat];
                     
                 }
                 
                 if (arrRating.count>0) {
                     
                     self.view.userInteractionEnabled = YES;
                     lblRateUsersCount.text = [NSString stringWithFormat:@"(%lu)",(unsigned long)arrRating.count];
                 }
                 else
                 {
                     self.view.userInteractionEnabled = YES;
                     [[Singlton sharedManager]killHUD];
                     lblRateUsersCount.text = @"(0)";
                     
                 }
                 [self FetchCheckInUsers];
                 
             });
             
         }
         
         return nil;
         
     }];
}

#pragma mark - Setting VenueInfo

-(void)SetVenueDetailInfo
{
    NSSet *setImages = [[arrVenueDetails valueForKey:@"Image"]objectAtIndex:0];
    if(![setImages isKindOfClass:[NSNull class]])
    {
        NSMutableArray *arrayShort = [NSMutableArray arrayWithArray:[setImages allObjects]];
        NSArray *array = [NSArray arrayWithArray:arrayShort];
        array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        arrImageSlider = [NSMutableArray arrayWithArray:array];
        for (int i = 0; i < arrayShort.count; i++)
        {
            NSString *strForEventImageName = [[arrayShort objectAtIndex:i] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
            
            [arrImageSlider replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@%@",BASE_VENUE_IMAGE_URL,strForEventImageName]];
        }
        [_imagePager reloadData];
    }
    else
    {
        
    }
    lblAddress.text = [[arrVenueDetails valueForKey:@"Address"]objectAtIndex:0];
    
    lblHours.text = [NSString stringWithFormat:@"%@-%@",[[arrVenueDetails valueForKey:@"StartTime"]objectAtIndex:0],[[arrVenueDetails valueForKey:@"EndTime"]objectAtIndex:0]];
    lblEventName.text = [[arrVenueDetails valueForKey:@"Name"]objectAtIndex:0];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[[[[Singlton sharedManager].dictVenueInfo valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] doubleValue] longitude:[[[[[Singlton sharedManager].dictVenueInfo valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] doubleValue]];
    lblDistance.text = [self calculateDistanceByLocation:location];
    NSString *strSpecial = [[arrVenueDetails valueForKey:@"Special"]objectAtIndex:0];
    if(![strSpecial isKindOfClass:[NSNull class]])
    {
        arrSpecialVenueImages = [NSMutableArray new];
        NSDictionary *dictSPecialVenueName;
        dictSPecialVenueName = [NSMutableDictionary new];
        if ([strSpecial rangeOfString:@","].location == NSNotFound)
        {
            if([strSpecial isEqualToString:@"Food"])
            {
                dictSPecialVenueName = @{@"imgName":@"Food",@"venueName":@"Food"};
            }
            else if([strSpecial isEqualToString:@"Drinks"])
            {
                dictSPecialVenueName = @{@"imgName":@"Drinks",@"venueName":@"Drinks"};
            }
            else if([strSpecial isEqualToString:@"Music"])
            {
                dictSPecialVenueName = @{@"imgName":@"Music",@"venueName":@"Music"};
            }
            else if([strSpecial isEqualToString:@"FoodCart"])
            {
                dictSPecialVenueName = @{@"imgName":@"FoodCart",@"venueName":@"FoodCart"};
            }
            [arrSpecialVenueImages addObject:dictSPecialVenueName];
            [_collectionSpecial reloadData];
        }
        else
        {
            NSArray *arrVenueSpecials = [strSpecial componentsSeparatedByString:@","];
            arrSpecialVenueImages = [NSMutableArray new];
            for(int i = 0 ; i < arrVenueSpecials.count ; i++)
            {
                //@"Beer on Top",@"Non Veg",@"DJ",@"FoodCart"
                if([[arrVenueSpecials objectAtIndex:i]isEqualToString:@"Food"])
                {
                    dictSPecialVenueName = @{@"imgName":@"Food",@"venueName":@"Food"};
                }
                else if([[arrVenueSpecials objectAtIndex:i]isEqualToString:@"Drinks"])
                {
                    dictSPecialVenueName = @{@"imgName":@"Drinks",@"venueName":@"Drinks"};
                }
                else if([[arrVenueSpecials objectAtIndex:i]isEqualToString:@"Music"])
                {
                    dictSPecialVenueName = @{@"imgName":@"Music",@"venueName":@"Music"};
                }
                else if([[arrVenueSpecials objectAtIndex:i]isEqualToString:@"FoodCart"])
                {
                    dictSPecialVenueName = @{@"imgName":@"FoodCart",@"venueName":@"FoodCart"};
                }
                [arrSpecialVenueImages addObject:dictSPecialVenueName];
                
            }
            [_collectionSpecial reloadData];
            
        }
    }
    
    
}

#pragma mark - Calculate distance b/w two Lat Long

- (NSString *) calculateDistanceByLocation:(CLLocation*)location
{
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:[Singlton sharedManager].latitude longitude:[Singlton sharedManager].longitude];
    return [NSString stringWithFormat:@"%.02f MI",[location distanceFromLocation:location2]*0.000621371];
}
#pragma mark - To Check whether User Checked in into that Venue
-(void)clickCheckIn
{
    
    NSArray *arryCheckAlready = [arrUsers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(UserId == %@)", [dictUserInfo valueForKey:@"UserId"]]];
    
    if (arryCheckAlready.count>0)
    {
        [[Singlton sharedManager] alert:self title:Alert message:@"You are already checkd-in"];
    }
    else if (checkInRange>500) {
        printf("%f",checkInRange);
        [[Singlton sharedManager] alert:self title:Alert message:@"you are away from the venue, you can't check-in right now"];
    }
    else
    {
        [self SaveCheckIndata];
    }
    
}

#pragma mark - Navigate to ChekedIn userList
-(void)clickVenueImage:(UIButton *) sender
{
    ConsumerChekInViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerChekInViewController"];
    Vc.arrCheckInUserList  =  arrUsers;
    [self.navigationController pushViewController:Vc animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 230;
    
}

#pragma mark - Table DataSource and Delegate Method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrVenueDetail count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier = @"ConsumerVenueDetailCell";
    ConsumerVenueDetailCell *cell = (ConsumerVenueDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.viewEvent setTranslatesAutoresizingMaskIntoConstraints:YES];
    cell.viewEvent.frame = CGRectMake(cell.viewEvent.frame.origin.x, cell.viewEvent.frame.origin.y, 144, 128);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imgEvent.image=[UIImage imageNamed:[arrVenueDetail objectAtIndex:indexPath.row]] ;
    return cell;
    
}

#pragma mark - CollectionView DataSource and Delegate Method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrSpecialVenueImages.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(84, 66);
    
    
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //top, left, bottom, right
    return UIEdgeInsetsMake(0, 10, 0, 10);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    VenueSpecialCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.imgVenueSpecial.image = [UIImage imageNamed:[[arrSpecialVenueImages objectAtIndex:indexPath.row]valueForKey:@"imgName"]];
    cell.lblSpecialName.text = [[arrSpecialVenueImages objectAtIndex:indexPath.row]valueForKey:@"venueName"];
    cell.btnSPecial.tag = indexPath.row;
    return cell;
}




#pragma mark – UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *) collectionView
                   layout:(UICollectionViewLayout *) collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger) section {
    return 0.0;
}

#pragma mark - IBAction Methods
-(IBAction)clickButtons:(id)sender
{
    UIButton * btnSelected = (UIButton *) sender;
    switch (btnSelected.tag) {
        case BTN_BACK:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(IBAction)actionGoToVenueCommentScreen:(id)sender
{
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    [self GetAllEventsForVenue];
    [self FetchVenueProfile];
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewsViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Creating Scrollview for Eve Programatically

- (void)createScrollMenu
{
    
    
}

#pragma mark - Opening Rate and Gallery Screen

-(void)navigateToGalleryVenue{
    
    ConsumerGalleryViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerGalleryViewController"];
    viewController.strVenueId = [[arrVenueDetails valueForKey:@"Id"]objectAtIndex:0];
    viewController.dicVenueDetails = [arrVenueDetails objectAtIndex:0];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
}
-(void)navigateToRatingVenue{
    
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueRatingViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

#pragma mark - Navigate to ConsumerEventDetail
-(void)navigateToVenueEventDetail:(UIButton*)sender
{
    
    ConsumerVenueEventDetailVC *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerVenueEventDetailVC"];
    viewController.dicEventDetails = [[arrEventsForThisVenue objectAtIndex:sender.tag] dictionaryValue];
    viewController.strComingFromNotScreen = nil;
    if(arrCheckInUser.count > 0)
    {
    NSArray *arryCheckAlready = [arrCheckInUser filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(UserId == %@)", [dictUserInfo valueForKey:@"UserId"]]];
    viewController.dicVenueEventCheckIn = [arryCheckAlready objectAtIndex:0];
    }
    if (arrVenueDetails.count>0) {
        viewController.dicVenueDetails = [arrVenueDetails objectAtIndex:0];
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
    
}

#pragma mark -------------
-(void)viewWillLayoutSubviews
{
    // The scrollview needs to know the content size for it to work correctly
    if(isEventsExists == YES)
        [self UpdateScrollViewHeight];
    else
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,900);

       // scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,(_collectionSpecial.frame.origin.y+_collectionSpecial.frame.size.height+15));
}

-(void)UpdateScrollViewHeight
{
    if(lblAddress.text.length!=0)
    {
        if(arrEventsForThisVenue.count>0)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,863+lblAddress.frame.size.height-25);
            // [self addCheckInUsersOnView:(NSMutableArray*)arrUsers];
        }
        else
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,863);
            //  [self addCheckInUsersOnView:(NSMutableArray*)arrUsers];
        }
        for(UIView *subview in [scrollVie subviews])
        {
            [subview removeFromSuperview];
        }
        if(arrEventsForThisVenue.count>0)
        {
            scrollVie=[[UIScrollView alloc]init];
            //[scrollVie removeFromSuperview];
            scrollVie.scrollEnabled = YES;
            int scrollWidth = 100;
            //660
            scrollVie.frame=CGRectMake(0, lblTableEvents.frame.size.height+lblTableEvents.frame.origin.y+10, self.view.frame.size.width, 120);
            scrollVie.backgroundColor=[UIColor clearColor];
            
            int xOffset = 10;
//            if(arrEventsForThisVenue.count>0)
//            {
                NSDictionary *dictEventInfo ;
                for(int index=0; index < arrEventsForThisVenue.count; index++)
                {
                    dictEventInfo = [arrEventsForThisVenue objectAtIndex:index];
                    NSString *strForEventImageName = [[dictEventInfo valueForKey:@"Image"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                    NSURL *imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",BASE_VENUE_EVENT_IMAGE_URL,strForEventImageName]];
                    UIImageView *imgEvent = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset,0,120, 120)];
                    viewEveContainer = [[UIView alloc] initWithFrame:CGRectMake(xOffset,0,120, 120)];
                    UIButton *btnImg = [[UIButton alloc] initWithFrame:CGRectMake(0,0,120, 120)];
                    UILabel *lblEveName = [[UILabel alloc] initWithFrame:CGRectMake(0,26,120, 15)];
                    UILabel *lblEveDate = [[UILabel alloc] initWithFrame:CGRectMake(0,lblEveName.frame.origin.y+lblEveName.frame.size.height+10,120, 15)];
                    UILabel *lblEveTime = [[UILabel alloc] initWithFrame:CGRectMake(0,lblEveDate.frame.origin.y+lblEveDate.frame.size.height+10,120, 15)];
                    viewEveContainer.backgroundColor = [UIColor blackColor];
                    viewEveContainer.alpha = 0.7;
                    lblEveName.font = [UIFont fontWithName:@"Roboto-Regular" size:12.0];
                    lblEveDate.font = [UIFont fontWithName:@"Roboto-Regular" size:12.0];
                    lblEveTime.font = [UIFont fontWithName:@"Roboto-Regular" size:12.0];
                    lblEveName.textColor = [UIColor whiteColor];
                    lblEveTime.textColor = [UIColor whiteColor];
                    lblEveDate.textColor = [UIColor whiteColor];
                    btnImg.tag = index;
                    imgEvent.tag = index;
                    viewEveContainer.tag = index;
                    [btnImg addTarget:self action:@selector(navigateToVenueEventDetail:) forControlEvents:UIControlEventTouchUpInside];
                    [imgEvent sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]options:SDWebImageRefreshCached];
                    lblEveName.text = [[dictEventInfo valueForKey:@"Name"] uppercaseString];
                    lblEveTime.text = [NSString stringWithFormat:@"%@-%@",[dictEventInfo valueForKey:@"StartTime"],[dictEventInfo valueForKey:@"EndTime"]];
                    lblEveDate.text = [dictEventInfo valueForKey:@"EventDate"];
                    lblEveName.textAlignment = NSTextAlignmentCenter;
                    lblEveTime.textAlignment = NSTextAlignmentCenter;
                    lblEveDate.textAlignment = NSTextAlignmentCenter;
                    
                    [viewEveContainer addSubview:lblEveName];
                    [viewEveContainer addSubview:lblEveDate];
                    [viewEveContainer addSubview:lblEveTime];
                    [viewEveContainer addSubview:btnImg];
                    
                    [viewEveContainer bringSubviewToFront:lblEveName];
                    [viewEveContainer bringSubviewToFront:lblEveTime];
                    [viewEveContainer bringSubviewToFront:lblEveDate];
                    [scrollVie addSubview:imgEvent];
                    [scrollVie addSubview:viewEveContainer];
                    [scrollVie bringSubviewToFront:viewEveContainer];
                    xOffset+= imgEvent.frame.size.width+10;
                }
           // }
            [scrollView addSubview:scrollVie];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollVie.showsHorizontalScrollIndicator = NO;
            scrollVie.contentSize = CGSizeMake(scrollWidth+xOffset,100);
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    [self GettingAVerageRatingForVenue];
    [self GettingAllReviewsCount];
}
#pragma mark -  CLLocationManager Delegate
//Get User Current Location
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    
    CLLocation *newLocation = [locations lastObject];
    CLLocation *oldLocation;
    if (locations.count >= 2) {
        oldLocation = [locations objectAtIndex:locations.count-1];
    } else {
        oldLocation = nil;
    }
    latitude = newLocation.coordinate.latitude;
    longitude =newLocation.coordinate.longitude;
    
    [self.locationManager stopUpdatingLocation];
    
}

#pragma mark - AWS Method
//Save Venue Profile Details
-(void)SaveCheckIndata
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSNumber *NumberCheckOut = [NSNumber numberWithDouble:timeInSeconds + 14400];
    NSString *Id = [NSString stringWithFormat:@"%@%f",[dictUserInfo valueForKey:@"firstName"],timeInSeconds];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    KN_VenueCheckIn *venueCheckIn = [KN_VenueCheckIn new];
    venueCheckIn.Id = Id;
    venueCheckIn.UserId = [dictUserInfo valueForKey:@"UserId"] ;
    venueCheckIn.VenueId = [[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"] ;
    venueCheckIn.Status = @"YES";
    venueCheckIn.CheckedInTime = NumberCreatedAt;
    venueCheckIn.CheckedOutTime = NumberCheckOut; //This time must be 4 hours after the checkedInTime
    venueCheckIn.CreatedAt = NumberCreatedAt;
    venueCheckIn.UpdatedAt = NumberCreatedAt;
    
    [[dynamoDBObjectMapper save:venueCheckIn]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 NSLog(@"The request failed. Error: [%@]", task.error);
             });
         }
         if (task.result) {
             
             //Do something with the result.
             NSLog(@"Task result: %@",task.result);
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 [self FetchCheckInUsers];
                 
                 
             });
             
         }
         return nil;
     }];
    
}
-(void)FetchCheckInUsers
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"VenueId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_VenueCheckIn class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 arrCheckInUser= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueCheckIn *chat in paginatedOutput.items) {
                     
                     [arrCheckInUser addObject:chat];
                     
                 }
                 if(arrCheckInUser.count > 0)
                 {
                 [self FetchAllCheckInUser];
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
    
}


-(void)FetchAllCheckInUser
{
    
    
    dictUserIds = [[NSMutableDictionary alloc]init];
    
    NSString *strFilter ;
    //printf("TRAVIS: THE ARRAY OF ALL CHECKED IN USERS\n");
    //NSLog(@"%@",arrCheckInUser);
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *CurrentTime = [NSNumber numberWithDouble:timeInSeconds];
    AWSDynamoDBScanExpression *scanExpression1 = [AWSDynamoDBScanExpression new];
    //scanExpression1.limit = @10;
    //scanExpression1.projectionExpression = @"CheckedInTime,CheckedOutTime";
   AWSDynamoDBObjectMapper *dynamoDBObjectMapper1 = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[dynamoDBObjectMapper1 scan:[KN_VenueCheckIn class]
      expression:scanExpression1]
     continueWithBlock:^id(AWSTask *task) {
         if(task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         } else {
             AWSDynamoDBPaginatedOutput *paginatedOutput1 = task.result;
             for(KN_VenueCheckIn *persons in paginatedOutput1.items) {
                 //do something with the persons checked in
                 //double checkedOutTime1 = [persons.CheckedOutTime doubleValue];
                 //double checkedInTime1 = [persons.CheckedInTime doubleValue];
                 //NSLog(@"%@",persons);
                 //printf("\n");
                // NSLog(@"%@",persons.CheckedOutTime);
                 
                 //printf("TRAVIS: CURRENT TIME IS: \n");
                // NSLog(@"%@",CurrentTime);
                
                 double dubCheckedOutTime = [persons.CheckedOutTime doubleValue];
                 double dubCurrentTime = [CurrentTime doubleValue];
                 if(dubCheckedOutTime <= dubCurrentTime) {
                     //printf("TRAVIS: CHECKOUT OUT TIME IS LESS THAN CURRENT TIME!\n");
                 }
                 if(dubCheckedOutTime <= dubCurrentTime) {
                     //NSNumber *subtraction = persons.CheckedOutTime - CurrentTime;
                     //NSLog(@"CHECKED OUT - CURRENT TIME = %@");
                     persons.Id = persons.Id;
                     [[dynamoDBObjectMapper1 remove:persons]
                      continueWithBlock:^id(AWSTask *task) {
                          if(task.error) {
                              NSLog(@"The Request failed. Error: [%@]", task.error);
                          } else {
                              NSLog(@"TRAVIS: PERSON HAS BEEN DELETED");
                              //Item Deleted
                          }
                          return nil;
                      }];
                     
                 }
                
             }
         }
         return nil;
     }];
     
    /*
    [[dynamoDBObjectMapper1 load:[KN_VenueCheckIn class] hashKey:@"Matthew 1529021240.714625" rangeKey:nil]
     continueWithBlock:^id(AWSTask *task) {
         if(task.error) {
             NSLog(@"ERROR: [%@]", task.error);
         } else {
             // Do something with task.result
             printf("TRAVIS: CHECK THIS!!\n");
             NSLog(@"%@",task.result);
         }
         return nil;
     }];
     */
    
    
    for (int i=0; i<arrCheckInUser.count; i++)
    {
        NSString *str = [NSString stringWithFormat:@":val%d",i+1];
        //NSLog(@"%@",arrCheckInUser);
        NSString *strcontains = [NSString stringWithFormat:@"contains(#P,%@)",str];
        
        [dictUserIds setObject:[[arrCheckInUser valueForKey:@"UserId"]objectAtIndex:i] forKey:str];
        //NSLog(@"%@",str); :val1, :val2, :val3
        if (strFilter.length>0)
        {
            strFilter = [NSString stringWithFormat:@"%@ OR %@",strFilter,strcontains];
        }
        else
        {
            strFilter = [NSString stringWithFormat:@"%@",strcontains];
        }
        
        strFilter = [NSString stringWithFormat:@"(%@)",strFilter];
        
    }
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"UserId"]
                                                };
    scanExpression.filterExpression = strFilter;
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = dictUserIds;
    [[dynamoDBObjectMapper scan:[KN_User class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 NSLog(@"The request failed. Error: [%@]", task.error);
               });
           
                        }
         
         if (task.result) {

             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 arrUsers= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_User *chat in paginatedOutput.items) {
                     //printf("TRAVIS\n");
                     // NSLog(@"%@",chat.dictionaryValue); The dictionary of users
                     [arrUsers addObject:chat.dictionaryValue];
                     
                 }
                 [self addCheckInUsersOnView:arrUsers];
                 
             });
             
         }
         
         return nil;
         
     }];
    
    
}
-(void)addCheckInUsersOnView:(NSMutableArray*)arryUsers
{
    // UIView *viewSlider = [[UIView alloc]initWithFrame:CGRectMake(14,400, self.view.frame.size.width-14,45)];
    int xOffset = 0;
    if (IS_IPHONE_5)
    {
        xOffset = 14;
    }
    for(int index=0; index < arryUsers.count; index++)
    {
        
        if (IS_IPHONE_5)
        {
            btnImageBubble = [[UIButton alloc] initWithFrame:CGRectMake(xOffset,lblCheckInHeading.frame.origin.y+lblCheckInHeading.frame.size.height+2,46, 46)];
            
        }
        else
        {
            btnImageBubble = [[UIButton alloc] initWithFrame:CGRectMake(xOffset,lblCheckInHeading.frame.origin.y+lblCheckInHeading.frame.size.height+2,46, 46)];
            
            
        }
        btnImageBubble.layer.cornerRadius = btnImageBubble.frame.size.height/2;
        btnImageBubble.clipsToBounds = YES;
        btnImageBubble.tag = index;
        //set button image
        NSString *strForEventImageName = [[[arryUsers valueForKey:@"UserImage"]objectAtIndex:index] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
        
        
        
        if (btnImageBubble.tag==3) {
            
            NSInteger userCount = arryUsers.count-3;
            btnImageBubble.backgroundColor = [UIColor colorWithRed:83/255.0 green:186/255.0 blue:231/255.0 alpha:1];
            [btnImageBubble setTitle:[NSString stringWithFormat: @"+ %ld", (long)userCount] forState:UIControlStateNormal];
            
        }
        else
        {
            [btnImageBubble sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
            
        }
        [btnImageBubble addTarget:self action:@selector(clickVenueImage:) forControlEvents:UIControlEventTouchUpInside];
        
        if (index<4) {
            
            if (IS_IPHONE_5)
            {
                //  [viewSlider addSubview:btnImageBubble];
                [scrollView addSubview:btnImageBubble];
                [scrollView bringSubviewToFront:btnImageBubble];
            }
            else
            {
                [scrollView addSubview:btnImageBubble];
                [scrollView bringSubviewToFront:btnImageBubble];
            }
        }
        
        xOffset+=30;
        
        
    }
    //    [self.view addSubview:viewSlider];
    //    viewSlider.hidden = NO;
    //    [self.view  bringSubviewToFront:viewSlider];
  
}

-(void)PlacingCheckInButton
{
    if (IS_IPHONE_6_PLUS)
    {
        btnChkIn = [[UIButton alloc]initWithFrame:CGRectMake(300,lblCheckInHeading.frame.origin.y+lblCheckInHeading.frame.size.height+10, 67, 28)];
    }
    else if (IS_IPHONE_6)
    {
        btnChkIn = [[UIButton alloc]initWithFrame:CGRectMake(285,lblCheckInHeading.frame.origin.y+lblCheckInHeading.frame.size.height+10, 67, 28)];
    }
    else if (IS_IPHONE_5)
    {
        //btnChkIn = [[UIButton alloc]initWithFrame:CGRectMake(190,580, 70, 20)];
        btnChkIn = [[UIButton alloc]initWithFrame:CGRectMake(235,lblCheckInHeading.frame.origin.y+lblCheckInHeading.frame.size.height+10, 67, 28)];
    }
    [btnChkIn addTarget:self action:@selector(clickCheckIn) forControlEvents:UIControlEventTouchUpInside];
    // btnChkIn.titleLabel.font = [UIFont systemFontOfSize:11.0];
    btnChkIn.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:11.0];
    [btnChkIn setTitle:@"Check In" forState:UIControlStateNormal];
    btnChkIn.layer.cornerRadius = 3.0f;
    btnChkIn.layer.masksToBounds = YES;
    [btnChkIn setBackgroundColor:[UIColor colorWithRed:83.0/255.0f green:186.0/255.0f blue:231.0/255.0f alpha:1]];
    if (IS_IPHONE_5)
    {
        [scrollView addSubview:btnChkIn];
        [scrollView bringSubviewToFront:btnChkIn];
    }
    else
    {
        [scrollView addSubview:btnChkIn];
        [scrollView bringSubviewToFront:btnChkIn];;
    }
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

