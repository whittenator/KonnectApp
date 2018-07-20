//
//  ConsumerSettingsViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsumerSettingsViewController : UIViewController
{
    __weak IBOutlet UIView *viewContainerNotifications;
    __weak IBOutlet UIView *viewContainerProfile;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;

-(IBAction)gotoEditProfile:(id)sender;
-(IBAction)gotoChangePassword:(id)sender;
- (IBAction)actionNotiOnOrOff:(id)sender;
@end
