//
//  AppDelegate.h
//  Konnect
//
//  Created by Balraj Randhawa on 13/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *strLoginType;
@property (strong, nonatomic) NSString *strAppAlreadyOpened;
@property (strong, nonatomic) NSString *strCommentScreen;
@property (strong, nonatomic)CLLocationManager *objLocationManager;

@end

