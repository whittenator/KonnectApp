//
//  ConsumerNotificationViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ConsumerNotificationViewController.h"
#import "ConsumerVenueEventDetailVC.h"
#import "ConsumerNotificationCell/ConsumerNotificationCell.h"
#import "AWSSNS.h"
#import "AWSLambda/AWSLambda.h"
#import "KN_Notification.h"
#import "KN_User.h"
#import "ProfileScreenViewController.h"
#import "NSDate+NVTimeAgo.h"
#import "UIImageView+WebCache.h"
@interface ConsumerNotificationViewController ()
{
    NSDictionary *dictUserInfo;
     NSMutableDictionary *dictSelfProfile;
     NSMutableDictionary *dictUserProfile;
    NSMutableArray *arrSelfFollowing;
    NSMutableArray *arrSelfFollower;
    NSMutableArray *arrNonSelfFollowing;
    NSMutableArray *arrNonSelfFollower;
    BOOL isAlreadyFollowing ;
    NSString *strNonLoginUserId, *strLoginUserId;
}
@end

@implementation ConsumerNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    _tblNotifications.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblNotifications.estimatedRowHeight = 61.0;
    _tblNotifications.rowHeight = UITableViewAutomaticDimension;
    dictSelfProfile = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"] mutableCopy];
    strLoginUserId = [dictSelfProfile valueForKey:@"UserId"];
    arrSelfFollowing = [[dictSelfProfile valueForKey:@"Following"] mutableCopy];
    arrSelfFollower = [[dictSelfProfile valueForKey:@"Followers"] mutableCopy];
    [Singlton sharedManager].arrNotifications = [NSMutableArray new];
    [self GetAllNotifications:[dictSelfProfile valueForKey:@"UserId"]];
 
  
  
}

-(void)GetAllNotifications:(NSString *)strLoginUserId
{
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    [[Singlton sharedManager]showHUD];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"NotificationTo"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" :strLoginUserId
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
                 if(![strLoginUserId isEqualToString:[dictSelfProfile valueForKey:@"UserId"]])
                 {
                     // This part is for removing notification from the Notification table for FOllow Type
                     AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                     for (KN_Notification *chat in paginatedOutput.items)
                     {
                         
                         [arrNotifications addObject:chat.dictionaryValue];
                         
                     }
                     if(arrNotifications.count>0)
                     {
                         [self callRemoveNotiFromTableforParticularUser:[dictSelfProfile valueForKey:@"UserId"] AndNonLoginUserId:[dictUserProfile valueForKey:@"UserId"] AndNotiArray:arrNotifications];
                     }
                 }
                 else
                 {
                 [Singlton sharedManager].arrNotifications = [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_Notification *chat in paginatedOutput.items)
                 {
                     
                     [[Singlton sharedManager].arrNotifications addObject:chat.dictionaryValue];
                     
                 }
                 if([Singlton sharedManager].arrNotifications.count==0)
                 {
                     _tblNotifications.hidden = YES;
                     _lblNoNotifications.hidden = NO;
                 }
                 else
                 {
                     [self GetImagesForUsersAndUpdateNotiData:[Singlton sharedManager].arrNotifications];
                    
                 }
                 }
             });
             
         }
         
         return nil;
         
     }];
}

