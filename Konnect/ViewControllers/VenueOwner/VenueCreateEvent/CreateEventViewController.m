//
//  CreateEventViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 11/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "CreateEventViewController.h"
#import "EventTypeNameTableViewCell.h"
#import "VenueOwnerHomeViewController.h"
#import <AWSS3/AWSS3.h>
#import "KN_Event.h"
@interface CreateEventViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,CLLocationManagerDelegate,UITextViewDelegate>
{
    UIImage *chosenImage;
    NSMutableArray *arrImages;
    NSMutableArray *arrText;
    UIToolbar *toolBar;
    NSMutableDictionary *dicUserData;
    NSMutableDictionary *dicProfileSetup;
    NSString *strImageName;
    NSMutableArray *arrType;
    NSMutableArray *arrayEventType;
    NSArray *arrSpecials;
}
@end

@implementation CreateEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    arrType = [[NSMutableArray alloc]init];
    dicUserData  = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"];
    dicProfileSetup = [[NSUserDefaults standardUserDefaults]valueForKey:@"VenueProfileData"];
    
    
    arrImages = [[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"Drinks"],[UIImage imageNamed:@"Food"],[UIImage imageNamed:@"Music"],[UIImage imageNamed:@"FoodCart"],[UIImage imageNamed:@"DJ"] ,nil];
    
    arrText = [[NSMutableArray alloc]initWithObjects:@"Drinks",@"Food",@"Music",@"FoodCart",@"Other",nil];
    arrayEventType =  [[NSMutableArray alloc]initWithObjects:@"Happy Hour",@"Brunch",@"Musicians",@"Club Specials",@"Party Specials",@"Bar Crawl Specials",@"Contest Information and Specials",@"Game Day Specials",nil];
    
    txtDescription.layer.borderColor=[[UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1.0]CGColor];
    txtDescription.layer.borderWidth=1.1;
    txtDescription.layer.cornerRadius = 3;
    
    btnEventImage.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btnEventImage.imageView.clipsToBounds = YES;
    btnEventImage.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    btnEventImage.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtEventName.leftView = paddingView;
    txtEventName.leftViewMode = UITextFieldViewModeAlways;
    
    
    UIView *paddingViewPhone = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtEventStart.leftView = paddingViewPhone;
    txtEventStart.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingViewStart = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtEventEnd.leftView = paddingViewStart;
    txtEventEnd.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingViewEnd = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtEventSpacial.leftView = paddingViewEnd;
    txtEventSpacial.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingViewSpcl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtEventType.leftView = paddingViewSpcl;
    txtEventType.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingViewDate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtEventDate.leftView = paddingViewDate;
    txtEventDate.leftViewMode = UITextFieldViewModeAlways;
    
    txtEventType.delegate  = self;
    
    [txtEventType addTarget:self action:@selector(textField1Active:) forControlEvents:UIControlEventEditingDidBegin];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeTime;
    //[datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    
    UIDatePicker *datePickerEnd = [[UIDatePicker alloc]init];
    datePickerEnd.datePickerMode = UIDatePickerModeTime;
    //[datePicker setDate:[NSDate date]];
    [datePickerEnd addTarget:self action:@selector(updateTextFieldEnd:) forControlEvents:UIControlEventValueChanged];
    
    UIDatePicker *dateEvent = [[UIDatePicker alloc]init];
    dateEvent.datePickerMode = UIDatePickerModeDate;
    [dateEvent setMinimumDate: [NSDate date]];
    [dateEvent addTarget:self action:@selector(dateTextField:) forControlEvents:UIControlEventValueChanged];
    [txtEventDate setInputView:dateEvent];
    
    [txtEventStart setInputView:datePicker];
    [txtEventEnd setInputView:datePickerEnd];
    
    
    toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    [toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(changeDateFromLabel:)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor blackColor];
    txtEventStart.inputAccessoryView = toolBar;
    txtEventEnd.inputAccessoryView = toolBar;
    txtEventDate.inputAccessoryView = toolBar;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    btnEvent.hidden = NO;
    
    if ([_strEventCheck isEqualToString:@"EventDetail"]) {
        
        txtDescription.delegate = self;
        txtDescription.text = [_dicEventDetail valueForKey:@"Description"];
        CGFloat fixedWidth = txtDescription.frame.size.width;
        
        CGSize newSize = [txtDescription sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        if (newSize.height==33) {
            
            newSize.height = 43;
        }
        CGRect newFrame = txtDescription.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        txtDescription.frame = newFrame;
        txtDescriptionHeight.constant = newSize.height;
        txtEventName.text = [_dicEventDetail valueForKey:@"Name"];
        
        txtEventDate.text = [_dicEventDetail valueForKey:@"EventDate"];
        txtEventStart.text = [_dicEventDetail valueForKey:@"StartTime"];
        txtEventEnd.text = [_dicEventDetail valueForKey:@"EndTime"];
        txtEventType.text = [_dicEventDetail valueForKey:@"Type"];
        NSSet *setSpecials =[_dicEventDetail valueForKey:@"Special"];
        arrSpecials = [setSpecials allObjects];
        txtEventSpacial.text = [arrSpecials componentsJoinedByString:@","];
        [btnEventImage setImage:_imgEvent forState:UIControlStateNormal];
        [btnSaveUpdate setTitle:@"Update" forState:UIControlStateNormal];
    }
    
    
    // Do any additional setup after loading the view.
}
#pragma mark - Custome Method
- (void)changeDateFromLabel:(id)sender
{
    [txtEventStart resignFirstResponder];
    [txtEventEnd resignFirstResponder];
    [txtEventDate resignFirstResponder];
}
-(void)dateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)txtEventDate.inputView;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventDate = picker.date;
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString *dateString = [dateFormat stringFromDate:eventDate];
    txtEventDate.text = [NSString stringWithFormat:@"%@",dateString];
}
-(void)updateTextFieldEnd:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)txtEventEnd.inputView;
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"hh:mm a"]; //24hr time format
    NSString *dateString = [outputFormatter stringFromDate:picker.date];
    txtEventEnd.text =  [NSString stringWithFormat:@"%@",dateString];
}
-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)txtEventStart.inputView;
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"hh:mm a"]; //24hr time format
    NSString *dateString = [outputFormatter stringFromDate:picker.date];
    txtEventStart.text =  [NSString stringWithFormat:@"%@",dateString];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Method
