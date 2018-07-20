//
//  ImageEventTableViewCell.h
//  Konnect
//
//  Created by Balraj Randhawa on 09/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageEventTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imgEvent;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@end
