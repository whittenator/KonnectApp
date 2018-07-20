//
//  PostCellCollectionViewCell.h
//  Konnect
//
//  Created by Balraj on 09/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostCellCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageGallry;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnplay;
@end
