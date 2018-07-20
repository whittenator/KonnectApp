//
//  VenueImageViewController.h
//  Konnect
//
//  Created by Balraj on 09/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueImageViewController : UIViewController
{
     IBOutlet UIImageView *imgEvent;
     __weak IBOutlet UIImageView *imgUserProfile;
    __weak IBOutlet UILabel *lblEventName;
    __weak IBOutlet UILabel *lblUserName;
    __weak IBOutlet UILabel *lblDateTime;
    __weak IBOutlet UIImageView *imgBackgraound;
    __weak IBOutlet UIView *viewContainer;
    __weak IBOutlet UIButton *btnComment;
    __weak IBOutlet UILabel *lblFullDetails;
}
@property (weak, nonatomic) NSString *strCount;
@property (nonatomic,weak) NSDictionary *dicPostDetails;
@property (nonatomic,weak) NSString *strName;
@property (nonatomic,weak) NSString *strchek;
@property (nonatomic,weak) NSNumber *eventDateTime;
@property (nonatomic,weak) NSString *strEventName;
@property (nonatomic,weak) NSString *strImage;
@property (nonatomic,weak) NSString *strUserImage;
-(IBAction)clickBack:(id)sender;

@end
