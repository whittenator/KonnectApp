//
//  SearchByEventandVenueViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 29/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "BaseVC.h"

@interface SearchByEventandVenueViewController : BaseVC<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *arrTableData;
}

- (IBAction)actionBack:(id)sender;
@property(weak,nonatomic)IBOutlet UITableView *tblVenueNEventNSearch;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@end
