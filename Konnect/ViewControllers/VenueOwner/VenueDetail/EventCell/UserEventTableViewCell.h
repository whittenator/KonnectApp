//
//  UserEventTableViewCell.h
//  Konnect
//
//  Created by Balraj Randhawa on 03/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserEventTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgUserProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgEvent;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentNumber;
@property (weak, nonatomic) IBOutlet UIView *viewCircleContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnTotalComents;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;

@end
