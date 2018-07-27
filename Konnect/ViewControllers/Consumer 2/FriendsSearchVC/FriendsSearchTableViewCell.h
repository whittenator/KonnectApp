//
//  FriendsSearchTableViewCell.h
//  Konnect
//
//  Created by Travis Whitten on 7/26/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsSearchTableViewCell : UITableViewCell
@property(strong,nonatomic)IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIImageView *userImg;

@end
