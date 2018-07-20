//
//  VenueOwnerCommentViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 09/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueOwnerCommentViewController : UIViewController
{
    
     __weak IBOutlet UILabel *lblAlert;
     __weak IBOutlet UIButton *btnDelete;
}
@property (weak, nonatomic) IBOutlet UITableView *tblComment;
@property (weak, nonatomic) NSString *strPostId;
@property (weak, nonatomic) NSString *strChek;
@property (nonatomic,weak) NSString *strNavigationCheck;
@property (weak, nonatomic) NSString *strEventName;
@property (weak, nonatomic) NSDictionary *dicPostDetails;
-(IBAction)clickButtons:(id)sender;
-(IBAction)clickDeleteBtn:(id)sender;
@end
