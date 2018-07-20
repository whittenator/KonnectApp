//
//  ConsumerVenueEventDetailVC.h
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ViewController.h"

@interface ConsumerVenueEventDetailVC : UIViewController
{
    UIImagePickerController *ipc;
    __weak IBOutlet UILabel *lblEventName;
    __weak IBOutlet UITableView *tblEvent;
    __weak IBOutlet UIView *viewSlider;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UILabel *lblDescription;
    __weak IBOutlet UILabel *lblEventType;
    __weak IBOutlet UILabel *lblHours;
    __weak IBOutlet UILabel *lblEveDay;
    __weak IBOutlet UIButton *btnFood;
    __weak IBOutlet UIButton *btnDJ;
    __weak IBOutlet UIButton *btnNonVeg;
    __weak IBOutlet UIButton *btnBeer;
    __weak IBOutlet UIImageView *imgEvent;
    
    __weak IBOutlet UIImageView *imgLine1;
    __weak IBOutlet UIImageView *imgLine2;
    
    __weak IBOutlet UILabel *lblAlert;
    __weak IBOutlet UICollectionView *collectionSpecial;
    float latitude;
    float longitude;
}
@property (nonatomic,strong) NSDictionary *dicVenueEventCheckIn;
@property (nonatomic,strong) NSDictionary *dicEventDetails;
@property (nonatomic,strong) NSDictionary *dicVenueDetails;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,weak)IBOutlet UIView *viewBox;
@property(nonatomic,weak)IBOutlet UIView *viewBox1;
@property (nonatomic,strong) NSString *strEventId;
@property NSString *strComingFromNotScreen;
-(IBAction)actionHideBox:(id)sender;

@end
