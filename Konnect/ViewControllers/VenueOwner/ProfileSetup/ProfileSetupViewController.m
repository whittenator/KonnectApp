//
//  ProfileSetupViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 26/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ProfileSetupViewController.h"
#import "VenueOwnerHomeViewController.h"
#import "MainViewController.h"
#import "SideViewController.h"
#import <AWSS3/AWSS3.h>
#import "UIImage+ImageCompress.h"
#import <AWSS3/AWSS3.h>
#import "KN_VenueProfileSetup.h"
#import "UIImageView+WebCache.h"
#import "AutoCompleteTableViewCell.h"
#import "EventTypeNameTableViewCell.h"
#import "SliderCollectionViewCell.h"
#import "AsyncImageView.h"
#define BTN_SKIP  0
#define BTN_DONE  1
#define BTN_BACK  2
@interface ProfileSetupViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,LGSideMenuDelegate,CLLocationManagerDelegate,UITextFieldDelegate>
{
    
    UIImageView *btnProfileVenueImage;
    UIImage *chosenImage;
    UIToolbar *toolBar;
    NSMutableArray *arrImages;
    NSMutableArray *arrImageName;
    NSInteger Imagecount;
    NSMutableDictionary *dicUserData;
    NSMutableArray *dicProfileDetails;
    NSMutableDictionary *dicAllProfileSetup;
    NSMutableArray *arrImageSet;
    NSString *strCheck;
    NSUInteger imageTag;
    NSMutableArray *arrListCity;
    NSMutableArray *arrText;
    NSMutableArray *arrSpecialImages;
    NSMutableArray *arrSpecialText;
    NSString *strProfileCheck;
    NSUInteger globelIndex;
    NSMutableDictionary *dicProfileSetup;
}
@end

