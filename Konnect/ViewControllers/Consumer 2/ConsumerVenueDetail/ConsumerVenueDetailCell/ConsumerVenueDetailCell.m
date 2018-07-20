//
//  ConsumerVenueDetailCell.m
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ConsumerVenueDetailCell.h"
static CGSize onLoadSize;
@implementation ConsumerVenueDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imgEvent.transform = CGAffineTransformMakeRotation(M_PI_2);
      
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(CGSizeZero.width==onLoadSize.width && CGSizeZero.height==onLoadSize.height)
    {
        onLoadSize=self.contentView.bounds.size;
    }
    self.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.imgEvent.frame = CGRectMake(0, 0, onLoadSize.width, onLoadSize.height);
   
    self.selectedBackgroundView.frame=self.imgEvent.frame;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
