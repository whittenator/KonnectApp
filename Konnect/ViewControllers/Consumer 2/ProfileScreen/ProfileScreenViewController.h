//
//  ProfileScreenViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 28/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileUserSelfInfoCell.h"
#import "ProfilePostImageCell.h"
@interface ProfileScreenViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
  NSMutableArray *arrTableData;
  NSMutableDictionary *dictSelfProfile;
    //IBOutlet UILabel *lblAlert;
}
@property(weak,nonatomic)IBOutlet UITableView *tblProfile;
@property(strong,nonatomic) NSMutableDictionary *dictUserProfile;
//@property (weak, nonatomic) IBOutlet UIImageView *imgUserBackground;
@property (weak, nonatomic) IBOutlet UIButton *btnEditProfile;
//@property (weak, nonatomic) IBOutlet UIImageView *imgEditProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserImage;
@property (weak, nonatomic) IBOutlet UILabel *lblFollowers;
@property (weak, nonatomic) IBOutlet UILabel *followingsTextLbl;
@property (weak, nonatomic) IBOutlet UILabel *followersTextLbl;
@property (weak, nonatomic) IBOutlet UILabel *lblFollowing;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *editProfileBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
@property (weak, nonatomic) IBOutlet UILabel *bioLbl;

//@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
//@property (weak, nonatomic) IBOutlet UIImageView *imgLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
//@property (weak, nonatomic) IBOutlet UIButton *btnHameBurgerIcon;
//@property (weak, nonatomic) IBOutlet UIView *viewLocation;

-(IBAction)actionBack:(id)sender;
@end