@implementation ProfileSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dicProfileSetup = [[NSUserDefaults standardUserDefaults]valueForKey:@"VenueProfileData"];
    viewContainer.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewContainer.layer.borderWidth = 0.5f;
    
    tblSecials.layer.borderColor = [UIColor lightGrayColor].CGColor;
    tblSecials.layer.borderWidth = 0.5f;
    
    dicUserData  = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"DefaultArray"];
    if(data != nil){
        NSArray *arrTemp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (arrTemp.count>0) {
            
            arrImages = [[NSMutableArray alloc]initWithArray:arrTemp];
        }
        else
        {
            arrImages = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"DefaultSetupImage"],[UIImage imageNamed:@"DefaultSetupImage"],[UIImage imageNamed:@"DefaultSetupImage"],[UIImage imageNamed:@"DefaultSetupImage"],[UIImage imageNamed:@"DefaultSetupImage"], nil];
        }
    }
    else
    {
        arrImages = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"DefaultSetupImage"],[UIImage imageNamed:@"DefaultSetupImage"],[UIImage imageNamed:@"DefaultSetupImage"],[UIImage imageNamed:@"DefaultSetupImage"],[UIImage imageNamed:@"DefaultSetupImage"], nil];
    }
    arrImageName = [[NSMutableArray alloc]init];
    arrImageSet = [[NSMutableArray alloc]init];
    arrSpecialText = [[NSMutableArray alloc]init];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtVenueName.leftView = paddingView;
    txtVenueName.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingViewPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtVenueAddress.leftView = paddingViewPassword;
    txtVenueAddress.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingViewPhone = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtVenuePhoneNo.leftView = paddingViewPhone;
    txtVenuePhoneNo.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingViewStart = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtVenueStart.leftView = paddingViewStart;
    txtVenueStart.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingViewEnd = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtVenueEnd.leftView = paddingViewEnd;
    txtVenueEnd.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingViewSpcl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtVenueSpecials.leftView = paddingViewSpcl;
    txtVenueSpecials.leftViewMode = UITextFieldViewModeAlways;
    
    [rateStarView  addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeTime;
    //[datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    
    UIDatePicker *datePickerEnd = [[UIDatePicker alloc]init];
    datePickerEnd.datePickerMode = UIDatePickerModeTime;
    //[datePicker setDate:[NSDate date]];
    [datePickerEnd addTarget:self action:@selector(updateTextFieldEnd:) forControlEvents:UIControlEventValueChanged];
    
    [txtVenueStart setInputView:datePicker];
    [txtVenueEnd setInputView:datePickerEnd];
    
    
    toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    [toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleDone target:self action:@selector(changeDateFromLabel:)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor blackColor];
    txtVenueStart.inputAccessoryView = toolBar;
    txtVenueEnd.inputAccessoryView = toolBar;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    singleTap.cancelsTouchesInView = NO;
    [scrollView addGestureRecognizer:singleTap];
    
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
    
    if ([_StrTextCheck isEqualToString:@"Notification"]) {
        
        btnBack.hidden = NO;
        btnSkip.hidden = YES;
        [self FetchVenueProfile];
    }
    else
    {
        btnBack.hidden = YES;
        btnSkip.hidden = NO;
        
        txtVenueAddress.text = [dicProfileSetup valueForKey:@"Address"];
        txtVenueStart.text = [dicProfileSetup valueForKey:@"StartTime"];
        txtVenueEnd.text = [dicProfileSetup valueForKey:@"EndTime"];
        txtVenueName.text = [dicProfileSetup valueForKey:@"Name"];
        txtVenuePhoneNo.text = [dicProfileSetup valueForKey:@"PhoneNumber"];
    }
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    txtVenueName.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    txtVenueAddress.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    txtVenueSpecials.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    strProfileCheck = @"FiveImages";
    strCheck = @"Normal";
    viewContainer.hidden = YES;
    
    [txtVenueAddress addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    
    arrSpecialImages = [[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"Drinks"],[UIImage imageNamed:@"Food"],[UIImage imageNamed:@"Music"],[UIImage imageNamed:@"FoodCart"],[UIImage imageNamed:@"Music"] ,nil];
    
    arrText = [[NSMutableArray alloc]initWithObjects:@"Drinks",@"Food",@"Music",@"FoodCart",@"Other",nil];
    
    
    txtVenueSpecials.delegate= self;
    tblSecials.hidden = YES;
    btnSpecials.hidden = NO;
    
    //[self createScrollMenu];
    
    // Do any additional setup after loading the view.
}

#pragma mark - Custome Method
- (void)changeDateFromLabel:(id)sender
{
    [txtVenueEnd resignFirstResponder];
    [txtVenueStart resignFirstResponder];
}
-(void)updateTextFieldEnd:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)txtVenueEnd.inputView;
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"hh:mm a"]; //24hr time format
    NSString *dateString = [outputFormatter stringFromDate:picker.date];
    txtVenueEnd.text =  [NSString stringWithFormat:@"%@",dateString];
}
-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)txtVenueStart.inputView;
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"hh:mm a"]; //24hr time format
    NSString *dateString = [outputFormatter stringFromDate:picker.date];
    txtVenueStart.text =  [NSString stringWithFormat:@"%@",dateString];
    
}
- (void)createScrollMenu
{
    
    int x = 10;
    for (int i = 0; i < 5; i++) {
        
        btnProfileVenueImage =[[UIImageView alloc] initWithFrame:CGRectMake(x, 10, 112, 110)];
        btnProfileVenueImage.image=[UIImage imageNamed:@"DefaultSetupImage"];
        btnProfileVenueImage.tag = i;
        x += btnProfileVenueImage.frame.size.width+10;
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickVenueImage:)];
        [btnProfileVenueImage addGestureRecognizer:gestureRecognizer];
        btnProfileVenueImage.userInteractionEnabled = YES;
        [scrollHorizontal addSubview:btnProfileVenueImage];
        
    }
    [scrollHorizontal setShowsHorizontalScrollIndicator:NO];
    scrollHorizontal.contentSize = CGSizeMake(x , scrollHorizontal.frame.size.height);
    
}
- (void)ShowScrollImages
{
    
    int x = 10;
    UIButton *btnClose;
    for (int i = 0; i < arrImageSet.count; i++) {
        
        
        
        btnProfileVenueImage =[[UIImageView alloc] initWithFrame:CGRectMake(x, 10, 112, 110)];
        
        
        NSString *str = [NSString stringWithFormat:@"%@%@",BASE_VENUE_IMAGE_URL,[arrImageSet objectAtIndex:i]];
        NSCharacterSet *set = [NSCharacterSet URLFragmentAllowedCharacterSet];
        NSString * encodedString = [str stringByAddingPercentEncodingWithAllowedCharacters:set];
        NSURL *url = [NSURL URLWithString:encodedString];
        
        btnProfileVenueImage.imageURL =  url;
        btnProfileVenueImage.contentMode = UIViewContentModeScaleAspectFill;
        btnProfileVenueImage.clipsToBounds = YES;
        
        btnProfileVenueImage.tag = i;
        x += btnProfileVenueImage.frame.size.width+10;
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickVenueImage:)];
        [btnProfileVenueImage addGestureRecognizer:gestureRecognizer];
        btnProfileVenueImage.userInteractionEnabled = YES;
        
        
        
        if (![[arrImageSet objectAtIndex:i]isEqualToString:@"None"]) {
            
            btnClose.hidden = NO;
            btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnClose addTarget:self
                         action:@selector(clickCrosImage:)
               forControlEvents:UIControlEventTouchUpInside];
            [btnClose setImage:[UIImage imageNamed:@"CloseIcon"] forState:UIControlStateNormal];
            btnClose.frame = CGRectMake(btnProfileVenueImage.frame.size.width-25,-5,30,30);
            btnClose.tag = i;
            [btnProfileVenueImage addSubview:btnClose];
            
        }
        else
        {
            btnClose.hidden = YES;
        }
        [scrollHorizontal addSubview:btnProfileVenueImage];
        
    }
    [scrollHorizontal setShowsHorizontalScrollIndicator:NO];
    scrollHorizontal.contentSize = CGSizeMake(620 , scrollHorizontal.frame.size.height);
    
}
- (IBAction)didChangeValue:(HCSStarRatingView *)sender {
    NSLog(@"Changed rating to %.1f", sender.value);
}

