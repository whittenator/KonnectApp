//
//  VenueGalleryViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 12/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VenueGalleryViewController.h"
#import "VenueGallryCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "KN_Event.h"
#import "UIImageView+WebCache.h"
#import "KN_Staging_PostEvent.h"
#import "KN_VenueProfileSetup.h"
#import "VenuePostViewController.h"
#import "CustomeCameraViewController.h"
#import "ConsumerPostEventViewController.h"
@interface VenueGalleryViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
     UIImage *chosenImage;
     NSMutableDictionary *dicProfileSetup;
     NSMutableDictionary *dicUserData;
     NSMutableArray *arrEvents;
     NSMutableArray *arrEventPost;
     NSMutableArray *arrVenueDetails;
     NSMutableArray * arrImageSlider;
     UIImagePickerController *ipc;
 
}
@end

@implementation VenueGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrEvents = [[NSMutableArray alloc]init];
    arrEventPost = [[NSMutableArray alloc]init];
    arrVenueDetails = [[NSMutableArray alloc]init];
    arrImageSlider = [[NSMutableArray alloc]init];
    dicProfileSetup = [[NSUserDefaults standardUserDefaults]valueForKey:@"VenueProfileData"];
    dicUserData  = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"];
    
    btnAdd.hidden = YES;
    lblGallery.text = @"Gallery";
    [self FetchVenueProfile];
  
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
# pragma mark UICollectionView Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   
        return arrEvents.count;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   
    
  VenueGallryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    

   
    //if ([StrCollectionCheck isEqualToString:@"PastEvent"]) {
    
    if (indexPath.row != 0) {
        
    cell.btnplay.hidden = YES;
    NSString *strForEventImageName = [[[arrEvents valueForKey:@"Image"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_VENUE_EVENT_IMAGE_URL,strForEventImageName]];
    
    [cell.imageGallry sd_setImageWithURL:url
                    placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    cell.lblName.text = [[arrEvents valueForKey:@"Name"]objectAtIndex:indexPath.row];
         
     }
    else
    {
        NSString *strForEventImageName = [[arrImageSlider objectAtIndex:0] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_VENUE_IMAGE_URL,strForEventImageName]];
        
        cell.btnplay.tag = indexPath.row;
        [cell.imageGallry sd_setImageWithURL:url
                            placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
        
        cell.lblName.text = [[arrEvents valueForKey:@"Name"]objectAtIndex:indexPath.row];
        cell.btnplay.hidden = YES;
        
    }
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.0;
}


# pragma mark UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *) collectionView
                   layout:(UICollectionViewLayout *) collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger) section {
    return 0.0;
}

// 1

# pragma mark collection view cell paddings
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0,0, 0);
}
- (CGSize)collectionView:(UICollectionView* )collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath* )indexPath
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 736) // iPhone 6 Plus Height
    {
        return CGSizeMake(136 , 136);
    }
    else if (screenBounds.size.height == 568) // iPhone 5 Height
    {
        return CGSizeMake(105 , 105);
    }
    else if (screenBounds.size.height == 667) // iPhone 6 Height
    {
        return CGSizeMake(123 , 123);
    }
    else
    {
        return CGSizeMake(105 , 105); // Default
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
     VenuePostViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VenuePostViewController"];
    if (indexPath.row==0) {
        
          Vc.strVenueId = [[arrVenueDetails valueForKey:@"Id"]objectAtIndex:indexPath.row];
          Vc.strChek = @"Gallery";
    }
    else
    {
       
        Vc.strId = [[arrEvents valueForKey:@"Id"]objectAtIndex:indexPath.row];
        Vc.strEventName = [[arrEvents valueForKey:@"Name"]objectAtIndex:indexPath.row];
         Vc.strChek = @"Event";
       
    }
     [self.navigationController pushViewController:Vc animated:YES];
   
}
#pragma mark - IBAction Method
-(void)clickPlayBtn:(UIButton *)Sender
{
   
    // grab a local URL to our video
    NSURL *videoURL = [[NSBundle mainBundle]URLForResource:@"Luvv U Zindaagi - HD HQ" withExtension:@"mp4"];
    
    // create an AVPlayer
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    // create a player view controller
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    [self presentViewController:controller animated:YES completion:nil];
    controller.player = player;
    [player play];
}
-(IBAction)actionHideBox:(UIButton *)sender{
    if([sender tag] == 123)
    {
        
      
            [self.view bringSubviewToFront:_viewBox];
            _viewBox.hidden = NO;
            _viewBox1.hidden = NO;
        
        
    }
    else
    {
        _viewBox.hidden = YES;
        _viewBox1.hidden = YES;
        //[self.view :_viewBox];
    }
}
-(IBAction)actionOpenCameraNGallery:(UIButton *)sender
{
    _viewBox.hidden = YES;
    _viewBox1.hidden = YES;
    ipc= [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    if([sender tag] == 0)
    {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Consumer" bundle: nil];
            CustomeCameraViewController *imageVC = [storyboard instantiateViewControllerWithIdentifier:@"CustomeCameraViewController"];
            imageVC.strVenueId = [[arrVenueDetails valueForKey:@"Id"]objectAtIndex:0];
            imageVC.classChek = @"VenueClass";
            [self.navigationController pushViewController:imageVC animated:NO];
        }
        else
        {
            [[Singlton sharedManager] alert:self title:@"Alert" message:@"Camera not available"];
            
        }
    }
    else
    {
        ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:ipc animated:YES completion:nil];
    }
    
}
-(IBAction)clickAddButton:(id)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:Take_A_Photo style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
        
        
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:Existing_Photos style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

