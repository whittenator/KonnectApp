//
//  SignupViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 18/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
@interface SignupViewController : BaseVC
{
    
    __weak IBOutlet UITextField *txtConfrmPassword;
    __weak IBOutlet UITextField *txtPassword;
    __weak IBOutlet UITextField *txtEmail;
    __weak IBOutlet UITextField *txtFirstName;
    __weak IBOutlet UITextField *txtPhoneNumber;
    __weak IBOutlet UITextField *txtLastName;
    
    __weak IBOutlet NSLayoutConstraint *layoutHeightEmail;
    __weak IBOutlet NSLayoutConstraint *layoutHeightPassword;
    __weak IBOutlet NSLayoutConstraint *layoutHeightConfirmPassowrd;
    __weak IBOutlet NSLayoutConstraint *imglogoYCoordinate;
    __weak IBOutlet NSLayoutConstraint *signupHeight;
    
    __weak IBOutlet UIButton *btnTermCondition;
     IBOutlet UIActivityIndicatorView *act;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UIView *viewTermsNPolicy;
    IBOutlet UIWebView *webViewTermsNPolicy;
}
- (IBAction)actionSegment:(UISegmentedControl *)sender;
- (IBAction)clickTermsAndCondition:(id)sender;
- (IBAction)clickSignUp:(id)sender;
- (IBAction)clickAlreadyAccount:(id)sender;
- (IBAction)actionHideView:(id)sender;

@end
