//
//  ConsumerPostEventViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "BaseVC.h"

@interface ConsumerPostEventViewController : BaseVC
{
    IBOutlet UILabel *lblHeader;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgPostEvent;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceHolder;
@property (strong, nonatomic) UIImage *imgData;
@property (nonatomic,strong) NSURL *UrlVideo;
@property (nonatomic,strong) NSString *classChek;
@property (nonatomic,strong) NSString *strCheck;
@property (nonatomic,strong) NSString *strEventId;
@property (nonatomic,strong) NSString *strVenueId;
@property (nonatomic,strong) NSString *strHeader;
@property (nonatomic,strong) NSString *postAddress;
- (IBAction)actionBack:(id)sender;
- (IBAction)actionSave:(id)sender;

@end
