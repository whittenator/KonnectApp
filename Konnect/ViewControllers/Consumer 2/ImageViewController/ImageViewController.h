//
//  ImageViewController.h
//  Konnect
//
//  Created by Balraj on 27/12/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
{
    IBOutlet UIImageView *imgView;
    IBOutlet UIButton *videoTimeCount;
    IBOutlet UIButton *btnshare;
}
@property (assign) int VideoTime;;
@property (nonatomic,strong) NSURL *UrlVideo;
@property (nonatomic,strong) NSString *strVenueId;
@property (nonatomic,strong) NSString *strPhotoVideo;
@property (nonatomic,strong) UIImage *imgCaptured;
@property (nonatomic,strong) NSString *strVideoName;
@property (nonatomic,strong) NSString *strEventId;
@property (nonatomic,strong) NSString *postAddress;
@property (nonatomic,strong) NSString *classChek;
- (instancetype)initWithImage:(UIImage *)image;
-(IBAction)clickCorss:(id)sender;
-(IBAction)clickPlayButon:(id)sender;
-(IBAction)clickPost:(id)sender;
@end
