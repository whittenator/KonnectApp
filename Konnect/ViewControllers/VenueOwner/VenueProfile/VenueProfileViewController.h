//
//  VenueProfileViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 12/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIImagePager.h"
@interface VenueProfileViewController : UIViewController<KIImagePagerDelegate,KIImagePagerDataSource>
@property (nonatomic,strong) IBOutlet UITableView *tblVenueDetails;

-(IBAction)clickEditEvent:(id)sender;
@end
