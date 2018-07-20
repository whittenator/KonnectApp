//
//  EventTableViewCell.h
//  Konnect
//
//  Created by Balraj Randhawa on 21/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface EventTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet HCSStarRatingView *rateStarView;
@property (weak, nonatomic) IBOutlet AsyncImageView *imgVenue;
@property (weak, nonatomic) IBOutlet UILabel *lblVenueName;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@end
