//
//  VOHomeViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 19/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VOHomeViewController.h"
#import "MainViewController.h"
#import "EventTableViewCell.h"
#import "NonKonnectScreen/NonKonnectViewController.h"
#import "ConsumerVenueDetailVC.h"
#import "FilterViewController.h"
#import "EditProfile/EditProfileViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ImageCompress.h"
#import "EditProfileAutoFillCell.h"
#import "KN_User.h"
#import "KN_Event.h"
#import "KN_VenueProfileSetup.h"
#import "SearchByEventNVenue/SearchByEventandVenueViewController.h"
#import "ConsumerNotificationViewController.h"
#import "ProfileScreenViewController.h"
#import "ConsumerVenueEventDetailVC.h"
@interface VOHomeViewController ()<UINavigationBarDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSArray *mainContents;
    NSInteger selectedIndex;
    NSMutableDictionary *dictUserInfo;
    NSString *strLong, *strLat;
    NSString *strImageName;
    NSString *strRateVal;
    BOOL isImageChanged;
    BOOL isArrayEmpty;
    BOOL isKonnectVenueFound;
    NSString *konnectVenue;
    NSString *strRequestParams;
    NSMutableArray *arrListCity;
    float DistanceInKms;
    BOOL mapChangedFromUserInteraction;
    NSMutableArray *unique;
    CLLocationCoordinate2D mapCoordinates;
    
    
}
@end

@implementation VOHomeViewController
{
@private
    BOOL regionWillChangeAnimatedCalled;
    BOOL regionChangedBecauseAnnotationSelected;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    /*
    CLLocationManager *locationManager2;
    locationManager2.delegate = self;
    switch (CLLocationManager.authorizationStatus) {
        case kCLAuthorizationStatusNotDetermined:
            self.locationManager.requestAlwaysAuthorization;
            break;
        case kCLAuthorizationStatusRestricted:
            printf("Xmode features restricted!");
            break;
        case kCLAuthorizationStatusDenied:
            printf("Xmode features Denied!");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            //enableMyWhenInUseFeatures();
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            //enableMyAlwaysFeatures();
            break;
        
        default:
            break;
    }*/
    
    //This condition is for handling Notification when App is removed from background and notification will arrive
    if([[[NSUserDefaults standardUserDefaults]valueForKey:@"appKill"]isEqualToString:@"yes"])
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"no" forKey:@"appKill"];
        [self AddNSPostNotificationForNavigationWhenAppIsRemovedFromBackground];
        
    }
    //This Will add NSPOSTNOTIFICATIONCENETR for handle notification arrival and navigation to particular screen
    [self AddNSPostNotificationForNavigation];
    unique = [NSMutableArray array];
    arrVenues = [[NSMutableArray alloc]init];
    [Singlton sharedManager].arrDataTempStorage = [[NSMutableArray alloc]init];
    mapChangedFromUserInteraction = NO;
    isImageChanged = NO;
    isArrayEmpty = YES;
    arrListCity = [NSMutableArray new];
    dictUserInfo =[[NSMutableDictionary alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
    //[self.locationManager requestAlwaysAuthorization]; //working on V 1.3 Xmode
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    //else if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){ //WOrking on V 1.3 Xmode
       // [self.locationManager requestAlwaysAuthorization];
    //}
    
    //Taking the localdata of USER in dictionary
    dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
    
    [self ShowDataForEditProfileWhenUserLOginForFirstTime];
    
    //This method will be called when user Login for the First Time in the App
    [self UpdateFirstTimeLogin:[dictUserInfo valueForKey:@"UserId"]];
    //Calling GOOGLE API  for fetching near by BAR N RESTAURANTS
    //[self  callGoogleAPI];
}

-(void)ShowDataForEditProfileWhenUserLOginForFirstTime
{
    if(![[dictUserInfo valueForKey:@"UserImage"]isEqualToString:@"NA"])
    {
        //This condition is to check whether User has login through FB
        if([[dictUserInfo valueForKey:@"fblogin"]isEqualToString:@"YES"])
        {
            //This condition is to check whether user has changed the FACEBOOK DP to Normal User DP
            if([[dictUserInfo valueForKey:@"FBProfilePicChanged"]isEqualToString:@"YES"])
            {
                _imgUserPic.image = nil;
                NSString *strForEventImageName = [[dictUserInfo valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                NSURL *imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
                
                [_imgUserPic sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]];
            }
            else
            {
                NSURL *imageUrl = [[NSURL alloc] initWithString:[dictUserInfo valueForKey:@"UserImage"]];
                [_imgUserPic sd_setImageWithURL:imageUrl] ;
            }
        }
        else
        {
            _imgUserPic.image = nil;
            NSString *strForEventImageName = [[dictUserInfo valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
            NSURL *imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
            
            [_imgUserPic sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]];
            
            
        }
        
        
        
    }
    else
    {
        [_imgUserPic sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
    }
    if([[dictUserInfo valueForKey:@"firstName"]isEqualToString:@"NA"]||[[dictUserInfo valueForKey:@"lastName"]isEqualToString:@"NA"])
    {
    }
    else
    {
        _txtfirstName.text = [dictUserInfo valueForKey:@"firstName"];
        _txtlastName.text = [dictUserInfo valueForKey:@"lastName"];
    }
    if([[dictUserInfo valueForKey:@"HomeLocation"]isEqualToString:@"NA"])
    {
        
    }
    else
    {
        
        _txthomeLoc.text = [dictUserInfo valueForKey:@"HomeLocation"];
    }
    _txtfirstName.delegate = self;
    _txtlastName.delegate = self;
    _txthomeLoc.delegate = self;
    _btnSkip.layer.cornerRadius = 8.0;
    _btnSkip.layer.masksToBounds = YES;
    _btnGotoProfile.layer.cornerRadius = 8.0;
    _btnGotoProfile.layer.masksToBounds = YES;
    _imgUserPic.layer.cornerRadius = _imgUserPic.bounds.size.width/2;
    _imgUserPic.layer.masksToBounds =YES;
    [btnList setImage:[UIImage imageNamed:@"ListViewUnselected"] forState:UIControlStateNormal];
    [btnMap setImage:[UIImage imageNamed:@"MapSelectedIcon"] forState:UIControlStateNormal];
    [self loadMapView];
    _tblEvent.hidden = YES;
    tblAutoComplete.delegate = self;
    _mapEvent.hidden = NO;
    _mapEvent.delegate = self;
    [_mapEvent setMapType:MKMapTypeStandard];
    [self.mapEvent setShowsUserLocation:YES];
    //For the textField Padding
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    _txtfirstName.leftView = paddingView1;
    _txtfirstName.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingViewPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    _txtlastName.leftView = paddingViewPassword;
    _txtlastName.leftViewMode = UITextFieldViewModeAlways;
    UIView *confirmPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    _txthomeLoc.leftView = confirmPassword;
    _txthomeLoc.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtSearch.leftView = paddingView;
    txtSearch.leftViewMode = UITextFieldViewModeAlways;
    
    //Calling Google Location API to get the accurate results
    [_txthomeLoc addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}

-(void)AddNSPostNotificationForNavigationWhenAppIsRemovedFromBackground
{
    [self HandleNotificationNavigation];
}

-(void)AddNSPostNotificationForNavigation
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotificationNavigation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NavigateToNotiScreen:)  name:@"NotificationNavigation" object:nil];
}

-(void)NavigateToNotiScreen:(NSNotification *)note
{
    NSLog(@"PostNotification called");
    [self HandleNotificationNavigation];
    
}

-(void)HandleNotificationNavigation
{
    //[[Singlton sharedManager] alert:self title:Alert message:@"Callednavigation"];
    if( [[[Singlton sharedManager].dictNotificationInfo valueForKey:@"type"]isEqualToString:@"Follow"])
    {
        
        [[Singlton sharedManager].dictNotificationInfo setObject:[[Singlton sharedManager].dictNotificationInfo valueForKey:@"itemId"] forKey:@"UserId"];
        ProfileScreenViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileScreenViewController"];
        [Singlton sharedManager].dictNonLoginUser = [Singlton sharedManager].dictNotificationInfo;
        [self.navigationController pushViewController:ivc animated:YES];
        
    }
    if( [[[Singlton sharedManager].dictNotificationInfo valueForKey:@"type"]isEqualToString:@"Post"])
    {
        ConsumerVenueEventDetailVC *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerVenueEventDetailVC"];
        ivc.strComingFromNotScreen = [[Singlton sharedManager].dictNotificationInfo valueForKey:@"itemId"];
        [self.navigationController pushViewController:ivc animated:YES];
    }
}
#pragma mark - Address autoFill method
-(void)textFieldDidChange
{
    [self  getApiForAutoComplete:_txthomeLoc.text];
}
-(void)getApiForAutoComplete:(NSString *)strInput
{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *strUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=%@&input=%@",GoogleApiKey,strInput];
    NSString* webStringURL = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString: webStringURL];
    
    // Asynchronously Api is hit here
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                       {
                                           NSDictionary* json = [NSJSONSerialization
                                                                 JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                 error:&error];
                                           
                                           arrListCity = [[json valueForKey:@"predictions"]valueForKey:@"description"];
                                           
                                           NSLog(@"%@",arrListCity);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c]%@", _txthomeLoc.text];
                                               NSArray *resultArray = [[arrListCity filteredArrayUsingPredicate:predicate] mutableCopy];
                                               arrListCity = [NSMutableArray arrayWithArray:resultArray];
                                               if (arrListCity.count>0) {
                                                   
                                                   tblAutoComplete.hidden = NO;
                                                   [tblAutoComplete reloadData];
                                               }
                                               else
                                               {
                                                   tblAutoComplete.hidden = YES;
                                               }
                                           });
                                           
                                           
                                       }];
    
    [dataTask resume];
    
}

