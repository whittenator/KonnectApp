//
//  VenueNotificationViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueNotificationViewController : UIViewController
{
    
    __weak IBOutlet UIView *viewContainerNotifications;
    __weak IBOutlet UIView *viewContainerProfile;
    __weak IBOutlet UIImageView *imgProfile;
    __weak IBOutlet UILabel *LbluserName;
}
- (IBAction)ClickSwitch:(id)sender;
- (IBAction)clickChangePassword:(id)sender;
- (IBAction)clickProfile:(id)sender;

@end
