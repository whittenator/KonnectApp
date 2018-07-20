//
//  ProfileScreenViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 28/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ProfileScreenViewController.h"
#import "ProfileUserSelfInfoCell.h"
#import "ProfilePostImageCell.h"
#import "EditProfileViewController.h"
#import "CommentScreenViewController.h"
#import "UIImageView+WebCache.h"
#import <AWSS3/AWSS3.h>
#import "AWSLambda/AWSLambda.h"
#import "KN_User.h"
#import "KN_Notification.h"
#import "KN_Staging_PostEvent.h"
#import "NSDate+NVTimeAgo.h"
#import "FriendsListScreenVC.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "VenueOwnerCommentViewController.h"
#import "VenueEventDetailViewController.h"
@interface ProfileScreenViewController ()
{
    BOOL isSelfProfile;
     BOOL isAlreadyFollowing;
    UIImage* imgUserLocal;
    NSURL *imageUrl;
    NSMutableArray *arrSelfFollowing;
    NSMutableArray *arrSelfFollower;
    NSMutableArray *arrNonSelfFollowing;
    NSMutableArray *arrNonSelfFollower;
    NSMutableArray *arrEventPost;
}
@end

@implementation ProfileScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tblProfile.estimatedRowHeight = 80;
    _tblProfile.rowHeight = UITableViewAutomaticDimension;
    _tblProfile.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    arrSelfFollowing = [NSMutableArray new];
    arrSelfFollower = [NSMutableArray new];
    arrNonSelfFollowing = [NSMutableArray new];
    arrNonSelfFollower = [NSMutableArray new];
    dictSelfProfile = [NSMutableDictionary new];
    _dictUserProfile = [NSMutableDictionary new];
    dictSelfProfile = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"] mutableCopy];
    arrSelfFollowing = [[dictSelfProfile valueForKey:@"Following"] mutableCopy];
    arrSelfFollower = [[dictSelfProfile valueForKey:@"Followers"] mutableCopy];
    _dictUserProfile = (NSMutableDictionary *)[Singlton sharedManager].dictNonLoginUser;
    if(!([[_dictUserProfile valueForKey:@"UserId"]isEqualToString:[dictSelfProfile valueForKey:@"UserId"]]))
    {
        isSelfProfile = NO;
        NSLog(@"dict Info is %@",_dictUserProfile);
        [self CallOtherUserProfile];
    }
    else
    {
        isSelfProfile = YES;
       
        [self CallSelfUserProfile];
        [self FetchEventPost:[dictSelfProfile valueForKey:@"UserId"]];
    }
    //arrTableData =[NSMutableArray arrayWithObjects:@"UserPostImageCell", nil];
}

#pragma mark - To Check whether NonLogin user is Following the Login User

-(void)CallOtherUserProfile
{
  
    isAlreadyFollowing = NO;
    //Below code is to check whether login User has following the particular User or not
    for(int i = 0 ;i< arrSelfFollowing.count ; i++)
    {
        if([[arrSelfFollowing objectAtIndex:i]isEqualToString:[_dictUserProfile valueForKey:@"UserId"]])
        {
            isAlreadyFollowing = YES;
        }
    }
    
    [self GetAnotherUserFullInfo];
    
}