#pragma mark - GoogleAPI method Call
-(void)callGoogleAPI
{
    /* [Singlton sharedManager].latitude  = @"22.729505".doubleValue;
     [Singlton sharedManager].longitude  = @"75.897610".doubleValue;
     strRequestParams = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=1000&types=restaurant|bar&key=%@",@"22.729505".doubleValue,@"75.897610".doubleValue,GoogleApiKey];
     */
    
    [[Singlton sharedManager] showHUD];
    strRequestParams = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=1000&types=bar&key=%@",[Singlton sharedManager].latitude,[Singlton sharedManager].longitude,GoogleApiKey];
    
    if(![Singlton sharedManager].latitude  || ![Singlton sharedManager].longitude)
    {
        isArrayEmpty = YES;
    }
    else
    {
        if([Singlton sharedManager].arrKonnectVenues.count > 0)
        {
            [self GetAllGoogleVenuesNearBy];
        }
        else
        {
            [self CallGetAllKonnectVenues];
        }
        
    }
}

-(void)GetAllGoogleVenuesNearBy
{
     NSLog(@"GoogleAPICalled");
    CLLocationCoordinate2D userCoordinate;
    userCoordinate.latitude = [Singlton sharedManager].latitude;
    userCoordinate.longitude = [Singlton sharedManager].longitude;
    mapCoordinates.latitude = userCoordinate.latitude;
    mapCoordinates.longitude = userCoordinate.longitude;
    [_mapEvent setRegion:MKCoordinateRegionMake(userCoordinate, MKCoordinateSpanMake(0.01f, 0.01f))animated:YES];
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
            // arrVenues = [[NSMutableArray alloc]init];
            [arrVenues addObjectsFromArray:[dict valueForKey:@"results"]];
            strNextPageToken=[dict valueForKey:@"next_page_token"];
            [Singlton sharedManager].strNextPageTempToken = [dict valueForKey:@"next_page_token"];
            if(arrVenues.count>0)
            {
                isArrayEmpty = NO;
                if([Singlton sharedManager].arrKonnectVenues.count > 0)
                {
                    // this method will be called when we have KOnnect Venue(s) in the List
                    [self CallIteratingthroughKonnectVenues];
                    
                }
                else
                {
                    // this method will be called when there is not a single KOnnect Venue in the List
                    [self CallIteratingthroughNonKonnectVenues];
                    
                }
            }
        });
    }
}
-(void)CallGetAllKonnectVenues
{
    [[Singlton sharedManager]showHUD];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    
    [[dynamoDBObjectMapper scan:[KN_VenueProfileSetup class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 [Singlton sharedManager].arrKonnectVenues = [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueProfileSetup *chat in paginatedOutput.items)
                 {
                     
                     [[Singlton sharedManager].arrKonnectVenues addObject:chat.dictionaryValue];
                     
                 }
                 if([Singlton sharedManager].arrKonnectVenues.count>0)
                 {
                     NSMutableArray *arrTempKoonect = [NSMutableArray new];
                     for(int i = 0 ; i< [Singlton sharedManager].arrKonnectVenues.count; i++ )
                     {
                         if([[[Singlton sharedManager].arrKonnectVenues objectAtIndex:i]valueForKey:@"isProfileSetupCompleted"] != nil){
                             if([[[[Singlton sharedManager].arrKonnectVenues objectAtIndex:i]valueForKey:@"isProfileSetupCompleted"]isEqualToString:@"no"])
                             {
                                 
                             }
                             else
                             {
                                 [arrTempKoonect addObject:[[Singlton sharedManager].arrKonnectVenues objectAtIndex:i]];
                             }
                         }
                     }
                     [[Singlton sharedManager].arrKonnectVenues removeAllObjects];
                     [[Singlton sharedManager].arrKonnectVenues addObjectsFromArray:arrTempKoonect.mutableCopy];
                     [self GetAllGoogleVenuesNearBy];
                 }
                 else
                 {
                     [self GetAllGoogleVenuesNearBy];
                 }
             });
             
         }
         
         return nil;
         
     }];
    
    
}

