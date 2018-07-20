//
//  FriendsListScreenVC.h
//  Konnect
//
//  Created by Simpalm_mac on 17/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import "BaseVC.h"

@interface FriendsListScreenVC : BaseVC<UITableViewDelegate,UITableViewDataSource>
@property(weak,nonatomic)IBOutlet UITableView *tblfriends;
- (IBAction)actionBack:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lblHeading;
@property NSMutableArray *arrayFriends;
@property NSString *strTitle;
@end
