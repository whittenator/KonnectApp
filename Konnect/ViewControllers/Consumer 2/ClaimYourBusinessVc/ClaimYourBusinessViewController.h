//
//  ClaimYourBusinessViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 03/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClaimYourBusinessViewController:BaseVC
{
    //NSMutableArray *arrTableData;
}
@property (weak, nonatomic) IBOutlet UITextField *txtBusinessName;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtOpenTime;
@property (weak, nonatomic) IBOutlet UITextField *txtCloseTime;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;

- (IBAction)actionBack:(id)sender;
- (IBAction)actionSaveInfo:(id)sender;

@end
