//
//  EditProfileViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 29/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "EditProfileViewController.h"
#import "MainViewController.h"
#import <AWSS3/AWSS3.h>
#import "Singlton.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ImageCompress.h"
#import "EditProfileAutoFillCell/EditProfileAutoFillCell.h"
#import "KN_User.h"
@interface EditProfileViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate>
{
    NSMutableDictionary *dictUserInfo;
    NSString *strId;
    NSString *strLong, *strLat;
    NSString *strImageName;
    BOOL isImageChanged;
 UIViewController *viewLogin;
    NSMutableArray *arrListCity;
}
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isImageChanged = NO;
    arrListCity = [NSMutableArray new];
    dictUserInfo = [NSMutableDictionary new];
    dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
    // Do any additional setup after loading the view.
    //For the textField Padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    _txtFirstName.leftView = paddingView;
    _txtFirstName.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingViewPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    _txtLastName.leftView = paddingViewPassword;
    _txtLastName.leftViewMode = UITextFieldViewModeAlways;
    UIView *confirmPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
   
    _txtHomeLoc.leftView = confirmPassword;
    _txtHomeLoc.leftViewMode = UITextFieldViewModeAlways;
    _imgUserPic.image = nil;
    if(![[dictUserInfo valueForKey:@"UserImage"]isEqualToString:@"NA"])
    {
        if([[dictUserInfo valueForKey:@"fblogin"]isEqualToString:@"YES"])
        {
           
            if([[dictUserInfo valueForKey:@"FBProfilePicChanged"]isEqualToString:@"YES"])
            {
                if([[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"]!=nil)
                {
                    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"];
                    UIImage* imgUserLocal = [UIImage imageWithData:imageData];
                    _imgUserPic.image = imgUserLocal;
                    
                }
                else
                {
                NSString *strForEventImageName = [[dictUserInfo valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                NSURL *imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
                
                [_imgUserPic sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"] options:SDWebImageRefreshCached];
                }
            }
            else
            {
            NSURL *imageUrl = [[NSURL alloc] initWithString:[dictUserInfo valueForKey:@"UserImage"]];
             [_imgUserPic sd_setImageWithURL:imageUrl] ;
            }
        }
        else
        {
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"]!=nil)
            {
                  NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"];
                UIImage* imgUserLocal = [UIImage imageWithData:imageData];
                _imgUserPic.image = imgUserLocal;
                
            }
            else{
             _imgUserPic.image = nil;
             NSString *strForEventImageName = [[dictUserInfo valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSURL *imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
           
          [_imgUserPic sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"] options:SDWebImageRefreshCached];
            }
      
            
        }
        
   
       
    }
    else
    {
        [_imgUserPic sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
    }
    if([[dictUserInfo valueForKey:@"firstName"]isEqualToString:@"NA"]||[[dictUserInfo valueForKey:@"lastName"]isEqualToString:@"NA"])
    {
    }
    else
    {
        _txtFirstName.text = [dictUserInfo valueForKey:@"firstName"];
        _txtLastName.text = [dictUserInfo valueForKey:@"lastName"];
    }
    if([[dictUserInfo valueForKey:@"HomeLocation"]isEqualToString:@"NA"])
    {
        
    }
    else
    {
        
        _txtHomeLoc.text = [dictUserInfo valueForKey:@"HomeLocation"];
    }
    [[Singlton sharedManager]imageProfileRounded:_imgUserPic withFlot:_imgUserPic.frame.size.width/2 withCheckLayer:NO];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [_txtHomeLoc addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    }
}

-(void)textFieldDidChange
{
     [self  getApiForAutoComplete:_txtHomeLoc.text];
}
-(void)getApiForAutoComplete:(NSString *)strInput

{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *strUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=%@&input=%@",GoogleApiKey,strInput];
    NSString* webStringURL = [strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString: webStringURL];
    
    // Asynchronously Api is hit here
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                       {
                                           NSDictionary* json = [NSJSONSerialization
                                                                 JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                 error:&error];
                                           
                                           arrListCity = [[json valueForKey:@"predictions"]valueForKey:@"description"];
                                           
                                           NSLog(@"%@",arrListCity);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c]%@", _txtHomeLoc.text];
                                               NSArray *resultArray = [[arrListCity filteredArrayUsingPredicate:predicate] mutableCopy];
                                               arrListCity = [NSMutableArray arrayWithArray:resultArray];
                                               if (arrListCity.count>0) {
                                                   
                                                   _tblAutoFill.hidden = NO;
                                                   [_tblAutoFill reloadData];
                                               }
                                               else
                                               {
                                                   _tblAutoFill.hidden = YES;
                                               }
                                           });
                                           
                                           
                                       }];
    
    [dataTask resume];
}

#pragma mark - Table Delegate And DataSOurce Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
        return arrListCity.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    return 44;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
        static NSString *CellIdentifier = @"Cell";
        EditProfileAutoFillCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[EditProfileAutoFillCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.lblAddress.text = [arrListCity objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        _txtHomeLoc.text = [arrListCity objectAtIndex:indexPath.row];
       _tblAutoFill.hidden = YES;
   
}
-(void)viewWillAppear:(BOOL)animated
{
   
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
}

#pragma mark - Delegate Method to update userLoc
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

#pragma mark ----
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionChoosePic:(id)sender {
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
    
    UIImage *chosenImage;
    chosenImage = info[UIImagePickerControllerEditedImage];
    _imgUserPic.image = chosenImage;
     isImageChanged = YES;
    // [_btnUserPic setImage:chosenImage forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - Updating UserData In DB
- (IBAction)funcSave:(id)sender {
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    if ([[Singlton sharedManager]check_null_data:_txtFirstName.text]) {
        
        [[Singlton sharedManager] alert:self title:Alert message:FirstName];
    }
   
    else if ([[Singlton sharedManager]check_null_data:_txtLastName.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:LastName];
    }
    else if ([[Singlton sharedManager]check_null_data:_txtHomeLoc.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:HomeLoc];
    }
    else
    {
       
        [self callEditProfileAPI];
    }
}



- (void)callEditProfileAPI {
     [[Singlton sharedManager]showHUD];
    if(isImageChanged == YES)
    {
    //[[SDImageCache sharedImageCache]clearMemory];
   // [[SDImageCache sharedImageCache]clearDisk];
    }
 
     UIImage *compressedImage = [[Singlton sharedManager]imageWithImage:_imgUserPic.image scaledToSize:CGSizeMake(150, 150)];
    _imgUserPic.image = compressedImage;
   strImageName = [NSString stringWithFormat:@"%@.jpg",[dictUserInfo valueForKey:@"Email"]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:strImageName];
    [UIImagePNGRepresentation(compressedImage) writeToFile:filePath atomically:YES];
    
    NSURL* imageUrl = [NSURL fileURLWithPath:filePath];
    
    AWSS3TransferManager *transferManager =
    [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = [UserMode isEqualToString:@"Test"] ? @"staging-consumerprofile":@"kon-consumerprofile";
    uploadRequest.key = strImageName;
    uploadRequest.body  =   imageUrl;
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error) {
                                                                [[Singlton sharedManager]killHUD];
                                                                [[Singlton sharedManager] alert:self title:Message message:@"Please try again"];
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
                                                                   
                                                               }
                                                           }
                                                           
                                                           if (task.result) {
                                                               isImageChanged = NO;
                                                  if([[dictUserInfo valueForKey:@"fblogin"]isEqualToString:@"YES"])
                                                  {
                                                      [dictUserInfo setObject:@"NO" forKey:@"fblogin"];
                                                      [dictUserInfo setObject:@"YES" forKey:@"FBProfilePicChanged"];
                                                 [[NSUserDefaults standardUserDefaults]setObject:dictUserInfo forKey:@"loginUser"];
                                                      //FBProfilePicChanged
                                                  }
                                                                   [self UpdateProfile:[dictUserInfo valueForKey:@"UserId"]];
                                                               
                                                               
                                                           }
                                                           
                                                           return nil;
                                                           
                                                           
                                                       }];
    
    
    
}



-(void)UpdateProfile:(NSString *)strUserId
{
    strLong =[NSString stringWithFormat:@"%f",longitude];
    strLat = [NSString stringWithFormat:@"%f",latitude];
    if([strLong isEqualToString:@""] || [strLat isEqualToString:@""])
    {
        strLong = @"75.8577";
        strLat = @"22.7196";
    }
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
    AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    
    hashKeyValue.S = strUserId;
    updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_User" : @"User";
    updateInput.key = @{ @"UserId" : hashKeyValue };
    //FirstName
    AWSDynamoDBAttributeValue *newPrice = [AWSDynamoDBAttributeValue new];
    newPrice.S = _txtFirstName.text.capitalizedString;
    AWSDynamoDBAttributeValueUpdate *valueUpdate = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate.value = newPrice;
    valueUpdate.action = AWSDynamoDBAttributeActionPut;
  
    
    //LastName
    AWSDynamoDBAttributeValue *newPrice2 = [AWSDynamoDBAttributeValue new];
    newPrice2.S = _txtLastName.text.capitalizedString;
    AWSDynamoDBAttributeValueUpdate *valueUpdate2 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate2.value = newPrice2;
    valueUpdate2.action = AWSDynamoDBAttributeActionPut;
    
    
     //Lattitude
    AWSDynamoDBAttributeValue *newPrice3 = [AWSDynamoDBAttributeValue new];
    newPrice3.S = strLat;
    AWSDynamoDBAttributeValueUpdate *valueUpdate3 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate3.value = newPrice3;
   valueUpdate3.action = AWSDynamoDBAttributeActionPut;
   
    
    //Longitude
    AWSDynamoDBAttributeValue *newPrice4 = [AWSDynamoDBAttributeValue new];
    newPrice4.S = strLong;
    AWSDynamoDBAttributeValueUpdate *valueUpdate4 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate4.value = newPrice4;
    valueUpdate4.action = AWSDynamoDBAttributeActionPut;
   
    
    //UpdatedAt
    AWSDynamoDBAttributeValue *newPrice5 = [AWSDynamoDBAttributeValue new];
    newPrice5.S = [NSString stringWithFormat:@"%@",NumberCreatedAt];
    AWSDynamoDBAttributeValueUpdate *valueUpdate5 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate5.value = newPrice5;
    valueUpdate5.action = AWSDynamoDBAttributeActionPut;
   
    
    //UserImage
    AWSDynamoDBAttributeValue *newPrice6 = [AWSDynamoDBAttributeValue new];
    newPrice6.S = strImageName;
    AWSDynamoDBAttributeValueUpdate *valueUpdate6 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate6.value = newPrice6;
    valueUpdate6.action = AWSDynamoDBAttributeActionPut;
    
    //HomeLOc
    AWSDynamoDBAttributeValue *newPrice7 = [AWSDynamoDBAttributeValue new];
    newPrice7.S = _txtHomeLoc.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdate7 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate7.value = newPrice7;
    valueUpdate7.action = AWSDynamoDBAttributeActionPut;
    
    //FBProfilePicChanged
    AWSDynamoDBAttributeValue *newPrice8 = [AWSDynamoDBAttributeValue new];
    newPrice8.S = @"YES";
    AWSDynamoDBAttributeValueUpdate *valueUpdate8 = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdate8.value = newPrice8;
    valueUpdate8.action = AWSDynamoDBAttributeActionPut;
 
    
    updateInput.attributeUpdates = @{@"Firstname": valueUpdate,@"Lastname":valueUpdate2,@"Latitude":valueUpdate3,@"Longitude":valueUpdate4,@"UpdatedAt":valueUpdate5,@"UserImage":valueUpdate6,@"HomeLocation":valueUpdate7,@"FBProfilePicChanged":valueUpdate8};

    updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
    
    [[dynamoDB updateItem:updateInput]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                  [[Singlton sharedManager] alert:self title:Message message:@"Please try again"];
                  self.view.userInteractionEnabled = YES;
             });
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
        if (task.result) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Singlton sharedManager]killHUD];
                dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
                [dictUserInfo setObject:_txtFirstName.text forKey:@"firstName"];
                [dictUserInfo setObject:strImageName forKey:@"UserImage"];
                [dictUserInfo setObject:_txtLastName.text forKey:@"lastName"];
                [dictUserInfo setObject:_txtHomeLoc.text forKey:@"HomeLocation"];
                [[NSUserDefaults standardUserDefaults]setObject:dictUserInfo forKey:@"loginUser"];
                [[NSUserDefaults standardUserDefaults]setObject:UIImagePNGRepresentation(_imgUserPic.image) forKey:@"localUserImage"];
                // Calling NSNotificationCenter for updating the data in sidemenuBar
                [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateValues"object:self];
                [self.navigationController popViewControllerAnimated:YES];
                self.view.userInteractionEnabled = YES;
            });
            
             
             
         }
         return nil;
     }];
    
}
-(void)UpdateVenueRatingUserNameInfo:(NSString *)strUserName AndUserId:(NSString *)strUserId
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
        AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
        AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
        hashKeyValue.S = strUserId;
        updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_VenueRating" : @"VenueRating";
        updateInput.key = @{ @"UserId" : hashKeyValue };
        //FirstName
        AWSDynamoDBAttributeValue *newPrice = [AWSDynamoDBAttributeValue new];
        newPrice.S = strUserName.capitalizedString;
        AWSDynamoDBAttributeValueUpdate *valueUpdate = [AWSDynamoDBAttributeValueUpdate new];
        valueUpdate.value = newPrice;
        valueUpdate.action = AWSDynamoDBAttributeActionPut;
        updateInput.attributeUpdates = @{@"UserName": valueUpdate
                                         };
        updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
        [[dynamoDB updateItem:updateInput]
         continueWithBlock:^id(AWSTask *task) {
             if (task.error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[Singlton sharedManager]killHUD];
                     self.view.userInteractionEnabled = YES;
                     NSLog(@"The request failed. Error: [%@]", task.error);
                 });
                 
             }
             if (task.result) {
                 [[Singlton sharedManager]killHUD];
                 NSLog(@"Updated Successfully");
                 
             }
             return nil;
             
         }];
    });
}

- (IBAction)funcBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
