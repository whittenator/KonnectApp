//
//  VenueNotificationViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VenueNotificationViewController.h"
#import "ProfileSetupViewController.h"
#import "UIImageView+WebCache.h"
@interface VenueNotificationViewController ()
{
    NSMutableDictionary *dicuserPorfile;
}
@end

@implementation VenueNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    viewContainerProfile.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewContainerProfile.layer.borderWidth = 0.5f;
    
    viewContainerNotifications.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewContainerNotifications.layer.borderWidth = 0.5f;
    
    
    dicuserPorfile = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserProfile"];
    
    [imgProfile sd_setImageWithURL:[dicuserPorfile valueForKey:@"UserImage"]
                      placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                               options:SDWebImageRefreshCached];
    
    LbluserName.text = [dicuserPorfile valueForKey:@"UserName"];

    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)ClickSwitch:(id)sender {
}

- (IBAction)clickChangePassword:(id)sender {
}
- (IBAction)clickProfile:(id)sender
{
    ProfileSetupViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileSetupViewController"];
    Vc.StrTextCheck = @"Notification";
    [self.navigationController pushViewController:Vc animated:YES];
}
@end
