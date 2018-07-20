//
//  ConsumerGalleryViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 16/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ConsumerGalleryViewController.h"
#import "ConsumerGalleryCell/ConsumerGalleryCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "MainViewController.h"
#import "KN_Event.h"
#import "UIImageView+WebCache.h"
#import "ConsumerGallerySelectedVCViewController.h"
#import "CustomeCameraViewController.h"
#import "ConsumerPostEventViewController.h"
#import "KN_VenueProfileSetup.h"
@interface ConsumerGalleryViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate>
{
    NSMutableArray *arrEvents;
    NSString *StrCollectionCheck;
    UIImagePickerController *ipc;
    float checkInRange;
    NSMutableArray *arrVenueDetails;
    NSMutableArray *arrImageSlider;
    
}
@end

@implementation ConsumerGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrEvents = [[NSMutableArray alloc]init];
    arrVenueDetails = [[NSMutableArray alloc]init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self FetchVenueProfile];
    // Do any additional setup after loading the view.
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrEvents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ConsumerGalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.row==0) {
        
        NSString *strForEventImageName = [[arrImageSlider objectAtIndex:0] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_VENUE_IMAGE_URL,strForEventImageName]];
        
        cell.btnplay.tag = indexPath.row;
        [cell.imageGallry sd_setImageWithURL:url
                            placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
        
        cell.lblName.text = [[arrEvents valueForKey:@"Name"]objectAtIndex:indexPath.row];
        cell.btnplay.hidden = YES;
    }
    else
    {
 
    cell.btnplay.hidden = YES;
    NSString *strForEventImageName = [[[arrEvents valueForKey:@"Image"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_VENUE_EVENT_IMAGE_URL,strForEventImageName]];
    
    [cell.imageGallry sd_setImageWithURL:url
                        placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    cell.lblName.text = [[arrEvents valueForKey:@"Name"]objectAtIndex:indexPath.row];
    
    
    }
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.0;
}


#pragma mark – UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *) collectionView
                   layout:(UICollectionViewLayout *) collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger) section {
    return 0.0;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
    
    ConsumerGallerySelectedVCViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerGallerySelectedVCViewController"];
    if (indexPath.row==0) {
        
        viewController.strVenueId = [[arrEvents valueForKey:@"Id"]objectAtIndex:indexPath.row];
        viewController.strCheck = @"venueGallery";
    }
    else
    {
 
    viewController.strEventId = [[arrEvents valueForKey:@"Id"]objectAtIndex:indexPath.row];
    viewController.strEventName = [[arrEvents valueForKey:@"Name"]objectAtIndex:indexPath.row];
    viewController.dicVenueDetails = _dicVenueDetails;
    viewController.strCheck = @"eventGallery";
    viewController.dicEventDetails = [arrEvents objectAtIndex:indexPath.row];
    
    }
    [self.navigationController pushViewController:viewController animated:YES];
   
}


#pragma mark collection view cell paddings

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0,0, 0);
}
- (CGSize)collectionView:(UICollectionView* )collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath* )indexPath
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 736) // iPhone 6 Plus Height
    {
        return CGSizeMake(136 , 136);
    }
    else if (screenBounds.size.height == 568) // iPhone 5 Height
    {
        return CGSizeMake(105 , 105);
    }
    else if (screenBounds.size.height == 667) // iPhone 6 Height
    {
        return CGSizeMake(123 , 123);
    }
    else
    {
        return CGSizeMake(105 , 105); // Default
    }
}

#pragma mark - IBAction Method
-(void)clickPlayBtn:(UIButton *)Sender
{
    
    // grab a local URL to our video
    NSURL *videoURL = [[NSBundle mainBundle]URLForResource:@"Luvv U Zindaagi - HD HQ" withExtension:@"mp4"];
    
    // create an AVPlayer
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    // create a player view controller
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    controller.player = player;
    [player play];
    
    // show the view controller
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    controller.view.frame = self.view.frame;
    
}

