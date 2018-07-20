//
//  VenueEventCollectionViewCell.h
//  Konnect
//
//  Created by Balraj Randhawa on 13/12/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueEventCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblventName;
@property (weak, nonatomic) IBOutlet UILabel *lblEventDate;
@property (weak, nonatomic) IBOutlet UILabel *lblEventTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgEvent;
@end