-(void)callGoogleAPIWhenMapIsBeingSwiped:(CLLocationCoordinate2D)coord
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSString *strRequestParams = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=1000&types=bar&key=%@",coord.latitude,coord.longitude,GoogleApiKey];
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
                [arrVenues addObjectsFromArray:[dict valueForKey:@"results"]];
                if(arrVenues.count>0)
                {
                    isArrayEmpty = NO;
                    if([Singlton sharedManager].arrKonnectVenues.count > 0)
                    {
                        // this method will be called when we have KOnnect Venue(s) in the List
                        [self CallIteratingthroughKonnectVenues];
                        
                    }
                    else
                    {
                        // this method will be called when there is not a single KOnnect Venue in the List
                        [self CallIteratingthroughNonKonnectVenues];
                        
                    }
                }
            });
        }
        
        
    });
}

#pragma mark -Iterating through NonKonnect and Konnect Venues
-(void)CallIteratingthroughNonKonnectVenues
{
    // Removing Duplicate elements from array
    NSMutableArray *finalArray = [NSMutableArray array];
    NSMutableSet *mainSet = [NSMutableSet set];
    for (NSDictionary *item in arrVenues) {
        //Extract the part of the dictionary that you want to be unique:
        NSDictionary *dict = [item dictionaryWithValuesForKeys:@[@"place_id"]];
        if ([mainSet containsObject:dict]) {
            continue;
        }
        [mainSet addObject:dict];
        [finalArray addObject:item];
    }
    [arrVenues removeAllObjects];
    [arrVenues addObjectsFromArray:finalArray.mutableCopy];
    NSMutableDictionary *tempDict = [NSMutableDictionary new];
    
    //Caluclate Dustance between LatLong of user ANd Location
    for(int i = 0; i < arrVenues.count; i++)
    {
        tempDict = [[arrVenues objectAtIndex:i]mutableCopy];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[[[[[arrVenues objectAtIndex:i] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] doubleValue] longitude:[[[[[arrVenues objectAtIndex:i] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] doubleValue]];
        
        [tempDict setObject: [self calculateDistanceByLocation:location] forKey:@"DistanceInMiles"];
        [arrVenues replaceObjectAtIndex:i withObject:tempDict];
        [tempDict setObject:@"0" forKey:@"averageRating"];
        
    }
    NSSortDescriptor * brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"DistanceInMiles" ascending:YES];
    NSArray * sortedArray = [arrVenues sortedArrayUsingDescriptors:@[brandDescriptor]];
    [arrVenues removeAllObjects];
    [arrVenues addObjectsFromArray:[sortedArray mutableCopy]];
    [[Singlton sharedManager].arrDataTempStorage addObjectsFromArray:[sortedArray mutableCopy]];
    // this method will filter the arrayList Data.
    //[self ApplyKonnectFilters];
    [_tblEvent reloadData];
    [self loadMapView];
    
}
-(void)CallIteratingthroughKonnectVenues
{
    NSMutableDictionary *tempDict = [NSMutableDictionary new];
    for(int i=0; i<[Singlton sharedManager].arrKonnectVenues.count; i++)
    {
        for(int j=0; j<arrVenues.count; j++)
        {
            tempDict = [[arrVenues objectAtIndex:j]mutableCopy];
            if([[[[Singlton sharedManager].arrKonnectVenues objectAtIndex:i]valueForKey:@"Id"]isEqualToString:[[arrVenues objectAtIndex:j]valueForKey:@"place_id"]] && [[[[Singlton sharedManager].arrKonnectVenues objectAtIndex:i]valueForKey:@"isProfileSetupCompleted"]isEqualToString:@"YES"])
            {
                isKonnectVenueFound = YES;
                [tempDict setObject:@"1" forKey:@"Konnect"];
                if([[[[Singlton sharedManager].arrKonnectVenues objectAtIndex:i]valueForKey:@"AverageRating"]isKindOfClass:[NSNull class]] || [[[Singlton sharedManager].arrKonnectVenues objectAtIndex:i]valueForKey:@"AverageRating"] == nil )
                {
                    [tempDict setObject:@"0" forKey:@"averageRating"];
                }
                else
                {
                    [tempDict setObject:[[[Singlton sharedManager].arrKonnectVenues objectAtIndex:i]valueForKey:@"AverageRating"] forKey:@"averageRating"];
                }
            }
            else
            {
                
            }
            //Caluclate Dustance between LatLong of user ANd Location
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[[[[[arrVenues objectAtIndex:j] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] doubleValue] longitude:[[[[[arrVenues objectAtIndex:j] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] doubleValue]];
            [tempDict setObject: [self calculateDistanceByLocation:location] forKey:@"DistanceInMiles"];
            [arrVenues replaceObjectAtIndex:j withObject:tempDict];
        }
    }
    // Removing Duplicate elements from array
    NSMutableArray *finalArray = [NSMutableArray array];
    NSMutableSet *mainSet = [NSMutableSet set];
    for (NSDictionary *item in arrVenues) {
        //Extract the part of the dictionary that you want to be unique:
        NSDictionary *dict = [item dictionaryWithValuesForKeys:@[@"place_id"]];
        if ([mainSet containsObject:dict]) {
            continue;
        }
        [mainSet addObject:dict];
        [finalArray addObject:item];
    }
    [arrVenues removeAllObjects];
    [arrVenues addObjectsFromArray:finalArray.mutableCopy];
    if(isKonnectVenueFound == YES)
    {
        // Sort on the basis of Konnect Venues
        
        NSSortDescriptor * brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Konnect" ascending:NO];
        NSArray * sortedArray = [arrVenues sortedArrayUsingDescriptors:@[brandDescriptor]];
        [arrVenues removeAllObjects];
        [[Singlton sharedManager].arrDataTempStorage removeAllObjects];
        [arrVenues addObjectsFromArray:[sortedArray mutableCopy]];
        [[Singlton sharedManager].arrDataTempStorage addObjectsFromArray:[sortedArray mutableCopy]];
    }
    else
    {
        // Sort on the basis of DIstance Venues
        NSSortDescriptor * brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"DistanceInMiles" ascending:YES];
        NSArray * sortedArray = [arrVenues sortedArrayUsingDescriptors:@[brandDescriptor]];
        [arrVenues removeAllObjects];
        [[Singlton sharedManager].arrDataTempStorage removeAllObjects];
        [arrVenues addObjectsFromArray:[sortedArray mutableCopy]];
        [[Singlton sharedManager].arrDataTempStorage addObjectsFromArray:[sortedArray mutableCopy]];
    }
    
    [_tblEvent reloadData];
    [self loadMapView];
    //[self ApplyKonnectFilters];
    
}

#pragma mark - Applying konnect filters to filter the array data

-(void)ApplyKonnectFilters
{
    if([[[Singlton sharedManager].arrFiltersForData objectAtIndex:0]isEqualToString:@"All Konnect Venues"])
    {
        [arrVenues removeAllObjects];
        [arrVenues addObjectsFromArray:[[Singlton sharedManager].arrDataTempStorage mutableCopy]];
        NSMutableArray *arrTempFilter= [NSMutableArray new];
        for(int i =0 ; i< arrVenues.count; i++)
        {
            if([[arrVenues objectAtIndex:i]valueForKey:@"Konnect"])
            {
                if([arrTempFilter containsObject:[arrVenues objectAtIndex:i]])
                {
                    NSLog(@"All Konnect Venues:-Contain");
                }
                else
                {
                    [arrTempFilter addObject:[arrVenues objectAtIndex:i]];
                    NSLog(@"All Konnect Venues:-Don'tContain");
                }
            }
        }
        
        if(arrTempFilter.count > 0)
        {
            strNextPageToken = nil;
            [arrVenues removeAllObjects];
            [arrVenues addObjectsFromArray:[arrTempFilter mutableCopy]];
        }
        else
        {
            [[Singlton sharedManager] alert:self title:Alert message:@"You don't have any Konnect Venues right now"];
        }
    }
    else if ([[[Singlton sharedManager].arrFiltersForData objectAtIndex:0]isEqualToString:@"Konnect Venue with events"])
    {
        //Getting Koonect Venues with Events
        [self GetKonnectVenuesWithEvents];
    }
    else if ([[[Singlton sharedManager].arrFiltersForData objectAtIndex:0]isEqualToString:@"All Venues"])
    {
        strNextPageToken = [Singlton sharedManager].strNextPageTempToken;
        [arrVenues removeAllObjects];
        [arrVenues addObjectsFromArray:[[Singlton sharedManager].arrDataTempStorage mutableCopy]];
    }
    [_tblEvent reloadData];
    [self loadMapView];
}

#pragma mark - GetKonnect Venues with Events
-(void)GetKonnectVenuesWithEvents
{
    NSMutableArray *arrVenueWithEvents = [NSMutableArray new];
    [[Singlton sharedManager]showHUD];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    
    [[dynamoDBObjectMapper scan:[KN_Event class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_Event *chat in paginatedOutput.items)
                 {
                     [arrVenueWithEvents addObject:chat];
                 }
                 if(arrVenueWithEvents.count>0)
                 {
                     [self callFilterVenuesWithEventsOnly:arrVenueWithEvents];
                 }
                 else
                 {
                     [[Singlton sharedManager] alert:self title:Alert message:@"You don't have any Konnect Venues with events right now"];
                 }
                 
             });
             
         }
         
         return nil;
         
     }];
    
}

#pragma mark - Filtering konnect venues with Events

-(void)callFilterVenuesWithEventsOnly:(NSMutableArray *)arrVenueWithEvents

{
    NSMutableArray *arrTempVenueWithEve = [[NSMutableArray alloc]init];
    NSMutableDictionary *tempDict = [NSMutableDictionary new];
    [arrVenues removeAllObjects];
    [arrVenues addObjectsFromArray:[Singlton sharedManager].arrDataTempStorage.mutableCopy];
    for(int i=0; i<arrVenueWithEvents.count; i++)
    {
        for(int j=0; j<arrVenues.count; j++)
        {
            tempDict = [[arrVenues objectAtIndex:j]mutableCopy];
            if([[[arrVenueWithEvents objectAtIndex:i]valueForKey:@"VenueId"]isEqualToString:[[arrVenues objectAtIndex:j]valueForKey:@"place_id"]] )
            {
                if([arrTempVenueWithEve containsObject:[arrVenues objectAtIndex:j]])
                {
                    NSLog(@" Konnect Venues with event:-Contain");
                }
                else
                {
                    NSLog(@" Konnect Venues with event:-Don'tContain");
                    [arrTempVenueWithEve addObject:[arrVenues objectAtIndex:j]];
                }
            }
            
        }
        [tempDict setObject:arrTempVenueWithEve forKey:@"VenueEvents"];
    }
    if(arrTempVenueWithEve.count>0)
    {
        [arrVenues removeAllObjects];
        [arrVenues addObjectsFromArray:[arrTempVenueWithEve mutableCopy]];
        strNextPageToken = nil;
        [_tblEvent reloadData];
        [self loadMapView];
    }
    else
    {
        [[Singlton sharedManager] alert:self title:Alert message:@"You don't have any Konnect Venues with events right now"];
    }
    /* NSMutableArray *arrTempVenueWithEve = [[NSMutableArray alloc]init];
     NSMutableDictionary *tempDict = [NSMutableDictionary new];
     for(int i=0; i<arrVenues.count; i++)
     {
     for(int j=0; j<arrVenueWithEvents.count; j++)
     {
     tempDict = [[arrVenues objectAtIndex:j]mutableCopy];
     if([[[arrVenues objectAtIndex:i]valueForKey:@"place_id"]isEqualToString:[[arrVenueWithEvents objectAtIndex:j]valueForKey:@"VenueId"]] )
     {
     NSLog(@" Konnect Venues with event:-");
     [arrTempVenueWithEve addObject:[arrVenues objectAtIndex:j]];
     }
     
     }
     [tempDict setObject:arrTempVenueWithEve forKey:@"VenueEvents"];
     [arrVenues replaceObjectAtIndex:i withObject:tempDict];
     [arrTempVenueWithEve removeAllObjects];
     }*/
    /*if(arrTempVenueWithEve.count>0)
     {
     [arrVenues removeAllObjects];
     [arrVenues addObjectsFromArray:[arrTempVenueWithEve mutableCopy]];
     strNextPageToken = nil;
     [_tblEvent reloadData];
     [self loadMapView];
     }
     else
     {
     [[Singlton sharedManager] alert:self title:Alert message:@"You don't have any Konnect Venues with events right now"];
     }*/
    
}

#pragma mark - Delegate method to update User Loc

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
    [Singlton sharedManager].latitude = newLocation.coordinate.latitude;
    [Singlton sharedManager].longitude =newLocation.coordinate.longitude;
    if(isArrayEmpty == YES)
    {
       
        [self callGoogleAPI];
    }
    [self.locationManager stopUpdatingLocation];
    
}

