//
//  CustomeCameraViewController.m
//  Konnect
//
//  Created by Balraj on 27/12/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "CustomeCameraViewController.h"
#import "ImageViewController.h"
#import "VideoViewController.h"
#import "ProgressView.h"
@interface CustomeCameraViewController ()
{
     IBOutlet UIView *paintView;
     ProgressView* m_testView;
     NSTimer* m_timer;
}
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UIButton *btnCorss;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@end

@implementation CustomeCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [self CreateCamera];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    m_timer = nil;
    [m_timer invalidate];
    m_testView.hidden = YES;
    [self AddProgressBar];
     [self.camera start];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Custome Method
-(void)CreateCamera
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.view.backgroundColor = [UIColor blackColor];
    // create camera with standard settings
    self.camera = [[LLSimpleCamera alloc] init];
    
    // camera with video recording capability
    self.camera =  [[LLSimpleCamera alloc] initWithVideoEnabled:YES];
    
    // camera with precise quality, position and video parameters.
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                 position:LLCameraPositionRear
                                             videoEnabled:YES];
    [self.camera start];
    // attach to the view
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    
    paintView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [paintView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:paintView];
    
    
    UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,64)];
    dot.backgroundColor=[UIColor blackColor];
    [paintView addSubview:dot];
    
    
    self.btnCorss = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnCorss.frame = CGRectMake(10, 10, 40, 40);
    self.btnCorss.clipsToBounds = YES;
    [self.btnCorss setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
    [self.btnCorss addTarget:self action:@selector(Cross:) forControlEvents:UIControlEventTouchUpInside];
    [paintView addSubview:self.btnCorss];
    
    
    // snap button to capture image
    self.snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.snapButton.frame = CGRectMake(screenRect.size.width/2-35, screenRect.size.height - 90.0f, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.frame.size.width / 2.0f;
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.layer.borderWidth = 2.0f;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.snapButton];
    
    if([LLSimpleCamera isFrontCameraAvailable] && [LLSimpleCamera isRearCameraAvailable]) {
        // button to toggle camera positions
        self.switchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.switchButton.frame = CGRectMake(screenRect.size.width-60, 10, 50 ,50.0f);
        self.switchButton.tintColor = [UIColor whiteColor];
        [self.switchButton setImage:[UIImage imageNamed:@"camera-switch.png"] forState:UIControlStateNormal];
        self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [paintView addSubview:self.switchButton];
    }
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Picture",@"Video"]];
    self.segmentedControl.frame = CGRectMake(12.0f, screenRect.size.height - 67.0f, 120.0f, 32.0f);
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.tintColor = [UIColor whiteColor];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    
}
#pragma mark - IBAction Method
-(IBAction)Cross:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)snapButtonPressed:(UIButton *)button
{
    __weak typeof(self) weakSelf = self;
    
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        
        
        // capture
        [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
            if(!error) {
                ImageViewController *imageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
                imageVC.imgCaptured = image;
                imageVC.strPhotoVideo = @"Photo";
                imageVC.strEventId = _strEventId;
                imageVC.postAddress = _postAddress;
                imageVC.strVenueId = _strVenueId;
                imageVC.classChek = _classChek;
                [self.navigationController pushViewController:imageVC animated:YES];
            }
            else {
                NSLog(@"An error has occured: %@", error);
            }
        } exactSeenImage:YES];
        
        
        
    } else {
        if(!self.camera.isRecording) {
            self.segmentedControl.hidden = YES;
            self.flashButton.hidden = YES;
            self.switchButton.hidden = YES;
            
            self.snapButton.layer.borderColor = [UIColor redColor].CGColor;
            self.snapButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
            
            m_testView.hidden = NO;
            m_testView.percent = 120;
            m_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(decrementSpin) userInfo:nil repeats:YES];
            
            
            NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
            //NSString *intervalString = [NSString stringWithFormat:@"%f", timeInSeconds];
            //   NSString *strUrlKey = [NSString stringWithFormat:@"%@%@",[dicUserData valueForKey:@"UserName"],intervalString];
            
            
            // start recording
            NSURL *outputURL = [[[self applicationDocumentsDirectory]
                                 URLByAppendingPathComponent:@"test1"] URLByAppendingPathExtension:@"mov"];
            [self.camera startRecordingWithOutputUrl:outputURL didRecord:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
                
                UIImage *imageView = [self getThumbnailForVideoNamed:outputURL];
                ImageViewController *imageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewController"];
                imageVC.imgCaptured = imageView;
                imageVC.strPhotoVideo = @"Video";
                imageVC.UrlVideo = outputURL;
                imageVC.strEventId = _strEventId;
                imageVC.postAddress = _postAddress;
                imageVC.strVenueId = _strVenueId;
                imageVC.classChek = _classChek;
                // imageVC.strVideoName = strUrlKey;
                //imageVC.VideoTime = m_testView.percent;
                [self.navigationController pushViewController:imageVC animated:NO];
            }];
            
        } else {
            self.segmentedControl.hidden = NO;
            self.flashButton.hidden = NO;
            self.switchButton.hidden = NO;
            m_testView.hidden = YES;
            self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
            
            [self.camera stopRecording];
        }
    }
}
- (void)switchButtonPressed:(UIButton *)button
{
    [self.camera togglePosition];
}

- (void)flashButtonPressed:(UIButton *)button
{
    if(self.camera.flash == LLCameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
            self.flashButton.tintColor = [UIColor yellowColor];
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:LLCameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
            self.flashButton.tintColor = [UIColor whiteColor];
        }
    }
}
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (void)segmentedControlValueChanged:(UISegmentedControl *)control
{
    NSLog(@"Segment value changed!");
}
-(UIImage *)getThumbnailForVideoNamed:(NSURL *)VideoUrl
{
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:VideoUrl options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *thumbNailImage = [[UIImage alloc] initWithCGImage:oneRef];
    return thumbNailImage;
}
-(void)AddProgressBar
{
    m_testView = [[ProgressView alloc] initWithFrame:self.view.bounds];
    m_testView.frame = CGRectMake(self.view.frame.size.width-60, 10, 50.0f, 50.0f);
    m_testView.backgroundColor = [UIColor clearColor];
    m_testView.percent = 120;
    m_testView.hidden = YES;
    [paintView addSubview:m_testView];
}
- (void)decrementSpin
{
    // If we can decrement our percentage, do so, and redraw the view
    if (m_testView.percent > 0) {
        m_testView.percent = m_testView.percent - 1;
        [m_testView setNeedsDisplay];
    }
    else {
        [self.camera stopRecording];
        
        [m_timer invalidate];
        m_timer = nil;
    }
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
