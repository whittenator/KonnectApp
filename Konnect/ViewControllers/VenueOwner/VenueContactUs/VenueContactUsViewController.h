//
//  VenueContactUsViewController.h
//  Konnect
//
//  Created by Balraj Randhawa on 16/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueContactUsViewController : BaseVC
{
    
    __weak IBOutlet UITextView *txtMessage;
    __weak IBOutlet UITextField *txtEMail;
}
@property (weak, nonatomic) IBOutlet UIButton *clickSendButton;
@end
