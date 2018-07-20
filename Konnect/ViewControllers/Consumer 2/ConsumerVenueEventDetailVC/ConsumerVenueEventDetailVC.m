//
//  ConsumerVenueEventDetailVC.m
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ConsumerVenueEventDetailVC.h"
#import "ConsumerVenueEventDetailCell.h"
#import "ConsumerChekInViewController.h"
#import "MainViewController.h"
#import "ConsumerPostEventViewController.h"
#import "CommentScreenViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "KN_EventCheckIn.h"
#import "KN_User.h"
#import "KN_Event.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Social/Social.h>
#import "ConsumerVenueEventDetailSpecialCell/ConsumerSpecialTypesCell.h"
#import "CustomeCameraViewController.h"
#import "KN_Staging_PostEvent.h"
#import "UIImage+ImageCompress.h"
#import "NSDate+NVTimeAgo.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "ProfileScreenViewController.h"
#import "KN_VenueProfileSetup.h"
#define BTN_BACK 0
@interface ConsumerVenueEventDetailVC ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
{
    NSMutableArray *arrImage;
    UIButton *btnImageBubble;
    CGRect screenBounds;
    NSMutableArray *arrCheckInUser;
    NSMutableArray *arrEventPost;
    NSMutableArray *arrUsers;
    NSMutableArray *fetchedImages;
    NSMutableDictionary *dictUserInfo;
    NSMutableDictionary *dictUserIds;
    NSMutableArray *arrSpecialIcon;
    float checkInRange;
    UIButton *btnChkIn;
    BOOL checkEventTimeandDate;
    NSDate *StartEventdate;
    NSDate *EndEventdate;
    NSString *strAddress;
    NSString *strVenueId;
}

@end

@implementation ConsumerVenueEventDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
    
    
    tblEvent.estimatedRowHeight = 80;
    tblEvent.rowHeight = UITableViewAutomaticDimension;
    
    arrSpecialIcon = [[NSMutableArray alloc]init];
    arrEventPost = [[NSMutableArray alloc]init];
    fetchedImages = [[NSMutableArray alloc]init];
    
    if(_strComingFromNotScreen == nil)
    {
       
        [self UpdateEventData];
    }
   
   /* if (IS_IPHONE_5)
    {
        btnBeer.frame = CGRectMake(btnBeer.frame.origin.x, btnBeer.frame.origin.y, btnBeer.frame.size.width, btnBeer.frame.size.height);
        btnNonVeg.frame = CGRectMake(btnNonVeg.frame.origin.x-12, btnNonVeg.frame.origin.y, btnNonVeg.frame.size.width, btnNonVeg.frame.size.height);
        btnDJ.frame = CGRectMake(btnDJ.frame.origin.x-32, btnDJ.frame.origin.y, btnDJ.frame.size.width, btnDJ.frame.size.height);
        btnFood.frame = CGRectMake(btnFood.frame.origin.x-55, btnFood.frame.origin.y, btnFood.frame.size.width, btnFood.frame.size.height);
        
    }*/
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
   
}