#pragma mark - UITextField Delegates

- (void)textFieldDidChange
{
    //you may need to call [resultArray removeAllObjects] to get fresh list of cities here
    [self  getApiForAutoComplete:txtVenueAddress.text];
    
}

#pragma mark - IBAction Method
-(void)handleTap
{
    [txtVenueName resignFirstResponder];
    [txtVenueAddress resignFirstResponder];
    [txtVenuePhoneNo resignFirstResponder];
    [txtVenueStart resignFirstResponder];
    [txtVenueEnd resignFirstResponder];
    [txtVenueSpecials resignFirstResponder];
}
- (IBAction)clickButtons:(id)sender {
    
    UIButton * btnSelected = (UIButton *) sender;
    
    switch (btnSelected.tag) {
            
        case BTN_SKIP:
        {
            [self performSegueWithIdentifier:@"VenueScreen" sender:self];
            [[NSUserDefaults standardUserDefaults]setValue:@"SkipUser" forKey:@"SKIPUSER"];
        }
            break;
        case BTN_DONE:
        {
            if ([[Singlton sharedManager]check_null_data:txtVenueName.text]) {
                
                [[Singlton sharedManager] alert:self title:Alert message:VenueName1];
                
            }
            else if ([[Singlton sharedManager]check_null_data:txtVenueAddress.text])
            {
                [[Singlton sharedManager] alert:self title:Alert message:VenueAddress];
            }
            else if ([[Singlton sharedManager]check_null_data:txtVenuePhoneNo.text])
            {
                [[Singlton sharedManager] alert:self title:Alert message:VenuePhoneNumber];
            }
            else if ([[Singlton sharedManager]check_null_data:txtVenueStart.text])
            {
                [[Singlton sharedManager] alert:self title:Alert message:VenueStart];
            }
            else if ([[Singlton sharedManager]check_null_data:txtVenueEnd.text])
            {
                [[Singlton sharedManager] alert:self title:Alert message:VenueEnd];
            }
            else if ([[Singlton sharedManager]check_null_data:txtVenueSpecials.text])
            {
                [[Singlton sharedManager] alert:self title:Alert message:VenueSpecials];
            }
            else
            {
                [self.view endEditing:YES];
                if ([_StrTextCheck isEqualToString:@"Notification"]){
                    if (arrImages.count>0) {
                        Imagecount = 0;
                        [self upload:[[NSNumber numberWithInteger:Imagecount] stringValue]];
                    }
                    else
                    {
                        [self UpdateUserProfile];
                    }
                }
                else
                {
                    Imagecount = 0;
                    [self upload:[[NSNumber numberWithInteger:arrImages.count] stringValue]];
                }
            }
        }
        break;
            
        case BTN_BACK:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
            
    }
}
- (IBAction)clickSpecial:(id)sender
{
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, tblSecials.frame.size.height+tblSecials.frame.origin.y);
    
    tblSecials.hidden = NO;
    [tblSecials reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static NSString * extracted() {
    return Existing_Photos;
}

-(void)clickVenueImage:(UITapGestureRecognizer *)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:Take_A_Photo style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (sender.view.tag==0)
        {
            btnProfileVenueImage = (UIImageView *)sender.view;;
            
        }
        else if (sender.view.tag==1)
        {
            btnProfileVenueImage = (UIImageView *)sender.view;
            
        }
        else if (sender.view.tag==2)
        {
            btnProfileVenueImage = (UIImageView *)sender.view;
            
        }
        else if (sender.view.tag==3)
        {
            btnProfileVenueImage = (UIImageView *)sender.view;
            
        }
        else if (sender.view.tag==4)
        {
            btnProfileVenueImage = (UIImageView *)sender.view;
            
        }
        else if (sender.view.tag==5)
        {
            btnProfileVenueImage = (UIImageView *)sender.view;
            
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
        
        
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:extracted() style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (sender.view.tag==0)
        {
            btnProfileVenueImage = (UIImageView *)sender.view;
            
        }
        else if (sender.view.tag==1)
        {
            btnProfileVenueImage = (UIImageView *)sender.view;
            
        }
        else if (sender.view.tag==2)
        {
            btnProfileVenueImage = (UIImageView *)sender.view;
            
        }
        else if (sender.view.tag==3)
        {
            btnProfileVenueImage = (UIImageView *)sender.view;
            
        }
        else if (sender.view.tag==4)
        {
            btnProfileVenueImage = (UIImageView *)sender.view;
            
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}
-(void)clickCrosImage:(UIButton *)sender
{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Message"
                                  message:@"Are you want to sure delete the image?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* YesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                          
                                                          [arrImageSet removeObjectAtIndex:sender.tag];
                                                          [arrImages replaceObjectAtIndex:sender.tag withObject:[UIImage imageNamed:@"DefaultSetupImage"]];
                                                          
                                                          NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
                                                          NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arrImages];
                                                          [currentDefaults setObject:data forKey:@"DefaultArray"];
                                                          [self UpdateUserProfile];
                                                          
                                                          
                                                          
                                                      }];
    UIAlertAction* NoAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];
    
    [alert addAction:YesAction];
    [alert addAction:NoAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    //[self ShowScrollImages];
    
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==0) {
        return arrListCity.count;
    }
    else
    {
        return arrText.count;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    return 44;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==0) {
        static NSString *CellIdentifier = @"Cell";
        AutoCompleteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[AutoCompleteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.lblCityName.text = [arrListCity objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        EventTypeNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[EventTypeNameTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imgEventType.image =[arrSpecialImages objectAtIndex:indexPath.row];
        cell.lblName.text = [arrText objectAtIndex:indexPath.row];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==0) {
        
        txtVenueAddress.text = [arrListCity objectAtIndex:indexPath.row];
        viewContainer.hidden = YES;
    }
    else
    {
        
        if ([[arrText objectAtIndex:indexPath.row] isEqualToString:@"Other"])
        {
            btnSpecials.hidden = YES;
            [txtVenueSpecials becomeFirstResponder];
            tblSecials.hidden = YES;
        }
        else
        {
            if (![arrSpecialText containsObject:[arrText objectAtIndex:indexPath.row]])
            {
                [arrSpecialText addObject:[arrText objectAtIndex:indexPath.row]];
                txtVenueSpecials.text = [arrSpecialText componentsJoinedByString:@","];
                tblSecials.hidden = YES;
            }
        }
    }
    
}

#pragma mark - UIImagePickerController Delegate Method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    chosenImage = info[UIImagePickerControllerEditedImage];
    btnProfileVenueImage.image = chosenImage;
    if ([[arrImages objectAtIndex:0] isEqual:[UIImage imageNamed:@"DefaultSetupImage"]]) {
        [arrImages replaceObjectAtIndex:0 withObject:chosenImage];
        globelIndex = 0;
    }
    else if ([[arrImages objectAtIndex:1] isEqual:[UIImage imageNamed:@"DefaultSetupImage"]]) {
        [arrImages replaceObjectAtIndex:1 withObject:chosenImage];
        globelIndex = 1;
    }
    else if ([[arrImages objectAtIndex:2] isEqual:[UIImage imageNamed:@"DefaultSetupImage"]]) {
        [arrImages replaceObjectAtIndex:2 withObject:chosenImage];
        globelIndex = 2;
    }
    else if ([[arrImages objectAtIndex:3] isEqual:[UIImage imageNamed:@"DefaultSetupImage"]]) {
        [arrImages replaceObjectAtIndex:3 withObject:chosenImage];
        globelIndex = 3;
    }
    else if ([[arrImages objectAtIndex:4] isEqual:[UIImage imageNamed:@"DefaultSetupImage"]]) {
        [arrImages replaceObjectAtIndex:4 withObject:chosenImage];
        globelIndex = 4;
    }
    
    
    if(arrImageSet.count>0)
    {
        if (globelIndex < [arrImageSet count])
        {
            
            [arrImageSet replaceObjectAtIndex:globelIndex withObject:chosenImage];
            [arrImages replaceObjectAtIndex:globelIndex withObject:chosenImage];
        }
        else
        {
            [arrImageSet addObject:chosenImage];
          
        }
        
    }
    else
    {
        [arrImageSet addObject:chosenImage];
      
    }
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arrImages];
    [currentDefaults setObject:data forKey:@"DefaultArray"];
    
    [collectionSlider reloadData];
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
        
        [txtVenueName resignFirstResponder];
        [txtVenueAddress resignFirstResponder];
        [txtVenuePhoneNo resignFirstResponder];
        [txtVenueStart resignFirstResponder];
        [txtVenueEnd resignFirstResponder];
        [txtVenueSpecials resignFirstResponder];
        
    }
}
#pragma mark -  Navigation
//Navigation segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    
    if ([[segue identifier] isEqualToString:@"VenueScreen"])
    {
        SideViewController *loginController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SideViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginController];
        loginController.rootViewController = self;
        loginController.delegate = self;
        
        UIWindow *window = UIApplication.sharedApplication.delegate.window;
        window.rootViewController = navController;
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
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