#pragma mark - Upload or take photo from App
- (IBAction)actionChoosePic:(id)sender {
    
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:Take_A_Photo style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:Existing_Photos style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
    
}
#pragma mark - UIImagePickerController Delegate Method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage;
    chosenImage = info[UIImagePickerControllerEditedImage];
    _imgUserPic.image = chosenImage;
    isImageChanged = YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - Update Data in UserTable

- (IBAction)funcSave:(id)sender {
    
   if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    if ([[Singlton sharedManager]check_null_data:_txtfirstName.text]) {
        
        [[Singlton sharedManager] alert:self title:Alert message:FirstName];
    }
    else if ([[Singlton sharedManager]check_null_data:_txtlastName.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:LastName];
    }
    else if ([[Singlton sharedManager]check_null_data:_txthomeLoc.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:HomeLoc];
    }
    else
    {
        //calling this method to update image in S3BUcket
        [self  callEditProfileAPI];
    }
}

- (void)callEditProfileAPI {
    [[Singlton sharedManager]showHUD];
    if(isImageChanged == YES)
    {
        //[[SDImageCache sharedImageCache]clearMemory];
        //[[SDImageCache sharedImageCache]clearDisk];
    }
    
    UIImage *compressedImage = [[Singlton sharedManager]imageWithImage:_imgUserPic.image scaledToSize:CGSizeMake(150, 150)];
    _imgUserPic.image=compressedImage;
    strImageName = [NSString stringWithFormat:@"%@.jpg",[dictUserInfo valueForKey:@"Email"]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:strImageName];
    [UIImagePNGRepresentation(_imgUserPic.image) writeToFile:filePath atomically:YES];
    
    NSURL* imageUrl = [NSURL fileURLWithPath:filePath];
    
    AWSS3TransferManager *transferManager =
    [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    
    uploadRequest.bucket = [UserMode isEqualToString:@"Test"] ? @"staging-consumerprofile":@"kon-consumerprofile";
    uploadRequest.key = strImageName;
    uploadRequest.body  =   imageUrl;
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error) {
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [[Singlton sharedManager]killHUD];
                                                                   
                                                                   self.view.userInteractionEnabled = YES;
                                                               });
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                           
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;
                                                                           
                                                                           
                                                                       default:
                                                                           NSLog(@"Error: %@", task.error);
                                                                           break;
                                                                           
                                                                   }
                                                                   
                                                               } else {
                                                                   
                                                                   // Unknown error.
                                                                   NSLog(@"Error: %@", task.error);
                                                                   
                                                               }
                                                           }
                                                           
                                                           if (task.result) {
                                                               if([[dictUserInfo valueForKey:@"fblogin"]isEqualToString:@"YES"])
                                                               {
                                                                   [dictUserInfo setObject:@"NO" forKey:@"fblogin"];
                                                                   [dictUserInfo setObject:@"YES" forKey:@"FBProfilePicChanged"];
                                                                   [[NSUserDefaults standardUserDefaults]setObject:dictUserInfo forKey:@"loginUser"];
                                                                   //FBProfilePicChanged
                                                               }
                                                               //Method for  Updating User data in UserTable
                                                               [self UpdateProfile:[dictUserInfo valueForKey:@"UserId"]];
                                                               
                                                           }
                                                           
                                                           return nil;
                                                           
                                                           
                                                       }];
    
    
    
}

