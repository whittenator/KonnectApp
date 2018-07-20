//
//  ClaimYourBusinessViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 03/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ClaimYourBusinessViewController.h"
#import "MainViewController.h"
#import "KN_ClaimYourBusiness.h"
@interface ClaimYourBusinessViewController ()
{
    NSMutableDictionary *dictUserInfo;
    NSNumber *NumberCreatedAt;
     NSString *strPhoto ;
   
}
@end

@implementation ClaimYourBusinessViewController
//@synthesize txtEmail;
- (void)viewDidLoad {
    [super viewDidLoad];
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    //integrating Done button when Mobile Pad opens
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    _txtPhone.inputAccessoryView = keyboardDoneButtonView;
    _txtOpenTime.inputAccessoryView = keyboardDoneButtonView;
    _txtCloseTime.inputAccessoryView = keyboardDoneButtonView;
    //Adding DatePicker for Open Hours
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    datePicker.datePickerMode = UIDatePickerModeTime;
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    
    //Adding DatePicker for  Close Hours
    UIDatePicker *datePickerEnd = [[UIDatePicker alloc]init];
    datePickerEnd.datePickerMode = UIDatePickerModeTime;
    [datePickerEnd addTarget:self action:@selector(updateTextFieldEnd:) forControlEvents:UIControlEventValueChanged];
    
    [_txtOpenTime setInputView:datePicker];
    [_txtCloseTime setInputView:datePickerEnd];
     dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
   
    _txtBusinessName.text = [[Singlton sharedManager].dictVenueInfo valueForKey:@"name"];
  _txtAddress.text =  [[Singlton sharedManager].dictVenueInfo valueForKey:@"vicinity"];
    if([Singlton sharedManager].strWorkingHours)
        {
           NSString *strOpenHours, *strCloseHours;
            NSArray *arrSplitTime = [[NSString stringWithFormat:@"%@",[Singlton sharedManager].strWorkingHours] componentsSeparatedByString:@"–"];
           strOpenHours =  [arrSplitTime[0] lowercaseString];
            strCloseHours =  [arrSplitTime[1] lowercaseString];
          
            
           /* if ([strOpenHours rangeOfString:@"am"].location == NSNotFound) {
                //strOpeningHrs = [NSString stringWithFormat:@"%@pm",strOpenHours];
                 _txtOpenTime.text = strOpenHours;
            } else {
                 _txtOpenTime.text = strOpenHours;
            }*/
              _txtOpenTime.text = strOpenHours;
            _txtCloseTime.text = strCloseHours;
           
        }
}


