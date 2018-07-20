//
//  SubscriptionPlanViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscriptionPlanViewController : UIViewController
{
    __weak IBOutlet NSLayoutConstraint *yLogoPosition;
     __weak IBOutlet UILabel *lblPlan;
     __weak IBOutlet UILabel *lblPlanMonthOrYear;
    __weak IBOutlet NSLayoutConstraint *ySubscriptiontext;
     __weak IBOutlet UILabel *lblStartFrom;
}
-(IBAction)clickCancelButtopn:(id)sender;
-(IBAction)clickChangePalnBtn:(id)sender;
-(IBAction)clickChangePaymentMethod:(id)sender;
@end
