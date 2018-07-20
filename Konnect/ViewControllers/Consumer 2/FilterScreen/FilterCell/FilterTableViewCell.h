//
//  FilterTableViewCell.h
//  Konnect
//
//  Created by Simpalm_mac on 29/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblFilterType;
@property (weak, nonatomic) IBOutlet UIButton *btnFilterType;
@property (weak, nonatomic) IBOutlet UIImageView *imgFilter;
@property (weak, nonatomic) IBOutlet UIButton *btnFilterType2;
@end
