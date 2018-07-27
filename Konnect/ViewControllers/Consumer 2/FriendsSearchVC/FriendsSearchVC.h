//
//  FriendsSearchVC.h
//  Konnect
//
//  Created by Travis Whitten on 7/26/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface FriendsSearchVC : BaseVC<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *arrTableData;
}

-(IBAction)actionBack:(id)sender;
@property(weak,nonatomic)IBOutlet UITableView *tblFriendSearch;
@property(weak,nonatomic)IBOutlet UITextField *txtSearch;

@property NSMutableArray *arrayUsers;

@end