#pragma mark - Fetching another userprofile Info From DB
-(void)GetAnotherUserFullInfo
{
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
   [[Singlton sharedManager]showHUD];
        self.view.userInteractionEnabled = NO;
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        
        AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
        scanExpression.expressionAttributeNames = @{
                                                    @"#P": [NSString stringWithFormat:@"%@", @"UserId"]
                                                    };
        scanExpression.filterExpression = @"(#P = :val1)";
        //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
        scanExpression.expressionAttributeValues = @{
                                                     @":val1" : [_dictUserProfile valueForKey:@"UserId"]
                                                     };
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
                     
                     [[Singlton sharedManager]killHUD];
                     self.view.userInteractionEnabled = YES;
                     NSMutableArray  *arrUserInfo = [NSMutableArray new];
                     AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                     for (KN_User *chat in paginatedOutput.items) {
                         
                         [arrUserInfo addObject:chat];
                         
                     }
                     
                     if (arrUserInfo.count>0) {
                         _dictUserProfile = [arrUserInfo objectAtIndex:0];
                         arrNonSelfFollowing = [[_dictUserProfile valueForKey:@"Following"]allObjects].mutableCopy;
                         arrNonSelfFollower = [[_dictUserProfile valueForKey:@"Followers"]allObjects].mutableCopy;
                         self.view.userInteractionEnabled = YES;
                        [self UpdateUserProfileImageAndLabelData];
                        [self FetchEventPost:[_dictUserProfile valueForKey:@"UserId"]];
                        
                     }
                     else
                     {
                         self.view.userInteractionEnabled = YES;
                         [[Singlton sharedManager]killHUD];
                       
                         
                     }
                     
                 });
                 
             }
             
             return nil;
             
         }];
    
}

#pragma mark ------

-(void)CallSelfUserProfile
{
     [self GetProfileImageURL];

}

