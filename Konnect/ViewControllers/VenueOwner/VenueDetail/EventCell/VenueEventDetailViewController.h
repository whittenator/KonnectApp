//
//  VenueEventDetailViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 03/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueEventDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    
    __weak IBOutlet UILabel *lblEventName;
    __weak IBOutlet UITableView *tblEvent;
    __weak IBOutlet UIView *viewSlider;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UILabel *lblDescription;
    __weak IBOutlet UILabel *lblEventType;
    __weak IBOutlet UILabel *lblHours;
    __weak IBOutlet UILabel *lblDate;
    __weak IBOutlet UILabel *lblAlert;
   __weak IBOutlet  UILabel *lblEventCheckIn;
    __weak IBOutlet UIImageView *imgEvent;
    __weak IBOutlet UICollectionView *collectionSpecial;
    __weak IBOutlet NSLayoutConstraint *lblDescriptionHeight;
    
    __weak IBOutlet UIImageView *imgLine;
    __weak IBOutlet UIImageView *imgLine1;
    
}
@property (weak, nonatomic) NSDictionary *dicEventDetail;
@end
