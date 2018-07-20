//
//  VenuePostViewController.m
//  Konnect
//
//  Created by Balraj on 09/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import "VenuePostViewController.h"
#import "KN_Staging_PostEvent.h"
#import "PostCellCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "VenueOwnerCommentViewController.h"
#import "MainViewController.h"
#import "KN_StagingVenueGallery.h"
#import "VenueImageViewController.h"
@interface VenuePostViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray *arrEventPost;
}
@end

@implementation VenuePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrEventPost = [[NSMutableArray alloc]init];
    lblGallery.text  = _strEventName;
    
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
    if ([_strChek isEqualToString:@"Gallery"]) {
        
        [self FetchVenueGallery:_strVenueId];
    }
    else
    {
        [self FetchEventPost:_strId];
    }
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction Method
-(IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -  AWS Method
-(void)FetchVenueGallery:(NSString *)strVenueId
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
                                                 @":val1" : strVenueId
                                                 };
    [[dynamoDBObjectMapper scan:[KN_StagingVenueGallery class]
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
                 arrEventPost= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_StagingVenueGallery *chat in paginatedOutput.items) {
                     
                     [arrEventPost addObject:chat];
                     
                 }
                 
                 if (arrEventPost.count>0) {
                     
                     lblAlert.hidden = YES;
                     _collectionGallry.hidden = NO;
                     NSSortDescriptor *sortDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"CreatedAt"
                                                                                     ascending:YES];
                     NSArray *arrayMesage = [arrEventPost
                                             sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                     arrEventPost = [NSMutableArray arrayWithArray:arrayMesage];
                     _collectionGallry.hidden = NO;
                     lblAlert.hidden = YES;
                     [_collectionGallry reloadData];
                 }
                 else
                 {
                     lblAlert.hidden = NO;
                     _collectionGallry.hidden = YES;
                     lblAlert.text = @"This Venue has no image video right now";
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
    
}
-(void)FetchEventPost:(NSString *)strEventId
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"EventId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : strEventId
                                                 };
    [[dynamoDBObjectMapper scan:[KN_Staging_PostEvent class]
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
                 arrEventPost= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_Staging_PostEvent *chat in paginatedOutput.items) {
                     
                     [arrEventPost addObject:chat];
                     
                 }
                 
                 if (arrEventPost.count>0) {
                     
                     lblAlert.hidden = YES;
                     _collectionGallry.hidden = NO;
                     NSSortDescriptor *sortDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"CreatedAt"
                                                                                     ascending:YES];
                     NSArray *arrayMesage = [arrEventPost
                                             sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                     arrEventPost = [NSMutableArray arrayWithArray:arrayMesage];
                     _collectionGallry.hidden = NO;
                     lblAlert.hidden = YES;
                     [_collectionGallry reloadData];
                 }
                 else
                 {
                     lblAlert.hidden = NO;
                     _collectionGallry.hidden = YES;
                     lblAlert.text = @"No comment item found";
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
    
}
# pragma mark UICollectionView Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    
    return arrEventPost.count;
    
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    PostCellCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    
    NSString *strForEventImageName = [[[arrEventPost valueForKey:@"Image"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSURL *url;
    if ([_strChek isEqualToString:@"Gallery"]) {
        
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_VENUEGALLERY_IMAGE_URL,strForEventImageName]];
    }
    else
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_POST_EVENT_IMAGE_URL,strForEventImageName]];
    }
    
    [cell.imageGallry sd_setImageWithURL:url
                        placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    cell.lblName.text = [[arrEventPost valueForKey:@"Name"]objectAtIndex:indexPath.row];
    cell.lblName.hidden = YES;
    
    if ([[[arrEventPost valueForKey:@"Type"]objectAtIndex:indexPath.row] isEqualToString:@"Video"]) {
        
        cell.btnplay.hidden = NO;
    }
    else
    {
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
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    VenueImageViewController *Vc = [storyboard instantiateViewControllerWithIdentifier:@"VenueImageViewController"];
    
    NSString *strForEventImageName = [[[arrEventPost valueForKey:@"Image"]objectAtIndex:indexPath.row]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    Vc.strImage = strForEventImageName;
    Vc.strName = [[arrEventPost valueForKey:@"Name"]objectAtIndex:indexPath.row];
    Vc.strUserImage = [[arrEventPost valueForKey:@"UserImage"]objectAtIndex:indexPath.row];
    Vc.dicPostDetails = [arrEventPost objectAtIndex:indexPath.row];
    if ([_strChek isEqualToString:@"Gallery"]) {
        Vc.strEventName =  [[arrEventPost valueForKey:@"PostComment"]objectAtIndex:indexPath.row];
        Vc.strchek = @"Gallery";
    }
    else
    {
        Vc.strEventName = _strEventName;
    }
    Vc.eventDateTime =[[arrEventPost valueForKey:@"CreatedAt"]objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:Vc animated:NO];
}
//    else
//    {
//    VenueOwnerCommentViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueOwnerCommentViewController"];
//    Vc.strPostId = [[arrEventPost valueForKey:@"Id"]objectAtIndex:indexPath.row];
//    Vc.dicPostDetails = [arrEventPost objectAtIndex:indexPath.row];
//
//
//    [self.navigationController pushViewController:Vc animated:YES];
//    }

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