#pragma mark - Hiding editProfile View

- (IBAction)funcBackk:(id)sender {
    _viewEditProfile.hidden = YES;
}

#pragma mark - Navigate to venue detail on clicking callout
- (void)calloutButtonClicked:(NSString *)title {
    //Navigating to Konnect or NonKonnect Venue
    [Singlton sharedManager].dictVenueInfo =[arrVenues  objectAtIndex:selectedIndex] ;
    NSArray *arrTitle;
    arrTitle = [title componentsSeparatedByString:@":"];
    if([arrTitle[1] isEqualToString:@"yes"])
    {
        ConsumerVenueDetailVC *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerVenueDetailVC"];
        [self.navigationController pushViewController:ivc animated:YES];
    }
    else
    {
        NonKonnectViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"NonKonnectViewController"];
        [self.navigationController pushViewController:ivc animated:YES];
    }
}

#pragma mark - Loading Mapview with array data
- (void) loadMapView
{
    [_mapEvent removeAnnotations:_mapEvent.annotations];
    for (int y = 0; y < arrVenues.count; y++)
    {
        double latRange = [[[[[arrVenues objectAtIndex:y] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] doubleValue];
        double longRange = [[[[[arrVenues objectAtIndex:y] valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] doubleValue];
        
        // Add new waypoint to map
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latRange, longRange);
        PinAnnotation *pinAnnotation;
        pinAnnotation = [[PinAnnotation alloc] init];
        pinAnnotation.title = [[arrVenues  objectAtIndex:y] valueForKey:@"name"];
        pinAnnotation.subTitle=[[arrVenues  objectAtIndex:y] valueForKey:@"vicinity"];
        pinAnnotation.coordinate = location;
        if([[arrVenues objectAtIndex:y]valueForKey:@"Konnect"])
        {
            pinAnnotation.title = [NSString stringWithFormat:@"%@:yes",[[arrVenues  objectAtIndex:y] valueForKey:@"name"]];
        }
        else
        {
            pinAnnotation.title = [NSString stringWithFormat:@"%@:no",[[arrVenues  objectAtIndex:y] valueForKey:@"name"]];
        }
        pinAnnotation.index=y;
        [_mapEvent addAnnotation:pinAnnotation];
    }
    
}

/*- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
 
 [_mapEvent setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.01f, 0.01f))animated:YES];
 
 }*/

#pragma mark - Mapview delegate and datasource methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView;
    NSString *identifier;
    NSArray *arrTitle;
    if ([annotation isKindOfClass:[PinAnnotation class]]) {
        // Pin annotation.
        
        identifier = @"Pin";
        annotationView = (MKAnnotationView *) [_mapEvent dequeueReusableAnnotationViewWithIdentifier: @"VoteSpotPin"];
        if (annotationView == nil)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"map_pin"];
        }
        else
        {
            annotationView.annotation = annotation;
        }
        //[annotationView setImage:[UIImage imageNamed:@"UnUserLocationIcon"]];
        arrTitle = [annotation.title componentsSeparatedByString:@":"];
        
        if([arrTitle[1] isEqualToString:@"yes"])
        {
            [annotationView setImage:[UIImage imageNamed:@"UserLocationIcon"]];
        }
        else
        {
            [annotationView setImage:[UIImage imageNamed:@"UnUserLocationIcon"]];
        }
    }
    else if ([annotation isKindOfClass:[CalloutAnnotation class]]) {
        
        // Callout annotation.
        identifier = @"Callout";
        annotationView = (CalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView == nil) {
            annotationView = [[CalloutAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        
        CalloutAnnotation *calloutAnnotation = (CalloutAnnotation *)annotation;
        arrTitle = [calloutAnnotation.title componentsSeparatedByString:@":"];
        ((CalloutAnnotationView *)annotationView).title = arrTitle[0];
        ((CalloutAnnotationView *)annotationView).subTitle = calloutAnnotation.subTitle;
        ((CalloutAnnotationView *)annotationView).delegate = self;
        [annotationView setNeedsDisplay];
        
        [annotationView setCenterOffset:CGPointMake(0, -130)];
        // Move the display position of MapView.
        [UIView animateWithDuration:0.5f
                         animations:^(void) {
                             mapView.centerCoordinate = calloutAnnotation.coordinate;
                         }];
    }
    
    annotationView.annotation = annotation;
    return annotationView;
}

- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
    UIView *view = self.mapEvent.subviews.firstObject;
    //  Look through gesture recognizers to determine whether this region change is from user interaction
    for(UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
            return YES;
        }
    }
    
    return NO;
}


- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    mapChangedFromUserInteraction = [self mapViewRegionDidChangeFromUserInteraction];
    
    if (mapChangedFromUserInteraction) {
        // user changed map region
        // regionWillChangeAnimatedCalled = YES;
        // regionChangedBecauseAnnotationSelected = NO;
        // NSLog(@"First Call");
    }
    
}
#define MERCATOR_RADIUS 85445659.44705395
#define MAX_GOOGLE_LEVELS 20
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    if(strNextPageToken == nil)
//    {
//        NSLog(@"Filter are enabled can't refresh data");
//    }
//    else
//    {
        float width = mapView.visibleMapRect.size.width;
        int ZoomFactor =log2(width)-9;
        //NSLog(@"Zoomfactor is %d",ZoomFactor);
        if(ZoomFactor <3)
        {
            NSLog(@"Zooming a particular Annotation");
        }
        else
        {
            if (mapChangedFromUserInteraction) {
                NSLog(@"Pressed");
                double lat = mapView.centerCoordinate.latitude;
                double lng = mapView.centerCoordinate.longitude;
                CLLocation *mapLocation = [[CLLocation alloc]initWithLatitude:mapCoordinates.latitude longitude:mapCoordinates.longitude];
                CLLocation *mapCurrentLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
                CLLocationDistance distance = ([mapLocation distanceFromLocation:mapCurrentLocation])* 0.000621371192;
                if(distance > 1.00)
                {
                    NSLog(@"API Calling");
                    CLLocationCoordinate2D draggedMapviewCoordinate;
                    draggedMapviewCoordinate.latitude = mapView.centerCoordinate.latitude;
                    draggedMapviewCoordinate.longitude = mapView.centerCoordinate.longitude;
                    [self callGoogleAPIWhenMapIsBeingSwiped:draggedMapviewCoordinate];
                    mapCoordinates.latitude = mapView.centerCoordinate.latitude;
                    mapCoordinates.longitude = mapView.centerCoordinate.longitude;
                }
            }
        }

    
}
/*
 // [mapView setRegion:MKCoordinateRegionMake(draggedMapviewCoordinate, MKCoordinateSpanMake(0.01f, 0.01f))animated:YES];
 if (!regionChangedBecauseAnnotationSelected) //note "!" in front
 {
 //reload (add/remove) annotations here...
 CLLocationCoordinate2D draggedMapviewCoordinate;
 draggedMapviewCoordinate.latitude = mapView.centerCoordinate.latitude;
 draggedMapviewCoordinate.longitude = mapView.centerCoordinate.longitude;
 // [mapView setRegion:MKCoordinateRegionMake(draggedMapviewCoordinate, MKCoordinateSpanMake(0.01f, 0.01f))animated:YES];
 [self callWhenMapIsBeingSwiped:draggedMapviewCoordinate];
 }
 
 //reset flags...
 regionWillChangeAnimatedCalled = NO;
 regionChangedBecauseAnnotationSelected = NO;
 NSLog(@"Third Call");*/

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    // regionChangedBecauseAnnotationSelected = regionWillChangeAnimatedCalled;
    if ([view.annotation isKindOfClass:[PinAnnotation class]]) {
        // Selected the pin annotation.
        CalloutAnnotation *calloutAnnotation = [[CalloutAnnotation alloc] init];
        
        PinAnnotation *pinAnnotation = ((PinAnnotation *)view.annotation);
        calloutAnnotation.title = pinAnnotation.title;
        calloutAnnotation.subTitle = pinAnnotation.subTitle;
        selectedIndex=pinAnnotation.index;
        calloutAnnotation.coordinate = pinAnnotation.coordinate;
        pinAnnotation.calloutAnnotation = calloutAnnotation;
        [mapView addAnnotation:calloutAnnotation];
    }
}

