//
//  ProfilePostImageCell.h
//  Konnect
//
//  Created by Simpalm_mac on 28/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfilePostImageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgUserPostCell;
@property (weak, nonatomic) IBOutlet UILabel *imgUserNameCell;
@property (weak, nonatomic) IBOutlet UILabel *imgUserLocationCell;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeCell;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UIImageView *imgPostImageCell;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalCommentCell;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@end
