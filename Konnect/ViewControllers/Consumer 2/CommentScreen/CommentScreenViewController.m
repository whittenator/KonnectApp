//
//  CommentScreenViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 29/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "CommentScreenViewController.h"
#import <AWSS3/AWSS3.h>
#import "KN_StagingPostComment.h"
#import "NSDate+NVTimeAgo.h"
#import "UIImageView+WebCache.h"
@interface CommentScreenViewController ()
{
    NSMutableDictionary *dictUserInfo;
    NSMutableArray *arrComment;
    UIEdgeInsets contentInsets;
    NSNumber *duration;
    CGSize keyboardSize;
    float textFieldHeight;
}
@end

@implementation CommentScreenViewController
@synthesize containerView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrComment = [[NSMutableArray alloc]init];
    
    dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self AddingGrowTextView];
   
    _tblComment.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _tblComment.estimatedRowHeight = 80;
    _tblComment.rowHeight = UITableViewAutomaticDimension;
    
    [self FetchAllComment];
 
  
    // Do any additional setup after loading the view.
}
-(void)AddingGrowTextView
{
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(8, 14, self.view.frame.size.width-80, containerView.frame.size.height-12)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    textView.layer.cornerRadius = 3.0;
    textView.layer.masksToBounds = YES;
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 3;
    textView.tag = 123;
    textView.returnKeyType = UIReturnKeyDefault; //just as an example
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor colorWithRed:233.0f/255.0f green:233.0f/255.0f blue:233.0f/255.0f alpha:1.0];
    //textView.font = [UIFont systemFontOfSize:15.0f];
    textView.placeholder = @"type your comment...";
 
    [containerView addSubview:textView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return arrComment.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"CommentCell";
   // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
     CommentTableViewCell *cell = (CommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
   
  
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblUserName.text = [[arrComment valueForKey:@"UserName"]objectAtIndex:indexPath.row];
    cell.lblDescription.text = [[arrComment valueForKey:@"PostComment"]objectAtIndex:indexPath.row];
    
    NSString *strForEventImageName = [[[arrComment valueForKey:@"UserImage"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
    
    [cell.imgUserCommentCell sd_setImageWithURL:url
                             placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    NSNumber *numberDate = [[arrComment valueForKey:@"CreatedAt"]objectAtIndex:indexPath.row];
    NSDate *postdate = [NSDate dateWithTimeIntervalSince1970:[numberDate doubleValue]];
    NSString *strPostDate = [[Singlton sharedManager]convertDateToString:postdate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSDate *myDate = [formatter dateFromString:strPostDate];
    [formatter setDateFormat:@"MMMM d,yyyy hh:mm a"];
    NSString *ago = [myDate formattedAsTimeAgo];
    cell.lblTime.text = ago;
    
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

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)funcBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)actionSendComment:(id)sender {
    [textView resignFirstResponder];
   
    if ([[Singlton sharedManager]check_null_data:textView.text]) {
        
        [[Singlton sharedManager] alert:self title:Alert message:Comment];
    }
    else
    {
       // textView.text = @"";
        [self SavePostCommentData];
        //[self  AddingGrowTextView];
    }
}
#pragma mark - AWS Method
-(void)SavePostCommentData
{
    self.view.userInteractionEnabled = NO;
    [[Singlton sharedManager]showHUD];
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSString *Id = [NSString stringWithFormat:@"%@%f",[dictUserInfo valueForKey:@"Email"],timeInSeconds];
    
    NSString *strName = [NSString stringWithFormat:@"%@ %@",[dictUserInfo valueForKey:@"firstName"],[dictUserInfo valueForKey:@"lastName"]];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    KN_StagingPostComment *PostComment = [KN_StagingPostComment new];
    PostComment.Id = Id;
    PostComment.UserId = [dictUserInfo valueForKey:@"UserId"] ;
    PostComment.PostId = _strPostId;
    PostComment.PostComment = textView.text;
    PostComment.UserName = strName;
    PostComment.UserImage = [dictUserInfo valueForKey:@"UserImage"];
    PostComment.CreatedAt = NumberCreatedAt;
    PostComment.UpdatedAt = NumberCreatedAt;
    
    [[dynamoDBObjectMapper save:PostComment]
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
                 textView.text = @"";
               
                 [self FetchAllComment];
                 
             });
             
         }
         return nil;
     }];
}
-(void)FetchAllComment
{
    [[Singlton sharedManager]showHUD];
    
    
    
    self.view.userInteractionEnabled = NO;
    
    
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
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 arrComment = [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_StagingPostComment *chat in paginatedOutput.items) {
                    
                     
                     [arrComment addObject:chat];
                     
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
            
                     [_tblComment reloadData];
                     [self scrollToBottomTableView];
                     
                
                     NSString *strCount = [NSString stringWithFormat: @"%ld", (long)arrComment.count];
                     [self UpdatePostCommentCount:strCount];
                   
                 }
                 else
                 {
                     lblAlert.hidden = NO;
                     _tblComment.hidden = YES;
                      [self UpdatePostCommentCount:@"0"];
                     
                     
                 }
                 
                 
                 
             });
             
         }
         
         return nil;
         
     }];
    
}
-(void)UpdatePostCommentCount:(NSString *)strCount
{
    
    self.view.userInteractionEnabled = NO;
    
   
    
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
                self.view.userInteractionEnabled = YES;
               
            });
            
            
        }
        return nil;
    }];
    
}
#pragma mark - NSNotification Method

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note {
    // get keyboard size and loctaion
    keyboardSize = [note.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    containerView.frame = containerFrame;
    
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note {
    duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

#pragma mark - HPGrowingTextView Delegates
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [growingTextView resignFirstResponder];
        
        // btnSendMessage.enabled = NO;
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // btnSendMessage.enabled = YES;
    return YES;
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    float temp =  -(diff);
    NSString *strCOunt = [NSString stringWithFormat: @"%f", temp+textFieldHeight];
    textFieldHeight = [strCOunt floatValue];
    CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    containerView.frame = r;
    float tblScroll = textFieldHeight+keyboardSize.height;
    contentInsets = UIEdgeInsetsMake(0.0, 0.0, tblScroll, 0.0);
    [UIView animateWithDuration:duration.floatValue animations:^{
        
        _tblComment.contentInset = contentInsets;
        _tblComment.scrollIndicatorInsets = contentInsets;
    }];
    if (arrComment.count != 0) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow:([arrComment count]-1) inSection:0];
        [_tblComment scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        
    }
    
}
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    
    [UIView animateWithDuration:duration.floatValue animations:^{
        
        _tblComment.contentInset = contentInsets;
        _tblComment.scrollIndicatorInsets = contentInsets;
    }];
    
    if (arrComment.count == 0) {
        return;
    }
    
    if (arrComment.count != 0) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow:([arrComment count]-1) inSection:0];
        [_tblComment scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        
    }
}
- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView
{
    //Tableview move dowen  when keyboard aapear
    UIEdgeInsets contentInset = _tblComment.contentInset;
    contentInset.bottom =  0.0f;
    
    UIEdgeInsets scrollIndicatorInsets = _tblComment.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom =  0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        _tblComment.contentInset = contentInset;
        _tblComment.scrollIndicatorInsets = scrollIndicatorInsets;
    }];
    
    if (arrComment.count != 0) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow:([arrComment count]-1) inSection:0];
        [_tblComment scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        
    }
    
    
    
}
#pragma mark - Custome Method
-(void) scrollToBottomTableView{
    //isBottomConentSizeTouch = NO;
    NSIndexPath* ipath = [NSIndexPath indexPathForRow:([arrComment count]-1) inSection:0];
    [_tblComment scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
}

@end
