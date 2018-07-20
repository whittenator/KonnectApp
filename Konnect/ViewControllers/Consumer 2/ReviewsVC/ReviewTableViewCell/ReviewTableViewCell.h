//
//  ReviewTableViewCell.h
//  Konnect
//
//  Created by Simpalm_mac on 04/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *imgUserName;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *viewRating;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnGotoProfile;

@end
