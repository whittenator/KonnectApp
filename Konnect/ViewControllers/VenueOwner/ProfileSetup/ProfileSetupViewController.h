//
//  ProfileSetupViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 26/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import <CoreLocation/CoreLocation.h>
@interface ProfileSetupViewController : BaseVC
{
    
    __weak IBOutlet UITextField *txtVenueSpecials;
    __weak IBOutlet UITextField *txtVenueEnd;
    __weak IBOutlet UITextField *txtVenueStart;
    __weak IBOutlet UITextField *txtVenuePhoneNo;
    __weak IBOutlet UITextField *txtVenueAddress;
    __weak IBOutlet UITextField *txtVenueName;
    __weak IBOutlet UIScrollView *scrollHorizontal;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIButton *btnBack;
    __weak IBOutlet UIButton *btnSkip;
    __weak IBOutlet UIButton *btnDone;
    __weak IBOutlet UITableView *tblAutoComplete;
     __weak IBOutlet UITableView *tblSecials;
     __weak IBOutlet UIView *viewContainer;
    IBOutlet HCSStarRatingView *rateStarView;
    IBOutlet UIActivityIndicatorView *act;
    __weak IBOutlet UIButton *btnSpecials;
    __weak IBOutlet UICollectionView *collectionSlider;
    
    float latitude;
    float longitude;
    
    
}

@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) NSString *StrTextCheck;
@property (nonatomic,strong) NSString *StrSignupCheck;
-(IBAction)clickButtons:(id)sender;
@end