-(void)doneClicked:(id)sender
{
    [self.view endEditing:YES];
}
-(void)updateTextFieldEnd:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)_txtCloseTime.inputView;
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"hh:mm a"]; //24hr time format
    NSString *dateString = [outputFormatter stringFromDate:picker.date];
    _txtCloseTime.text =  [NSString stringWithFormat:@"%@",dateString];
}
-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)_txtOpenTime.inputView;
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"hh:mm a"]; //24hr time format
    NSString *dateString = [outputFormatter stringFromDate:picker.date];
    _txtOpenTime.text =  [NSString stringWithFormat:@"%@",dateString];
}
-(void)viewWillAppear:(BOOL)animated
{
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
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




- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionSaveInfo:(id)sender {
    if ([[Singlton sharedManager]check_null_data:_txtBusinessName.text]) {
        
        [[Singlton sharedManager] alert:self title:Alert message:@"Please enter type  business name"];
    }
    else if ([[Singlton sharedManager]check_null_data:_txtOpenTime.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:@"Please enter the opening time"];
    }
    else if ([[Singlton sharedManager]check_null_data:_txtCloseTime.text])
    {
       [[Singlton sharedManager] alert:self title:Alert message:@"Please enter the ending time"];
    }
   else if ([[Singlton sharedManager]check_null_data:_txtAddress.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:@"Please enter the address"];
    }
    else if ([[Singlton sharedManager]check_null_data:_txtFirstName.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:FirstName];
    }
    else if ([[Singlton sharedManager]check_null_data:_txtCloseTime.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:LastName];
    }
    else if ([[Singlton sharedManager]check_null_data:_txtEmail.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:Eamil_Alert];
    }
    else if  (![[Singlton sharedManager] validEmail:_txtEmail.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:ValidEmail_Alert];
    }
    else if ([[Singlton sharedManager]check_null_data:_txtPhone.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:@"Please enter phone number"];
    }
    else if ([_txtPhone.text length] < 10 || [_txtPhone.text length] > 10)
    {
        [[Singlton sharedManager] alert:self title:Alert message:@"Phone number must consists of 10 digits"];
    }
    else
    {
        [self SaveClaimBusinessData];
    }
}
-(void)SaveClaimBusinessData
{
    if([[Singlton sharedManager].dictVenueInfo valueForKey:@"photos"])
    {
        strPhoto = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?photoreference=%@&sensor=false&maxheight=300&maxwidth=1000&key=%@",[[[[Singlton sharedManager].dictVenueInfo valueForKey:@"photos"] objectAtIndex:0] valueForKey:@"photo_reference"],GoogleApiKey];
    }
    else
    {
        strPhoto = @"NA";
    }
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    
    KN_ClaimYourBusiness *BusinessDetail = [KN_ClaimYourBusiness new];
    BusinessDetail.UserId = [dictUserInfo valueForKey:@"UserId"];
     BusinessDetail.Id =[NSString stringWithFormat:@"%@%@",[dictUserInfo valueForKey:@"Email"],NumberCreatedAt] ;
    BusinessDetail.Email = _txtEmail.text ;
    BusinessDetail.EmailVerification = [NSNumber numberWithBool:NO];
    BusinessDetail.CreatedAt = NumberCreatedAt;
    BusinessDetail.UpdatedAt = NumberCreatedAt;
    BusinessDetail.Firstname = _txtFirstName.text;
    BusinessDetail.Lastname = _txtLastName.text;
    BusinessDetail.PhoneNumber = _txtPhone.text;
    BusinessDetail.strImgPath = [NSSet setWithObject:strPhoto];
    BusinessDetail.OpenHours = _txtOpenTime.text;
    BusinessDetail.CloseHours = _txtCloseTime.text;
    BusinessDetail.VenueLatitude = [[[[Singlton sharedManager].dictVenueInfo valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] ;
    BusinessDetail.VenueLongitude = [[[[Singlton sharedManager].dictVenueInfo valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"];
    BusinessDetail.Venueaddress = [[Singlton sharedManager].dictVenueInfo valueForKey:@"vicinity"];
    BusinessDetail.VenueId = [[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"];
    BusinessDetail.Venuename = [[Singlton sharedManager].dictVenueInfo valueForKey:@"name"];
    [[dynamoDBObjectMapper save:BusinessDetail]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
             [[Singlton sharedManager] alert:self title:Message message:@"please try again"];
         }
         if (task.result) {
            NSLog(@"Task result: %@",task.result);
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
            
                 MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
                 UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VOHomeViewController"];
                 UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
                 [navigationController pushViewController:viewController animated:YES];
                 [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
                 [[Singlton sharedManager] alert:self title:Message message:@"Thanks for submitting the claim request. Admin will review and contact you."];
             });
         }
         return nil;
     }];
}

-(void)UpdateLocalKonnectArrayNGoToHomeScreen
{
    //This method is for updating local konnect array. It was used before not in use currently
    NSDictionary *dictClaimVenue;
    dictClaimVenue = @{@"UserId":[dictUserInfo valueForKey:@"UserId"],@"Id":[NSString stringWithFormat:@"%@%@",[[dictUserInfo valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"],NumberCreatedAt],@"Id":[[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"],@"Venuename":[[Singlton sharedManager].dictVenueInfo valueForKey:@"name"],@"OpenHours":_txtOpenTime.text,@"CloseHours":_txtCloseTime.text,
                       @"Venueaddress":[[Singlton sharedManager].dictVenueInfo valueForKey:@"vicinity"],@"Email":_txtEmail.text,
                       @"Firstname":_txtFirstName.text,@"Lastname":_txtLastName.text,@"PhoneNumber":_txtPhone.text,
                       @"EmailVerification":[NSNumber numberWithBool:NO],@"VenueLatitude":[[[[Singlton sharedManager].dictVenueInfo valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"],
                       @"VenueLongitude":[[[[Singlton sharedManager].dictVenueInfo valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"],@"CreatedAt":NumberCreatedAt,@"UpdatedAt":NumberCreatedAt,@"strImgPath":strPhoto
                       };
    
    [[Singlton sharedManager].arrKonnectVenues addObject:dictClaimVenue.mutableCopy];
    dictClaimVenue = nil;
    self.view.userInteractionEnabled = YES;
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VOHomeViewController"];
    UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
    [navigationController pushViewController:viewController animated:YES];
    [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
}
@end
