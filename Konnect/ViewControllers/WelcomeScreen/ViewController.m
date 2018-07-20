//
//  ViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 13/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ViewController.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "VOHomeViewController.h"
#define BTN_USER  0
#define BTN_VENUE  1
@interface ViewController ()<CLLocationManagerDelegate>
{
    AppDelegate *delegate;

}
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //printf("WHITTEN: WE ARE HERE BITCH!!");
    //CLLocationManager * locationManager1 = [[CLLocationManager alloc] init];
    //locationManager1.delegate = self;
   // [locationManager1 requestAlwaysAuthorization];
  
    
    
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
   delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if([[Singlton sharedManager] getLoginAndSignUpStatus])
    {
        if([[[NSUserDefaults standardUserDefaults]valueForKey:@"UserType"]isEqualToString:@"User"])
        {
            delegate.strLoginType = @"User";
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Consumer" bundle:nil];
            LoginViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self.navigationController pushViewController:vc animated:NO];
            // [[NSUserDefaults standardUserDefaults]setValue:@"Consumer" forKey:@"UserType"];
        }
        else if([[[NSUserDefaults standardUserDefaults]valueForKey:@"UserType"]isEqualToString:@"VenueUser"])
        {
            
            delegate.strLoginType = @"VenueUser";
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self.navigationController pushViewController:vc animated:NO];
        }
    }
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark -  Navigation
//Navigation segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"MainScreen"])
    {
          UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"Consumer" bundle:nil];
        MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
        UIViewController *viewController = [secondStoryBoard instantiateViewControllerWithIdentifier:@"VOHomeViewController"];
        UINavigationController *navigationController = (UINavigationController *)mainViewController.rootViewController;
        [navigationController pushViewController:viewController animated:YES];
        [mainViewController hideLeftViewAnimated:YES completionHandler:nil];
    }
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clickButtons:(id)sender {
    
    UIButton * btnSelected = (UIButton *) sender;
    
    switch (btnSelected.tag) {
            
        case BTN_USER:
        {
            delegate.strLoginType = @"User";
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Consumer" bundle:nil];
            [[NSUserDefaults standardUserDefaults]setValue:@"User" forKey:@"UserType"];
            LoginViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case BTN_VENUE:
        {
            [[NSUserDefaults standardUserDefaults]setValue:@"VenueUser" forKey:@"UserType"];
            delegate.strLoginType = @"VenueUser";
            [self performSegueWithIdentifier:@"LoginScreen" sender:self];
        }
            break;
        default:
            break;
            
    }
}
@end
