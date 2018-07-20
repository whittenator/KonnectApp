//
//  AppDelegate.m
//  Konnect
//
//  Created by Balraj Randhawa on 13/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "VOHomeViewController.h"
#import "LGSideMenuController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import <UserNotifications/UserNotifications.h>//We have import this file to allow PushNot in Foreground
#import <GJPG/GJPG.h>

@interface AppDelegate ()<LGSideMenuDelegate,UNUserNotificationCenterDelegate>
@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
   
    [self callUpdateLoc];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@"us-east-1:c03f5c58-2bb9-45f8-b2be-5be7a2edfc7e"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    [[GJPG sharedInstance] startWithApiKey:@"07f7f37ec6c34dba9180349d06014e48"]; // X-Mode
    
    
    /*Below code is to check whether our iOS version iOS >=10.0, if yes then we use below code for registering for PUSH NOTIFIcation Service.  */
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error )
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[UIApplication sharedApplication] registerForRemoteNotifications];
                 });
                 // required to get the app to do anything at all about push notifications
                 NSLog( @"Push registration success." );
             }
             else
             {
                 NSLog( @"Push registration FAILED" );
                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
             }
         }];
    }
    else
    {
        // Fallback on earlier versions
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        }
    }
    [Singlton sharedManager].dictNotificationInfo = [[[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]valueForKey:@"aps"]mutableCopy];
    
    if( [Singlton sharedManager].dictNotificationInfo != nil)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"yes" forKey:@"appKill"];
    }
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"UserType"]isEqualToString:@"User"])
    {
        // [[Singlton sharedManager] GettingKonnectVenues];
    }
    
    [Fabric with:@[[Crashlytics class]]];
    return YES;
    
}



-(void)callUpdateLoc
{
    self.objLocationManager = [[CLLocationManager alloc] init];
    self.objLocationManager.delegate = self;
    self.objLocationManager.distanceFilter = kCLDistanceFilterNone;
    self.objLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    if ([self.objLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.objLocationManager requestAlwaysAuthorization];
    }
    
    [self.objLocationManager startUpdatingLocation];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [Singlton sharedManager].dictNotificationInfo = [[userInfo valueForKey:@"aps"] mutableCopy];
    if (@available(iOS 10.0, *))
    {
    }
    else
    {
        if(application.applicationState==UIApplicationStateActive)
        {
            
            
        }
        else if(application.applicationState==UIApplicationStateInactive)
        {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationNavigation" object:nil userInfo:nil];
        }
        
    }
}

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
    [Singlton sharedManager].latitude = newLocation.coordinate.latitude;
    [Singlton sharedManager].longitude =newLocation.coordinate.longitude;
    [_objLocationManager stopUpdatingLocation];
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings // NS_AVAILABLE_IOS(8_0);
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    
    NSLog(@"deviceToken: %@", deviceToken);
    NSString * token = [NSString stringWithFormat:@"%@", deviceToken];
    //Format token as you need:
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    [Singlton sharedManager].strDeviceToken = token;
    
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    if (@available(iOS 10.0, *)) {
        //For showing the Notification as App is in Foreground
        completionHandler(UNNotificationPresentationOptionAlert);
    } else {
        // Fallback on earlier versions
    }
    // NSLog( @"Here handle push notification in foreground" );
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    // NSLog( @"Handle push from background or closed" );
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSLog(@"%@", response.notification.request.content.userInfo);
    [Singlton sharedManager].dictNotificationInfo = [[ response.notification.request.content.userInfo valueForKey:@"aps"] mutableCopy];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationNavigation" object:nil userInfo:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication
                                                               annotation:annotation];
    // Add any custom logic here.
    return handled;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // [self GettingKonnectVenueFromLocalStorage];
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    /*
     NSMutableArray *finalArray = [NSMutableArray array];
     NSMutableSet *mainSet = [NSMutableSet set];
     for (NSDictionary *item in arrVenues) {
     //Extract the part of the dictionary that you want to be unique:
     NSDictionary *dict = [item dictionaryWithValuesForKeys:@[@"place_id"]];
     if ([mainSet containsObject:dict]) {
     continue;
     }
     [mainSet addObject:dict];
     [finalArray addObject:item];
     }
     [arrVenues removeAllObjects];
     [arrVenues addObjectsFromArray:finalArray.mutableCopy];
     */
}

-(void)GettingKonnectVenueFromLocalStorage
{
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
