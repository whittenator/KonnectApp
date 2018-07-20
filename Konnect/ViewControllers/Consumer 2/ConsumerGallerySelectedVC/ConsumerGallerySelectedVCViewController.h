//
//  ConsumerGallerySelectedVCViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 17/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsumerGallerySelectedVCViewController : UIViewController
{
      IBOutlet UILabel *lblAlert;
      IBOutlet UILabel *lblHeader;
      float latitude;
      float longitude;
}
@property (weak, nonatomic) NSString *strCheck;
@property (weak, nonatomic) NSString *strEventId;
@property (weak, nonatomic) NSString *strVenueId;
@property (weak, nonatomic) NSString *strEventName;
@property (nonatomic,strong) NSDictionary *dicVenueDetails;
@property (nonatomic,strong) NSDictionary *dicEventDetails;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,weak)IBOutlet UIView *viewBox;
@property(nonatomic,weak)IBOutlet UIView *viewBox1;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionGallry;
-(IBAction)actionHideBox:(id)sender;
@end
