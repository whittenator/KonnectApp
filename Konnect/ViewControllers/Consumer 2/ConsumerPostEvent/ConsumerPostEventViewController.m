//
//  ConsumerPostEventViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ConsumerPostEventViewController.h"
#import "MainViewController.h"
#import <AWSS3/AWSS3.h>
#import "KN_Staging_PostEvent.h"
#import "ConsumerVenueEventDetailVC.h"
#import "UIImage+ImageCompress.h"
#import "KN_StagingVenueGallery.h"
#import "ConsumerGalleryViewController.h"
#import "VenueGalleryViewController.h"
@interface ConsumerPostEventViewController ()<UITextViewDelegate>
{
    CGFloat animatedDistance;
    UIImage *chosenImage;
    NSString *strImageName;
    NSString *_strVideoName;
    NSMutableDictionary *dictUserInfo;
    NSMutableDictionary *dictVenueUserInfo;

}
@end

@implementation ConsumerPostEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![_classChek isEqualToString:@"VenueClass"])
    {
        dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
    }
    else
    {
         dictVenueUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"]mutableCopy];
    }
    
    if ([_strHeader isEqualToString:@"Post"]) {
        
        lblHeader.text = @"PostEvent";
    }
    else
    {
         lblHeader.text = @"Gallery";
    }
     _txtDescription.contentInset = UIEdgeInsetsMake(3, 3, 3, 3);
    _txtDescription.delegate = self;
    NSLog(@"imgData is %@",_imgData);
    _imgPostEvent.image = _imgData;
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _lblPlaceHolder.hidden = YES;
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 230;
    static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 216;
    
    CGRect textFieldRect;
    CGRect viewRect;
    
    textFieldRect =[self.view.window convertRect:textView.bounds fromView:textView];
    viewRect =[self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 0.9;
    }
    
    UIInterfaceOrientation orientation =[[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame;
    
    viewFrame= self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
}



-(void)textViewDidEndEditing:(UITextView *)textView
{
    if(textView.tag==0)
    {
        _lblPlaceHolder.hidden = NO;
        static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
        CGRect viewFrame;
        
        viewFrame= self.view.frame;
        viewFrame.origin.y += animatedDistance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSave:(id)sender {
    [self.view endEditing:YES];
    
    if ([[Singlton sharedManager]check_null_data:_txtDescription.text]) {
        
        [[Singlton sharedManager] alert:self title:Alert message:EventDescription];
    }
    else
    {
      
        if ([_strCheck isEqualToString:@"Photo"]) {
            
            [self UploadPostImage];
        }
        else
        {
             [self UploadVideoOnServer];
        }
        
        
    }
}
#pragma mark - UITextView Delegates
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
         _lblPlaceHolder.hidden = YES;
        return NO;
    }
    return textView.text.length + (text.length - range.length) <= 250;
}
#pragma mark - AWS Method
-(void)UploadPostImage
{
    [[Singlton sharedManager]showHUD];
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    
    if (![_classChek isEqualToString:@"VenueClass"])
    {
          strImageName = [NSString stringWithFormat:@"%@%@.jpg",[dictUserInfo valueForKey:@"firstName"],NumberCreatedAt];
    }
    else
    {
        strImageName = [NSString stringWithFormat:@"%@%@.jpg",[dictVenueUserInfo valueForKey:@"Email"],NumberCreatedAt];
    }
    

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:strImageName];
    
    _imgData   =   [UIImage compressImage:_imgData
             compressRatio:0.2f];
    
   // UIImage *imag   =   [UIImage compressImage:_imgData compressRatio:0.7f];
    
    NSData *imgData= UIImageJPEGRepresentation(_imgData,0.6);
    chosenImage = [UIImage imageWithData:imgData];
    [UIImagePNGRepresentation(_imgData) writeToFile:filePath atomically:YES];
    NSURL* imageUrl = [NSURL fileURLWithPath:filePath];
    
    AWSS3TransferManager *transferManager =
    [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    if ([_strHeader isEqualToString:@"Post"]) {
        
    
        uploadRequest.bucket =  [UserMode isEqualToString:@"Test"] ? @"staging-post":@"kon-post"; // Your Bucket Name
    }
    else
    {
       
          uploadRequest.bucket =  [UserMode isEqualToString:@"Test"] ? @"staging-gallery":@"kon-gallery";
    }
    uploadRequest.key = strImageName;
    uploadRequest.body  =   imageUrl;
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error) {
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                           
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;
                                                                           
                                                                           
                                                                       default:
                                                                           [[Singlton sharedManager]killHUD];
                                                                           NSLog(@"Error: %@", task.error);
                                                                           break;
                                                                           
                                                                   }
                                                                   
                                                               } else {
                                                                   
                                                                   [[Singlton sharedManager]killHUD];
                                                                   // Unknown error.
                                                                   NSLog(@"Error: %@", task.error);
                                                                   
                                                               }
                                                           }
                                                           
                                                           if (task.result) {
                                                               
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   
                                                                   
                                                                   self.view.userInteractionEnabled = YES;
                                                                   
                                                                   if ([_strHeader isEqualToString:@"Post"]) {
                                                                       
                                                                       [self SavePostData];
                                                                   }
                                                                   else
                                                                   {
                                                                       [self SaveVenueGalleryData];
                                                                   }
                                                                   
                                                                   
                                                                   
                                                                   
                                                               });

                                                           }
                                                           
                                                           return nil;
                                                           
                                                           
                                                       }];
    
}

