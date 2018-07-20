//
//  VenueOwnerHomeViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 28/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VenueOwnerHomeViewController.h"
#import "VenueEventCollectionViewCell.h"
#import "MainViewController.h"
#import "ProfileSetupViewController.h"
#import <AWSS3/AWSS3.h>
#import "KN_VenueProfileSetup.h"
#import "KN_Event.h"
#import "KN_VenueRating.h"
#import "UIImageView+WebCache.h"
#import "VenueEventDetailViewController.h"
@interface VenueOwnerHomeViewController ()
{
    NSMutableArray *arrVenueDetails;
    NSMutableDictionary *dicUserData;
    NSMutableArray *arrImageSlider;
    NSMutableArray *arrEvents;
    NSMutableDictionary *dicProfileSetup;
    
}
@end

@implementation VenueOwnerHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dicProfileSetup = [[NSUserDefaults standardUserDefaults]valueForKey:@"VenueProfileData"];
    dicUserData  = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"];
    arrVenueDetails = [[NSMutableArray alloc]init];
    arrEvents = [[NSMutableArray alloc]init];
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.automaticallyAdjustsScrollViewInsets = false;
    _rateStarView.userInteractionEnabled = NO;
    
    if (IS_IPHONE_5)
    {
        venueAddressYAsix.constant = 10;
        imageFirstYAxis.constant = 4;
        imageSeconfYaxis.constant = 4;
        venuHoursYaxis.constant= 9;
        [viewContainer setTranslatesAutoresizingMaskIntoConstraints:YES];
        [EventCollectionView setTranslatesAutoresizingMaskIntoConstraints:YES];
        viewContainer.frame = CGRectMake(0, 410, self.view.frame.size.width, 130);
        EventCollectionView.frame = CGRectMake(EventCollectionView.frame.origin.x, EventCollectionView.frame.origin.y, self.view.frame.size.width, EventCollectionView.frame.size.height);
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = YES;
    
    //PageController Properties
    _imagePager.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    _imagePager.pageControl.pageIndicatorTintColor = [UIColor greenColor];
    _imagePager.slideshowTimeInterval = 5.5f;
    _imagePager.slideshowShouldCallScrollToDelegate = YES;
    _imagePager.delegate = self;
    _imagePager.dataSource = self;
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"SKIPUSER"] isEqualToString:@"SkipUser"]) {
        
        
        [self ShowAlertForProfileSetup];
    }
    else if(dicProfileSetup != nil)
    {
        [self FetchVenueProfile];
    }
    // Do any additional setup after loading the view.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -  UICollectionView Method

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return arrEvents.count;
    
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(159, 137);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //top, left, bottom, right
    return UIEdgeInsetsMake(0, 16, 0, 16);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VenueEventDetailViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueEventDetailViewController"];
    Vc.dicEventDetail = [arrEvents objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:Vc animated:YES];
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VenueEventCollectionViewCell *cell = (VenueEventCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (!cell)
    {
        cell  = [EventCollectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
    }
    
    NSString *strForEventImageName = [[[arrEvents valueForKey:@"Image"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    strForEventImageName = [[[arrEvents valueForKey:@"Image"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *strimageURL = [NSString stringWithFormat:@"%@%@",BASE_VENUE_EVENT_IMAGE_URL,strForEventImageName];
    [cell.imgEvent sd_setImageWithURL:[NSURL URLWithString:strimageURL]
                     placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    
    cell.lblEventDate.text  =  [[Singlton sharedManager]changeStringToDate:[[arrEvents objectAtIndex:indexPath.row] valueForKey:@"EventDate"]];
    cell.lblEventTime.text = [NSString stringWithFormat:@"%@-%@",[[arrEvents objectAtIndex:indexPath.row] valueForKey:@"StartTime"],[[arrEvents objectAtIndex:indexPath.row] valueForKey:@"EndTime"]];
   
    //Set Event Name
    cell.lblventName.text = [[arrEvents valueForKey:@"Name"]objectAtIndex:indexPath.row];
    
    return cell;
}
-(void)ShowAlertForProfileSetup
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Message"
                                  message:@"Please setup your profile"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* YesAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                          UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                          ProfileSetupViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ProfileSetupViewController"];
                                                          [self.navigationController pushViewController:vc animated:NO];
                                                      }];
    [alert addAction:YesAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - AWS Method

-(void)FetchVenueProfile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[Singlton sharedManager]showHUD];
    });
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"Id"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [dicProfileSetup valueForKey:@"Id"]
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
                     if([[arrVenueDetails valueForKey:@"Image"]objectAtIndex:0] == nil || [[[arrVenueDetails valueForKey:@"Image"]objectAtIndex:0] isKindOfClass:[NSNull class]])
                     {
                         lblVenueAddress.text = [[arrVenueDetails valueForKey:@"Address"]objectAtIndex:0];
                         lblVenueAddress.numberOfLines = 0;
                         lblVenueAddress.lineBreakMode = NSLineBreakByWordWrapping;
                         lblHours.text = [NSString stringWithFormat:@"%@-%@",[[arrVenueDetails valueForKey:@"StartTime"]objectAtIndex:0],[[arrVenueDetails valueForKey:@"EndTime"]objectAtIndex:0]];
                         lblVenueName.text = [[arrVenueDetails valueForKey:@"Name"]objectAtIndex:0];
                         _rateStarView.allowsHalfStars = YES;
                         if (![[[arrVenueDetails valueForKey:@"AverageRating"]objectAtIndex:0] isEqual:[NSNull null]]) {
                             _rateStarView.value = [[[arrVenueDetails valueForKey:@"AverageRating"]objectAtIndex:0] doubleValue];
                         }
                         
                         [_imagePager reloadData];
                         [self FetchVenueEvents];
                     }
                     else{
                         NSSet *setImages = [[arrVenueDetails valueForKey:@"Image"]objectAtIndex:0];
                         NSMutableArray *arrayShort = [NSMutableArray arrayWithArray:[setImages allObjects]];
                         NSArray *array = [NSArray arrayWithArray:arrayShort];
                         array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                         arrImageSlider = [NSMutableArray arrayWithArray:array];
                         for (int i = 0; i < arrayShort.count; i++)
                         {
                             NSString *strForEventImageName = [[arrayShort objectAtIndex:i] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                             
                             [arrImageSlider replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@%@",BASE_VENUE_IMAGE_URL,strForEventImageName]];
                         }
                         
                         lblVenueAddress.text = [[arrVenueDetails valueForKey:@"Address"]objectAtIndex:0];
                         lblHours.text = [NSString stringWithFormat:@"%@-%@",[[arrVenueDetails valueForKey:@"StartTime"]objectAtIndex:0],[[arrVenueDetails valueForKey:@"EndTime"]objectAtIndex:0]];
                         lblVenueName.text = [[arrVenueDetails valueForKey:@"Name"]objectAtIndex:0];
                         _rateStarView.allowsHalfStars = YES;
                         if (![[[arrVenueDetails valueForKey:@"AverageRating"]objectAtIndex:0] isEqual:[NSNull null]]) {
                             _rateStarView.value = [[[arrVenueDetails valueForKey:@"AverageRating"]objectAtIndex:0] doubleValue];
                         }
                         
                         [_imagePager reloadData];
                         [self FetchVenueEvents];
                     }
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
-(void)FetchVenueEvents
{
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"VenueId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [dicProfileSetup valueForKey:@"Id"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_Event class]
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
                 arrEvents= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_Event *chat in paginatedOutput.items) {
                     NSDate *Eventdate = [[Singlton sharedManager]convertStringToDate:[NSString stringWithFormat:@"%@ %@",[chat valueForKey:@"EventDate"],[chat valueForKey:@"EndTime"]]];
                     BOOL checkEventTimeandDate = [[Singlton sharedManager]DateChekDifference:[NSDate date] andDate:Eventdate];
                     if (checkEventTimeandDate)
                         [arrEvents addObject:chat];
                 }
                 if (arrEvents.count>0) {
                     self.view.userInteractionEnabled = YES;
                     [EventCollectionView reloadData];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
