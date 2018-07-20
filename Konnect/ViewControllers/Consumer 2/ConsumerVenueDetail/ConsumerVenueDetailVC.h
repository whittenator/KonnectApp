//
//  ConsumerVenueDetailVC.h
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIImagePager.h"
@interface ConsumerVenueDetailVC : UIViewController<KIImagePagerDelegate,KIImagePagerDataSource,UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray *arrVenueDetail;
    __weak IBOutlet UILabel *lblEventName;
    __weak IBOutlet UIImageView *imgVenue;
    __weak IBOutlet UILabel *lblDistance;
    __weak IBOutlet UITableView *tblEvent;
    __weak IBOutlet UIView *viewSlider;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UILabel *lblAddress;
    __weak IBOutlet UILabel *lblRateUsersCount;
    __weak IBOutlet UILabel *lblEventType;
    __weak IBOutlet UILabel *lblHours;
    __weak IBOutlet UILabel *lblCheckInHeading;
    __weak IBOutlet UILabel *lblTableEvents;
    __weak IBOutlet UIButton *btnFood;
    __weak IBOutlet UIButton *btnDJ;
    __weak IBOutlet UIButton *btnNonVeg;
    __weak IBOutlet UIButton *btnBeer;
    __weak IBOutlet UIButton *btnCheckIn;
    __weak IBOutlet UIView *viewContainer;//scrollHorizontal
    __weak IBOutlet UIScrollView *scrollHorizontal;
    IBOutlet KIImagePager *_imagePager;
    float latitude;
    float longitude;
    
}
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionSpecial;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *rateStarView;
@property (weak, nonatomic) IBOutlet UITableView *tblVenueDetail;
@property (weak, nonatomic) IBOutlet UIImageView *imgLine;
-(IBAction)actionGoToVenueCommentScreen:(id)sender;
@end