-(IBAction)clickSaveBtn:(id)sender
{
    if ([[Singlton sharedManager]check_null_data:txtEventName.text]) {
        
        [[Singlton sharedManager] alert:self title:Alert message:EventName];
        
    }
    else if ([[Singlton sharedManager]check_null_data:txtDescription.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:EventDescription];
    }
    else if ([[Singlton sharedManager]check_null_data:txtEventStart.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:EventStartTime];
    }
    else if ([[Singlton sharedManager]check_null_data:txtEventEnd.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:EventEndTime];
    }
    else if ([[Singlton sharedManager]check_null_data:txtEventSpacial.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:EventSpecial];
    }
    else if ([[Singlton sharedManager]check_null_data:txtEventType.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:EventType];
    }
    else if (!btnEventImage.currentImage)
    {
        [[Singlton sharedManager] alert:self title:Alert message:EventImage];
    }
    else
    {
       [self.view endEditing:YES];
        if (chosenImage)
             [self UploadEventImage];
        else
            [self UpdateEvent];
    }
}
-(void)clickEventImage:(UIButton *)sender
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

#pragma mark - UIImagePickerController Delegate Method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    chosenImage = info[UIImagePickerControllerEditedImage];
    [btnEventImage setImage:chosenImage forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ----------Touches event------------
//Implement for hide keyborad on touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        
        [txtEventName resignFirstResponder];
        [txtDescription resignFirstResponder];
        [txtEventStart resignFirstResponder];
        [txtEventEnd resignFirstResponder];
        [txtEventSpacial resignFirstResponder];
        [txtEventType resignFirstResponder];
        
    }
}
#pragma mark - UITextView Delegates
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return textView.text.length + (text.length - range.length) <= 250;
}
- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    if (newSize.height==33) {
        
        newSize.height = 43;
    }
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    txtDescriptionHeight.constant = newSize.height;
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==0)
        return arrayEventType.count;
    else
        return arrText.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==0) {
        
        static NSString *simpleTableIdentifier = @"SimpleTableItem";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        cell.textLabel.font = [UIFont fontWithName:@"Roboto" size:12.0];
        cell.textLabel.text = [arrayEventType objectAtIndex:indexPath.row];
        UITapGestureRecognizer *recognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureActionType:)];
        [recognizer1 setNumberOfTapsRequired:1];
        scrollView.userInteractionEnabled = YES;
        [scrollView addGestureRecognizer:recognizer1];
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        EventTypeNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[EventTypeNameTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.imgEventType.image =[arrImages objectAtIndex:indexPath.row];
        cell.lblName.text = [arrText objectAtIndex:indexPath.row];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)];
        [recognizer setNumberOfTapsRequired:1];
        scrollView.userInteractionEnabled = YES;
        [scrollView addGestureRecognizer:recognizer];
        return cell;
    }
}
-(void)gestureAction:(UITapGestureRecognizer *) sender
{
    CGPoint touchLocation = [sender locationOfTouch:0 inView:_tblEventType];
    NSIndexPath *indexPath = [_tblEventType indexPathForRowAtPoint:touchLocation];
    if ([[arrText objectAtIndex:indexPath.row] isEqualToString:@"Other"])
    {
        btnEvent.hidden = YES;
        [txtEventSpacial becomeFirstResponder];
        _tblEventType.hidden = YES;
    }
    else
    {
        if (![arrType containsObject:[arrText objectAtIndex:indexPath.row]])
        {
            [arrType addObject:[arrText objectAtIndex:indexPath.row]];
            txtEventSpacial.text = [arrType componentsJoinedByString:@","];
            _tblEventType.hidden = YES;
        }
    }
}
-(void)gestureActionType:(UITapGestureRecognizer *) sender
{
    CGPoint touchLocation = [sender locationOfTouch:0 inView:tblType];
    NSIndexPath *indexPath = [tblType indexPathForRowAtPoint:touchLocation];
    if ([[arrayEventType objectAtIndex:indexPath.row] isEqualToString:@"Other"])
    {
        btnType.hidden = YES;
        [txtEventType becomeFirstResponder];
        tblType.hidden = YES;
    }
    else
    {
        txtEventType.text = [arrayEventType objectAtIndex:indexPath.row];
        tblType.hidden = YES;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}
#pragma mark - Custome Method
- (void) textField1Active:(UITextField *)textField
{
    [[self view] endEditing:YES];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,_tblEventType.frame.size.height+_tblEventType.frame.origin.y);
    _tblEventType.hidden = NO;
}
-(void)addUpdatePopup
{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Message"
                                  message:@"The Event is updated."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* YesAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                          VenueOwnerHomeViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueOwnerHomeViewController"];
                                                          [self.navigationController pushViewController:Vc animated:YES];
                                                          
                                                      }];
    
    
    [alert addAction:YesAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark -  CLLocationManager Delegate
//Get User Current Location
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    
    CLLocation *newLocation = [locations lastObject];
    CLLocation *oldLocation;
    if (locations.count >= 2) {
        oldLocation = [locations objectAtIndex:locations.count-1];
    } else {
        oldLocation = nil;
    }
    latitude = newLocation.coordinate.latitude;
    longitude =newLocation.coordinate.longitude;
    
    [self.locationManager stopUpdatingLocation];
    
}