-(void)GetProfileImageURL
{
        if(![[dictSelfProfile valueForKey:@"UserImage"]isEqualToString:@"NA"])
        {
            if([[dictSelfProfile valueForKey:@"fblogin"]isEqualToString:@"YES"])
            {
                
                if([[dictSelfProfile valueForKey:@"FBProfilePicChanged"]isEqualToString:@"YES"])
                {
                    if([[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"]!=nil)
                    {
                        NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"];
                        imgUserLocal = [UIImage imageWithData:imageData];
                        
                    }
                    else
                    {
                        NSString *strForEventImageName = [[dictSelfProfile valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                        imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
                        
                    }
                }
                else
                {
                   imageUrl = [[NSURL alloc] initWithString:[dictSelfProfile valueForKey:@"UserImage"]];
                }
            }
            else
            {
                if([[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"]!=nil)
                {
                    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"];
                   imgUserLocal = [UIImage imageWithData:imageData];
                    
                    
                }
                else{
                    NSString *strForEventImageName = [[dictSelfProfile valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                    imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
                }
                
                
            }
            
           
        }
    else
    {
        [_imgUserImage sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
         [_imgUserBackground sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
    }
    [self UpdateUserProfileImageAndLabelData];
}

-(void)UpdateUserProfileImageAndLabelData
{
    if(isSelfProfile == YES)
    {
        ////Self User Profile
        if(arrSelfFollower.count>0)
        {
            if(arrSelfFollower.count-1 > 0)
            {
                _lblFollowers.text = [NSString stringWithFormat:@"%lu",(unsigned long)arrSelfFollower.count-1];
            }
            else
            {
                _lblFollowers.text = @"0";
            }
        }
        else
        {
            _lblFollowers.text = @"0";
        }
        if(arrSelfFollowing.count>0)
        {
            if(arrSelfFollowing.count-1 > 0)
            {
                _lblFollowing.text = [NSString stringWithFormat:@"%lu",(unsigned long)arrSelfFollowing.count-1];
            }
            else
            {
                _lblFollowing.text = @"0";
            }
        }
        else
        {
            _lblFollowing.text = @"0";
        }
        _imgEditProfile.hidden = NO;
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"]!=nil)
        {
            _imgUserImage.image = imgUserLocal;
            _imgUserBackground.image = imgUserLocal;
        }
        else
        {
            [_imgUserImage sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
             [_imgUserBackground sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
        }
          [[Singlton sharedManager]imageProfileRounded:_imgUserImage withFlot:_imgUserImage.frame.size.width/2 withCheckLayer:NO];
        [_btnEditProfile addTarget:self action:@selector(funcGotoEditScreen) forControlEvents:UIControlEventTouchUpInside];
        
        
        if([[dictSelfProfile valueForKey:@"firstName"]isEqualToString:@"NA"]||[[dictSelfProfile valueForKey:@"lastName"]isEqualToString:@"NA"])
        {
            //_lblUserName.text =@"";
        }
        else
        {
            _lblUserName.text = [NSString stringWithFormat:@"%@ %@",[dictSelfProfile valueForKey:@"firstName"],[dictSelfProfile valueForKey:@"lastName"]].uppercaseString;
        }
        if(![[dictSelfProfile valueForKey:@"HomeLocation"]isEqualToString:@"NA"])
        {
            _viewLocation.hidden = NO;
            _lblLocation.text = [dictSelfProfile valueForKey:@"HomeLocation"];

        }
        else
        {
             _viewLocation.hidden = YES;
            _lblLocation.text = @"Dunkirk, New York";
        }
        if([Singlton sharedManager].strComingFromVenueOwnerCommentScreen!=nil)
        {
            _btnBack.hidden = NO;
            _btnHameBurgerIcon.hidden = YES;
            _btnEditProfile.hidden = YES;
            _imgEditProfile.hidden = YES;
        }
        else
        {
            _btnBack.hidden = YES;
            _btnHameBurgerIcon.hidden = NO;
             _btnEditProfile.hidden = NO;
        }
    }
    else
    {
        //Another User Profile
        if(arrNonSelfFollower.count>0)
        {
            if(arrNonSelfFollower.count-1 > 0)
            {
                _lblFollowers.text = [NSString stringWithFormat:@"%lu",(unsigned long)arrNonSelfFollower.count-1];
            }
            else
            {
                _lblFollowers.text = @"0";
            }
        }
        else
        {
            _lblFollowers.text = @"0";
        }
        if(arrNonSelfFollowing.count>0)
        {
            if(arrNonSelfFollowing.count-1 > 0)
            {
                _lblFollowing.text = [NSString stringWithFormat:@"%lu",(unsigned long)arrNonSelfFollowing.count-1];
            }
            else
            {
                _lblFollowing.text = @"0";
            }
        }
        else
        {
            _lblFollowing.text = @"0";
        }
        NSString *strForEventImageName = [[_dictUserProfile valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
        [_imgUserImage sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
         [_imgUserBackground sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
         [[Singlton sharedManager]imageProfileRounded:_imgUserImage withFlot:_imgUserImage.frame.size.width/2 withCheckLayer:NO];
        if([Singlton sharedManager].strComingFromVenueOwnerCommentScreen!=nil)
        {
            _btnBack.hidden = NO;
            _btnHameBurgerIcon.hidden = YES;
            _btnEditProfile.hidden = YES;
            _imgEditProfile.hidden = YES;
        }
        else
        {
            _btnBack.hidden = YES;
            _btnHameBurgerIcon.hidden = NO;
            _btnEditProfile.hidden = NO;
             _imgEditProfile.hidden = YES;
        }
       
    [_btnBack addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
        if([[_dictUserProfile valueForKey:@"Firstname"]isEqualToString:@"NA"]||[[_dictUserProfile valueForKey:@"Lastname"]isEqualToString:@"NA"])
        {
            _lblUserName.text =@"";
        }
        else
        {
            _lblUserName.text = [NSString stringWithFormat:@"%@ %@",[_dictUserProfile valueForKey:@"Firstname"],[_dictUserProfile valueForKey:@"Lastname"]].uppercaseString;
        }
        if(![[_dictUserProfile valueForKey:@"HomeLocation"]isEqualToString:@"NA"])
        {
            _viewLocation.hidden = NO;
            _lblLocation.text = [dictSelfProfile valueForKey:@"HomeLocation"];
            
        }
        else
        {
              _viewLocation.hidden = YES;
            _lblLocation.text = @"Dunkirk, New York";
        }
        
        if(isAlreadyFollowing == YES)
        {
             _tblProfile.hidden = NO;
            [_btnEditProfile addTarget:self action:@selector(funcFollowUnFollowUser)
                      forControlEvents:UIControlEventTouchUpInside];
            _btnEditProfile.userInteractionEnabled = YES;
              [_btnEditProfile setTitle:@"Following" forState:UIControlStateNormal];
        }
        else
        {
             _tblProfile.hidden = YES;
            [_btnEditProfile addTarget:self action:@selector(funcFollowUnFollowUser)
                      forControlEvents:UIControlEventTouchUpInside];
             [_btnEditProfile setTitle:@"Follow" forState:UIControlStateNormal];
            _btnEditProfile.userInteractionEnabled = YES;
           
        }
       
    }
}

#pragma mark - TableView Delegate and DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return arrEventPost.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSString *quantityCellIdentifier = @"UserPostImageCell";
         ProfilePostImageCell *cell = (ProfilePostImageCell *)[tableView dequeueReusableCellWithIdentifier:quantityCellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
        cell.btnComment.tag = indexPath.row;
        [cell.btnComment addTarget:self
                            action:@selector(funcGotoCommentsScreen:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    NSString *strForEventImageName = [[[arrEventPost valueForKey:@"Image"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_POST_EVENT_IMAGE_URL,strForEventImageName]];
    
    [cell.imgPostImageCell sd_setImageWithURL:url
                     placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    NSString *strForUserImageName = [[[arrEventPost valueForKey:@"UserImage"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *Userurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,strForUserImageName]];
    
    [cell.imgUserPostCell sd_setImageWithURL:Userurl
                           placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    cell.imgUserNameCell.text = [[arrEventPost valueForKey:@"Name"]objectAtIndex:indexPath.row];
    
    NSNumber *numberDate = [[arrEventPost valueForKey:@"CreatedAt"]objectAtIndex:indexPath.row];
    NSDate *postdate = [NSDate dateWithTimeIntervalSince1970:[numberDate doubleValue]];
    NSString *strPostDate = [[Singlton sharedManager]convertDateToString:postdate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSDate *myDate = [formatter dateFromString:strPostDate];
    [formatter setDateFormat:@"MMMM d,yyyy hh:mm a"];
    //NSString *strFate =[formatter stringFromDate:myDate];
    NSString *ago = [myDate formattedAsTimeAgo];
    cell.lblTimeCell.text = ago;
    cell.lblAddress.text =  [[arrEventPost valueForKey:@"PostAddress"]objectAtIndex:indexPath.row];
    cell.lblTotalCommentCell.text = [[arrEventPost valueForKey:@"commentCount"]objectAtIndex:indexPath.row];
    
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
        
      return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 500; // customize the height
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}



#pragma mark - Implementation of Follow and Following functionality
-(void)funcFollowUnFollowUser
{
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    if(isAlreadyFollowing)
    {
        [self CallUnfollowuser];
    }
    else
    {
        [self CallFollowUserNUpdateSelfFollowingArray];
    }
}

- (void)CallUnfollowuser
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Unfollow"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                   [self CallUnFollowUserNUpdateSelfFollowingArray];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)CallUnFollowUserNUpdateSelfFollowingArray
{
    self.view.userInteractionEnabled = NO;
    [arrSelfFollowing removeObject:[_dictUserProfile valueForKey:@"UserId"]];
    [[Singlton sharedManager]showHUD];
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
    AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    
    hashKeyValue.S = [dictSelfProfile valueForKey:@"UserId"];
    updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_User" : @"User";
    updateInput.key = @{@"UserId" : hashKeyValue };
    
    AWSDynamoDBAttributeValue *newPrice8 = [AWSDynamoDBAttributeValue new];
    newPrice8.SS = arrSelfFollowing;
    AWSDynamoDBAttributeValueUpdate *valueUpdate8 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate8.value = newPrice8;
    valueUpdate8.action = AWSDynamoDBAttributeActionPut;
    updateInput.attributeUpdates = @{@"Following":valueUpdate8};
    updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
    
    [[dynamoDB updateItem:updateInput]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                  [arrSelfFollowing addObject:[_dictUserProfile valueForKey:@"UserId"]];
                 [dictSelfProfile setValue:arrSelfFollowing forKey:@"Following"];
                 [[NSUserDefaults standardUserDefaults]setValue:dictSelfProfile forKey:@"loginUser"];
                 dictSelfProfile = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"] mutableCopy];
                 [[Singlton sharedManager] alert:self title:Message message:@"Please try again"];
                 self.view.userInteractionEnabled = YES;
             });
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 isAlreadyFollowing = YES;
                 [dictSelfProfile setValue:arrSelfFollowing forKey:@"Following"];
                 [[NSUserDefaults standardUserDefaults]setValue:dictSelfProfile forKey:@"loginUser"];
                 dictSelfProfile = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"] mutableCopy];
                 [self UpdateUserProfileImageAndLabelData];
                 [self CallNonSelfUserUnfollowerNUpdateFollowerArray];
                
                 self.view.userInteractionEnabled = YES;
             });
             
             
             
         }
         return nil;
     }];
    
}

-(void)CallLambdaFuncForSendingNoti
{
AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
  NSDictionary *parameters = @{@"SenderUserId":[dictSelfProfile valueForKey:@"UserId"],
                                 @"ReceiverUserId":[_dictUserProfile valueForKey:@"UserId"],
                                 @"Message":[NSString stringWithFormat:@"%@ %@ has followed you!",[dictSelfProfile valueForKey:@"firstName"],[dictSelfProfile valueForKey:@"lastName"]],
                                 @"Type":@"follow",
                                  @"ItemId":[dictSelfProfile valueForKey:@"UserId"]
                                 };
    
    [[lambdaInvoker invokeFunction:[UserMode isEqualToString:@"Test"] ? @"KON_sendNotification":@"KONProd_sendNotification"
                        JSONObject:parameters] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            self.view.userInteractionEnabled = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
            
            NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            NSLog(@"Result: %@", task.result);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
                
            });
        }
        return nil;
    }];
}

-(void)CallNonSelfUserUnfollowerNUpdateFollowerArray
 {
     self.view.userInteractionEnabled = NO;
     [arrNonSelfFollower removeObject:[dictSelfProfile valueForKey:@"UserId"]];
     [[Singlton sharedManager]showHUD];
     //NSSet *setSelfUpdatedFollowingUser = [[NSSet alloc]initWithArray:arrSelfFollowing];
     AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
     AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
     AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
     
     hashKeyValue.S = [_dictUserProfile valueForKey:@"UserId"];
     updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_User" : @"User";
     updateInput.key = @{@"UserId" : hashKeyValue };
     
     AWSDynamoDBAttributeValue *newPrice8 = [AWSDynamoDBAttributeValue new];
     newPrice8.SS = arrNonSelfFollower;
     AWSDynamoDBAttributeValueUpdate *valueUpdate8 = [AWSDynamoDBAttributeValueUpdate new];
     valueUpdate8.value = newPrice8;
     valueUpdate8.action = AWSDynamoDBAttributeActionPut;
     updateInput.attributeUpdates = @{@"Followers":valueUpdate8};
     updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
     
     [[dynamoDB updateItem:updateInput]
      continueWithBlock:^id(AWSTask *task) {
          if (task.error) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [[Singlton sharedManager]killHUD];
                   [arrNonSelfFollower addObject:[dictSelfProfile valueForKey:@"UserId"]];
                  [dictSelfProfile setValue:arrNonSelfFollower forKey:@"Followers"];
                  [Singlton sharedManager].dictNonLoginUser = (NSMutableDictionary *)_dictUserProfile ;
                   isAlreadyFollowing = YES;
                  [[Singlton sharedManager] alert:self title:Message message:@"Please try again"];
                  self.view.userInteractionEnabled = YES;
              });
              NSLog(@"The request failed. Error: [%@]", task.error);
          }
          if (task.result) {
              
              dispatch_async(dispatch_get_main_queue(), ^{
                 [dictSelfProfile setValue:arrNonSelfFollower forKey:@"Followers"];
                  isAlreadyFollowing = NO;
                [Singlton sharedManager].dictNonLoginUser = (NSMutableDictionary *)_dictUserProfile ;
                  [self UpdateUserProfileImageAndLabelData];
                  [self GetAllNotifications:[_dictUserProfile valueForKey:@"UserId"]];
              });
              
              
              
          }
          return nil;
      }];
 }

-(void)GetAllNotifications:(NSString *)strNonLoginUserId
{
    [[Singlton sharedManager]showHUD];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"NotificationTo"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" :strNonLoginUserId
                                                 };
    [[dynamoDBObjectMapper scan:[KN_Notification class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 NSMutableArray *arrNotifications = [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_Notification *chat in paginatedOutput.items)
                 {
                     
                     [arrNotifications addObject:chat.dictionaryValue];
                     
                 }//NotificationTo
                 [self callRemoveNotiFromTableforParticularUser:[dictSelfProfile valueForKey:@"UserId"] AndNonLoginUserId:[_dictUserProfile valueForKey:@"UserId"] AndNotiArray:arrNotifications];
             });
             
         }
         
         return nil;
         
     }];
}

-(void)callRemoveNotiFromTableforParticularUser:(NSString *)strLoginUserId AndNonLoginUserId:(NSString *)strNonLoginId AndNotiArray:(NSMutableArray *)arrNotifications
{
    NSString *strNotiId;
    int j = 0;
      BOOL IsAlreadyNotiExist = NO;
    if(arrNotifications.count>0)
    {
        for(int i =0; i<arrNotifications.count; i++)
        {
            if([[[arrNotifications objectAtIndex:i]valueForKey:@"Type"]isEqualToString:@"follow"])
            {
                if([[[arrNotifications objectAtIndex:i]valueForKey:@"NotificationBy"]isEqualToString:strLoginUserId] && [[[arrNotifications objectAtIndex:i]valueForKey:@"NotificationTo"]isEqualToString:strNonLoginId])
                {
                   
                    strNotiId = [[arrNotifications objectAtIndex:i]valueForKey:@"Id"];
                    j = i;
                    IsAlreadyNotiExist = YES;
                    break;
                    
                }
            }
        }
        if(IsAlreadyNotiExist == YES)
        {
            [self CallRemoveNotificationFromTable:strNotiId AndIndex:j AndNotiArray:arrNotifications];
        }
        else
        {
            [[Singlton sharedManager]killHUD];
            self.view.userInteractionEnabled = YES;
        }
        
    }
    else
    {
        [[Singlton sharedManager]killHUD];
        self.view.userInteractionEnabled = YES;
    }
    
}

-(void)CallRemoveNotificationFromTable:(NSString *)strNotiId AndIndex:(int)index AndNotiArray:(NSMutableArray *)arrNotifications
{
    KN_Notification *notiDetail = [KN_Notification new];
    notiDetail.Id = strNotiId ;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper remove:notiDetail]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 
             });
             NSLog(@"The request failed. Error: [%@]", task.error);
         } else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 //@"" [self InsertingIntoNotiTable:index];
                 NSLog(@"item Deleted successfully");
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 [arrNotifications removeObjectAtIndex:index];
                 
             });
             
             
             
         }
         return nil;
     }];
}
-(void) CallFollowUserNUpdateSelfFollowingArray
{
    self.view.userInteractionEnabled = NO;
    [arrSelfFollowing addObject:[[_dictUserProfile valueForKey:@"UserId"] mutableCopy]];
     [[Singlton sharedManager]showHUD];
    //NSSet *setSelfUpdatedFollowingUser = [[NSSet alloc]initWithArray:arrSelfFollowing];
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
        AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
        AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    
        hashKeyValue.S = [dictSelfProfile valueForKey:@"UserId"];
        updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_User" : @"User";
        updateInput.key = @{ @"UserId" : hashKeyValue };
        
        AWSDynamoDBAttributeValue *newPrice8 = [AWSDynamoDBAttributeValue new];
        newPrice8.SS = arrSelfFollowing;
        AWSDynamoDBAttributeValueUpdate *valueUpdate8 = [AWSDynamoDBAttributeValueUpdate new];
        valueUpdate8.value = newPrice8;
        valueUpdate8.action = AWSDynamoDBAttributeActionPut;
        updateInput.attributeUpdates = @{@"Following":valueUpdate8};
        updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
        
        [[dynamoDB updateItem:updateInput]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[Singlton sharedManager]killHUD];
                      [arrSelfFollowing removeObject:[[_dictUserProfile valueForKey:@"UserId"] mutableCopy]];
                     isAlreadyFollowing = NO;
                     [dictSelfProfile setValue:arrSelfFollowing forKey:@"Following"];
                     [[NSUserDefaults standardUserDefaults]setValue:dictSelfProfile forKey:@"loginUser"];
                     dictSelfProfile = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"] mutableCopy];
                     [[Singlton sharedManager] alert:self title:Message message:@"Please try again"];
                     self.view.userInteractionEnabled = YES;
                 });
                 NSLog(@"The request failed. Error: [%@]", task.error);
             }
             if (task.result) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[Singlton sharedManager]killHUD];
                     [dictSelfProfile setValue:arrSelfFollowing forKey:@"Following"];
                     [[NSUserDefaults standardUserDefaults]setValue:dictSelfProfile forKey:@"loginUser"];
                     dictSelfProfile = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"] mutableCopy];
                     [self UpdateUserProfileImageAndLabelData];
                     [self CallNonSelfUserNUpdateFollowerNArray];
                     self.view.userInteractionEnabled = YES;
                 });
                 
                 
                 
             }
             return nil;
         }];
      
}

