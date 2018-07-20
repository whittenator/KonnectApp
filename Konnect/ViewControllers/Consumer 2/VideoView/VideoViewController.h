//
//  VideoViewController.h
//  Konnect
//
//  Created by Balraj on 27/12/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface VideoViewController : UIViewController
{
    IBOutlet UIView *viewContainer;
    IBOutlet UIButton *btnShare;
}
@property (nonatomic,strong) NSURL *url;
-(IBAction)clickCrossButton:(id)sender;
@end
