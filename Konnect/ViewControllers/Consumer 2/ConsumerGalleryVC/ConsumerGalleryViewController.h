//
//  ConsumerGalleryViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 16/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsumerGalleryViewController : UIViewController
{
    IBOutlet UILabel *lblAlert;
    float latitude;
    float longitude;
}
@property (weak, nonatomic) NSString *strVenueId;
@property (nonatomic,strong) NSDictionary *dicVenueDetails;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionGallry;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,weak)IBOutlet UIView *viewBox;
@property(nonatomic,weak)IBOutlet UIView *viewBox1;
-(IBAction)actionHideBox:(id)sender;
@end
