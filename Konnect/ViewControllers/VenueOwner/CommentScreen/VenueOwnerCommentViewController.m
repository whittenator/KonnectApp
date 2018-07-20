//
//  VenueOwnerCommentViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 09/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VenueOwnerCommentViewController.h"
#import "VenueCommentTableViewCell.h"
#import "ImageEventTableViewCell.h"
#import "KN_StagingPostComment.h"
#import "UIImageView+WebCache.h"
#import "NSDate+NVTimeAgo.h"
#import "UIButton+WebCache.h"
#import "AWSLambda/AWSLambda.h"
#import "VenueImageViewController.h"
#import "ProfileScreenViewController.h"
#define BTN_BACK  0
#define BTN_DELTE  1
@interface VenueOwnerCommentViewController ()<UIGestureRecognizerDelegate>
{
    NSMutableArray *arrComment;
    NSString *strCount;
}
@end

@implementation VenueOwnerCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tblComment.estimatedRowHeight = 80;
    _tblComment.rowHeight = UITableViewAutomaticDimension;
    
    arrComment = [[NSMutableArray alloc]init];
    
    _tblComment.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (![_strChek isEqualToString:@"Gallery"]) {
        btnDelete.hidden = YES;
    }
  
  [self FetchAllComment];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return arrComment.count;
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
    
