//
//  NonKonnectViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 03/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NonKonnectViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblImgTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnClaimYourBusiness;
@property (weak, nonatomic) IBOutlet UIImageView *imgNonKonnectScreen;
- (IBAction)actionBack:(id)sender;
- (IBAction)actionSave:(id)sender;

@end
