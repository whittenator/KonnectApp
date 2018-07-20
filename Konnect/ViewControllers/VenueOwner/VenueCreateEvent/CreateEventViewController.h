//
//  CreateEventViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 11/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import <CoreLocation/CoreLocation.h>
@interface CreateEventViewController : BaseVC
{
    __weak IBOutlet UIButton *btnEventImage;
    __weak IBOutlet UITextField *txtEventName;
    __weak IBOutlet UITextField *txtEventType;
    __weak IBOutlet UITextField *txtEventSpacial;
    __weak IBOutlet UITextField *txtEventEnd;
    __weak IBOutlet UITextField *txtEventStart;
    __weak IBOutlet UITextView *txtDescription;
    __weak IBOutlet UITextField *txtEventDate;
    __weak IBOutlet NSLayoutConstraint *EventHeight;
    __weak IBOutlet NSLayoutConstraint *DescriptionHeight;
    __weak IBOutlet NSLayoutConstraint *EndEventHeight;
    __weak IBOutlet NSLayoutConstraint *startEventHeight;
    __weak IBOutlet NSLayoutConstraint *SpicalEventHeight;
    __weak IBOutlet NSLayoutConstraint *TypeHeight;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIButton *btnSaveUpdate;
    float latitude;
    float longitude;
    __weak IBOutlet UIButton *btnEvent;
      __weak IBOutlet UIButton *btnType;
    __weak IBOutlet UITableView *tblType;
    
    __weak IBOutlet NSLayoutConstraint *txtDescriptionHeight;
    
}
@property (weak, nonatomic) UIImage *imgEvent;
@property (weak, nonatomic) NSDictionary *dicEventDetail;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) NSString *strEventCheck;
@property (weak, nonatomic) IBOutlet UITableView *tblEventType;
-(IBAction)clickEventImage:(id)sender;
-(IBAction)clickSaveBtn:(id)sender;
@end
