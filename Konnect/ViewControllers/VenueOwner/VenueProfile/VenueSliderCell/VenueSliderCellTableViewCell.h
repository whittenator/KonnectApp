//
//  VenueSliderCellTableViewCell.h
//  Konnect
//
//  Created by Balraj Randhawa on 12/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIImagePager.h"
@interface VenueSliderCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet KIImagePager *viewSlider;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end
