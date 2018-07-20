//
//  ConsumerGallerySelectedVCViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 17/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ConsumerGallerySelectedVCViewController.h"
#import "ConsumerGallerySelectedCell/ConsumerGallerySelectedCell.h"
#import "MainViewController.h"
#import <AVKit/AVKit.h>
#import "KN_Staging_PostEvent.h"
#import "UIImageView+WebCache.h"
#import "VenueOwnerCommentViewController.h"
#import "CustomeCameraViewController.h"
#import "KN_StagingVenueGallery.h"
#import "VenueImageViewController.h"
@interface ConsumerGallerySelectedVCViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate>
{

    NSString *StrCollectionCheck;
    NSMutableArray *arrEventPost;
    float checkInRange;
    BOOL checkEventTimeandDate;
    NSDate *EndEventdate;
    NSDate *StartEventdate;
    UIImagePickerController*ipc;
    NSString *strAddress;
}
@end

@implementation ConsumerGallerySelectedVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrEventPost = [[NSMutableArray alloc]init];
    lblHeader.text = _strEventName;
    
    if ([_strCheck isEqualToString:@"venueGallery"]) {
        
        [self FetchVenueGallery:_strVenueId];
    }
    else
    {
         [self FetchEventPost:_strEventId];
    }
    
   
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    StartEventdate = [[Singlton sharedManager]convertStringToDate:[NSString stringWithFormat:@"%@ %@",[_dicEventDetails valueForKey:@"EventDate"],[_dicEventDetails valueForKey:@"StartTime"]]];
    
    EndEventdate = [[Singlton sharedManager]convertStringToDate:[NSString stringWithFormat:@"%@ %@",[_dicEventDetails valueForKey:@"EventDate"],[_dicEventDetails valueForKey:@"EndTime"]]];
    
    checkEventTimeandDate = [[Singlton sharedManager]date:[NSDate date] isBetweenDate:StartEventdate andDate:EndEventdate];
    
    
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrEventPost.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    ConsumerGallerySelectedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
        
    NSString *strForEventImageName = [[[arrEventPost valueForKey:@"Image"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSURL *url;
    if ([_strCheck isEqualToString:@"venueGallery"]) {
        
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_VENUEGALLERY_IMAGE_URL,strForEventImageName]];
    }
    else
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_POST_EVENT_IMAGE_URL,strForEventImageName]];
    }
    
    [cell.imageGallry sd_setImageWithURL:url
                        placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    cell.lblName.text = [[arrEventPost valueForKey:@"Name"]objectAtIndex:indexPath.row];
    cell.lblName.hidden = YES;
    
    if ([[[arrEventPost valueForKey:@"Type"]objectAtIndex:indexPath.row] isEqualToString:@"Video"]) {
        
        cell.btnplay.hidden = NO;
    }
    else
    {
        cell.btnplay.hidden = YES;
    }
    
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
  
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    VenueImageViewController *Vc = [storyboard instantiateViewControllerWithIdentifier:@"VenueImageViewController"];
    
    NSString *strForEventImageName = [[[arrEventPost valueForKey:@"Image"]objectAtIndex:indexPath.row]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    Vc.strImage = strForEventImageName;
    Vc.strName = [[arrEventPost valueForKey:@"Name"]objectAtIndex:indexPath.row];
    Vc.strUserImage = [[arrEventPost valueForKey:@"UserImage"]objectAtIndex:indexPath.row];
    Vc.dicPostDetails = [arrEventPost objectAtIndex:indexPath.row];
    if ([_strCheck isEqualToString:@"venueGallery"]) {
        Vc.strEventName =  [[arrEventPost valueForKey:@"PostComment"]objectAtIndex:indexPath.row];
        Vc.strchek = @"Gallery";
    }
    else
    {
        Vc.strEventName = _strEventName;
    }
    Vc.eventDateTime =[[arrEventPost valueForKey:@"CreatedAt"]objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:Vc animated:NO];
    
    
}


#pragma mark – UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *) collectionView
                   layout:(UICollectionViewLayout *) collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger) section {
    return 0.0;
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionGoBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AWS Method
-(void)FetchEventPost:(NSString *)strEventId
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"EventId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : strEventId
                                                 };
    [[dynamoDBObjectMapper scan:[KN_Staging_PostEvent class]
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
                 arrEventPost= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_Staging_PostEvent *chat in paginatedOutput.items) {
                     
                     [arrEventPost addObject:chat];
                     
                 }
                 
                 if (arrEventPost.count>0) {
                     
                     lblAlert.hidden = YES;
                     _collectionGallry.hidden = NO;
                     NSSortDescriptor *sortDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"CreatedAt"
                                                                                     ascending:YES];
                     NSArray *arrayMesage = [arrEventPost
                                             sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                     arrEventPost = [NSMutableArray arrayWithArray:arrayMesage];
                     _collectionGallry.hidden = NO;
                     lblAlert.hidden = YES;
                     [_collectionGallry reloadData];
                 }
                 else
                 {
                     lblAlert.hidden = NO;
                     _collectionGallry.hidden = YES;
                     lblAlert.text = @"No comment item found";
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
    
}
-(void)FetchVenueGallery:(NSString *)strVenueId
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
                                                 @":val1" : strVenueId
                                                 };
    [[dynamoDBObjectMapper scan:[KN_StagingVenueGallery class]
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
                 arrEventPost= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_StagingVenueGallery *chat in paginatedOutput.items) {
                     
                     [arrEventPost addObject:chat];
                     
                 }
                 
                 if (arrEventPost.count>0) {
                     
                     lblAlert.hidden = YES;
                     _collectionGallry.hidden = NO;
                     NSSortDescriptor *sortDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"CreatedAt"
                                                                                     ascending:YES];
                     NSArray *arrayMesage = [arrEventPost
                                             sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                     arrEventPost = [NSMutableArray arrayWithArray:arrayMesage];
                     _collectionGallry.hidden = NO;
                     lblAlert.hidden = YES;
                     [_collectionGallry reloadData];
                 }
                 else
                 {
                     lblAlert.hidden = NO;
                     _collectionGallry.hidden = YES;
                     lblAlert.text = @"This Venue has no image video right now";
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
    
}
-(IBAction)actionHideBox:(UIButton *)sender{
    if([sender tag] == 123)
    {
        
        checkInRange = [self GetDifferenceBetweenTwoLatitudeLongitude:[_dicVenueDetails valueForKey:@"Latitude"] withLongitude:[_dicVenueDetails valueForKey:@"Longitude"]];
        
        checkEventTimeandDate = [[Singlton sharedManager]date:[NSDate date] isBetweenDate:StartEventdate andDate:EndEventdate];
        
        BOOL checkEndTimeComplete = [[Singlton sharedManager]DateChekDifference:[NSDate date] andDate:EndEventdate];
        
        if (checkInRange>500) {
            
            [[Singlton sharedManager] alert:self title:@"Alert" message:@"Sorry, you must present at the venue location to add the image/Video for this event."];
        }
        else if (!checkEventTimeandDate)
        {
            [[Singlton sharedManager] alert:self title:@"Alert" message:@"Sorry, The event is not started yet. You can’t add the image/Video for this event."];
        }
        else if (!checkEndTimeComplete)
        {
            [[Singlton sharedManager] alert:self title:@"Alert" message:@"Sorry, The event is ended. You can’t add the image/Video for this event."];
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
            imageVC.strEventId = [_dicEventDetails valueForKey:@"Id"];
            imageVC.postAddress = strAddress;
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

#pragma mark - Custom method
-(float)GetDifferenceBetweenTwoLatitudeLongitude:(NSString*)Venuelatitude withLongitude:(NSString*)Venuelongitude
{
    
    
    CLLocation *OldLocation = [[CLLocation alloc] initWithLatitude:[[NSString stringWithFormat:@"%@", Venuelatitude] doubleValue] longitude:[[NSString stringWithFormat:@"%@", Venuelongitude] doubleValue]];
    
    CLLocation *closestLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    float Range = [closestLocation distanceFromLocation:OldLocation];
    return Range;
    
}

-(void)GetAddress:(CLLocation *)location
{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       NSLog(@"placemark.ISOcountryCode =%@",placemark.ISOcountryCode);
                       NSLog(@"placemark.country =%@",placemark.country);
                       NSLog(@"placemark.postalCode =%@",placemark.postalCode);
                       NSLog(@"placemark.administrativeArea =%@",placemark.administrativeArea);
                       NSLog(@"lat %f  long %f",placemark.location.coordinate.latitude,placemark.location.coordinate.longitude);
                       NSLog(@"placemark.name =%@",placemark.name);
                       NSLog(@"placemark.locality =%@",placemark.locality);
                       NSLog(@"placemark.Thoroughfare =%@",placemark.thoroughfare);
                       NSLog(@"placemark.subLocality =%@",placemark.subLocality);
                       strAddress = [NSString stringWithFormat:@"%@,%@,%@",placemark.name,placemark.locality,placemark.administrativeArea];
                   }];
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
    
    NSString *strLat = [_dicEventDetails valueForKey:@"Latitude"];
    NSString *strLong = [_dicEventDetails valueForKey:@"Longitude"];
    
    checkInRange = [self GetDifferenceBetweenTwoLatitudeLongitude:strLat withLongitude:strLong];
    
    [self GetAddress:newLocation];
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
