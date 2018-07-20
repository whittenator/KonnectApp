//
//  VenuePostViewController.h
//  Konnect
//
//  Created by Balraj on 09/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenuePostViewController : UIViewController
{
    
    __weak IBOutlet UILabel *lblGallery;
    __weak IBOutlet UIButton *btnAdd;
    __weak IBOutlet UILabel *lblAlert;
}
@property (weak, nonatomic) NSString *strId;
@property (weak, nonatomic) NSString *strChek;
@property (weak, nonatomic) NSString *strEventName;
@property (weak, nonatomic) NSString *strVenueId;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionGallry;
-(IBAction)clickBack:(id)sender;
@end
