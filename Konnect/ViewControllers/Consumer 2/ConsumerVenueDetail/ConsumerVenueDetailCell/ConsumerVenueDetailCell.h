//
//  ConsumerVenueDetailCell.h
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsumerVenueDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblventName;
@property (weak, nonatomic) IBOutlet UILabel *lblEventTime;

@property (nonatomic,strong) IBOutlet UIView *viewEvent;
@property (nonatomic,strong) IBOutlet UIView *lblCenter;
@property (nonatomic,strong) IBOutlet UIImageView *imgEvent;

@end
