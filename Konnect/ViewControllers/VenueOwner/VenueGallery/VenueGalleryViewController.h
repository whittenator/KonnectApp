//
//  VenueGalleryViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 12/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueGalleryViewController : UIViewController
{
    
    __weak IBOutlet UILabel *lblGallery;
    __weak IBOutlet UIButton *btnAdd;
    __weak IBOutlet UILabel *lblAlert;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionGallry;
@property(nonatomic,weak)IBOutlet UIView *viewBox;
@property(nonatomic,weak)IBOutlet UIView *viewBox1;
- (IBAction)clickAddButton:(id)sender;
-(IBAction)actionHideBox:(id)sender;
@end
