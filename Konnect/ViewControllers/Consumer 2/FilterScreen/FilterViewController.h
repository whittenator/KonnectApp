//
//  FilterViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 29/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
NSMutableArray *arrTableData;
}
@property (weak, nonatomic) IBOutlet UITableView *tblFilterData;
- (IBAction)actionApplyFilter:(id)sender;
- (IBAction)actionBack:(id)sender;
@end
