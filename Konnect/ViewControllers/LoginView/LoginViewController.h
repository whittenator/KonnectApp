//
//  LoginViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 13/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface LoginViewController : BaseVC
{
    __weak IBOutlet UITextField *txtEmail;
    __weak IBOutlet UITextField *txtPassword;
    
    __weak IBOutlet UIImageView *imgLogo;
    __weak IBOutlet NSLayoutConstraint *yCordinate;
    __weak IBOutlet NSLayoutConstraint *yCordinateSignUp;
    
    __weak IBOutlet NSLayoutConstraint *EmailTextHeight;
    
    __weak IBOutlet NSLayoutConstraint *loginHeight;
    __weak IBOutlet NSLayoutConstraint *PasswordTextHeight;
    __weak IBOutlet NSLayoutConstraint *yCordinateOrlogin;
    
    __weak IBOutlet NSLayoutConstraint *yCordinatefacebook;
    
    __weak IBOutlet UIImageView *imgOrLogin;
    __weak IBOutlet UIButton *btnFacebook;
     IBOutlet UIActivityIndicatorView *act;

}
@property (nonatomic,strong) NSString *strLoginType;
-(IBAction)clickButtons:(id)sender;

@end