//---------------------------------------------------------------

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[PinAnnotation class]]) {
        // Deselected the pin annotation.
        PinAnnotation *pinAnnotation = ((PinAnnotation *)view.annotation);
        
        [mapView removeAnnotation:pinAnnotation.calloutAnnotation];
        
        pinAnnotation.calloutAnnotation = nil;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([Singlton sharedManager].arrFiltersForData == nil)
    {
        [Singlton sharedManager].arrFiltersForData = [NSMutableArray new];
        [[Singlton sharedManager].arrFiltersForData addObject:@"All Venues"];
        if(arrVenues.count>0)
        {
            [self ApplyKonnectFilters];
        }
    }
    else if([Singlton sharedManager].arrFiltersForData.count>0)
    {
        if(arrVenues.count>0)
        {
            [self ApplyKonnectFilters];
        }
    }
    else
    {
        if([Singlton sharedManager].arrKonnectVenues.count>0)
        {
            [self CallIteratingthroughKonnectVenues];
        }
        else
        {
            [self CallIteratingthroughNonKonnectVenues];
        }
        
    }
    
    
}

#pragma mark - Check user has login for the first time and show edit profile screen

-(void)UpdateFirstTimeLogin:(NSString *)strUserId
{
    
    if([[[NSUserDefaults standardUserDefaults]valueForKey:@"isFirstTimeLogin"]isEqualToString:@"YES"])
    {
        _viewEditProfile.hidden = NO;
        [self.view bringSubviewToFront:_viewEditProfile];
        AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
        AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
        AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
        
        hashKeyValue.S = strUserId;
        updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_User" : @"User";
        updateInput.key = @{ @"UserId" : hashKeyValue};
        
        AWSDynamoDBAttributeValue *newPrice8 = [AWSDynamoDBAttributeValue new];
        newPrice8.S = @"NO";
        AWSDynamoDBAttributeValueUpdate *valueUpdate8 = [AWSDynamoDBAttributeValueUpdate new];
        valueUpdate8.value = newPrice8;
        valueUpdate8.action = AWSDynamoDBAttributeActionPut;
        updateInput.attributeUpdates = @{@"isFirstTimeLogin":valueUpdate8};
        updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
        
        [[dynamoDB updateItem:updateInput]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[Singlton sharedManager]killHUD];
                     [[Singlton sharedManager] alert:self title:Message message:@"Please try again"];
                     self.view.userInteractionEnabled = YES;
                 });
                 NSLog(@"The request failed. Error: [%@]", task.error);
             }
             if (task.result) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[Singlton sharedManager]killHUD];
                     [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:@"isFirstTimeLogin"];
                     self.view.userInteractionEnabled = YES;
                 });
                 
                 
                 
             }
             return nil;
         }];
        
    }
    else
    {
        
    }
}
#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==0) {
        return arrListCity.count;
    }
    else
    {
        return arrVenues.count;
    }
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedIndex = indexPath.row;
    if (tableView.tag==0) {
        _txthomeLoc.text = [arrListCity objectAtIndex:indexPath.row];
        tblAutoComplete.hidden = YES;
    }
    else
    {
        [Singlton sharedManager].dictVenueInfo = [arrVenues objectAtIndex:indexPath.row];
        
        if ([[arrVenues objectAtIndex:indexPath.row]valueForKey:@"Konnect"])
        {
            
            ConsumerVenueDetailVC *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerVenueDetailVC"];
            [self.navigationController pushViewController:ivc animated:YES];
            
        }
        else
        {
            NonKonnectViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"NonKonnectViewController"];
            [self.navigationController pushViewController:ivc animated:YES];
        }
        
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (tableView.tag==0) {
        return 44;
    }
    else
    {
        return 227;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==0) {
        static NSString *CellIdentifier = @"Cell";
        EditProfileAutoFillCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[EditProfileAutoFillCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.lblAddress.text = [arrListCity objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        EventTableViewCell *cell = (EventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell.imgVenue setImage:nil];
        cell.imgVenue.contentMode = UIViewContentModeScaleAspectFit;
        cell.imgVenue.backgroundColor = [UIColor blackColor];
        if([[arrVenues objectAtIndex:indexPath.row] valueForKey:@"photos"])
        {
            NSString *strPhoto = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?photoreference=%@&sensor=false&maxheight=300&maxwidth=1000&key=%@",[[[[arrVenues objectAtIndex:indexPath.row] valueForKey:@"photos"] objectAtIndex:0] valueForKey:@"photo_reference"],GoogleApiKey];
            [cell.imgVenue sd_setImageWithURL:[NSURL URLWithString:strPhoto] placeholderImage:[UIImage imageNamed:@"EventIcon"]];
        }
        else
        {
            [cell.imgVenue setImage:[UIImage imageNamed:@"EventIcon"]];
        }
        cell.rateStarView.allowsHalfStars = YES;
        if ([[arrVenues objectAtIndex:indexPath.row] valueForKey:@"averageRating"])
        {
            cell.rateStarView.value = [NSString stringWithFormat:@"%@",[[arrVenues objectAtIndex:indexPath.row] valueForKey:@"averageRating"]].doubleValue;
            cell.rateStarView.hidden = NO;
        }
        else
        {
            cell.rateStarView.value = @"0".doubleValue;
            cell.rateStarView.hidden = YES;
        }
        cell.rateStarView.userInteractionEnabled = NO;
        cell.lblVenueName.text = [[arrVenues objectAtIndex:indexPath.row] valueForKey:@"name"];
        cell.lblAddress.text = [[arrVenues objectAtIndex:indexPath.row] valueForKey:@"vicinity"];
        cell.lblDistance.text = [[arrVenues objectAtIndex:indexPath.row] valueForKey:@"DistanceInMiles"];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==0) {
    }
    else
    {
        NSInteger sectionsAmount = [tableView numberOfSections];
        NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
        if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
            // This is the last cell in the table
            NSLog(@"end of the table");
            [self call_GoogleAPI_For_Next_Results];
        }
    }
    
}


