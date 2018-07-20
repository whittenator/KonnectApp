//
//  ConsumerChangePasswordVC.h
//  Konnect
//
//  Created by Simpalm_mac on 25/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "BaseVC.h"

@interface ConsumerChangePasswordVC : BaseVC
{
    
    __weak IBOutlet UITextField *txtConfirmPassword;
    __weak IBOutlet UITextField *txtPassword;
}
- (IBAction)clickUpdate:(id)sender;
- (IBAction)clickback:(id)sender;
@end