#pragma mark -  AWS Method
//Upload Profile Images in recursion
- (void)upload:(NSString *)strImageCount {
    
    NSData *data1 = UIImagePNGRepresentation([UIImage imageNamed:@"DefaultSetupImage"]);
    NSData *data2 = UIImagePNGRepresentation([arrImages objectAtIndex:Imagecount]);
    if(data1.length == data2.length) {
        
        if([data1 isEqual:data2]) {
            Imagecount++;
            if (Imagecount<arrImages.count) {
                [self upload:[[NSNumber numberWithInteger:Imagecount] stringValue]];
            }
            else
            {
                if ([strCheck isEqualToString:@"ProfileFetch"])
                    [self UpdateUserProfile];
                else
                    [self UpdateUserProfile];
            }
        }else
            [self SavePhotoToS3];
    }
    else
        [self SavePhotoToS3];
}
-(void)SavePhotoToS3
{
    [[Singlton sharedManager]showHUD];
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSString *strImageName = [NSString stringWithFormat:@"%@%@.jpg", [dicUserData valueForKey:@"Email"],NumberCreatedAt];
    if ([arrImageSet containsObject:@"None"]) {
        
        [arrImageSet removeObject:@"None"];
        [arrImageSet addObject:strImageName];
    }
    else
    {
        if (Imagecount < [arrImageSet count])
            [arrImageSet replaceObjectAtIndex:Imagecount withObject:strImageName];
        else
            [arrImageSet addObject:strImageName];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:strImageName];
    
    UIImage *compressedImage = [[Singlton sharedManager]imageWithImage:[arrImages objectAtIndex:Imagecount] scaledToSize:CGSizeMake(450, 150)];
    ;
    
    [UIImagePNGRepresentation(compressedImage) writeToFile:filePath atomically:YES];
    NSURL* imageUrl = [NSURL fileURLWithPath:filePath];
    AWSS3TransferManager *transferManager =
    [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = [UserMode isEqualToString:@"Test"] ? @"staging-profilesetup":@"kon-profilesetup";
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
                                                               
                                                               Imagecount++;
                                                               
                                                               if (Imagecount<arrImages.count) {
                                                                   [self upload:[[NSNumber numberWithInteger:Imagecount] stringValue]];
                                                               }
                                                               else
                                                               {
                                                                   if ([strCheck isEqualToString:@"ProfileFetch"])
                                                                       [self UpdateUserProfile];
                                                                   else
                                                                       [self UpdateUserProfile];
                                                               }
                                                           }
                                                           return nil;
                                                       }];
    
}
//Save Venue Profile Details
-(void)SaveVenueProfiledata
{
    
    self.view.userInteractionEnabled = NO;
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSString *Id = [NSString stringWithFormat:@"%@%f",txtVenueName.text,timeInSeconds];
    
    NSArray *array = [NSArray arrayWithArray:arrImageSet];
    array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    arrImageSet = [NSMutableArray arrayWithArray:array];
    NSSet *setImages = [NSSet setWithArray:arrImageSet];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    KN_VenueProfileSetup *ProfileDetail = [KN_VenueProfileSetup new];
    ProfileDetail.Id = Id;
    ProfileDetail.UserId = [dicUserData valueForKey:@"UserId"] ;
    ProfileDetail.Name = txtVenueName.text;
    ProfileDetail.VenueName = txtVenueName.text;
    ProfileDetail.Address = txtVenueAddress.text;
    ProfileDetail.PhoneNumber =  txtVenuePhoneNo.text;
    ProfileDetail.Special = txtVenueSpecials.text;
    ProfileDetail.StartTime = txtVenueStart.text;
    ProfileDetail.EndTime = txtVenueEnd.text;
    ProfileDetail.Image = setImages;
    ProfileDetail.AverageRating = [NSNumber numberWithFloat:0.0];
    ProfileDetail.Latitude = [NSNumber numberWithFloat:latitude].stringValue;
    ProfileDetail.Longitude = [NSNumber numberWithFloat:longitude].stringValue;
    ProfileDetail.CreatedAt = NumberCreatedAt;
    ProfileDetail.UpdateAt = NumberCreatedAt;
    
    [[dynamoDBObjectMapper save:ProfileDetail]
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
                 //[[Singlton sharedManager] GettingKonnectVenues];
                 self.view.userInteractionEnabled = YES;
                 
                 dicAllProfileSetup = [[NSMutableDictionary alloc]init];
                 [dicAllProfileSetup setValue:Id forKey:@"Id"];
                 [dicAllProfileSetup setValue:txtVenueName.text forKey:@"ProfileName"];
                 [dicAllProfileSetup setValue:txtVenueAddress.text forKey:@"Address"];
                 [dicAllProfileSetup setValue:txtVenuePhoneNo.text forKey:@"PhoneNumber"];
                 [dicAllProfileSetup setValue:txtVenueSpecials.text forKey:@"Special"];
                 [dicAllProfileSetup setValue:txtVenueStart.text forKey:@"StartTime"];
                 [dicAllProfileSetup setValue:txtVenueEnd.text forKey:@"EndTime"];
                 [[NSUserDefaults standardUserDefaults]setObject:dicAllProfileSetup forKey:@"UserProfileSetup"];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SKIPUSER"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 [[NSNotificationCenter defaultCenter]
                  postNotificationName:@"VenueUpdateValues"
                  object:self];
                
                 if ([_StrTextCheck isEqualToString:@"Notification"])
                 {
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 else
                 {
                     [self performSegueWithIdentifier:@"VenueScreen" sender:self];
                     
                 }
                 
             });
             
         }
         return nil;
     }];
}

