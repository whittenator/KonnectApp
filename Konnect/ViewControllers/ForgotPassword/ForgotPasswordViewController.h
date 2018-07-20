//
//  ForgotPasswordViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 13/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
@interface ForgotPasswordViewController : BaseVC
{
    
    __weak IBOutlet NSLayoutConstraint *continueHeight;
    __weak IBOutlet NSLayoutConstraint *emailHeight;
    __weak IBOutlet NSLayoutConstraint *yCoordinateImageLogo;
    __weak IBOutlet UITextField *txtEmail;
}
- (IBAction)clickButton:(id)sender;

@end
