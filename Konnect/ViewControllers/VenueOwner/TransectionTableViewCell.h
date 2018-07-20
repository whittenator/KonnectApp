//
//  TransectionTableViewCell.h
//  Konnect
//
//  Created by Balraj Randhawa on 16/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransectionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTransectionDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTransectionName;
@property (weak, nonatomic) IBOutlet UILabel *lblTansectionBookEvent;

@end