-(void)FetchVenueProfile
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
                                                 @":val1" : [dicUserData valueForKey:@"UserId"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_VenueProfileSetup class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.view.userInteractionEnabled = YES;
                 dicProfileDetails= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueProfileSetup *chat in paginatedOutput.items) {
                     [dicProfileDetails addObject:chat];
                 }
                 if (dicProfileDetails.count>0) {
                     arrImageSet = [[NSMutableArray alloc]init];
                     self.view.userInteractionEnabled = YES;
                     [[Singlton sharedManager]killHUD];
                     NSSet *setProfileImages = [[dicProfileDetails valueForKey:@"Image"]objectAtIndex:0];
                     arrImageSet = [NSMutableArray arrayWithArray:[setProfileImages allObjects]];
                     NSArray *array = [NSArray arrayWithArray:arrImageSet];
                     array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                     arrImageSet = [NSMutableArray arrayWithArray:array];
                     txtVenueName.text = [[dicProfileDetails valueForKey:@"Name"]objectAtIndex:0];
                     txtVenueEnd.text = [[dicProfileDetails valueForKey:@"EndTime"]objectAtIndex:0];
                     txtVenueStart.text = [[dicProfileDetails valueForKey:@"StartTime"]objectAtIndex:0];
                     txtVenueAddress.text = [[dicProfileDetails valueForKey:@"Address"]objectAtIndex:0];
                     txtVenuePhoneNo.text = [[dicProfileDetails valueForKey:@"PhoneNumber"]objectAtIndex:0];
                     txtVenueSpecials.text = [[dicProfileDetails valueForKey:@"Special"]objectAtIndex:0];
                     strCheck = @"ProfileFetch";
                     strProfileCheck = @"FromServer";
                     scrollHorizontal.scrollEnabled = YES;
                     
                     
                     dicAllProfileSetup = [[NSMutableDictionary alloc]init];
                     [dicAllProfileSetup setValue:[[dicProfileDetails valueForKey:@"Id"]objectAtIndex:0] forKey:@"Id"];
                     [dicAllProfileSetup setValue:[[dicProfileDetails valueForKey:@"Name"]objectAtIndex:0] forKey:@"ProfileName"];
                     [dicAllProfileSetup setValue:[[dicProfileDetails valueForKey:@"Address"]objectAtIndex:0] forKey:@"Address"];
                     [dicAllProfileSetup setValue:[[dicProfileDetails valueForKey:@"PhoneNumber"]objectAtIndex:0] forKey:@"PhoneNumber"];
                     [dicAllProfileSetup setValue:[[dicProfileDetails valueForKey:@"Special"]objectAtIndex:0] forKey:@"Special"];
                     [dicAllProfileSetup setValue:[[dicProfileDetails valueForKey:@"StartTime"]objectAtIndex:0] forKey:@"StartTime"];
                     [dicAllProfileSetup setValue:[[dicProfileDetails valueForKey:@"StartTime"]objectAtIndex:0] forKey:@"EndTime"];
                     [[NSUserDefaults standardUserDefaults]setObject:dicAllProfileSetup forKey:@"UserProfileSetup"];
                     
                     for (int i = 1; i <=5; i++) {
                         if (arrImageSet.count<i)
                         {
                             [arrImageSet addObject:@"DefaultSetupImage"];
                         }
                     }
                     [collectionSlider reloadData];

                     if (![_StrTextCheck isEqualToString:@"Notification"])
                     {
                         [self performSegueWithIdentifier:@"VenueScreen" sender:self];
                     }
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


-(void)UpdateUserProfile
{
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    
    NSMutableDictionary *dicValue =  [[NSUserDefaults standardUserDefaults]valueForKey:@"UserProfileSetup"];
    
    if ([arrImageSet containsObject:@"DefaultSetupImage"]) {
        
        [arrImageSet removeObject:@"DefaultSetupImage"];
    }
    NSSet *setImages = [NSSet setWithArray:arrImageSet];
    if (setImages.count==0) {
        setImages = [NSSet setWithObject:@"None"];
        
    }
    NSArray *array = [setImages allObjects];
    
    
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
    AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    
    hashKeyValue.S = [dicProfileSetup valueForKey:@"Id"];
    updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"staging_VenueProfileSetup" : @"VenueProfileSetup";
    updateInput.key = @{ @"Id" : hashKeyValue };
    
    //********************* Venue Name
    AWSDynamoDBAttributeValue *newFirstNameValue = [AWSDynamoDBAttributeValue new];
    newFirstNameValue.S = txtVenueName.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdateForFirstName = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateForFirstName.value = newFirstNameValue;
    valueUpdateForFirstName.action = AWSDynamoDBAttributeActionPut;
    
    //********************* Venue Name
    AWSDynamoDBAttributeValue *newVenueNameValue = [AWSDynamoDBAttributeValue new];
    newVenueNameValue.S = txtVenueName.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdateForVenueName = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateForVenueName.value = newVenueNameValue;
    valueUpdateForVenueName.action = AWSDynamoDBAttributeActionPut;
    
    //********************* Address
    AWSDynamoDBAttributeValue *newLastNameValue = [AWSDynamoDBAttributeValue new];
    newLastNameValue.S = txtVenueAddress.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdateForLastName = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateForLastName.value = newLastNameValue;
    valueUpdateForLastName.action = AWSDynamoDBAttributeActionPut;
    
    //********************* Phone Number
    AWSDynamoDBAttributeValue *newGender = [AWSDynamoDBAttributeValue new];
    newGender.S = txtVenuePhoneNo.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdateForGender = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateForGender.value = newGender;
    valueUpdateForGender.action = AWSDynamoDBAttributeActionPut;
    
    
    //********************* Profile
    
    AWSDynamoDBAttributeValue *newProfile = [AWSDynamoDBAttributeValue new];
    newProfile.SS = array;
    AWSDynamoDBAttributeValueUpdate *valueUpdateForProfile = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateForProfile.value = newProfile;
    valueUpdateForProfile.action = AWSDynamoDBAttributeActionPut;
    
    
    //********************* StartTime
    
    AWSDynamoDBAttributeValue *newStartTime = [AWSDynamoDBAttributeValue new];
    newStartTime.S = txtVenueStart.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdateStartTime = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateStartTime.value = newStartTime;
    valueUpdateStartTime.action = AWSDynamoDBAttributeActionPut;
    
    //********************* EndTime
    
    AWSDynamoDBAttributeValue *newEndTime = [AWSDynamoDBAttributeValue new];
    newEndTime.S = txtVenueEnd.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdateEndTime = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateEndTime.value = newEndTime;
    valueUpdateEndTime.action = AWSDynamoDBAttributeActionPut;
    
    //********************* Specials
    
    AWSDynamoDBAttributeValue *newSpecial = [AWSDynamoDBAttributeValue new];
    newSpecial.S = txtVenueSpecials.text;
    AWSDynamoDBAttributeValueUpdate *valueUpdatespecial = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdatespecial.value = newSpecial;
    valueUpdatespecial.action = AWSDynamoDBAttributeActionPut;
    
    //********************* UserId
    
    AWSDynamoDBAttributeValue *newUserId = [AWSDynamoDBAttributeValue new];
    newUserId.S = [dicUserData valueForKey:@"UserId"];
    AWSDynamoDBAttributeValueUpdate *valueUpdateUserId = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateUserId.value = newUserId;
    valueUpdateUserId.action = AWSDynamoDBAttributeActionPut;
    
    //********************* ProfileSetup
    AWSDynamoDBAttributeValue *newSkipValue = [AWSDynamoDBAttributeValue new];
    newSkipValue.S = @"YES";
    AWSDynamoDBAttributeValueUpdate *valueUpdatenewSkipValue = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdatenewSkipValue.value = newSkipValue;
    valueUpdatenewSkipValue.action = AWSDynamoDBAttributeActionPut;
    
    updateInput.attributeUpdates = @{@"Name": valueUpdateForFirstName,@"VenueName":valueUpdateForVenueName,@"Address": valueUpdateForLastName,@"PhoneNumber": valueUpdateForGender,@"StartTime": valueUpdateStartTime,@"Image":valueUpdateForProfile,@"EndTime": valueUpdateEndTime,@"Special": valueUpdatespecial,@"UserId": valueUpdateUserId,@"isProfileSetupCompleted": valueUpdatenewSkipValue};
    
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
                [[Singlton sharedManager]killHUD];
                self.view.userInteractionEnabled = YES;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SKIPUSER"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"VenueUpdateValues"
                 object:self];
                
                if ([_StrTextCheck isEqualToString:@"Notification"]) {
                    
                    [self addUpdatePopup];
                }
                else
                {
                    [self FetchVenueProfile];
                }
            });
        }
        return nil;
    }];
}

