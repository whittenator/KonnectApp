//
//  Singlton.h
//  Konnect
//
//  Created by Balraj Randhawa on 18/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Singlton : NSObject
{
    
}
//@property (strong, nonatomic) KN_ConsumerProfileSetup *objUser;
+ (Singlton *)sharedManager;
-(BOOL)validEmail:(NSString*)email;
-(BOOL)check_null_data:(NSString*)strdata;
-(void)alert:(UIViewController *)view title: (NSString *) title message: (NSString *) message;
-(void)alert:(UIViewController *)view title: (NSString *) title message: (NSString *) message email: (NSString *) email;
-(BOOL)isSpace:(NSString *)strData;
-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
-(CGFloat)getLabelHeight:(NSString*)label;
-(float)calculateHeightForLbl:(NSString*)text width:(float)width;
-(void) setLoginAndSignUpStatus:(BOOL) value;
-(BOOL) getLoginAndSignUpStatus;
-(void)imageProfileRounded:(UIImageView *)imageView withFlot:(float)rdeius withCheckLayer:(BOOL)status;
-(BOOL)CheckInterConnectivity;
- (NSString *)getMD5Checksum:(NSString *)input;
- (void)showHUD;
- (void)killHUD;
-(void)GettingKonnectVenues;
-(NSString *)changeStringToDate:(NSString *)strEventDate;
-(NSDate *)convertStringToDate:(NSString *)strEventDate;
-(NSString *)convertDateToString:(NSDate *)strEventDate;
-(NSNumber *)ConvertDateToTimeStamWithDate:(NSDate *)Date;
-(BOOL)DateChekDifference:(NSDate *)beginedate andDate:(NSDate*)endDate;
-(BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;
-(void) SettingANSForPushNotification:(NSString *)strUserId AndEmailId:(NSString *)strEmail;
-(void)deleteEndPointARNByDeviceToken:(NSString *)strEndPointARN;
@property double latitude;
@property double longitude;
@property NSString *strVerified;
@property NSDictionary *dictVenueInfo;
@property NSString *strWorkingHours;
@property NSMutableArray *arrKonnectVenues;
@property NSMutableArray *arrFiltersForData;
@property NSMutableArray *arrDataTempStorage;
@property NSMutableArray *arrNotifications;
@property NSString *strNextPageTempToken;
@property NSDictionary *dictNonLoginUser;
@property NSString *strDeviceToken;
@property NSString *strEndPointARN;
@property NSMutableDictionary *dictNotificationInfo;
@property NSDictionary *dictVenueEventDetailInfo;
@property NSString *strComingFromVenueOwnerCommentScreen;
@end

