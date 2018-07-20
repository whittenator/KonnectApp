//
//  PrivacyNPolicyViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivacyNPolicyViewController : UIViewController
{
    NSMutableArray *arrTableData;
    IBOutlet UIWebView *webViewTermsNPolicy;
}
@property (weak, nonatomic) IBOutlet UITableView *tblPrivacyNPolicy;

@end
