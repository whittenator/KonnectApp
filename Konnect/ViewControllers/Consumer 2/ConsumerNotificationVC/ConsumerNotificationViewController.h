//
//  ConsumerNotificationViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsumerNotificationViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
     NSMutableArray *arrTableData;
}
@property (weak, nonatomic) IBOutlet UITableView *tblNotifications;
@property (weak, nonatomic) IBOutlet UILabel *lblNoNotifications;

@end