#pragma mark - Calculate distance between two Lat Long

- (NSString *) calculateDistanceByLocation:(CLLocation*)location
{
    
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:[Singlton sharedManager].latitude longitude:[Singlton sharedManager].longitude];
    return [NSString stringWithFormat:@"%.02f MI",[location distanceFromLocation:location2]*0.000621371];
    
}

#pragma mark - Call google API for next results when we scroll tableView

-(void)call_GoogleAPI_For_Next_Results
{
    if(strNextPageToken == nil)
    {
        NSLog(@"strtoken is %@",strNextPageToken);
    }
    else
    {
        [[Singlton sharedManager]showHUD];
        NSString *strRequestParams = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=1000&types=bar&key=%@&pagetoken=%@",[Singlton sharedManager].latitude,[Singlton sharedManager].longitude,GoogleApiKey,strNextPageToken];
        strRequestParams = [strRequestParams stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
        
        NSURL *url = [NSURL URLWithString:strRequestParams];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        [request setHTTPMethod:@"GET"];
        
        NSError *error;
        NSURLResponse *response;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Singlton sharedManager]killHUD];
            });
            
        }
        
        NSString *respString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] ;
        NSData *data = [respString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *responseObject = [[NSMutableDictionary alloc]init];
        responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(responseObject)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Singlton sharedManager]killHUD];
                if([[responseObject valueForKey:@"status"]isEqualToString:@"INVALID_REQUEST"])
                {
                    NSLog(@"No more records available");
                }
                else
                {
                    
                    [arrVenues addObjectsFromArray:[responseObject valueForKey:@"results"]];
                    NSArray *arrNoDuplicates = [[NSSet setWithArray: arrVenues] allObjects];
                    [arrVenues removeAllObjects];
                    [arrVenues addObjectsFromArray:[arrNoDuplicates mutableCopy]];
                    strNextPageToken=[responseObject valueForKey:@"next_page_token"];
                    [Singlton sharedManager].strNextPageTempToken = [responseObject valueForKey:@"next_page_token"];
                    isArrayEmpty = NO;
                    if([Singlton sharedManager].arrKonnectVenues.count > 0)
                    {
                        [self CallIteratingthroughKonnectVenues];
                        
                    }
                    else
                    {
                        [self CallIteratingthroughNonKonnectVenues];
                        
                    }
                }
                
            });
        }
    }
}

- (void)willShowLeftView:(nonnull UIView *)leftView sideMenuController:(nonnull LGSideMenuController *)sideMenuController
{
    
}
- (void)didShowLeftView:(nonnull UIView *)leftView sideMenuController:(nonnull LGSideMenuController *)sideMenuController
{
    
}
- (void)willHideLeftView:(nonnull UIView *)leftView sideMenuController:(nonnull LGSideMenuController *)sideMenuController
{
    
}
- (void)didHideLeftView:(nonnull UIView *)leftView sideMenuController:(nonnull LGSideMenuController *)sideMenuController
{
    
}
- (void)showAnimationsForLeftView:(nonnull UIView *)leftView sideMenuController:(nonnull LGSideMenuController *)sideMenuController duration:(NSTimeInterval)duration
{
    
}
- (void)hideAnimationsForLeftView:(nonnull UIView *)leftView sideMenuController:(nonnull LGSideMenuController *)sideMenuController duration:(NSTimeInterval)duration
{
    
}
- (void)setLeftViewEnabledWithWidth:(CGFloat)width
                  presentationStyle:(LGSideMenuPresentationStyle)presentationStyle
               alwaysVisibleOptions:(LGSideMenuAlwaysVisibleOptions)alwaysVisibleOptions
{
    
}

#pragma mark - IBAction Methods
- (IBAction)clickButton:(UIButton *)sender {
    
    sender.selected=!sender.selected;
    
}
- (IBAction)actionSwitchView:(UIButton*)sender {
    if([sender tag]==0){
        [btnMap setImage:[UIImage imageNamed:@"MapUnselected"] forState:UIControlStateNormal];
        [btnList setImage:[UIImage imageNamed:@"ListViewSelected"] forState:UIControlStateNormal];
        [_tblEvent reloadData];
        _tblEvent.hidden = NO;
        _mapEvent.hidden = YES;
    }
    else
    {
        [btnList setImage:[UIImage imageNamed:@"ListViewUnselected"] forState:UIControlStateNormal];
        [btnMap setImage:[UIImage imageNamed:@"MapSelectedIcon"] forState:UIControlStateNormal];
        [self loadMapView];
        _tblEvent.hidden = YES;
        _mapEvent.hidden = NO;
    }
}
- (IBAction)actionFirstTime:(UIButton *)sender
{
    if([sender tag] == 0)
    {
        [self performSelector:@selector(HideView) withObject:self afterDelay:0.5 ];
        EditProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        _viewLoginFirstTime.hidden = YES;
    }
    
}
- (IBAction)clickFilterIcon:(id)sender {
    FilterViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterViewController"];
    [self.navigationController pushViewController:ivc animated:YES];
}

