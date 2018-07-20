//
//  ReviewsViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 04/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tblReviews;
- (IBAction)actionBack:(id)sender;

@end