-(void)UploadVideoThumnilImage
{
    [[Singlton sharedManager]showHUD];
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    
    if (![_classChek isEqualToString:@"VenueClass"])
    {
        strImageName = [NSString stringWithFormat:@"%@%@.jpg",[dictUserInfo valueForKey:@"firstName"],NumberCreatedAt];
    }
    else
    {
        strImageName = [NSString stringWithFormat:@"%@%@.jpg",[dictVenueUserInfo valueForKey:@"Email"],NumberCreatedAt];
    }
    
  
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:strImageName];
    NSData *imgData= UIImageJPEGRepresentation(_imgData,0.6);
    chosenImage = [UIImage imageWithData:imgData];
    [UIImagePNGRepresentation(_imgData) writeToFile:filePath atomically:YES];
    NSURL* imageUrl = [NSURL fileURLWithPath:filePath];
    AWSS3TransferManager *transferManager =
    [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
     if ([_strHeader isEqualToString:@"Post"]) {
         
         uploadRequest.bucket =  [UserMode isEqualToString:@"Test"] ? @"staging-post":@"kon-post";
     }
    else
    {
           uploadRequest.bucket =  [UserMode isEqualToString:@"Test"] ? @"staging-gallery":@"kon-gallery";
    }
    uploadRequest.key = strImageName;
    uploadRequest.body  =   imageUrl;
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error) {
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                           
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;
                                                                           
                                                                           
                                                                       default:
                                                                           [[Singlton sharedManager]killHUD];
                                                                           NSLog(@"Error: %@", task.error);
                                                                           break;
                                                                           
                                                                   }
                                                                   
                                                               } else {
                                                                   
                                                                   [[Singlton sharedManager]killHUD];
                                                                   // Unknown error.
                                                                   NSLog(@"Error: %@", task.error);
                                                                   
                                                               }
                                                           }
                                                           
                                                           if (task.result) {
                                                               
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   
                                                                   
                                                                   self.view.userInteractionEnabled = YES;
                                                                   
                                                                   if ([_strHeader isEqualToString:@"Post"]) {
                                                                       
                                                                        [self SavePostData];
                                                                   }
                                                                   else
                                                                   {
                                                                       [self SaveVenueGalleryData];
                                                                   }
                                                                   
                                                                  
                                                                   
                                                                   
                                                               });
                                                               
                                                               
                                                               
                                                           }
                                                           
                                                           return nil;
                                                           
                                                           
                                                       }];
    
}
- (void)UploadVideoOnServer
{
    // amazon web service s3 api
     [[Singlton sharedManager]showHUD];
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    
    if (![_classChek isEqualToString:@"VenueClass"])
    {
        _strVideoName = [NSString stringWithFormat:@"%@%@.mp4",[dictUserInfo valueForKey:@"firstName"],NumberCreatedAt];
    }
    else
    {
         _strVideoName = [NSString stringWithFormat:@"%@%@.mp4",[dictVenueUserInfo valueForKey:@"Email"],NumberCreatedAt];
       
    }
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
      if ([_strHeader isEqualToString:@"Post"]) {
    uploadRequest.bucket =  [UserMode isEqualToString:@"Test"] ? @"staging-post":@"kon-post";
      }
    else
    {
        uploadRequest.bucket =  [UserMode isEqualToString:@"Test"] ? @"staging-gallery":@"kon-gallery";
    }
    uploadRequest.key = _strVideoName; // Your File Name in Bucket
    uploadRequest.body = _UrlVideo;

    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error) {
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;
                                                                           
                                                                       default:
                                                                           NSLog(@"Error: %@", task.error);
                                                                           break;
                                                                   }
                                                               } else {
                                                                   // Unknown error.
                                                                   NSLog(@"Error: %@", task.error);
                                                                   [uploadRequest pause];
                                                               }
                                                           }
                                                           
                                                           if (task.result) {
                                                               AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                               NSLog(@"upload response: %@", uploadOutput);
                                                               [self UploadVideoThumnilImage];
                                                               
                                                           }
                                                           return nil;
                                                       }];
    
}
-(void)SaveVenueGalleryData
{
    self.view.userInteractionEnabled = NO;
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSString *Id = [NSString stringWithFormat:@"%@%f",[dictUserInfo valueForKey:@"Email"],timeInSeconds];
    
    NSString *strName = [NSString stringWithFormat:@"%@ %@",[dictUserInfo valueForKey:@"firstName"],[dictUserInfo valueForKey:@"lastName"]];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    KN_StagingVenueGallery *galleryPost = [KN_StagingVenueGallery new];
    galleryPost.Id = Id;
    galleryPost.UserId = [dictUserInfo valueForKey:@"UserId"] ;
    galleryPost.VenueId = _strVenueId;
    galleryPost.PostComment = _txtDescription.text;
    galleryPost.Video = _strVideoName;
    galleryPost.Type = _strCheck;
    galleryPost.Image = strImageName;
    galleryPost.UserImage = [dictUserInfo valueForKey:@"UserImage"];
    galleryPost.Name = strName;
    galleryPost.CreatedAt = NumberCreatedAt;
    galleryPost.UpdatedAt = NumberCreatedAt;
    
    [[dynamoDBObjectMapper save:galleryPost]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 NSLog(@"The request failed. Error: [%@]", task.error);
             });
         }
         if (task.result) {
             
             //Do something with the result.
             NSLog(@"Task result: %@",task.result);
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 
                 for (UIViewController *controller in self.navigationController.viewControllers) {
                     
                     //Do not forget to import AnOldViewController.h
                     if ([_classChek isEqualToString:@"VenueClass"]) {
                         
                         if ([controller isKindOfClass:[VenueGalleryViewController class]]) {
                             
                             [self.navigationController popToViewController:controller
                                                                   animated:YES];
                             break;
                         }
                     }
                     else
                     {
                     
                     if ([controller isKindOfClass:[ConsumerGalleryViewController class]]) {
                         
                         [self.navigationController popToViewController:controller
                                                               animated:YES];
                         break;
                     }
                 }
                 }
                 
             });
             
         }
         return nil;
     }];
}
-(void)SavePostData
{
    self.view.userInteractionEnabled = NO;
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSString *Id = [NSString stringWithFormat:@"%@%f",[dictUserInfo valueForKey:@"Email"],timeInSeconds];
    
    NSString *strName = [NSString stringWithFormat:@"%@ %@",[dictUserInfo valueForKey:@"firstName"],[dictUserInfo valueForKey:@"lastName"]];

    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    KN_Staging_PostEvent *PostEvent = [KN_Staging_PostEvent new];
    PostEvent.Id = Id;
    PostEvent.UserId = [dictUserInfo valueForKey:@"UserId"] ;
    PostEvent.EventId = _strEventId;
    PostEvent.PostComment = _txtDescription.text;
    PostEvent.commentCount = @"0";
    PostEvent.Video = _strVideoName;
    PostEvent.Type = _strCheck;
    PostEvent.Image = strImageName;
    PostEvent.PostAddress = _postAddress;
    PostEvent.Name = strName;
    PostEvent.UserImage = [dictUserInfo valueForKey:@"UserImage"];
    PostEvent.CreatedAt = NumberCreatedAt;
    PostEvent.UpdatedAt = NumberCreatedAt;
    
    [[dynamoDBObjectMapper save:PostEvent]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 NSLog(@"The request failed. Error: [%@]", task.error);
             });
         }
         if (task.result) {
             
             //Do something with the result.
             NSLog(@"Task result: %@",task.result);
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                
                 for (UIViewController *controller in self.navigationController.viewControllers) {
                     
                     //Do not forget to import AnOldViewController.h
                     
                    if ([controller isKindOfClass:[ConsumerVenueEventDetailVC class]]) {
                         
                         [self.navigationController popToViewController:controller
                                                               animated:YES];
                         break;
                     }
                     
                 }
                 
             });
             
         }
         return nil;
     }];
}

@end
