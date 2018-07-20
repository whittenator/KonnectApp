//
//  VenuOwnerViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 26/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenuOwnerViewController : UIViewController
{
    __weak IBOutlet UIImageView *imgUserProfile;
    __weak IBOutlet UILabel *lblAppVersion;
    __weak IBOutlet UILabel *lblUserName;
    __weak IBOutlet UIImageView *imgBackgraound;
}
@property (weak, nonatomic) IBOutlet UITableView *tblMenuItems;

@end