-(void)GetImagesForUsersAndUpdateNotiData:(NSMutableArray *)arrayOfId
{
     [[Singlton sharedManager]showHUD];
    for(int i =0; i< arrayOfId.count; i++)
    {
       
        NSMutableDictionary *dictionaryAttributes = [[NSMutableDictionary alloc] init];
        NSString *expression = @"";
        for (int i = 0; i < arrayOfId.count; i++) {
            NSString *variableName = [NSString stringWithFormat:@":val%i", i+1];
            [dictionaryAttributes setValue:[[arrayOfId objectAtIndex:i]valueForKey:@"NotificationBy"] forKey:variableName];
            expression = [expression stringByAppendingString:expression.length ? [NSString stringWithFormat:@"OR #P = %@ " , variableName] : [NSString stringWithFormat:@"#P = %@ " , variableName]];
        }
        
        AWSDynamoDBScanExpression *query = [AWSDynamoDBScanExpression new];
        query.expressionAttributeNames = @{
                                           @"#P": [NSString stringWithFormat:@"%@", @"UserId"]
                                           };
        query.filterExpression = expression;
        query.expressionAttributeValues = dictionaryAttributes;
        
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        [[dynamoDBObjectMapper scan:[KN_User class] expression:query] continueWithBlock:^id _Nullable(AWSTask * _Nonnull task) {
            if (task.result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@" Paginated Output %@",task.result);
                    [[Singlton sharedManager]killHUD];
                    NSMutableArray *arrTemp = [NSMutableArray new];
                    NSMutableDictionary *dicTemp = [NSMutableDictionary new];
                    AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                    for (KN_User *chat in paginatedOutput.items) {
                        [arrTemp addObject:chat.dictionaryValue];
                    }
                    for(int i = 0; i< arrayOfId.count; i++)
                    {
                        for(int j = 0; j< arrTemp.count; j++)
                        {
                            if([[[arrayOfId objectAtIndex:i]valueForKey:@"NotificationBy"]isEqualToString:[[arrTemp objectAtIndex:j]valueForKey:@"UserId"]])
                            {
                                dicTemp = [[arrayOfId objectAtIndex:i]mutableCopy];
                                [dicTemp setObject:[[arrTemp objectAtIndex:j]valueForKey:@"Email"] forKey:@"Email"];
                                [arrayOfId replaceObjectAtIndex:i withObject:dicTemp];
                            }
                       
                        }
                    
                    }
                    
                    //[[Singlton sharedManager].arrNotifications removeAllObjects];
                    
                    [Singlton sharedManager].arrNotifications = arrayOfId.mutableCopy ;
                    _tblNotifications.delegate = self;
                    _tblNotifications.dataSource = self;
                    [_tblNotifications reloadData];
                    _tblNotifications.hidden = NO;
                    _lblNoNotifications.hidden = YES;
                    
                });
                
            }
            if (task.error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Error %@",task.error);
                    [[Singlton sharedManager]killHUD];
                });
            }
            return nil;
        }];
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return [Singlton sharedManager].arrNotifications.count;
   // return 3;
    
}- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"NotificationsCell";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    ConsumerNotificationCell *cell = (ConsumerNotificationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *dictData;
    dictData = [[Singlton sharedManager].arrNotifications objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.btnGotoProfile.tag = indexPath.row;
    [cell.btnGotoProfile addTarget:self
                            action:@selector(goToScreen:)
                  forControlEvents:UIControlEventTouchUpInside];
    cell.btnFollow.tag = indexPath.row;
    cell.btnFollow.layer.cornerRadius = 6.0f;
    cell.btnFollow.layer.masksToBounds = YES;
    NSString *strForEventImageName = [[dictData valueForKey:@"Email"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
    [cell.imgUSer sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    NSNumber *numberDate = [[[Singlton sharedManager].arrNotifications valueForKey:@"CreatedAt"]objectAtIndex:indexPath.row];
    NSDate *postdate = [NSDate dateWithTimeIntervalSince1970:[numberDate doubleValue]];
    NSString *strPostDate = [[Singlton sharedManager]convertDateToString:postdate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSDate *myDate = [formatter dateFromString:strPostDate];
    [formatter setDateFormat:@"MMMM d,yyyy hh:mm a"];
    //NSString *strFate =[formatter stringFromDate:myDate];
    NSString *ago = [myDate formattedAsTimeAgo];
    cell.lblTime.text = ago;
    if([[dictData valueForKey:@"Type"]isEqualToString:@"follow"])
    {
        NSArray *strSplit = [[dictData valueForKey:@"Item"] componentsSeparatedByString:@"has" ];
        cell.lblNotiHead.text = strSplit[0];
        cell.lblNotiDes.text = [dictData valueForKey:@"Item"];
          if([arrSelfFollowing containsObject:[dictData valueForKey:@"NotificationBy"]])
            {
                isAlreadyFollowing = YES;
                [cell.btnFollow setTitle:@"Following" forState:UIControlStateNormal];
            }
         else
           {
                isAlreadyFollowing = NO;
                [cell.btnFollow setTitle:@"Follow" forState:UIControlStateNormal];
           }
         cell.btnFollow.hidden = NO;
         [cell.btnFollow addTarget:self action:@selector(clickFollowBtn:) forControlEvents:UIControlEventTouchUpInside];
         cell.imgEvent.hidden =YES;
    }
   else if([[dictData valueForKey:@"Type"]isEqualToString:@"Post"])
    {
        NSArray *strSplit = [[dictData valueForKey:@"Item"] componentsSeparatedByString:@"has" ];
        cell.lblNotiHead.text = strSplit[0];
        //cell.lblNotiDes.text = [dictData valueForKey:@"Item"];
        cell.lblNotiDes.text = [NSString stringWithFormat:@"%@ has posted for an event",strSplit[0]];
        cell.btnFollow.hidden = YES;
        cell.imgEvent.hidden =NO;
        
    }
    return cell;
    
}
- (IBAction)goToScreen:(UIButton *)sender
{
    if([[[[Singlton sharedManager].arrNotifications objectAtIndex:sender.tag]valueForKey:@"Type"]isEqualToString:@"Post"])
    {
        ConsumerVenueEventDetailVC *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerVenueEventDetailVC"];
        ivc.strComingFromNotScreen = [[[Singlton sharedManager].arrNotifications objectAtIndex:sender.tag]valueForKey:@"ItemId"];
        [self.navigationController pushViewController:ivc animated:YES];
        
    }
    if([[[[Singlton sharedManager].arrNotifications objectAtIndex:sender.tag]valueForKey:@"Type"]isEqualToString:@"follow"])
    {
      ProfileScreenViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileScreenViewController"];
     NSDictionary *dicTemp = @{@"UserId":[[[Singlton sharedManager].arrNotifications objectAtIndex:sender.tag]valueForKey:@"NotificationBy"]};
     [Singlton sharedManager].dictNonLoginUser = dicTemp;
      [self.navigationController pushViewController:ivc animated:YES];
    }
}
-(void)clickFollowBtn:(UIButton *)sender
{
    [self GetAnotherUserFullInfo:sender];
    
    
}

-(void)GetAnotherUserFullInfo:(UIButton *)sender
{
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
                                                 @":val1" : [[[Singlton sharedManager].arrNotifications objectAtIndex:sender.tag]valueForKey:@"NotificationBy"]
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
                     dictUserProfile = [arrUserInfo objectAtIndex:0];
                     arrNonSelfFollowing = [[dictUserProfile valueForKey:@"Following"]allObjects].mutableCopy;
                     arrNonSelfFollower = [[dictUserProfile valueForKey:@"Followers"]allObjects].mutableCopy;
                     if([sender.titleLabel.text isEqualToString:@"Follow"])
                     {
                         NSLog(@"Btn Text is Follow");
                          [self FollowUser:[[[Singlton sharedManager].arrNotifications objectAtIndex:sender.tag]valueForKey:@"NotificationBy"] AndSender:sender];
                     }
                     else
                     {
                         NSLog(@"Btn Text is Unfollow");
                          //[self UnfollowUser:[[[Singlton sharedManager].arrNotifications objectAtIndex:sender.tag]valueForKey:@"NotificationBy"] AndSender:sender];
                         [self CallUnfollowuser:sender];
                         
                     }
                     self.view.userInteractionEnabled = YES;
                    
                     
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
-(void)FollowUser:(NSString *)strNonLoginUser AndSender:(UIButton *)sender
{
     strNonLoginUserId = [[[Singlton sharedManager].arrNotifications objectAtIndex:sender.tag]valueForKey:@"NotificationBy"];
    [arrSelfFollowing removeAllObjects];
    arrSelfFollowing = [[dictSelfProfile valueForKey:@"Following"]allObjects].mutableCopy;
    if(![arrSelfFollowing containsObject:strLoginUserId])
    {
    [arrSelfFollowing addObject:strNonLoginUser];
    }
    [[Singlton sharedManager]showHUD];
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
                 [arrSelfFollowing removeObject:strNonLoginUser];
                 [sender setTitle:@"Follow" forState:UIControlStateNormal];
                 [[Singlton sharedManager]killHUD];
                 [[Singlton sharedManager] alert:self title:Message message:@"Please try again"];
                 self.view.userInteractionEnabled = YES;
             });
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [dictSelfProfile setValue:arrSelfFollowing forKey:@"Following"];
                 [[NSUserDefaults standardUserDefaults]setValue:dictSelfProfile forKey:@"loginUser"];
                 dictSelfProfile = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"] mutableCopy];
                 [self CallNonSelfUpdateFollowerNArrayFollower:sender];
                 self.view.userInteractionEnabled = YES;
             });
             
             
             
         }
         return nil;
     }];
}
-(void)UnfollowUser:(NSString *)strNonLoginUser AndSender:(UIButton *)sender
{
   arrSelfFollowing = [[dictSelfProfile valueForKey:@"Following"] mutableCopy];
    [arrSelfFollowing removeObject:strNonLoginUser];
    [[Singlton sharedManager]showHUD];
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
                 [arrSelfFollowing addObject:strNonLoginUser];
                 [sender setTitle:@"Following" forState:UIControlStateNormal];
                 [[Singlton sharedManager]killHUD];
                 [[Singlton sharedManager] alert:self title:Message message:@"Please try again"];
                 self.view.userInteractionEnabled = YES;
             });
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [dictSelfProfile setValue:arrSelfFollowing forKey:@"Following"];
                 [[NSUserDefaults standardUserDefaults]setValue:dictSelfProfile forKey:@"loginUser"];
                 dictSelfProfile = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"] mutableCopy];
                 [self CallNonSelfUpdateFollowerNArrayFollower:sender];
                 self.view.userInteractionEnabled = YES;
             });
             
             
             
         }
         return nil;
     }];
}
-(void)CallNonSelfUpdateFollowerNArrayFollower:(UIButton *)sender
{
      strNonLoginUserId = [[[Singlton sharedManager].arrNotifications objectAtIndex:sender.tag]valueForKey:@"NotificationBy"];
    self.view.userInteractionEnabled = NO;
   if([sender.titleLabel.text isEqualToString:@"Following"])
    {
        [arrNonSelfFollower removeObject:[strLoginUserId mutableCopy]];
    }
    else  if([sender.titleLabel.text isEqualToString:@"Follow"])
    {
        [arrNonSelfFollower addObject:[strLoginUserId mutableCopy]];
    }
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
    AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    
    hashKeyValue.S = strNonLoginUserId;
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
                // [arrNonSelfFollower addObject:[strNonLoginUserId mutableCopy]];
                 [[Singlton sharedManager] alert:self title:Message message:@"Please try again"];
                 self.view.userInteractionEnabled = YES;
             });
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 if([sender.titleLabel.text isEqualToString:@"Following"])
                 {
                     [sender setTitle:@"Follow" forState:UIControlStateNormal];
                       [self GetAllNotifications:[dictUserProfile valueForKey:@"UserId"]];
                 }
                 else  if([sender.titleLabel.text isEqualToString:@"Follow"])
                 {
                      [sender setTitle:@"Following" forState:UIControlStateNormal];
                      [self CallLambdaFuncForSendingNoti];
                    
                 }
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
                                 @"ReceiverUserId":[dictUserProfile valueForKey:@"UserId"],
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

- (void)CallUnfollowuser:(UIButton *)sender
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
                                   [self UnfollowUser:[[[Singlton sharedManager].arrNotifications objectAtIndex:sender.tag]valueForKey:@"NotificationBy"] AndSender:sender];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    arrSelfFollowing = [NSMutableArray new];
    arrSelfFollower = [NSMutableArray new];
    arrNonSelfFollowing = [NSMutableArray new];
    arrNonSelfFollower = [NSMutableArray new];
    dictSelfProfile = [NSMutableDictionary new];
    dictUserProfile = [NSMutableDictionary new];
    dictSelfProfile = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"] mutableCopy];
    strLoginUserId = [dictSelfProfile valueForKey:@"UserId"];
    arrSelfFollowing = [[dictSelfProfile valueForKey:@"Following"] mutableCopy];
    arrSelfFollower = [[dictSelfProfile valueForKey:@"Followers"] mutableCopy];
    if([Singlton sharedManager].arrNotifications.count>0)
    {
        [_tblNotifications reloadData];
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
