//
//  ImageViewController.m
//  Konnect
//
//  Created by Balraj on 27/12/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ImageViewController.h"
#import <AVFoundation/AVFoundation.h>
//#import "UIImage+Crop.h"
#import "ConsumerPostEventViewController.h"
@interface ImageViewController ()
{
    NSString *strPhotoCheck;
    NSData *newDataForUpload ;
    NSURL *uploadURL;
}
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerLayer *avPlayerLayer;
@end

@implementation ImageViewController

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        _imgCaptured = image;
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
       imgView.image = _imgCaptured;
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    if ([_strPhotoVideo isEqualToString:@"Photo"]) {
        
        strPhotoCheck = @"Photo";
    }
    else
    {
        newDataForUpload = [NSData dataWithContentsOfURL:_UrlVideo];
        NSLog(@"Size of new Video after compression is (bytes):%lu",(unsigned long)[newDataForUpload length]);
        
        uploadURL = [NSURL fileURLWithPath:
                     [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"Viraj"]]];
        
        [self compressVideo:_UrlVideo outputURL:uploadURL handler:^(AVAssetExportSession *completion) {
            if (completion.status == AVAssetExportSessionStatusCompleted) {
                
                newDataForUpload = [NSData dataWithContentsOfURL:uploadURL];
                
                NSLog(@"Size of new Video after compression is (bytes):%lu",(unsigned long)[newDataForUpload length]);
            }
        }];
        strPhotoCheck = @"Video";
        [self PLayVideo];
        [self.avPlayer play];
       
    }
}
#pragma mark - IBAction Method
-(IBAction)clickPost:(id)sender
{
     ConsumerPostEventViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerPostEventViewController"];
    if ([strPhotoCheck isEqualToString:@"Photo"]) {
        
       
        vc.imgData = _imgCaptured;
       
    }
    else
    {
         vc.imgData = _imgCaptured;
         vc.UrlVideo = _UrlVideo;
        
    }
      vc.strEventId = _strEventId;
      vc.strVenueId = _strVenueId;
      vc.strCheck = strPhotoCheck;
      vc.classChek = _classChek;
     [self.navigationController pushViewController:vc animated:YES];
    
  
}
-(IBAction)clickCorss:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}
-(IBAction)clickPlayButon:(id)sender
{
//    VideoViewController *videoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoViewController"];
//    videoVC.url = _UrlVideo;
//    [self.navigationController presentViewController:videoVC animated:YES completion:nil];
}
-(IBAction)clickShare:(id)sender
{
    
    NSString *strTime = [self timeFormatted:120-_VideoTime];
    
    [self.avPlayer pause];
    [self.avPlayerLayer removeFromSuperlayer];

}

#pragma mark - Custom Method
-(void)PLayVideo
{
    self.avPlayer = [AVPlayer playerWithURL:_UrlVideo];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    //self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.avPlayerLayer.frame = CGRectMake(0, 64, screenRect.size.width, screenRect.size.height);
    [self.view.layer addSublayer:self.avPlayerLayer];
    [self.view addSubview:btnshare];
    
    
}
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    //  AVPlayerItem *p = [notification object];
    //  [p seekToTime:kCMTimeZero];
}
- (NSString *)timeFormatted:(int)totalSeconds{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Compress Video
- (void)compressVideo:(NSURL*)inputURL
            outputURL:(NSURL*)outputURL
              handler:(void (^)(AVAssetExportSession*))completion  {
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        completion(exportSession);
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
