//
//  ChangePasswordViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 23/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
@interface ChangePasswordViewController : BaseVC
{
    
    __weak IBOutlet UITextField *txtConfirmPassword;
    __weak IBOutlet UITextField *txtPassword;
}
- (IBAction)clickUpdate:(id)sender;
- (IBAction)clickback:(id)sender;


@end
