//
//  VenueEventDetailViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 03/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VenueEventDetailViewController.h"
#import "UserEventTableViewCell.h"
#import "VenueCheckInViewController.h"
#import "MainViewController.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "SpecialCollectionViewCell.h"
#import "CreateEventViewController.h"
#import "KN_EventCheckIn.h"
#import "KN_User.h"
#import "KN_Staging_PostEvent.h"
#import "VenueOwnerHomeViewController.h"
#import "NSDate+NVTimeAgo.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "VenueOwnerCommentViewController.h"
#import "ProfileScreenViewController.h"
#define BTN_BACK 0
@interface VenueEventDetailViewController ()<UIGestureRecognizerDelegate>
{
    NSMutableArray *arrImage;
    UIButton *btnImageBubble;
    CGRect screenBounds;
    NSArray *arrSpecialIcon;
    UIButton *btnChkIn;
    NSMutableArray *arrCheckInUser;
    NSMutableArray *arrUsers;
    NSMutableArray *arrEventPost;
    NSMutableDictionary *dictUserIds;
}

@end

@implementation VenueEventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
     mainViewController.leftViewSwipeGestureEnabled = NO;

    tblEvent.estimatedRowHeight = 80;
    tblEvent.rowHeight = UITableViewAutomaticDimension;
    
      tblEvent.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    arrImage = [[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"checkin1"],[UIImage imageNamed:@"checkin2"],[UIImage imageNamed:@"checkin3"],[UIImage imageNamed:@"checkInCircleNo"],nil];
    
    arrEventPost = [[NSMutableArray alloc]init];
    
    lblEventName.text = [_dicEventDetail valueForKey:@"Name"];
    lblDescription.text = [_dicEventDetail valueForKey:@"Description"];
    lblDate.text =  [[Singlton sharedManager]changeStringToDate:[_dicEventDetail valueForKey:@"EventDate"]];
    
    NSString *strForEventImageName = [[_dicEventDetail valueForKey:@"Image"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    strForEventImageName = [strForEventImageName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *strimageURL = [NSString stringWithFormat:@"%@%@",BASE_VENUE_EVENT_IMAGE_URL,strForEventImageName];
    [imgEvent sd_setImageWithURL:[NSURL URLWithString:strimageURL]
                     placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    lblEventType.text = [_dicEventDetail valueForKey:@"Type"];
    NSSet *setSpecial = [_dicEventDetail valueForKey:@"Special"];
    arrSpecialIcon = [setSpecial allObjects];
    [collectionSpecial reloadData];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
       [self  FetchCheckInUsers];
}
-(IBAction)clickButtons:(id)sender
{
     UIButton * btnSelected = (UIButton *) sender;
    switch (btnSelected.tag) {
        case BTN_BACK:
        {
            //[self.navigationController popViewControllerAnimated:YES];VenueOwnerHomeViewController
            VenueOwnerHomeViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueOwnerHomeViewController"];
            [self.navigationController pushViewController:Vc animated:NO];
        }
            break;
            
        default:
            break;
    }
}
-(void)clickVenueImage:(UIButton *) sender
{
    VenueCheckInViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueCheckInViewController"];
    Vc.arrCheckInUserList = arrUsers;
    [self.navigationController pushViewController:Vc animated:YES];
}

#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return arrEventPost.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 500; // customize the height
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *CellIdentifier = @"Cell";
    
    UserEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UserEventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.btnTotalComents.tag = indexPath.row;
    [cell.btnTotalComents addTarget:self
                             action:@selector(clickCommentBtn:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    
    
    NSString *strForEventImageName = [[[arrEventPost valueForKey:@"Image"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_POST_EVENT_IMAGE_URL,strForEventImageName]];
    
    [cell.imgEvent sd_setImageWithURL:url
                     placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    NSString *strForUserImageName = [[[arrEventPost valueForKey:@"UserImage"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *Userurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,strForUserImageName]];
    
    [cell.imgUserProfile sd_setImageWithURL:Userurl
                           placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    cell.lblUserName.text = [[arrEventPost valueForKey:@"Name"]objectAtIndex:indexPath.row];
    
    NSNumber *numberDate = [[arrEventPost valueForKey:@"CreatedAt"]objectAtIndex:indexPath.row];
    NSDate *postdate = [NSDate dateWithTimeIntervalSince1970:[numberDate doubleValue]];
    NSString *strPostDate = [[Singlton sharedManager]convertDateToString:postdate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSDate *myDate = [formatter dateFromString:strPostDate];
    [formatter setDateFormat:@"MMMM d,yyyy hh:mm a"];
    NSString *strFate =[formatter stringFromDate:myDate];
    
    
    NSString *ago = [myDate formattedAsTimeAgo];
    cell.lblTime.text = ago;
    cell.lblDescription.text = [[arrEventPost valueForKey:@"PostComment"]objectAtIndex:indexPath.row];
    cell.lblDate.text =  strFate;
    cell.lblCommentNumber.text = [[arrEventPost valueForKey:@"commentCount"]objectAtIndex:indexPath.row];
    
    NSString *strPlay = [[arrEventPost valueForKey:@"Type"]objectAtIndex:indexPath.row];
    if ([strPlay isEqualToString:@"Photo"]) {
        
        cell.btnPlay.hidden = YES;
    }
    else
    {
        cell.btnPlay.hidden = NO;
    }
    
    cell.btnPlay.tag = indexPath.row;
    
    [cell.btnPlay addTarget:self
                     action:@selector(clickPlayVideo:)
           forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.view.tag = indexPath.row;
    cell.imgUserProfile.tag = indexPath.row;
    cell.imgUserProfile.userInteractionEnabled = YES;
    [cell.imgUserProfile addGestureRecognizer:tapGestureRecognizer];
    
    UITapGestureRecognizer *tapName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserName:)];
    tapName.numberOfTapsRequired = 1;
    tapName.delegate = self;
    cell.lblUserName.tag = indexPath.row;
    cell.lblUserName.userInteractionEnabled = YES;
    [cell.lblUserName addGestureRecognizer:tapName];
    
          return cell;
        
    }

#pragma mark -  UICollectionView Method
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  
        
        return arrSpecialIcon.count;
    
   
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
        return CGSizeMake(84, 66);
    

}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //top, left, bottom, right
    return UIEdgeInsetsMake(0, 10, 0, 10);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SpecialCollectionViewCell *cell = (SpecialCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (!cell)
    {
        cell  = [collectionSpecial dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
    }
    cell.lblName.text = [arrSpecialIcon objectAtIndex:indexPath.row];
    cell.imgIcon.image = [UIImage imageNamed:[arrSpecialIcon objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - IBAction Method
- (IBAction)clickEditButton:(id)sender {
    
    CreateEventViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateEventViewController"];
    Vc.strEventCheck = @"EventDetail";
    Vc.dicEventDetail = _dicEventDetail;
    Vc.imgEvent = imgEvent.image;
    [self.navigationController pushViewController:Vc animated:YES];
    
}
-(void)clickCommentBtn:(UIButton *)sender
{
    VenueOwnerCommentViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueOwnerCommentViewController"];
    Vc.strPostId = [[arrEventPost valueForKey:@"Id"]objectAtIndex:sender.tag];
    Vc.dicPostDetails = [arrEventPost objectAtIndex:sender.tag];
    [self.navigationController pushViewController:Vc animated:YES];
}

-(IBAction)clickImage:(UITapGestureRecognizer*)recognizer
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Consumer" bundle: nil];
    ProfileScreenViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileScreenViewController"];
     [Singlton sharedManager].dictVenueEventDetailInfo = _dicEventDetail;
    [Singlton sharedManager].strComingFromVenueOwnerCommentScreen = @"no";
    [Singlton sharedManager].dictNonLoginUser = [arrEventPost objectAtIndex:recognizer.view.tag];
    
    [self.navigationController pushViewController:ivc animated:YES];
}
-(IBAction)clickUserName:(UITapGestureRecognizer*)recognizer
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Consumer" bundle: nil];
    ProfileScreenViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileScreenViewController"];
    [Singlton sharedManager].dictVenueEventDetailInfo = _dicEventDetail;
      [Singlton sharedManager].strComingFromVenueOwnerCommentScreen = @"no";
    [Singlton sharedManager].dictNonLoginUser = [arrEventPost objectAtIndex:recognizer.view.tag];
    [self.navigationController pushViewController:ivc animated:YES];
}
#pragma mark - AWS Methods
-(void)FetchCheckInUsers
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
                                                 @":val1" : [_dicEventDetail valueForKey:@"Id"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_EventCheckIn class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 
                 self.view.userInteractionEnabled = YES;
                 arrCheckInUser= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_EventCheckIn *chat in paginatedOutput.items) {
                     
                     [arrCheckInUser addObject:chat];
                     
                 }
                 if (arrCheckInUser.count>0) {
                     
                     lblEventCheckIn.hidden = NO;
                     viewSlider.hidden = NO;
                     imgLine.hidden = NO;
                     [tblEvent setTranslatesAutoresizingMaskIntoConstraints:NO];
                     tblEvent.frame = CGRectMake(tblEvent.frame.origin.x, imgLine.frame.origin.y+imgLine.frame.size.height+10, tblEvent.frame.size.width,tblEvent.frame.size.height);
                     [self FetchAllCheckInUser];
                 }
                 else
                 {
                     lblEventCheckIn.hidden = YES;
                     viewSlider.hidden = YES;
                     imgLine.hidden = YES;
                     [tblEvent setTranslatesAutoresizingMaskIntoConstraints:NO];
                     tblEvent.frame = CGRectMake(tblEvent.frame.origin.x, imgLine1.frame.origin.y+imgLine1.frame.size.height+10, tblEvent.frame.size.width,tblEvent.frame.size.height);
                     [self FetchEventPost];
                 }
             });
         }
         return nil;
     }];
}
-(void)FetchAllCheckInUser
{
    dictUserIds = [[NSMutableDictionary alloc]init];
    
    NSString *strFilter ;
    
    for (int i=0; i<arrCheckInUser.count; i++)
    {
        NSString *str = [NSString stringWithFormat:@":val%d",i+1];
        
        NSString *strcontains = [NSString stringWithFormat:@"contains(#P,%@)",str];
        
        [dictUserIds setObject:[[arrCheckInUser valueForKey:@"UserId"]objectAtIndex:i] forKey:str];
        
        if (strFilter.length>0)
        {
            strFilter = [NSString stringWithFormat:@"%@ OR %@",strFilter,strcontains];
        }
        else
        {
            strFilter = [NSString stringWithFormat:@"%@",strcontains];
        }
        strFilter = [NSString stringWithFormat:@"(%@)",strFilter];
    }
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"UserId"]
                                                };
    scanExpression.filterExpression = strFilter;
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = dictUserIds;
    [[dynamoDBObjectMapper scan:[KN_User class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
               
                 self.view.userInteractionEnabled = YES;
                 arrUsers= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_User *chat in paginatedOutput.items) {
                     
                     [arrUsers addObject:chat.dictionaryValue];
                     
                 }
                 [self FetchEventPost];
                 [self addCheckInUsersOnView:arrUsers];
                 
             });
             
         }
         
         return nil;
         
     }];
    
    
}
-(void)FetchEventPost
{
    self.view.userInteractionEnabled = NO;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"EventId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [_dicEventDetail valueForKey:@"Id"]
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
                     tblEvent.hidden = NO;
                     NSSortDescriptor *sortDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"CreatedAt"
                                                                                     ascending:YES];
                     NSArray *arrayMesage = [arrEventPost
                                             sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                     arrEventPost = [NSMutableArray arrayWithArray:arrayMesage];
                     [tblEvent reloadData];
                 }
                 else
                 {
                     lblAlert.hidden = NO;
                     tblEvent.hidden = YES;
                     
                     float sizeOfContent = 0;
                     UIView *lLast = [scrollView.subviews lastObject];
                     NSInteger wd = lLast.frame.origin.y;
                     NSInteger ht = lLast.frame.size.height;
                     
                     sizeOfContent = wd+ht;
                     if(IS_IPHONE_5){
                         scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, sizeOfContent+300);
                     }
                     else{
                        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, sizeOfContent+200);
                     }
                     
                     
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
    
}
-(void)addCheckInUsersOnView:(NSMutableArray*)arryUsers
{
    int xOffset = 0;
    if (IS_IPHONE_5)
    {
        xOffset = 14;
    }
    for(int index=0; index < arryUsers.count; index++)
    {
        
        if (IS_IPHONE_5)
        {
            btnImageBubble = [[UIButton alloc] initWithFrame:CGRectMake(xOffset,lblEventCheckIn.frame.size.height+lblEventCheckIn.frame.origin.y+5,46, 46)];
            
        }
        else
        {
            btnImageBubble = [[UIButton alloc] initWithFrame:CGRectMake(xOffset,5,46, 46)];
            
            
        }
        btnImageBubble.layer.cornerRadius = btnImageBubble.frame.size.height/2;
        btnImageBubble.clipsToBounds = YES;
        btnImageBubble.tag = index;
        //set button image
        NSString *strForEventImageName = [[[arryUsers valueForKey:@"UserImage"]objectAtIndex:index] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
        
        
        
        if (btnImageBubble.tag==3) {
            
            NSInteger userCount = arryUsers.count-3;
            btnImageBubble.backgroundColor = [UIColor colorWithRed:83/255.0 green:186/255.0 blue:231/255.0 alpha:1];
            [btnImageBubble setTitle:[NSString stringWithFormat: @"+ %ld", (long)userCount] forState:UIControlStateNormal];
        }
        else
        {
            [btnImageBubble sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
            
        }
        [btnImageBubble addTarget:self action:@selector(clickVenueImage:) forControlEvents:UIControlEventTouchUpInside];
        
        if (index<4) {
            if (IS_IPHONE_5)
            {
                [scrollView addSubview:btnImageBubble];
                [scrollView bringSubviewToFront:btnImageBubble];
            }
            else
            {
                [viewSlider addSubview:btnImageBubble];
            }
        }
        xOffset+=30;
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

@end