-(IBAction)actionHideBox:(UIButton *)sender{
    if([sender tag] == 123)
    {
        
        checkInRange = [self GetDifferenceBetweenTwoLatitudeLongitude:[_dicVenueDetails valueForKey:@"Latitude"] withLongitude:[_dicVenueDetails valueForKey:@"Longitude"]];
        
        
        if (checkInRange>50) {
            
            [[Singlton sharedManager] alert:self title:@"Alert" message:@"Sorry, you must present at the venue location to add the image/Video for this event."];
        }
        else
        {
            [self.view bringSubviewToFront:_viewBox];
            _viewBox.hidden = NO;
            _viewBox1.hidden = NO;
        }

    }
    else
    {
        _viewBox.hidden = YES;
        _viewBox1.hidden = YES;
        //[self.view :_viewBox];
    }
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
                                                 @":val1" : [_dicVenueDetails valueForKey:@"Id"]
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
                     NSSet *setImages = [[arrVenueDetails valueForKey:@"Image"]objectAtIndex:0];
                     NSMutableArray *arrayShort = [NSMutableArray arrayWithArray:[setImages allObjects]];
                     NSArray *array = [NSArray arrayWithArray:arrayShort];
                     array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                     arrImageSlider = [NSMutableArray arrayWithArray:array];
                     NSLog(@"%@",arrImageSlider);
                     [self FetchVenuEventGallery];
                     
                 }
                 else
                 {
                     _collectionGallry.hidden = YES;
                     lblAlert.hidden = NO;
                     lblAlert.text = @"No past event available";
                     self.view.userInteractionEnabled = YES;
                     [[Singlton sharedManager]killHUD];
                     
                 }
                 
             });
             
         }
         
         return nil;
         
     }];
    
}
-(void)FetchVenuEventGallery
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
                                                 @":val1" : _strVenueId
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

                     if (!checkEventTimeandDate) {

                         [arrEvents addObject:chat];

                     }

                 }

                 if (arrEvents.count>0) {

                     self.view.userInteractionEnabled = YES;
                     NSSortDescriptor *sortDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"CreatedAt"
                                                                                     ascending:YES];
                     NSArray *arrayMesage = [arrEvents
                                             sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                     arrEvents = [NSMutableArray arrayWithArray:arrayMesage];
                     _collectionGallry.hidden = NO;
                     lblAlert.hidden = YES;
                    [arrEvents insertObject:[arrVenueDetails objectAtIndex:0] atIndex:0];
                     [_collectionGallry reloadData];

                 }
                 else
                 {
                     self.view.userInteractionEnabled = YES;
                     [[Singlton sharedManager]killHUD];
                     [arrEvents insertObject:[arrVenueDetails objectAtIndex:0] atIndex:0];
                     [_collectionGallry reloadData];
                

                 }

             });

         }

         return nil;

     }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage;
    chosenImage = info[UIImagePickerControllerEditedImage];
    ConsumerPostEventViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerPostEventViewController"];
    vc.imgData = chosenImage;
    _viewBox.hidden = YES;
    vc.strCheck = @"Photo";
    vc.strHeader = @"Gallery";
    vc.classChek = @"ConsumerClass";
    vc.strVenueId = [_dicVenueDetails valueForKey:@"Id"];
    [self.navigationController pushViewController:vc animated:YES];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)actionOpenCameraNGallery:(UIButton *)sender
{
    _viewBox.hidden = YES;
    _viewBox1.hidden = YES;
    ipc= [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    if([sender tag] == 0)
    {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            CustomeCameraViewController *imageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomeCameraViewController"];
             imageVC.strVenueId = [_dicVenueDetails valueForKey:@"Id"];
            [self.navigationController pushViewController:imageVC animated:NO];
        }
        else
        {
            [[Singlton sharedManager] alert:self title:@"Alert" message:@"Camera not available"];
            
        }
    }
    else
    {
        ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:ipc animated:YES completion:nil];
    }
    
}
-(float)GetDifferenceBetweenTwoLatitudeLongitude:(NSString*)Venuelatitude withLongitude:(NSString*)Venuelongitude
{
    
    
    CLLocation *OldLocation = [[CLLocation alloc] initWithLatitude:[[NSString stringWithFormat:@"%@", Venuelatitude] doubleValue] longitude:[[NSString stringWithFormat:@"%@", Venuelongitude] doubleValue]];
    
    CLLocation *closestLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    float Range = [closestLocation distanceFromLocation:OldLocation];
    return Range;
    
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