-(void)HideView
{
    _viewLoginFirstTime.hidden = YES;
}

#pragma mark - Custome method
- (IBAction)didChangeValue:(HCSStarRatingView *)sender {
    NSLog(@"Changed rating to %.1f", sender.value);
}


-(void)UpdateProfile:(NSString *)strUserId
{
    strLong =[NSString stringWithFormat:@"%f",[Singlton sharedManager].longitude];
    strLat = [NSString stringWithFormat:@"%f",[Singlton sharedManager].latitude];
    if([strLong isEqualToString:@""] || [strLat isEqualToString:@""])
    {
        strLong = @"75.8577";
        strLat = @"22.7196";
    }
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
    AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    
    hashKeyValue.S = strUserId;
    updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_User" : @"User";
    updateInput.key = @{ @"UserId" : hashKeyValue };
    //FirstName
    AWSDynamoDBAttributeValue *newPrice = [AWSDynamoDBAttributeValue new];
    newPrice.S = _txtfirstName.text.capitalizedString;
    AWSDynamoDBAttributeValueUpdate *valueUpdate = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate.value = newPrice;
    valueUpdate.action = AWSDynamoDBAttributeActionPut;
    
    
    //LastName
    AWSDynamoDBAttributeValue *newPrice2 = [AWSDynamoDBAttributeValue new];
    newPrice2.S = _txtlastName.text.capitalizedString;
    AWSDynamoDBAttributeValueUpdate *valueUpdate2 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate2.value = newPrice2;
    valueUpdate2.action = AWSDynamoDBAttributeActionPut;
    
    
    //Lattitude
    AWSDynamoDBAttributeValue *newPrice3 = [AWSDynamoDBAttributeValue new];
    newPrice3.S = strLat;
    AWSDynamoDBAttributeValueUpdate *valueUpdate3 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate3.value = newPrice3;
    valueUpdate3.action = AWSDynamoDBAttributeActionPut;
    
    
    //Longitude
    AWSDynamoDBAttributeValue *newPrice4 = [AWSDynamoDBAttributeValue new];
    newPrice4.S = strLong;
    AWSDynamoDBAttributeValueUpdate *valueUpdate4 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate4.value = newPrice4;
    valueUpdate4.action = AWSDynamoDBAttributeActionPut;
    
    
    //UpdatedAt
    AWSDynamoDBAttributeValue *newPrice5 = [AWSDynamoDBAttributeValue new];
    newPrice5.S = [NSString stringWithFormat:@"%@",NumberCreatedAt];
    AWSDynamoDBAttributeValueUpdate *valueUpdate5 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate5.value = newPrice5;
    valueUpdate5.action = AWSDynamoDBAttributeActionPut;
    
    
    //UserImage
    AWSDynamoDBAttributeValue *newPrice6 = [AWSDynamoDBAttributeValue new];
    newPrice6.S = strImageName;
    AWSDynamoDBAttributeValueUpdate *valueUpdate6 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate6.value = newPrice6;
    valueUpdate6.action = AWSDynamoDBAttributeActionPut;
    
    //HomeLOc
    AWSDynamoDBAttributeValue *newPrice7 = [AWSDynamoDBAttributeValue new];
    newPrice7.S = _txthomeLoc.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdate7 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate7.value = newPrice7;
    valueUpdate7.action = AWSDynamoDBAttributeActionPut;
    
    //FBProfilePicChanged
    AWSDynamoDBAttributeValue *newPrice8 = [AWSDynamoDBAttributeValue new];
    newPrice8.S = @"YES";
    AWSDynamoDBAttributeValueUpdate *valueUpdate8 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate8.value = newPrice8;
    valueUpdate8.action = AWSDynamoDBAttributeActionPut;
    updateInput.attributeUpdates = @{@"Firstname": valueUpdate,@"Lastname":valueUpdate2,@"Latitude":valueUpdate3,@"Longitude":valueUpdate4,@"UpdatedAt":valueUpdate5,@"UserImage":valueUpdate6,@"HomeLocation":valueUpdate7,@"FBProfilePicChanged":valueUpdate8};
    
    updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
    
    [[dynamoDB updateItem:updateInput]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
             });
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
                 [dictUserInfo setObject:_txtfirstName.text forKey:@"firstName"];
                 [dictUserInfo setObject:strImageName forKey:@"UserImage"];
                 [dictUserInfo setObject:_txtlastName.text forKey:@"lastName"];
                 [dictUserInfo setObject:_txthomeLoc.text forKey:@"HomeLocation"];
                 [[NSUserDefaults standardUserDefaults]setObject:dictUserInfo forKey:@"loginUser"];
                 [[NSUserDefaults standardUserDefaults]setObject:UIImagePNGRepresentation(_imgUserPic.image) forKey:@"localUserImage"];
                 [[NSNotificationCenter defaultCenter]
                  postNotificationName:@"UpdateValues"
                  object:self];
                 // [self UpdateVenueRatingUserNameInfo:[NSString stringWithFormat:@"%@ %@",_txtfirstName.text,_txtlastName.text] AndUserId:strUserId];
                 _viewEditProfile.hidden = YES;
                 self.view.userInteractionEnabled = YES;
             });
             
             
             
         }
         return nil;
     }];
    
}

-(void)UpdateVenueRatingUserNameInfo:(NSString *)strUserName AndUserId:(NSString *)strUserId
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
        AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
        AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
        hashKeyValue.S = strUserId;
        updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_VenueRating" : @"VenueRating";
        updateInput.key = @{ @"UserId" : hashKeyValue };
        //FirstName
        AWSDynamoDBAttributeValue *newPrice = [AWSDynamoDBAttributeValue new];
        newPrice.S = strUserName.capitalizedString;
        AWSDynamoDBAttributeValueUpdate *valueUpdate = [AWSDynamoDBAttributeValueUpdate new];    valueUpdate.value = newPrice;
        valueUpdate.action = AWSDynamoDBAttributeActionPut;
        updateInput.attributeUpdates = @{@"UserName": valueUpdate
                                         };
        updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
        [[dynamoDB updateItem:updateInput]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[Singlton sharedManager]killHUD];
                     self.view.userInteractionEnabled = YES;
                     NSLog(@"The request failed. Error: [%@]", task.error);
                 });
                 
             }
             if (task.result) {
                 [[Singlton sharedManager]killHUD];
                 NSLog(@"Updated Successfully");
                 
             }
             return nil;
             
         }];
    });
}
- (IBAction)actionGotoSearchScreen:(id)sender
{
    SearchByEventandVenueViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchByEventandVenueViewController"];
    [self.navigationController pushViewController:ivc animated:YES];
}
@end

