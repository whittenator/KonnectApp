//
//  VenueCheckInViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 09/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VenueCheckInViewController.h"
#import "VanueCheckInTableViewCell.h"
#import "ImageEventTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "AWSLambda/AWSLambda.h"
#import "KN_Notification.h"
#define BTN_BACK  0
#define BTN_DELTE  1
@interface VenueCheckInViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableDictionary  *dictSelfProfile;
    NSMutableDictionary  *dictNonSelfProfile;
    NSMutableArray *arrSelfFollowing;
    NSMutableArray *arrSelfFollower;
    NSMutableArray *arrNonSelfFollowing;
    NSMutableArray *arrNonSelfFollower;
    NSString *strLoginUserId,*strNonLoginUserId;
}
@end

@implementation VenueCheckInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrSelfFollowing = [NSMutableArray new];
    arrSelfFollower = [NSMutableArray new];
    arrNonSelfFollowing = [NSMutableArray new];
    arrNonSelfFollower = [NSMutableArray new];
    dictSelfProfile = [NSMutableDictionary new];
    // Do any additional setup after loading the view.
}
#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.arrCheckInUserList.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    return 71;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    
    static NSString *CellIdentifier = @"Cell";
    VanueCheckInTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[VanueCheckInTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *strUserName = [NSString stringWithFormat:@"%@ %@",[[self.arrCheckInUserList valueForKey:@"Firstname"]objectAtIndex:indexPath.row],[[self.arrCheckInUserList valueForKey:@"Lastname"]objectAtIndex:indexPath.row]];
    cell.lblName.text = strUserName;
    
    NSString *strForEventImageName = [[[self.arrCheckInUserList valueForKey:@"UserImage"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
    
    [cell.imgProfile sd_setImageWithURL:url
                       placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    cell.btnFollow.tag  = indexPath.row;
    [cell.btnFollow addTarget:self action:@selector(clickFollowBtn:) forControlEvents:UIControlEventTouchUpInside];
    return cell;

}

#pragma mark - IBAction Method
-(IBAction)clickButtons:(id)sender
{
    UIButton * btnSelected = (UIButton *) sender;
    
    switch (btnSelected.tag) {
            
        case BTN_BACK:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default:
            break;
            
    }
}

#pragma mark - Functionality for Follow and Unfollow User
-(void)clickFollowBtn:(UIButton *)sender
{
    dictNonSelfProfile = [[_arrCheckInUserList objectAtIndex:sender.tag] mutableCopy];
    strNonLoginUserId = [[_arrCheckInUserList objectAtIndex:sender.tag]valueForKey:@"UserId"];
    if([sender.titleLabel.text isEqualToString:@"Follow"])
    {
        NSLog(@"Btn Text is Follow");
        [self FollowUser:[[_arrCheckInUserList objectAtIndex:sender.tag]valueForKey:@"UserId"] AndSender:sender];
    }
    else
    {
        NSLog(@"Btn Text is Following");
        [self CallUnfollowuser:sender];
        // [self UnfollowUser:[[_arrCheckInUserList objectAtIndex:sender.tag]valueForKey:@"UserId"] AndSender:sender];
    }
}
-(void)FollowUser:(NSString *)strNonLoginUser AndSender:(UIButton *)sender
{
    [arrSelfFollowing removeAllObjects];
    arrSelfFollowing = [[dictSelfProfile valueForKey:@"Following"]allObjects].mutableCopy;
    [arrSelfFollowing addObject:strNonLoginUser];
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
                 [[NSUserDefaults standardUserDefaults]setValue:dictSelfProfile forKey:@"UserDetail"];
                 dictSelfProfile = [[[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"] mutableCopy];
                 [self CallNonSelfUpdateFollowerNArrayFollower:sender];
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
                                    [self UnfollowUser:[[_arrCheckInUserList objectAtIndex:sender.tag]valueForKey:@"UserId"] AndSender:sender];
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

-(void)UnfollowUser:(NSString *)strNonLoginUser AndSender:(UIButton *)sender
{
    // [arrSelfFollowing removeAllObjects];
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
                 [[NSUserDefaults standardUserDefaults]setValue:dictSelfProfile forKey:@"UserDetail"];
                 dictSelfProfile = [[[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"] mutableCopy];
                 [self CallNonSelfUpdateFollowerNArrayFollower:sender];
                 self.view.userInteractionEnabled = YES;
             });
             
             
             
         }
         return nil;
     }];
    
}

-(void)CallNonSelfUpdateFollowerNArrayFollower:(UIButton *)sender
{
    self.view.userInteractionEnabled = NO;
    //[arrNonSelfFollower removeAllObjects];
    arrNonSelfFollower = [[[_arrCheckInUserList objectAtIndex:sender.tag] valueForKey:@"Followers"]allObjects].mutableCopy;
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
                 [arrNonSelfFollower addObject:[strNonLoginUserId mutableCopy]];
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
                     [self GetAllNotifications:[dictNonSelfProfile valueForKey:@"UserId"]];
                 }
                 else  if([sender.titleLabel.text isEqualToString:@"Follow"])
                 {
                     [sender setTitle:@"Following" forState:UIControlStateNormal];
                     [self CallLambdaFuncForSendingNoti];
                 }
                 //[sender setTitle:@"Unfollow" forState:UIControlStateNormal];
                 [dictNonSelfProfile setValue:arrNonSelfFollower forKey:@"Followers"];
                 [_arrCheckInUserList replaceObjectAtIndex:sender.tag withObject:dictNonSelfProfile];
                 self.view.userInteractionEnabled = YES;
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
                     
                 }
                 if(arrNotifications.count>0)
                 {
                     [self callRemoveNotiFromTableforParticularUser:[dictSelfProfile valueForKey:@"UserId"] AndNonLoginUserId:[dictNonSelfProfile valueForKey:@"UserId"] AndNotiArray:arrNotifications];
                 }
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

-(void)CallLambdaFuncForSendingNoti
{
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    NSDictionary *parameters = @{@"SenderUserId":[dictSelfProfile valueForKey:@"UserId"],
                                 @"ReceiverUserId":[dictNonSelfProfile valueForKey:@"UserId"],
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self callSettingStateOfUsers];
}
-(void)callSettingStateOfUsers
{
    
    NSLog(@"checkedIn USers %@",_arrCheckInUserList);
    NSMutableDictionary *dicTemp = [NSMutableDictionary new];
    dictSelfProfile = [[[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"] mutableCopy];
    strLoginUserId = [dictSelfProfile valueForKey:@"UserId"];
    arrSelfFollowing = [[dictSelfProfile valueForKey:@"Following"] mutableCopy];
    arrSelfFollower = [[dictSelfProfile valueForKey:@"Followers"] mutableCopy];
    for(int i = 0; i< _arrCheckInUserList.count; i++)
    {
        dicTemp = [[_arrCheckInUserList objectAtIndex:i] mutableCopy];
        if([[dictSelfProfile valueForKey:@"UserId"]isEqualToString:[dicTemp valueForKey:@"UserId"]])
        {
            [dicTemp setObject:@"self" forKey:@"Following"];
        }
        else
        {
            if([arrSelfFollowing containsObject:[dicTemp valueForKey:@"UserId"]])
            {
                [dicTemp setObject:@"yes" forKey:@"Following"];
            }
            else
            {
                [dicTemp setObject:@"no" forKey:@"Following"];
            }
        }
        [_arrCheckInUserList replaceObjectAtIndex:i withObject:dicTemp];
    }
    if(_arrCheckInUserList.count > 0)
    {
        _tblCheckInUsers.delegate =self;
        _tblCheckInUsers.dataSource = self;
        [_tblCheckInUsers reloadData];
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