-(void)addUpdatePopup
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Message"
                                  message:@"The profile is updated."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* YesAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                          
                                                          
                                                          [self.navigationController popViewControllerAnimated:YES];
                                                          
                                                          
                                                      }];
    
    
    [alert addAction:YesAction];
    [self presentViewController:alert animated:YES completion:nil];
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
                                               NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c]%@", txtVenueAddress.text];
                                               NSArray *resultArray = [[arrListCity filteredArrayUsingPredicate:predicate] mutableCopy];
                                               arrListCity = [NSMutableArray arrayWithArray:resultArray];
                                               if (arrListCity.count>0) {
                                                   
                                                   viewContainer.hidden = NO;
                                                   [tblAutoComplete reloadData];
                                               }
                                               else
                                               {
                                                   viewContainer.hidden = YES;
                                               }
                                           });
                                           
                                           
                                       }];
    
    [dataTask resume];
}


#pragma mark -  UICollectionView Method
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([strProfileCheck isEqualToString:@"FiveImages"]) {
        
        return arrImages.count;
    }
    else
    {
        return arrImageSet.count;
    }
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_5) {
        
        return CGSizeMake(112, 110);
    }
    else if (IS_IPHONE_6)
    {
        return CGSizeMake(115, 112);
    }
    else
    {
        return CGSizeMake(122, 120);
    }
    
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //top, left, bottom, right
    return UIEdgeInsetsMake(0, 16, 0, 16);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SliderCollectionViewCell *cell = (SliderCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (!cell)
    {
        cell  = [collectionSlider dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
    }
    
    if ([strProfileCheck isEqualToString:@"FiveImages"]) {
        
        cell.btnCross.hidden = YES;
        cell.ProfileVenueImage.image = [arrImages objectAtIndex:indexPath.row];
    }
    else
    {
        
        if ([[arrImageSet objectAtIndex:indexPath.row] isKindOfClass:[UIImage class]])
        {
            cell.ProfileVenueImage.image = [arrImages objectAtIndex:indexPath.row];
        }
        else if ([[arrImageSet objectAtIndex:indexPath.row] isKindOfClass:[NSString class]])
        {
            
            NSString *strForEventImageName = [[arrImageSet objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
            
            if ([strForEventImageName containsString:@"DefaultSetupImage"]) {
                
                cell.btnCross.hidden = YES;
                
            }
            else
            {
                cell.btnCross.hidden = NO;
            }
            
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_VENUE_IMAGE_URL,strForEventImageName]];
            
            [cell.ProfileVenueImage sd_setImageWithURL:url
                                      placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
            
            cell.btnCross.tag = indexPath.row;
            [cell.btnCross addTarget:self
                              action:@selector(clickCrosImage:)
                    forControlEvents:UIControlEventTouchUpInside];
            cell.ProfileVenueImage.contentMode = UIViewContentModeScaleAspectFill;
            cell.ProfileVenueImage.clipsToBounds = YES;
            
        }
        
        
    }
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    globelIndex = indexPath.row;
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
    [actionSheet addAction:[UIAlertAction actionWithTitle:extracted() style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end

