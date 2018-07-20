//
//  VenueRatingViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 04/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VenueRatingViewController.h"
#import "MainViewController.h"
#import "KN_VenueRating.h"
@interface VenueRatingViewController ()<UITextViewDelegate>
{
    CGFloat animatedDistance;
    NSDictionary *dictUserInfo;
    UIAlertController * alert;
}
@end

@implementation VenueRatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
   _txtViewComment.contentInset = UIEdgeInsetsMake(3, 3, 3, 3);
    _txtViewComment.delegate = self;
    _viewRating.value = 0.0;
    // Do any additional setup after loading the view.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
         _lblPlaceHoler.hidden = YES;
        return NO;
    }
    
    return YES;
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
         _lblPlaceHoler.hidden = YES;
        static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
        static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
        static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
        static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 230;
        static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 216;
        
        CGRect textFieldRect;
        CGRect viewRect;
        
        textFieldRect =[self.view.window convertRect:textView.bounds fromView:textView];
        viewRect =[self.view.window convertRect:self.view.bounds fromView:self.view];
        
        CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
        CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
        CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
        CGFloat heightFraction = numerator / denominator;
        
        if (heightFraction < 0.0)
        {
            heightFraction = 0.0;
        }
        else if (heightFraction > 1.0)
        {
            heightFraction = 0.9;
        }
        
        UIInterfaceOrientation orientation =[[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait ||orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
        }
        else
        {
            animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
        }
        
        CGRect viewFrame;
        
        viewFrame= self.view.frame;
        viewFrame.origin.y -= animatedDistance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        
        [UIView commitAnimations];
        
    }
    


-(void)textViewDidEndEditing:(UITextView *)textView
{
    if(textView.tag==0)
    {
        _lblPlaceHoler.hidden = NO;
        static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
        CGRect viewFrame;
        
        viewFrame= self.view.frame;
        viewFrame.origin.y += animatedDistance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
    }
    
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
- (IBAction)actionSubmit:(id)sender {
   if ([[Singlton sharedManager]check_null_data:_txtViewComment.text]) {
        
       // [[Singlton sharedManager] alert:self title:Alert message:EventDescription];
        alert=   [UIAlertController
                                     alertControllerWithTitle:@"Alert"
                                     message:@"Are you sure want to post rating without description ?"
                                     preferredStyle:UIAlertControllerStyleAlert];
       
       UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self actionRatingVenue];
                                                             }];
       UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self hideAlertController];
                                                             }];
       
       [alert addAction:defaultAction];
       [alert addAction:cancelAction];
       [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [self actionRatingVenue];
       
    }
}

-(void)actionRatingVenue
{
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    NSString *strUserId = [[Singlton sharedManager] getMD5Checksum:[NSString stringWithFormat:@"%@%@",[dictUserInfo valueForKey:@"UserId"],NumberCreatedAt]];
    KN_VenueRating *ratingObject = [KN_VenueRating new];
    ratingObject.Id = strUserId;
    ratingObject.UserId =[dictUserInfo valueForKey:@"UserId"] ;
    ratingObject.VenueId = [[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"];
    ratingObject.CreatedAt = NumberCreatedAt;
    //firstName lastName
    if([[dictUserInfo valueForKey:@"firstName"]isEqualToString:@"NA"] ||[[dictUserInfo valueForKey:@"lastName"]isEqualToString:@"NA"] )
    {
        ratingObject.UserName = @"Unknown";
    }
    else
    {
        ratingObject.UserName = [NSString stringWithFormat:@"%@ %@",[dictUserInfo valueForKey:@"firstName"],[dictUserInfo valueForKey:@"lastName"]];
    }
    ratingObject.Email = [dictUserInfo valueForKey:@"Email"];
    ratingObject.VenueRatingValue = _viewRating.value;
    if(_txtViewComment.text.length == 0)
    {
      ratingObject.VenueComment = @"NA";
    }
    else
    {
    ratingObject.VenueComment = _txtViewComment.text;
    }
  
    [[dynamoDBObjectMapper save:ratingObject]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
             [[Singlton sharedManager] alert:self title:Message message:@"please try again"];
         }
         if (task.result) {
             //Do something with the result.
             NSLog(@"Task result: %@",task.result);
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[Singlton sharedManager]killHUD];
                 _txtViewComment.text = nil;
                 self.view.userInteractionEnabled = YES;
                 
                 [self.navigationController popViewControllerAnimated:YES];
                 
             });
             
         }
         return nil;
     }];
}
-(void)hideAlertController
{
[self dismissViewControllerAnimated:YES completion:nil];
}
@end