#pragma mark - AWS Method
-(void)FetchVenueProfile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[Singlton sharedManager]showHUD];
    });
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"Id"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [dicProfileSetup valueForKey:@"Id"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_VenueProfileSetup class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 arrVenueDetails= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueProfileSetup *chat in paginatedOutput.items) {
                     
                     
                     [arrVenueDetails addObject:chat];
                     
                 }
                 
                 if (arrVenueDetails.count>0) {
                     
                     self.view.userInteractionEnabled = YES;
                     NSSet *setImages = [[arrVenueDetails valueForKey:@"Image"]objectAtIndex:0];
                     NSMutableArray *arrayShort = [NSMutableArray arrayWithArray:[setImages allObjects]];
                     NSArray *array = [NSArray arrayWithArray:arrayShort];
                     array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                     arrImageSlider = [NSMutableArray arrayWithArray:array];
                     NSLog(@"%@",arrImageSlider);
                     [self FetchVenueEvents];
                     
                 }
                 else
                 {
                     self.view.userInteractionEnabled = YES;
                     [[Singlton sharedManager]killHUD];
                    _collectionGallry.hidden = YES;
                    lblAlert.hidden = NO;
                    lblAlert.text = @"No past event available";
                  
                 }
                 
             });
             
         }
         
         return nil;
         
     }];
    
}
-(void)FetchVenueEvents
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"VenueId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [dicProfileSetup valueForKey:@"Id"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_Event class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 arrEvents= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_Event *chat in paginatedOutput.items) {
                     
                     
                     NSDate *Eventdate = [[Singlton sharedManager]convertStringToDate:[NSString stringWithFormat:@"%@ %@",[chat valueForKey:@"EventDate"],[chat valueForKey:@"EndTime"]]];
                     
                     
                     BOOL checkEventTimeandDate = [[Singlton sharedManager]DateChekDifference:[NSDate date] andDate:Eventdate];
                     
                     if (!checkEventTimeandDate) {
                         
                         [arrEvents addObject:chat];
                         
                     }
                     
                 }
                 
                 if (arrEvents.count>0) {
                     
                     self.view.userInteractionEnabled = YES;
                     NSSortDescriptor *sortDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"CreatedAt"
                                                                                     ascending:YES];
                     NSArray *arrayMesage = [arrEvents
                                             sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                     arrEvents = [NSMutableArray arrayWithArray:arrayMesage];
                     _collectionGallry.hidden = NO;
                     lblAlert.hidden = YES;
                     [arrEvents insertObject:[arrVenueDetails objectAtIndex:0] atIndex:0];
                     [_collectionGallry reloadData];
                     
                 }
                 else
                 {
                     _collectionGallry.hidden = NO;
                     lblAlert.hidden = YES;
                     [arrEvents insertObject:[arrVenueDetails objectAtIndex:0] atIndex:0];
                     [_collectionGallry reloadData];

                     
                 }
                 
             });
             
         }
         
         return nil;
         
     }];
    
}
#pragma mark - UIImagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage;
    chosenImage = info[UIImagePickerControllerEditedImage];
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Consumer" bundle: nil];
    ConsumerPostEventViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ConsumerPostEventViewController"];
    vc.imgData = chosenImage;
    _viewBox.hidden = YES;
    vc.strCheck = @"Photo";
    vc.strHeader = @"Gallery";
    vc.classChek = @"VenueClass";
    vc.strVenueId = [[arrVenueDetails valueForKey:@"Id"]objectAtIndex:0];
    [self.navigationController pushViewController:vc animated:YES];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