-(void)UpdateEventData
{
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    NSSet *specialSet =[_dicEventDetails valueForKey:@"Special"];
    arrSpecialIcon =[specialSet allObjects].mutableCopy;
    if(arrSpecialIcon.count > 0)
    {
        collectionSpecial.delegate = self;
        collectionSpecial.dataSource = self;
        [collectionSpecial reloadData];
    }
    lblDescription.text = [_dicEventDetails valueForKey:@"Description"];
    lblHours.text = [[Singlton sharedManager]changeStringToDate:[_dicEventDetails valueForKey:@"EventDate"]] ;
    lblEveDay.text = [NSString stringWithFormat:@"%@-%@",[_dicEventDetails valueForKey:@"StartTime"],[_dicEventDetails valueForKey:@"EndTime"]];
    lblEventName.text = [_dicEventDetails valueForKey:@"Name"];
    lblEventType.text = [_dicEventDetails valueForKey:@"Type"];
    NSString *strForEventImageName = [[_dicEventDetails valueForKey:@"Image"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSURL *imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",BASE_VENUE_EVENT_IMAGE_URL,strForEventImageName]];
    [imgEvent sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
    _viewBox1.layer.cornerRadius = 10;
    _viewBox1.layer.masksToBounds = YES;
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
    
    
    arrImage = [[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"checkin1"],[UIImage imageNamed:@"checkin2"],[UIImage imageNamed:@"checkin3"],[UIImage imageNamed:@"checkInCircleNo"],nil];
    
    
    
    if (IS_IPHONE_6_PLUS)
    {
        btnChkIn = [[UIButton alloc]initWithFrame:CGRectMake(300,10, 67, 28)];
    }
    else if (IS_IPHONE_6)
    {
        btnChkIn = [[UIButton alloc]initWithFrame:CGRectMake(285,10, 67, 28)];
    }
    else if (IS_IPHONE_5)
    {
        btnChkIn = [[UIButton alloc]initWithFrame:CGRectMake(235,10, 67, 28)];
    }
    [btnChkIn addTarget:self action:@selector(clickCheckIn) forControlEvents:UIControlEventTouchUpInside];
    btnChkIn.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:11.0];
    [btnChkIn setTitle:@"Check In" forState:UIControlStateNormal];
    btnChkIn.layer.cornerRadius = 3.0f;
    btnChkIn.layer.masksToBounds = YES;
    [btnChkIn setBackgroundColor:[UIColor colorWithRed:83.0/255.0f green:186.0/255.0f blue:231.0/255.0f alpha:1]];
    [viewSlider addSubview:btnChkIn];
    StartEventdate = [[Singlton sharedManager]convertStringToDate:[NSString stringWithFormat:@"%@ %@",[_dicEventDetails valueForKey:@"EventDate"],[_dicEventDetails valueForKey:@"StartTime"]]];
    
    EndEventdate = [[Singlton sharedManager]convertStringToDate:[NSString stringWithFormat:@"%@ %@",[_dicEventDetails valueForKey:@"EventDate"],[_dicEventDetails valueForKey:@"EndTime"]]];
    
    checkEventTimeandDate = [[Singlton sharedManager]date:[NSDate date] isBetweenDate:StartEventdate andDate:EndEventdate];
    
    if (!checkEventTimeandDate) {
        
        btnChkIn.hidden = YES;
        
    }
    else
    {
        btnChkIn.hidden = NO;
    }
}

-(void)GetDetailOfParticularEvent:(NSString *)strEventId
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
  //  AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
 
}
-(void)viewWillAppear:(BOOL)animated
{
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    if(_strComingFromNotScreen == nil)
    {
        [self FetchCheckInUsers];
        
    }
    else
    {
        [self GetEventDetailsWhenNotiArrived];
    }
   
    
    
}

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
                                                 @":val1" : strVenueId
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
                NSMutableArray *arrVenueDetails= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueProfileSetup *chat in paginatedOutput.items) {
                     
                     [arrVenueDetails addObject:chat];
                     
                 }
                 
                 if (arrVenueDetails.count>0)
                 {
                     
                     self.view.userInteractionEnabled = YES;
                     _dicVenueDetails = [arrVenueDetails objectAtIndex:0];
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
-(void)clickCheckIn
{
    
    
    NSArray *arryCheckAlready = [arrUsers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(UserId == %@)", [dictUserInfo valueForKey:@"UserId"]]];
    
    if (arryCheckAlready.count>0)
    {
        [[Singlton sharedManager] alert:self title:Alert message:@"You are already checkd-in"];
    }
    else if (checkInRange>50) {
        
        [[Singlton sharedManager] alert:self title:Alert message:@"you are away from the venue, you can't check-in right now"];
    }
    else if ([[_dicVenueEventCheckIn valueForKey:@"Status"]isEqualToString:@"NO"]) {
        
        [[Singlton sharedManager] alert:self title:Alert message:@"you have to check into the venue first"];
    }
    else
    {
        
        [self SaveCheckIndata];
    }
    
    
}
#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return arrEventPost.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 500; // customize the height
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *CellIdentifier = @"ConsumerVenueEventDetailCell";
    
    ConsumerVenueEventDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ConsumerVenueEventDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.btnTotalComents.tag = indexPath.row;
    [cell.btnTotalComents addTarget:self
                             action:@selector(funcGotoCommentsScreen:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    
    
    NSString *strForEventImageName = [[[arrEventPost valueForKey:@"Image"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_POST_EVENT_IMAGE_URL,strForEventImageName]];
    
    [cell.imgEvent sd_setImageWithURL:url
                     placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    NSString *strForUserImageName = [[[arrEventPost valueForKey:@"UserImage"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *Userurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,strForUserImageName]];
    
    [cell.imgUserProfile sd_setImageWithURL:Userurl
                           placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    cell.lblUserName.text = [[arrEventPost valueForKey:@"Name"]objectAtIndex:indexPath.row];
    
    NSNumber *numberDate = [[arrEventPost valueForKey:@"CreatedAt"]objectAtIndex:indexPath.row];
    NSDate *postdate = [NSDate dateWithTimeIntervalSince1970:[numberDate doubleValue]];
    NSString *strPostDate = [[Singlton sharedManager]convertDateToString:postdate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSDate *myDate = [formatter dateFromString:strPostDate];
    [formatter setDateFormat:@"MMMM d,yyyy hh:mm a"];
    NSString *strFate =[formatter stringFromDate:myDate];
    
    
    NSString *ago = [myDate formattedAsTimeAgo];
    cell.lblTime.text = ago;
    cell.lblDescription.text = [[arrEventPost valueForKey:@"PostComment"]objectAtIndex:indexPath.row];
    cell.lblDate.text =  strFate;
    cell.lblCommentNumber.text = [[arrEventPost valueForKey:@"commentCount"]objectAtIndex:indexPath.row];
    cell.btnShare.tag = indexPath.row;
    [cell.btnShare addTarget:self
                     action:@selector(sharePost:)
           forControlEvents:UIControlEventTouchUpInside];
    NSString *strPlay = [[arrEventPost valueForKey:@"Type"]objectAtIndex:indexPath.row];
    if ([strPlay isEqualToString:@"Photo"]) {
        
        cell.btnPlay.hidden = YES;
    }
    else
    {
        cell.btnPlay.hidden = NO;
    }
    
    cell.btnPlay.tag = indexPath.row;
    
    [cell.btnPlay addTarget:self
                     action:@selector(clickPlayVideo:)
           forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.view.tag = indexPath.row;
    cell.imgUserProfile.tag = indexPath.row;
    cell.imgUserProfile.userInteractionEnabled = YES;
    [cell.imgUserProfile addGestureRecognizer:tapGestureRecognizer];
    
    UITapGestureRecognizer *tapName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserName:)];
    tapName.numberOfTapsRequired = 1;
    tapName.delegate = self;
    cell.lblUserName.tag = indexPath.row;
    cell.lblUserName.userInteractionEnabled = YES;
    [cell.lblUserName addGestureRecognizer:tapName];
    
    
    return cell;
    
}

#pragma mark - collectionView Delegates and DataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return arrSpecialIcon.count;
    
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
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
    ConsumerSpecialTypesCell *cell = (ConsumerSpecialTypesCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.lblName.text = [arrSpecialIcon objectAtIndex:indexPath.row];
    cell.imgIcon.image = [UIImage imageNamed:[arrSpecialIcon objectAtIndex:indexPath.row]];
    
    return cell;
}
#pragma mark - Goto Comment Screen
-(void)funcGotoCommentsScreen:(UIButton *) sender
{
    CommentScreenViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentScreenViewController"];
    vc.strPostId = [[arrEventPost valueForKey:@"Id"]objectAtIndex:sender.tag];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)sharePost:(UIButton *) sender
{
    UIButton *button=(UIButton *) sender;
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    ConsumerVenueEventDetailCell *tappedCell = (ConsumerVenueEventDetailCell *)[tblEvent cellForRowAtIndexPath:indexpath];
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    UIImage *img=tappedCell.imgEvent.image;
    photo.image =img ;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *photoContent = [[FBSDKSharePhotoContent alloc] init];
    photoContent.photos = @[photo];
    [FBSDKShareDialog showFromViewController:self withContent:photoContent delegate:nil];
}
-(void)clickPlayVideo:(UIButton *) sender
{
    
    NSString *strForEventVideo = [[[arrEventPost valueForKey:@"Video"]objectAtIndex:sender.tag] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_POST_EVENT_IMAGE_URL,strForEventVideo]];
    
    // create an AVPlayer
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    // create a player view controller
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    [self presentViewController:controller animated:YES completion:nil];
    controller.player = player;
    [player play];
}
-(void)clickVenueImage:(UIButton *) sender
{
    ConsumerChekInViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerChekInViewController"];
    Vc.arrCheckInUserList  =  arrUsers;
    [self.navigationController pushViewController:Vc animated:YES];
}


#pragma mark - IBAction Method

-(IBAction)clickImage:(UITapGestureRecognizer*)recognizer
{
    ProfileScreenViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileScreenViewController"];
    [Singlton sharedManager].dictNonLoginUser = [arrEventPost objectAtIndex:recognizer.view.tag];
    [self.navigationController pushViewController:ivc animated:YES];
}
-(IBAction)clickUserName:(UITapGestureRecognizer*)recognizer
{
    ProfileScreenViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileScreenViewController"];
    [Singlton sharedManager].dictNonLoginUser = [arrEventPost objectAtIndex:recognizer.view.tag];
    [self.navigationController pushViewController:ivc animated:YES];
}
-(IBAction)actionHideBox:(UIButton *)sender{
    if([sender tag] == 123)
    {
        
        checkInRange = [self GetDifferenceBetweenTwoLatitudeLongitude:[_dicVenueDetails valueForKey:@"Latitude"] withLongitude:[_dicVenueDetails valueForKey:@"Longitude"]];
        
        checkEventTimeandDate = [[Singlton sharedManager]date:[NSDate date] isBetweenDate:StartEventdate andDate:EndEventdate];
        
        BOOL checkEndTimeComplete = [[Singlton sharedManager]DateChekDifference:[NSDate date] andDate:EndEventdate];
        
        if (checkInRange>50) {
            
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
       
    }
}
-(IBAction)clickButtons:(UIButton *)sender
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage;
    chosenImage = info[UIImagePickerControllerEditedImage];
    ConsumerPostEventViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerPostEventViewController"];
    vc.imgData = chosenImage;
    _viewBox.hidden = YES;
    vc.strCheck = @"Photo";
    vc.strHeader = @"Post";
    vc.strEventId = [_dicEventDetails valueForKey:@"Id"];
    vc.postAddress = strAddress;
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
#pragma mark ----------
-(void)viewDidDisappear:(BOOL)animated
{
    _strComingFromNotScreen = nil;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark - AWS Method
//Save Venue Profile Details
-(void)SaveCheckIndata
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSString *Id = [NSString stringWithFormat:@"%@%f",[dictUserInfo valueForKey:@"firstName"],timeInSeconds];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    KN_EventCheckIn *venueCheckIn = [KN_EventCheckIn new];
    venueCheckIn.Id = Id;
    venueCheckIn.UserId = [dictUserInfo valueForKey:@"UserId"] ;
    venueCheckIn.EventId = [_dicEventDetails valueForKey:@"Id"];
    venueCheckIn.Status = @"YES";
    venueCheckIn.CheckedInTime = NumberCreatedAt;
    venueCheckIn.CheckedOutTime = NumberCreatedAt;
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
                                                @"#P": [NSString stringWithFormat:@"%@", @"EventId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [_dicEventDetails valueForKey:@"Id"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_EventCheckIn class]
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
                 for (KN_EventCheckIn *chat in paginatedOutput.items) {
                     
                     [arrCheckInUser addObject:chat];
                     
                 }
                 if (arrCheckInUser.count>0) {
                     
                     [self FetchAllCheckInUser];
                 }
                 else
                 {
                     [self FetchEventPost];
                 }
                 
             });
             
         }
         
         return nil;
         
     }];
    
}

-(void)GetEventDetailsWhenNotiArrived
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
                                                 @":val1" : _strComingFromNotScreen
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
                 NSMutableArray *arrTempEveInfo= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_Event *chat in paginatedOutput.items) {
                     
                     [arrTempEveInfo addObject:chat.dictionaryValue];
                     
                 }
                 if (arrTempEveInfo.count>0) {
                     
                     _dicEventDetails = [[arrTempEveInfo objectAtIndex:0] mutableCopy];
                     strVenueId = [_dicEventDetails valueForKey:@"VenueId"];
                       [self UpdateEventData];
                      [self FetchCheckInUsers];
                     [self FetchVenueProfile];
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
    
    for (int i=0; i<arrCheckInUser.count; i++)
    {
        NSString *str = [NSString stringWithFormat:@":val%d",i+1];
        
        NSString *strcontains = [NSString stringWithFormat:@"contains(#P,%@)",str];
        
        [dictUserIds setObject:[[arrCheckInUser valueForKey:@"UserId"]objectAtIndex:i] forKey:str];
        
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
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 arrUsers= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_User *chat in paginatedOutput.items) {
                     
                     [arrUsers addObject:chat];
                     
                 }
                 
                 [self FetchEventPost];
                 
                 [self addCheckInUsersOnView:arrUsers];
                 
             });
             
         }
         
         return nil;
         
     }];
    
    
}
-(void)FetchEventPost
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
                                                 @":val1" : [_dicEventDetails valueForKey:@"Id"]
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
                     [fetchedImages addObject:[NSNull null]];
                 }
                 
                 if (arrEventPost.count>0) {
                     
                     lblAlert.hidden = YES;
                     tblEvent.hidden = NO;
                     NSSortDescriptor *sortDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"CreatedAt"
                                                                                     ascending:YES];
                     NSArray *arrayMesage = [arrEventPost
                                             sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                     arrEventPost = [NSMutableArray arrayWithArray:arrayMesage];
                     [tblEvent reloadData];
                 }
                 else
                 {
                     lblAlert.hidden = NO;
                     tblEvent.hidden = YES;
                     
                     float sizeOfContent = 0;
                     UIView *lLast = [scrollView.subviews lastObject];
                     NSInteger wd = lLast.frame.origin.y;
                     NSInteger ht = lLast.frame.size.height;
                     
                     sizeOfContent = wd+ht;
                     
                     scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, sizeOfContent+200);
                     
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
    
}
-(void)addCheckInUsersOnView:(NSMutableArray*)arryUsers
{
    int xOffset = 0;
    if (IS_IPHONE_5)
    {
        xOffset = 14;
    }
    for(int index=0; index < arryUsers.count; index++)
    {
        
        if (IS_IPHONE_5)
        {
            btnImageBubble = [[UIButton alloc] initWithFrame:CGRectMake(xOffset,570,46, 46)];
            
        }
        else
        {
            btnImageBubble = [[UIButton alloc] initWithFrame:CGRectMake(xOffset,5,46, 46)];
            
            
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
                [scrollView addSubview:btnImageBubble];
                [scrollView bringSubviewToFront:btnImageBubble];
            }
            else
            {
                [viewSlider addSubview:btnImageBubble];
            }
        }
        xOffset+=30;
        
        
    }
    
}
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

