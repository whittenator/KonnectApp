//
//  SubscriptionViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 25/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshUserData.h"

@interface SubscriptionViewController : UIViewController
{
    
    __weak IBOutlet NSLayoutConstraint *yImageLogo;
    __weak IBOutlet UIButton *btnFor12Month;
    __weak IBOutlet UIButton *btnFor1Month;
    __weak IBOutlet UIButton *btnBack;
}
@property(nonatomic, strong, readwrite) NSString *environment;
@property(nonatomic, strong, readwrite) NSString *resultText;
@property (nonatomic,strong) NSString *strChangePaln;
@property (nonatomic,strong) NSString *StrSignupCheck;
-(IBAction)clickButton:(id)sender;
@end

