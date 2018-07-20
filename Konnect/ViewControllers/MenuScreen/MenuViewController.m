//
//  MenuViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 19/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "MenuViewController.h"
#import "MainViewController.h"
#import "UIImageView+WebCache.h"
@interface MenuViewController ()
{
    NSArray *menuItems;
    NSMutableDictionary *dictUserInfo;
     NSString *strUserName;
}
@end

@implementation MenuViewController
- (void) UpdatePicNUserName:(NSNotification *) notification
{
    NSLog(@"Resend Caklled");
    [self SetProfileImage];
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self SetBuildVersion];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UpdatePicNUserName:)name:@"UpdateValues"
                                               object:nil];
    _tblMenuItems.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    menuItems = @[@"Home", @"Notification", @"Settings",@"Friends", @"FAQ", @"PrivacyPolicy", @"Logout"];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [[Singlton sharedManager]imageProfileRounded:imgUserProfile withFlot:imgUserProfile.frame.size.width/2 withCheckLayer:NO];
    [_tblMenuItems setTranslatesAutoresizingMaskIntoConstraints:YES];
     [lblName setTranslatesAutoresizingMaskIntoConstraints:YES];
    if (IS_IPHONE_5) {
        
        [imgBackgraound setTranslatesAutoresizingMaskIntoConstraints:YES];
        [imgUserProfile setTranslatesAutoresizingMaskIntoConstraints:YES];
       
        
        imgBackgraound.frame = CGRectMake(imgBackgraound.frame.origin.x, imgBackgraound.frame.origin.y-20,imgBackgraound.frame.size.width, imgBackgraound.frame.size.height);
        imgUserProfile.frame = CGRectMake(imgUserProfile.frame.origin.x, imgUserProfile.frame.origin.y-20,imgUserProfile.frame.size.width, imgUserProfile.frame.size.height);
        lblName.frame = CGRectMake(lblName.frame.origin.x, lblName.frame.origin.y-20,lblName.frame.size.width, lblName.frame.size.height);
        
         _tblMenuItems.frame = CGRectMake(_tblMenuItems.frame.origin.x, _tblMenuItems.frame.origin.y-15,_tblMenuItems.frame.size.width, _tblMenuItems.frame.size.height);
    }
    else if (IS_IPHONE_6_PLUS)
    {
        
        lblName.frame = CGRectMake(lblName.frame.origin.x, lblName.frame.origin.y+10,lblName.frame.size.width, lblName.frame.size.height);
           _tblMenuItems.frame = CGRectMake(_tblMenuItems.frame.origin.x, _tblMenuItems.frame.origin.y+40,_tblMenuItems.frame.size.width, _tblMenuItems.frame.size.height);
    }
    if (IS_IPHONE_6)
    {
         lblName.frame = CGRectMake(lblName.frame.origin.x, lblName.frame.origin.y+10,lblName.frame.size.width, lblName.frame.size.height);
    }
    
     lblName.text = strUserName;
    
    // Do any additional setup after loading the view.
}

-(void)SetProfileImage
{
    dictUserInfo = [NSMutableDictionary new];
    dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
   // [self SetProfileImage];
      lblName.text = strUserName;
    if([[dictUserInfo valueForKey:@"firstName"]isEqualToString:@"NA"]||[[dictUserInfo valueForKey:@"lastName"]isEqualToString:@"NA"])
    {
        strUserName =@"";
    }
    else
    {
        strUserName = [NSString stringWithFormat:@"%@ %@",[dictUserInfo valueForKey:@"firstName"],[dictUserInfo valueForKey:@"lastName"]];
    }
    lblName.text = strUserName;
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
                    imgUserProfile.image = imgUserLocal;
                    
                }
                else
                {
                    NSString *strForEventImageName = [[dictUserInfo valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                    NSURL *imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
                    
                     [imgUserProfile sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
                }
            }
            else
            {
                NSURL *imageUrl = [[NSURL alloc] initWithString:[dictUserInfo valueForKey:@"UserImage"]];
                [imgUserProfile sd_setImageWithURL:imageUrl] ;
            }
        }
        else
        {
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"]!=nil)
            {
                NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"];
                UIImage* imgUserLocal = [UIImage imageWithData:imageData];
                imgUserProfile.image = imgUserLocal;
                
            }
            else{
                imgUserProfile.image = nil;
                NSString *strForEventImageName = [[dictUserInfo valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                NSURL *imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
                
               [imgUserProfile sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
            }
            
            
        }
        
        
        
    }
    else
    {
        [imgUserProfile sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dictUserInfo = [NSMutableDictionary new];
    dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
    [self SetProfileImage];
    
    if([[dictUserInfo valueForKey:@"firstName"]isEqualToString:@"NA"]||[[dictUserInfo valueForKey:@"lastName"]isEqualToString:@"NA"])
    {
        strUserName =@"";
    }
    else
    {
        strUserName = [NSString stringWithFormat:@"%@ %@",[dictUserInfo valueForKey:@"firstName"],[dictUserInfo valueForKey:@"lastName"]];
    }
     lblName.text = strUserName;
}
-(void)SetBuildVersion
{ NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *strVersionLength=[NSString stringWithFormat:@"%@(%@)",[infoDictionary objectForKey:@"CFBundleShortVersionString"],[infoDictionary objectForKey:@"CFBundleVersion"]];
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"Version %@",strVersionLength]];
    [ _lblBuildVersion setAttributedText: text];
  
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
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.contentView.backgroundColor = [UIColor clearColor];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if( IS_IPHONE_5 )
    {
        return 40;
    }
    else if(IS_IPHONE_6)
    {
        return 48.0;
    }
    else if(IS_IPHONE_6_PLUS)
    {
        return 56.0;
    }
    return 40.0;
}
- (IBAction)actionGotoProfile:(id)sender {
    
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileScreenViewController"];
    UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
     [Singlton sharedManager].dictNonLoginUser = dictUserInfo;
  [[NSUserDefaults standardUserDefaults]setObject:dictUserInfo forKey:@"nonLoginUser"];
    [navigationController pushViewController:viewController animated:YES];
    
    [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VOHomeViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
        
    }
   else if(indexPath.row == 1)
    {
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerNotificationViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
        
    }
    else if(indexPath.row == 2)
    {
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerSettingsViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
        
    }
    else if(indexPath.row == 3)
    {
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
        
    }
    else if(indexPath.row == 4)
    {
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FAQViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
        
    }
    else if(indexPath.row == 5)//FAQViewController.h
    {
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyNPolicyViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
        
    }
    else
    {
        if([[Singlton sharedManager] CheckInterConnectivity] == NO)
        {
            [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
            return;
        }
         [[Singlton sharedManager] setLoginAndSignUpStatus:NO];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"localUserImage"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"User"];
         [[NSUserDefaults standardUserDefaults]synchronize];
        
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIStoryboard * storyBoardName = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *viewController = [storyBoardName instantiateViewControllerWithIdentifier:@"ViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
       
         [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotificationNavigation" object:nil];
        dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue1, ^{
            [[Singlton sharedManager] deleteEndPointARNByDeviceToken:@""];
        });
        AppDelegate  *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        delegate.strLoginType = nil;
        [mainViewController hideLeftViewAnimated:NO completionHandler:nil];
        
        
        
    }
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
