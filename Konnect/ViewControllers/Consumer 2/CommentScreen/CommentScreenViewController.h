//
//  CommentScreenViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 29/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "BaseVC.h"
#import "CommentCell/CommentTableViewCell.h"
#import "HPGrowingTextView.h"
@interface CommentScreenViewController : BaseVC<UITableViewDataSource,UITableViewDelegate,HPGrowingTextViewDelegate>
{

    HPGrowingTextView *textView;
    IBOutlet UILabel *lblAlert;
}
- (IBAction)funcBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet  HPGrowingTextView *txtComment;
@property (weak, nonatomic) IBOutlet UITableView *tblComment;
@property (weak, nonatomic) IBOutlet UIButton *btnSendComment;
@property (weak, nonatomic) IBOutlet NSString *strPostId;
@end