//    if (indexPath.row==0) {
//
//      static NSString *CellIdentifier = @"ImageCell";
//        ImageEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[ImageEventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.lblUserName.text = [_dicPostDetails valueForKey:@"Name"];
//
//        NSString *strForUserImageName = [[_dicPostDetails valueForKey:@"UserImage"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//        NSURL *Userurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,strForUserImageName]];
//
//        [cell.btnProfile sd_setImageWithURL:Userurl forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
//
//        NSString *strForEventImageName = [[_dicPostDetails valueForKey:@"Image"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_POST_EVENT_IMAGE_URL,strForEventImageName]];
//
//        [cell.imgEvent sd_setImageWithURL:url
//                        placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
//
//        NSNumber *numberDate = [_dicPostDetails valueForKey:@"CreatedAt"];
//
//        cell.lblTime.text = [self getTimeAgo:numberDate];
//
////        NSDate *postdate = [NSDate dateWithTimeIntervalSince1970:[numberDate doubleValue]];
////        NSString *strPostDate = [[Singlton sharedManager]convertDateToString:postdate];
////        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
////        [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
////        NSDate *myDate = [formatter dateFromString:strPostDate];
////        [formatter setDateFormat:@"MMMM d,yyyy hh:mm a"];
////        NSString *ago = [myDate formattedAsTimeAgo];
////        cell.lblTime.text = ago;
////
//        return cell;
//    }
//    else
    {
    static NSString *CellIdentifier = @"Cell";
    VenueCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[VenueCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *text = [NSString stringWithFormat:@"%@ %@",[[arrComment valueForKey:@"UserName"]objectAtIndex:indexPath.row],[[arrComment valueForKey:@"PostComment"]objectAtIndex:indexPath.row]];
        
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:text];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[[arrComment valueForKey:@"UserName"]objectAtIndex:indexPath.row] options:kNilOptions error:nil]; // Matches 'God' case SENSITIVE
        
        NSRange range = NSMakeRange(0 ,text.length);
        
        // Change all words that are equal to 'God' to red color in the attributed string
        [regex enumerateMatchesInString:text options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            
            NSRange subStringRange = [result rangeAtIndex:0];
            [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:83/255.0 green:186/255.0 blue:231/255.0 alpha:1.0] range:subStringRange];
            
            // Set font, notice the range is for the whole string
           
            [mutableAttributedString addAttribute:NSFontAttributeName
                          value:[UIFont fontWithName:@"Roboto-Regular" size:14]
                          range:subStringRange];
            
        }];
        
        cell.lblCommentText.attributedText = mutableAttributedString;
        
        cell.btnDelete.tag = indexPath.row;
        [cell.btnDelete addTarget:self action:@selector(clickDeleteCommentBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        NSString *strForEventImageName = [[[arrComment valueForKey:@"UserImage"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
        
        [cell.imgUser sd_setImageWithURL:url
                                   placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
        
        NSNumber *numberDate = [[arrComment valueForKey:@"CreatedAt"]objectAtIndex:indexPath.row];
        cell.lblTime.text = [self getTimeAgo:numberDate];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.delegate = self;
        tapGestureRecognizer.view.tag = indexPath.row;
        cell.imgUser.tag = indexPath.row;
        cell.imgUser.userInteractionEnabled = YES;
        [cell.imgUser addGestureRecognizer:tapGestureRecognizer];
        
        UITapGestureRecognizer *tapName = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserName:)];
        tapName.numberOfTapsRequired = 1;
        tapName.delegate = self;
        cell.lblUserName.tag = indexPath.row;
        cell.lblUserName.userInteractionEnabled = YES;
        [cell.lblUserName addGestureRecognizer:tapName];
        
        
        return cell;
    }
   
  
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row==0) {
        
    VenueImageViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueImageViewController"];
    NSString *strForEventImageName = [[_dicPostDetails valueForKey:@"Image"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    Vc.strImage = strForEventImageName;
    Vc.strName = [_dicPostDetails valueForKey:@"Name"];
    Vc.eventDateTime = [_dicPostDetails valueForKey:@"CreatedAt"];
    Vc.strEventName = _strEventName;
    Vc.strchek = @"Post";
    [self.navigationController pushViewController:Vc animated:NO];
        
    }
}
#pragma mark - IBAction Method
-(IBAction)clickButtons:(id)sender
{
    UIButton * btnSelected = (UIButton *) sender;
    
    switch (btnSelected.tag) {
            
        case BTN_BACK:
        {
        
            if ([_strNavigationCheck isEqualToString:@"Present"]) {
                
            NSDictionary *postCommentCount = [NSDictionary dictionaryWithObjectsAndKeys:strCount,@"Count", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:
             @"ChangeCommmentCount" object:nil userInfo:postCommentCount];
            [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                 [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
            break;
        default:
            break;
            
    }
}
-(IBAction)clickDeleteBtn:(id)sender
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Alert"
                                  message:@"Are you want to sure to delete the post?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* YesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                          
                                                        
                                                          [self deletePostEvent:[_dicPostDetails valueForKey:@"Id"]];
                                                      }];
                                                          
                                
    UIAlertAction* NoAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                        
                                                          
                                                      }];
    
    
    [alert addAction:YesAction];
    [alert addAction:NoAction];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)clickDeleteCommentBtn:(UIButton *)sender
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Alert"
                                  message:@"Are you want to sure to delete the Comment?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* YesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                          
                                                          
                                                          [self deletePostComment:[[arrComment valueForKey:@"Id"]objectAtIndex:sender.tag]];
                                                      }];
    
    
    UIAlertAction* NoAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         
                                                         
                                                         
                                                     }];
    
    
    [alert addAction:YesAction];
    [alert addAction:NoAction];
    [self presentViewController:alert animated:YES completion:nil];
}
-(IBAction)clickImage:(UITapGestureRecognizer*)recognizer
{
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Consumer" bundle:nil];
    ProfileScreenViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileScreenViewController"];
    [Singlton sharedManager].strComingFromVenueOwnerCommentScreen = _strPostId;
    [Singlton sharedManager].dictVenueEventDetailInfo = nil;
    [Singlton sharedManager].dictNonLoginUser = [arrComment objectAtIndex:recognizer.view.tag];
    [self.navigationController pushViewController:ivc animated:YES];
}
-(IBAction)clickUserName:(UITapGestureRecognizer*)recognizer
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Consumer" bundle:nil];
    ProfileScreenViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileScreenViewController"];
    [Singlton sharedManager].dictNonLoginUser =[arrComment objectAtIndex:recognizer.view.tag];
    [self.navigationController pushViewController:ivc animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Method

-(void) scrollToBottomTableView{
    //isBottomConentSizeTouch = NO;
    NSIndexPath* ipath = [NSIndexPath indexPathForRow:([arrComment count]-1) inSection:0];
    [_tblComment scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
}


#pragma mark - AWS Method

-(void)FetchAllComment
{
    [[Singlton sharedManager]showHUD];
    

    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"PostId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : _strPostId
                                                 };
    [[dynamoDBObjectMapper scan:[KN_StagingPostComment class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
           
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
              
                 arrComment = [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_StagingPostComment *chat in paginatedOutput.items) {
                     
                     
                     [arrComment addObject:chat.dictionaryValue];
                     
                 }
                 
                 if (arrComment.count>0) {
                     
                     lblAlert.hidden = YES;
                     _tblComment.hidden = NO;
                     
                   
                     
                     NSSortDescriptor *sortDescriptor =
                     [[NSSortDescriptor alloc] initWithKey:@"CreatedAt"
                                                 ascending:YES];
                     NSArray *arrayMesage = [arrComment
                                             sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                     arrComment = [NSMutableArray arrayWithArray:arrayMesage];
                     NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                     [dic setValue:@"1514987506.488276" forKey:@"CreatedAt"];
                     [dic setValue:@"prakash@simpalm.com1514987506.488276" forKey:@"Id"];
                     [dic setValue:@"Hello" forKey:@"PostComment"];
                     [dic setValue:@"prakash@simpalm.com1514553547.010482" forKey:@"PostId"];
                     [dic setValue:@"1514987506.488276" forKey:@"UpdatedAt"];
                     [dic setValue:@"478dbe8da820283648accbf5da00f302" forKey:@"UserId"];
                     [dic setValue:@"prakash@simpalm.com.jpg" forKey:@"UserImage"];
                     [dic setValue:@"Prakash Kumar" forKey:@"UserName"];
                    // [arrComment insertObject:dic atIndex:0];
                     
                     [_tblComment reloadData];
                     
                     [self scrollToBottomTableView];
                     strCount = [NSString stringWithFormat: @"%ld", (long)arrComment.count-1];
                     [self UpdatePostCommentCount:strCount];

                 }
                 else
                 {
                     lblAlert.hidden = NO;
                     _tblComment.hidden = NO;
                     
                       [_tblComment reloadData];
                      [self UpdatePostCommentCount:@"0"];
                     
                     
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
    
}
-(void)deletePostEvent:(NSString *)strPostId
{
    [[Singlton sharedManager] showHUD];
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    NSDictionary *parameters = @{
                                 @"PostId":strPostId,
                                 };
    
    [[lambdaInvoker invokeFunction:[UserMode isEqualToString:@"Test"] ? @"KON_deletePost":@"KONProd_deletePost"
                        JSONObject:parameters] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            self.view.userInteractionEnabled = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Singlton sharedManager] killHUD];
                
            });
            
            NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            NSLog(@"Result: %@", task.result);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
                [[Singlton sharedManager] killHUD];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        return nil;
    }];
}
-(void)deletePostComment:(NSString *)strCommentId
{
    [[Singlton sharedManager]showHUD];
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    AWSDynamoDBDeleteItemInput *updateInput = [AWSDynamoDBDeleteItemInput new];
    AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    

    hashKeyValue.S = strCommentId;
    updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_PostComment" : @"PostComment";
    updateInput.key = @{ @"Id" : hashKeyValue};
    
    [[dynamoDB deleteItem:updateInput]continueWithBlock:^id(AWSTask *task) {
        if (task.error)
        {
            [[Singlton sharedManager]killHUD];
            NSLog(@"The request failed Error:%@", task.error);
        }
        if (task.result)
        {
            NSLog(@"The Result:%@", task.result);
           
            dispatch_async(dispatch_get_main_queue(), ^{
          
                    [[Singlton sharedManager]killHUD];
                    [self FetchAllComment];
                    
              
                
            });
        }
        return nil;
    }];
    
    
}
-(void)UpdatePostCommentCount:(NSString *)strCount
{
    
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
    AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    
    hashKeyValue.S = _strPostId;
    updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_PostEvent" : @"PostEvent";
    updateInput.key = @{ @"Id" : hashKeyValue };
    
    //********************* Venue Name
    AWSDynamoDBAttributeValue *newFirstNameValue = [AWSDynamoDBAttributeValue new];
    newFirstNameValue.S = strCount;
    AWSDynamoDBAttributeValueUpdate *valueUpdateForFirstName = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateForFirstName.value = newFirstNameValue;
    valueUpdateForFirstName.action = AWSDynamoDBAttributeActionPut;
    
    
    
    updateInput.attributeUpdates = @{@"commentCount": valueUpdateForFirstName};
    
    
    
    updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
    
    [[dynamoDB updateItem:updateInput]continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            // NSLog(@"The request failed. Error: [%@]", task.error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Singlton sharedManager]killHUD];
            });
        }
        
        if (task.result) {
            //Do something with result.
            dispatch_async(dispatch_get_main_queue(), ^{
                //  [self getLoginUser];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[Singlton sharedManager]killHUD];
                });
              
                
            });
            
            
        }
        return nil;
    }];
    
}
-(NSString *)getTimeAgo:(NSNumber *)numberCreatedAt
{
NSNumber *numberDate = numberCreatedAt;
NSDate *postdate = [NSDate dateWithTimeIntervalSince1970:[numberDate doubleValue]];
NSString *strPostDate = [[Singlton sharedManager]convertDateToString:postdate];
NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
[formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
NSDate *myDate = [formatter dateFromString:strPostDate];
[formatter setDateFormat:@"MMMM d,yyyy hh:mm a"];
NSString *ago = [myDate formattedAsTimeAgo];
    return ago;
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
