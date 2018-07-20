//
//  FAQViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FAQViewController : UIViewController
{
    NSMutableArray *arrTableData;
}
@property (weak, nonatomic) IBOutlet UITableView *tblFAQ;
@property (weak, nonatomic) IBOutlet UIWebView *webViewFAQ;


@end
