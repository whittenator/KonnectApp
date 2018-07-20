//
//  ConsumerSettingsViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ConsumerSettingsViewController.h"
#import "SettingTableViewCell.h"
#import "MainViewController.h"
#import "ConsumerChangePasswordVC.h"
#import "EditProfileViewController.h"
#import "UIImageView+WebCache.h"
@interface ConsumerSettingsViewController ()
{
    NSDictionary *dictUserInfo;
    NSString *strUserName;
    NSURL *imageUrl;
    
}
@end

@implementation ConsumerSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
   
   // [_tblSetting reloadData];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self ShowUpdatedInfo];
}
-(void)ShowUpdatedInfo
{
    dictUserInfo = [NSMutableDictionary new];
    dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
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
                    _imgUser.image = imgUserLocal;
                    
                }
                else
                {
                    NSString *strForEventImageName = [[dictUserInfo valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                    NSURL *imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
                    
                    [_imgUser sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
                }
            }
            else
            {
                NSURL *imageUrl = [[NSURL alloc] initWithString:[dictUserInfo valueForKey:@"UserImage"]];
                [_imgUser sd_setImageWithURL:imageUrl] ;
            }
        }
        else
        {
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"]!=nil)
            {
                NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"localUserImage"];
                UIImage* imgUserLocal = [UIImage imageWithData:imageData];
                _imgUser.image = imgUserLocal;
                
            }
            else{
                _imgUser.image = nil;
                NSString *strForEventImageName = [[dictUserInfo valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                NSURL *imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
                
                 [_imgUser sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
            }
            
            
        }
        
        
        
    }
    else
    {
        [_imgUser sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]options:SDWebImageRefreshCached];
    }
      viewContainerProfile.layer.borderColor = [UIColor lightGrayColor].CGColor;    viewContainerProfile.layer.borderWidth = 0.5f;        viewContainerNotifications.layer.borderColor = [UIColor lightGrayColor].CGColor;    viewContainerNotifications.layer.borderWidth = 0.5f;
    if([[dictUserInfo valueForKey:@"firstName"]isEqualToString:@"NA"]||[[dictUserInfo valueForKey:@"lastName"]isEqualToString:@"NA"])
    {
        strUserName =@"";
    }
    else
    {
        strUserName = [NSString stringWithFormat:@"%@ %@",[dictUserInfo valueForKey:@"firstName"],[dictUserInfo valueForKey:@"lastName"]];
        _lblUserName.text = strUserName;
    }
}
/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return 1;
    
}- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"SettingCell";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    SettingTableViewCell *cell = (SettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
   [cell.btnEditProfile addTarget:self action:@selector(gotoEditProfile) forControlEvents:UIControlEventTouchUpInside];
     [cell.btnChangePassword addTarget:self action:@selector(gotoChangePassword) forControlEvents:UIControlEventTouchUpInside];
   cell.selectionStyle = UITableViewCellSelectionStyleNone;
 [[Singlton sharedManager]imageProfileRounded:cell.imgUser withFlot:cell.imgUser.frame.size.width/2 withCheckLayer:NO];
    cell.lblName.text = strUserName;
    [cell.imgUser sd_setImageWithURL:imageUrl];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPHONE_6)
    {
        return 200;
    }
    else if(IS_IPHONE_5)
    {
    return 160.0;
    }
    else
        return 200;
}
 
 -(void)gotoEditProfile
 {
 EditProfileViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
 [self.navigationController pushViewController:Vc animated:YES];
 
 }
 
 -(void)gotoChangePassword
 {
 ConsumerChangePasswordVC *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerChangePasswordVC"];
 [self.navigationController pushViewController:Vc animated:YES];
 
 }
*/


-(IBAction)gotoEditProfile:(id)sender
{
    EditProfileViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    [self.navigationController pushViewController:Vc animated:YES];
}


-(IBAction)gotoChangePassword:(id)sender
{
    if([[dictUserInfo valueForKey:@"fblogin"]isEqualToString:@"YES"])
    {
         [[Singlton sharedManager] alert:self title:Alert message:@"You are login as facebook user therefore can't change Password for your account."];
    }
    else
    {
    ConsumerChangePasswordVC *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerChangePasswordVC"];
    [self.navigationController pushViewController:Vc animated:YES];
    }
}

- (IBAction)actionNotiOnOrOff:(id)sender {
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    if([sender isOn])
    {
        
        dispatch_async(queue1, ^{
            [[Singlton sharedManager] SettingANSForPushNotification:[dictUserInfo valueForKey:@"UserId"] AndEmailId:[dictUserInfo valueForKey:@"Email"]];
        });
    }
    else
    {
        
        dispatch_async(queue1, ^{
            [[Singlton sharedManager] deleteEndPointARNByDeviceToken:@""];
        });
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

- (IBAction)actionBAck:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
