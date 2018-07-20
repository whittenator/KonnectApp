//
//  ConsumerChekInCell.h
//  Konnect
//
//  Created by Simpalm_mac on 16/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsumerChekInCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnGotoProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnFollow;
@end
