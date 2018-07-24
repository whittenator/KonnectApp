//
//  FriendsCell.h
//  Konnect
//
//  Created by Simpalm_mac on 17/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsCell : UITableViewCell
@property(weak,nonatomic)IBOutlet UIImageView *imgUser;
@property(weak,nonatomic)IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnGoToProfile;
@end