#pragma mark - AWS Method
//Save Venue Profile Details
-(void)saveVenueEvent
{
    self.view.userInteractionEnabled = NO;
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSString *Id = [NSString stringWithFormat:@"%@%f",[dicUserData valueForKey:@"Email"],timeInSeconds];
    
    
    NSSet *setVemueType = [NSSet setWithArray:arrType];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    KN_Event *ProfileEvent = [KN_Event new];
    ProfileEvent.Id = Id;
    ProfileEvent.VenueId = [dicProfileSetup valueForKey:@"Id"] ;
    ProfileEvent.Name = txtEventName.text;
    ProfileEvent.Description = txtDescription.text;
    ProfileEvent.Special = setVemueType;
    ProfileEvent.Type = txtEventType.text;
    ProfileEvent.EventDate = txtEventDate.text;
    ProfileEvent.StartTime = txtEventStart.text;
    ProfileEvent.EndTime = txtEventEnd.text;
    ProfileEvent.Image = strImageName;
    ProfileEvent.Latitude = [NSNumber numberWithFloat:latitude].stringValue;
    ProfileEvent.Longitude = [NSNumber numberWithFloat:longitude].stringValue;
    ProfileEvent.CreatedAt = NumberCreatedAt;
    ProfileEvent.UpdatedAt = NumberCreatedAt;
    
    [[dynamoDBObjectMapper save:ProfileEvent]
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
                 VenueOwnerHomeViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueOwnerHomeViewController"];
                 [self.navigationController pushViewController:Vc animated:YES];
                 
             });
             
         }
         return nil;
     }];
    
}
-(void)UploadEventImage
{
    [[Singlton sharedManager]showHUD];
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSString *strTimeStamp = [NumberCreatedAt stringValue];

    strTimeStamp = [strTimeStamp stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *trimmed = [txtEventName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    trimmed = [trimmed stringByReplacingOccurrencesOfString:@" " withString:@""];
    strImageName = [NSString stringWithFormat:@"%@%@.jpg",trimmed,strTimeStamp];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:strImageName];
    NSData *imgData= UIImageJPEGRepresentation(chosenImage,0.6);
    chosenImage = [UIImage imageWithData:imgData];
    [UIImagePNGRepresentation(chosenImage) writeToFile:filePath atomically:YES];
    NSURL* imageUrl = [NSURL fileURLWithPath:filePath];
    AWSS3TransferManager *transferManager =
    [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
     uploadRequest.bucket = [UserMode isEqualToString:@"Test"] ? @"staging-knevents":@"kon-event";
    
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
                                                                   if ([_strEventCheck isEqualToString:@"EventDetail"]) {
                                                                       
                                                                       [self UpdateEvent];
                                                                   }
                                                                   else
                                                                   {
                                                                   [self saveVenueEvent];
                                                                   }
                                                                   
                                                               });
                                                               
                                                               
                                                               
                                                           }
                                                           
                                                           return nil;
                                                           
                                                           
                                                       }];
    
}
-(void)UpdateEvent
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    NSArray *arraySpcl;
    NSSet *setSpecial;
    if (arrType.count>0) {
        
        setSpecial = [NSSet setWithArray:arrType];
        arraySpcl = [setSpecial allObjects];
        
    }
    else
    {
        setSpecial = [NSSet setWithArray:arrSpecials];
        arraySpcl = [setSpecial allObjects];
    }
   
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
    AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    
    hashKeyValue.S = [_dicEventDetail valueForKey:@"Id"];
    updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_Event" : @"Event";
    updateInput.key = @{ @"Id" : hashKeyValue };

    //********************* Event Name
    AWSDynamoDBAttributeValue *newFirstNameValue = [AWSDynamoDBAttributeValue new];
    newFirstNameValue.S = txtEventName.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdateForFirstName = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateForFirstName.value = newFirstNameValue;
    valueUpdateForFirstName.action = AWSDynamoDBAttributeActionPut;

    //********************* Event Description
    AWSDynamoDBAttributeValue *newDescriptionValue = [AWSDynamoDBAttributeValue new];
    newDescriptionValue.S = txtDescription.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdateDescription = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateDescription.value = newDescriptionValue;
    valueUpdateDescription.action = AWSDynamoDBAttributeActionPut;

    //********************* Event Date
    AWSDynamoDBAttributeValue *newDate = [AWSDynamoDBAttributeValue new];
    newDate.S = txtEventDate.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdateForEventDate = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateForEventDate.value = newDate;
    valueUpdateForEventDate.action = AWSDynamoDBAttributeActionPut;
    //********************* StartTime

    AWSDynamoDBAttributeValue *newStartTime = [AWSDynamoDBAttributeValue new];
    newStartTime.S = txtEventStart.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdateStartTime = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateStartTime.value = newStartTime;
    valueUpdateStartTime.action = AWSDynamoDBAttributeActionPut;

    //********************* EndTime

    AWSDynamoDBAttributeValue *newEndTime = [AWSDynamoDBAttributeValue new];
    newEndTime.S = txtEventEnd.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdateEndTime = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateEndTime.value = newEndTime;
    valueUpdateEndTime.action = AWSDynamoDBAttributeActionPut;

    //********************* Event Type

    AWSDynamoDBAttributeValue *newType = [AWSDynamoDBAttributeValue new];
    newType.S = txtEventType.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdateType = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateType.value = newType;
    valueUpdateType.action = AWSDynamoDBAttributeActionPut;
    
    //********************* Event Photo
    AWSDynamoDBAttributeValue *newImage;
    AWSDynamoDBAttributeValueUpdate *valueImage;
    if (chosenImage) {
    newImage = [AWSDynamoDBAttributeValue new];
    newImage.S = strImageName;
    valueImage = [AWSDynamoDBAttributeValueUpdate new];
    valueImage.value = newImage;
    valueImage.action = AWSDynamoDBAttributeActionPut;
    }

    //********************* Specials

    AWSDynamoDBAttributeValue *newSpecial = [AWSDynamoDBAttributeValue new];
    newSpecial.SS = arraySpcl;
    AWSDynamoDBAttributeValueUpdate *valueUpdatespecial = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdatespecial.value = newSpecial;
    valueUpdatespecial.action = AWSDynamoDBAttributeActionPut;

    if (chosenImage) {
        updateInput.attributeUpdates = @{@"Name": valueUpdateForFirstName,@"Description": valueUpdateDescription,@"EventDate": valueUpdateForEventDate,@"StartTime": valueUpdateStartTime,@"EndTime": valueUpdateEndTime,@"Special": valueUpdatespecial,@"Type": valueUpdateType,@"Image":valueImage};
    }
    else
    {
         updateInput.attributeUpdates = @{@"Name": valueUpdateForFirstName,@"Description": valueUpdateDescription,@"EventDate": valueUpdateForEventDate,@"StartTime": valueUpdateStartTime,@"EndTime": valueUpdateEndTime,@"Special": valueUpdatespecial,@"Type": valueUpdateType};
    }

//@"Image":valueUpdateForProfile

    updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;

    [[dynamoDB updateItem:updateInput]continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            // NSLog(@"The request failed. Error: [%@]", task.error);
            dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"Error: %@", task.error);
                [[Singlton sharedManager]killHUD];
            });
        }
        
        if (task.result) {
            //Do something with result.
            dispatch_async(dispatch_get_main_queue(), ^{
                //  [self getLoginUser];
               
                [[Singlton sharedManager]killHUD];
                self.view.userInteractionEnabled = YES;
                [self addUpdatePopup];;
            });
        }
        return nil;
    }];



}

#pragma IBAction Method
- (IBAction)clickSpecial:(id)sender
{
    [[self view] endEditing:YES];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,_tblEventType.frame.size.height+_tblEventType.frame.origin.y);
    _tblEventType.hidden = NO;
     [_tblEventType reloadData];
    tblType.hidden = YES;
}
- (IBAction)clickEvent:(id)sender
{
    [[self view] endEditing:YES];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,tblType.frame.size.height+tblType.frame.origin.y);
    tblType.hidden = NO;
    [tblType reloadData];
    _tblEventType.hidden = YES;
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
