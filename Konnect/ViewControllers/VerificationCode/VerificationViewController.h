//
//  VerificationViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 18/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerificationViewController : UIViewController
{
    
    __weak IBOutlet NSLayoutConstraint *yCoordinateImage;
    __weak IBOutlet NSLayoutConstraint *heightContimueBtn;
    __weak IBOutlet NSLayoutConstraint *heightVerificationField;
    __weak IBOutlet UITextField *txtVerificationFieldCode;
}
- (IBAction)clickContinueButton:(id)sender;
- (IBAction)clickLoginNow:(id)sender;



@end