-(void)CallNonSelfUserNUpdateFollowerNArray
{
    self.view.userInteractionEnabled = NO;
    [arrNonSelfFollower addObject:[[dictSelfProfile valueForKey:@"UserId"] mutableCopy]];
    [[Singlton sharedManager]showHUD];
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
    AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    
    hashKeyValue.S = [_dictUserProfile valueForKey:@"UserId"];
    updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_User" : @"User";
    updateInput.key = @{ @"UserId" : hashKeyValue };
    
    AWSDynamoDBAttributeValue *newPrice8 = [AWSDynamoDBAttributeValue new];
    newPrice8.SS = arrNonSelfFollower;
    AWSDynamoDBAttributeValueUpdate *valueUpdate8 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate8.value = newPrice8;
    valueUpdate8.action = AWSDynamoDBAttributeActionPut;
    updateInput.attributeUpdates = @{@"Followers":valueUpdate8};
    updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
    
    [[dynamoDB updateItem:updateInput]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                  isAlreadyFollowing = NO;
                 [arrNonSelfFollower removeObject:[[dictSelfProfile valueForKey:@"UserId"] mutableCopy]];
                 [_dictUserProfile setValue:arrNonSelfFollower forKey:@"Followers"];
                 [Singlton sharedManager].dictNonLoginUser = (NSMutableDictionary *)_dictUserProfile ;
                 [[Singlton sharedManager] alert:self title:Message message:@"Please try again"];
                 self.view.userInteractionEnabled = YES;
             });
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 isAlreadyFollowing = YES;
                 [_dictUserProfile setValue:arrNonSelfFollower forKey:@"Followers"];
                [Singlton sharedManager].dictNonLoginUser = (NSMutableDictionary *)_dictUserProfile ;
                 [self UpdateUserProfileImageAndLabelData];
                 [self CallLambdaFuncForSendingNoti];
                 self.view.userInteractionEnabled = YES;
             });
             
             
             
         }
         return nil;
     }];
}

