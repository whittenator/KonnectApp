//
//  VOHomeViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 19/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "LGSideMenuController.h"
#import <MapKit/MapKit.h>
#import "PinAnnotation.h"
#import "CalloutAnnotationView.h"
@interface VOHomeViewController : BaseVC<LGSideMenuDelegate,CalloutAnnotationViewDelegate,MKMapViewDelegate>
{
    
    __weak IBOutlet UIView *viewSlider;
    __weak IBOutlet UITextField *txtSearch;
    __weak IBOutlet UIButton *btnList;
    __weak IBOutlet UIButton *btnMap;
    __weak IBOutlet UITableView *tblAutoComplete;
    NSMutableArray *arrVenues;
    NSString *strNextPageToken;
    float latitude;
    float longitude;
    
}
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapEvent;
@property (weak, nonatomic) IBOutlet UIView *viewNavigationBar;
@property (weak, nonatomic) IBOutlet UIView *viewEditProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnGotoProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@property (weak, nonatomic) IBOutlet UITableView *tblEvent;
@property (weak, nonatomic) IBOutlet UIView *viewLoginFirstTime;
@property (weak, nonatomic) IBOutlet UITextField *txtfirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtlastName;
@property (weak, nonatomic) IBOutlet UITextField *txthomeLoc;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserPic;
- (IBAction)actionChoosePic:(id)sender;
- (IBAction)funcSave:(id)sender;
- (IBAction)funcBackk:(id)sender;
- (IBAction)actionSwitchView:(id)sender;
- (IBAction)actionFirstTime:(id)sender;
- (IBAction)clickFilterIcon:(id)sender;
- (IBAction)actionGotoSearchScreen:(id)sender;





@end

