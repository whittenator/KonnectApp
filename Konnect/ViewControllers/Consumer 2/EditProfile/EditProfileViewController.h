//
//  EditProfileViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 29/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "BaseVC.h"
#import <CoreLocation/CoreLocation.h>
@interface EditProfileViewController : BaseVC<UITableViewDelegate,UITableViewDataSource>
{
    float latitude;
    float longitude;
}
@property (weak, nonatomic) IBOutlet UITableView *tblAutoFill;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtHomeLoc;
@property (weak, nonatomic) IBOutlet UITextField *txtBio;

@property (weak, nonatomic) IBOutlet UIImageView *imgUserPic;
@property (weak, nonatomic) IBOutlet UIButton *btnUserPic;
@property (nonatomic,strong) CLLocationManager *locationManager;
- (IBAction)actionChoosePic:(id)sender;
- (IBAction)funcSave:(id)sender;
- (IBAction)funcBack:(id)sender;

@end
