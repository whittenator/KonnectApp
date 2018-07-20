//
//  VenuOwnerViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 26/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VenuOwnerViewController.h"
#import "MainViewController.h"
#import "LGSideMenuController.h"
#import "VenueOwnerHomeViewController.h"
#import "CreateEventViewController.h"
#import "VenueGalleryViewController.h"
#import "SubscriptionPlanViewController.h"
#import "VenueNotificationViewController.h"
#import "VenueFAQViewController.h"
#import "VenueContactUsViewController.h"
#import "ViewController.h"
#import <AWSS3/AWSS3.h>
#import "KN_VenueProfileSetup.h"
#import "UIImageView+WebCache.h"
@interface VenuOwnerViewController ()
{
    NSArray *menuItems;
    NSMutableDictionary *dicUserData;
    NSMutableDictionary *dicProfile;
    NSMutableArray *arrVenueDetails;
    NSMutableArray *arrImageSet;
}
@end

@implementation VenuOwnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self SetBuildVersion];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UpdateValues:)name:@"VenueUpdateValues"
                                               object:nil];
    
    dicUserData  = [[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"];
    
    arrImageSet = [[NSMutableArray alloc]init];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    _tblMenuItems.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    menuItems = @[@"VenueHome", @"CreateEvent",@"Gallery",@"Subscription", @"Setting", @"Faq", @"KonnectSupport",@"VenueLogout"];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    //UIimage rounded
    [[Singlton sharedManager]imageProfileRounded:imgUserProfile withFlot:imgUserProfile.frame.size.width/2 withCheckLayer:NO];
    
    [_tblMenuItems setTranslatesAutoresizingMaskIntoConstraints:YES];
    [lblUserName setTranslatesAutoresizingMaskIntoConstraints:YES];
    if (IS_IPHONE_5) {
        
        lblUserName.frame = CGRectMake(lblUserName.frame.origin.x+10, lblUserName.frame.origin.y-20,lblUserName.frame.size.width, lblUserName.frame.size.height);
         _tblMenuItems.frame = CGRectMake(_tblMenuItems.frame.origin.x, _tblMenuItems.frame.origin.y-20,_tblMenuItems.frame.size.width, _tblMenuItems.frame.size.height);
    }
    else if (IS_IPHONE_6_PLUS)
    {
        
        lblUserName.frame = CGRectMake(lblUserName.frame.origin.x+15, lblUserName.frame.origin.y,lblUserName.frame.size.width, lblUserName.frame.size.height);
        _tblMenuItems.frame = CGRectMake(_tblMenuItems.frame.origin.x, _tblMenuItems.frame.origin.y+35,_tblMenuItems.frame.size.width, _tblMenuItems.frame.size.height);
    }
    if (IS_IPHONE_6)
    {
        lblUserName.frame = CGRectMake(lblUserName.frame.origin.x+15, lblUserName.frame.origin.y,lblUserName.frame.size.width, lblUserName.frame.size.height);
         _tblMenuItems.frame = CGRectMake(_tblMenuItems.frame.origin.x, _tblMenuItems.frame.origin.y+20,_tblMenuItems.frame.size.width, _tblMenuItems.frame.size.height);
    }
    
    [self FetchVenueProfile];
    
}

-(void)SetBuildVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *strVersionLength=[NSString stringWithFormat:@"%@(%@)",[infoDictionary objectForKey:@"CFBundleShortVersionString"],[infoDictionary objectForKey:@"CFBundleVersion"]];
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"Version %@",strVersionLength]];
    [ lblAppVersion setAttributedText: text];
}
-(void)UpdateValues:(NSNotification *) notification
{
    [self FetchVenueProfile];
}
-(void)viewWillAppear:(BOOL)animated
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return menuItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if( IS_IPHONE_5 )
    {
        return 40.0;
    }
    else if(IS_IPHONE_6)
    {
        return 48.0;
    }
    else if(IS_IPHONE_6_PLUS)
    {
        return 52.0;
    }
    return 40.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row==0) {
        
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueOwnerHomeViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
    }
    else  if (indexPath.row==1) {
        
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateEventViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
    }
    else  if (indexPath.row==2) {
        
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueGalleryViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
    }
    else  if (indexPath.row==3) {
        
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SubscriptionPlanViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
    }
    else  if (indexPath.row==4) {
        
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueNotificationViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
    }
    else  if (indexPath.row==5) {
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueFAQViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
    }
     else  if (indexPath.row==6) {
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueContactUsViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
    }
     else  if (indexPath.row==6) {
         MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
         UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueContactUsViewController"];
         UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
         [navigationController pushViewController:viewController animated:YES];
         
         [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
     }
    else
    {
        [[Singlton sharedManager] setLoginAndSignUpStatus:NO];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DefaultArray"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VenueUser"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue1, ^{
            [[Singlton sharedManager] deleteEndPointARNByDeviceToken:@""];
        });
        
        [mainViewController hideLeftViewAnimated:NO completionHandler:nil];
       
        
    }
    
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
              dispatch_async(dispatch_get_main_queue(), ^{
                  self.view.userInteractionEnabled = YES;
              });
             //SLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 arrVenueDetails= [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueProfileSetup *chat in paginatedOutput.items) {
                     
                     [arrVenueDetails addObject:chat];
                     
                 }
                 
                 if (arrVenueDetails.count>0) {
                     
                     self.view.userInteractionEnabled = YES;
                     NSSet *setImages = [[arrVenueDetails valueForKey:@"Image"]objectAtIndex:0];
                     arrImageSet = [NSMutableArray arrayWithArray:[setImages allObjects]];
                     NSArray *array = [NSArray arrayWithArray:arrImageSet];
                     array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                     arrImageSet = [NSMutableArray arrayWithArray:array];
                     for (int i = 0; i < arrImageSet.count; i++)
                     {
                         
                        NSString *strForEventImageName = [[arrImageSet objectAtIndex:i] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                       
                         [arrImageSet replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@%@",BASE_VENUE_IMAGE_URL,strForEventImageName]];
                     }
                     
                     [imgUserProfile sd_setImageWithURL:[arrImageSet objectAtIndex:0]
                                  placeholderImage:[UIImage imageNamed:@"avatar-placeholder.png"]
                                           options:SDWebImageRefreshCached];
                     
                     lblUserName.text = [[arrVenueDetails valueForKey:@"Name"]objectAtIndex:0];
                     dicProfile = [[NSMutableDictionary alloc]init];
                     [dicProfile setObject:[arrImageSet objectAtIndex:0] forKey:@"UserImage"];
                     [dicProfile setObject:[[arrVenueDetails valueForKey:@"Name"]objectAtIndex:0] forKey:@"UserName"];
                     [[NSUserDefaults standardUserDefaults]setObject:dicProfile forKey:@"UserProfile"];
                   
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
