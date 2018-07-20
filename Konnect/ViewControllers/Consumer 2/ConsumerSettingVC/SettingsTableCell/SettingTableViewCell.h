//
//  SettingTableViewCell.h
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnEditProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnChangePassword;

@end
