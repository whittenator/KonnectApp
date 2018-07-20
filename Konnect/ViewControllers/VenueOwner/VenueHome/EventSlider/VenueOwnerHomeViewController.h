//
//  VenueOwnerHomeViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 28/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIImagePager.h"
@interface VenueOwnerHomeViewController : UIViewController<KIImagePagerDelegate,KIImagePagerDataSource>

{
    __weak IBOutlet NSLayoutConstraint *venuHoursYaxis;
    __weak IBOutlet NSLayoutConstraint *imageSeconfYaxis;
    __weak IBOutlet NSLayoutConstraint *imageFirstYAxis;
    __weak IBOutlet NSLayoutConstraint *venueAddressYAsix;
    __weak IBOutlet UILabel *lblVenueAddress;
    __weak IBOutlet UILabel *lblHours;
    __weak IBOutlet UILabel *lblVenueName;
    __weak IBOutlet UICollectionView *EventCollectionView;
    
    
    IBOutlet KIImagePager *_imagePager;
    IBOutlet UIView *viewContainer;
}
@property (weak, nonatomic) IBOutlet HCSStarRatingView *rateStarView;
@end
