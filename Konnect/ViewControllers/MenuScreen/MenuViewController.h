//
//  MenuViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 19/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController
{
    
    __weak IBOutlet UIImageView *imgUserProfile;
    __weak IBOutlet UIImageView *imgBackgraound;
    IBOutlet UILabel *lblName;;
}
@property (strong , nonatomic)IBOutlet UITableView *tblMenuItems;
@property (strong , nonatomic)IBOutlet UILabel *lblBuildVersion;

@end
