//
//  VenueCheckInViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 09/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueCheckInViewController : UIViewController
{
    __weak IBOutlet UIButton *btnUserProfile;
    __weak IBOutlet UILabel *lblUserName;
    __weak IBOutlet UILabel *lblTime;
}
@property(nonatomic,weak) NSMutableArray *arrCheckInUserList;
@property (weak, nonatomic) IBOutlet UITableView *tblCheckInUsers;

@end
