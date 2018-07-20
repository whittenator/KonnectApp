//
//  ConsumerNotificationCell.h
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsumerNotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgUSer;
@property (weak, nonatomic) IBOutlet UIImageView *imgEvent;
@property (weak, nonatomic) IBOutlet UILabel *lblNotiHead;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblNotiDes;
@property (weak, nonatomic) IBOutlet UIButton *btnFollow;
@property (weak, nonatomic) IBOutlet UIButton *btnGotoProfile;

@end