#pragma mark - Costom Methods

-(void)clickPlayVideo:(UIButton *) sender
{
    
    NSString *strForEventVideo = [[[arrEventPost valueForKey:@"Video"]objectAtIndex:sender.tag] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_POST_EVENT_IMAGE_URL,strForEventVideo]];
    
    // create an AVPlayer
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    // create a player view controller
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    [self presentViewController:controller animated:YES completion:nil];
    controller.player = player;
    [player play];
}
-(void)funcGotoCommentsScreen:(UIButton *)sender
{
    CommentScreenViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentScreenViewController"];
    vc.strPostId = [[arrEventPost valueForKey:@"Id"]objectAtIndex:sender.tag];
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(void)funcGotoEditScreen
{
    EditProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}
-(IBAction)actionBack:(id)sender
{
    if([Singlton sharedManager].strComingFromVenueOwnerCommentScreen!=nil)
    {
        if([Singlton sharedManager].dictVenueEventDetailInfo != nil)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            VenueEventDetailViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"VenueEventDetailViewController"];
           ivc.dicEventDetail = [Singlton sharedManager].dictVenueEventDetailInfo;
            [self.navigationController pushViewController:ivc animated:NO];
        }
        else
        {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        VenueOwnerCommentViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"VenueOwnerCommentViewController"];
        ivc.strNavigationCheck = @"Present";
       ivc.strPostId = [Singlton sharedManager].strComingFromVenueOwnerCommentScreen;
        [self.navigationController pushViewController:ivc animated:NO];
    }
    }
    else
    {
    [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)FetchEventPost:(NSString *)strUserId
{
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    [[Singlton sharedManager]showHUD];
    
    
    
    self.view.userInteractionEnabled = NO;
    
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"UserId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : strUserId
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
                     _tblProfile.hidden = NO;
                     NSSortDescriptor *sortDescriptor =
                     [[NSSortDescriptor alloc] initWithKey:@"CreatedAt"
                                                 ascending:YES];
                     NSArray *arrayMesage = [arrEventPost
                                             sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                     arrEventPost = [NSMutableArray arrayWithArray:arrayMesage];
                     [_tblProfile reloadData];
                 }
                 else
                 {
                     lblAlert.hidden = NO;
                     _tblProfile.hidden = YES;
                    
                     
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
    
}

-(IBAction)GettMultipleUserDataUsingBatch:(UIButton *)sender
{
    if(isSelfProfile == YES)
    {
        if(sender.tag == 0)
        {
           
            [self GetDataForMultipleIds:arrSelfFollower AndTitle:@"Followers"];
        }
        else
        {
           [self GetDataForMultipleIds:arrSelfFollowing AndTitle:@"Followings"];
        }
        
    }
    else
    {  if(sender.tag == 0)
        {
            
            [self GetDataForMultipleIds:arrNonSelfFollower AndTitle:@"Followers"];
        }
        else
        {
            [self GetDataForMultipleIds:arrNonSelfFollowing AndTitle:@"Followings"];
        }
        
    }
}

-(void)GetDataForMultipleIds:(NSMutableArray *)arrayOfId AndTitle:(NSString *)strTitle
{
    [arrayOfId removeObject:@"NA"];
    if(arrayOfId.count>0)
    {
        FriendsListScreenVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsListScreenVC"];
        vc.arrayFriends = [NSMutableArray new];
        [vc.arrayFriends addObjectsFromArray:arrayOfId];
        vc.strTitle = strTitle;
        [self.navigationController pushViewController:vc animated:YES];
    }
  
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _dictUserProfile = nil;
    //[Singlton sharedManager].strComingFromVenueOwnerCommentScreen = nil;
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
