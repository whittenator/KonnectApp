//
//  Singlton.m
//  Konnect
//
//  Created by Balraj Randhawa on 18/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "Singlton.h"
#import <CommonCrypto/CommonDigest.h>
#import "HudView.h"
#import "KN_VenueProfileSetup.h"
#import "AWSSNS.h"
#import "AWSSNS.h"
#import "AWSLambda/AWSLambda.h"
#import "KN_Notification.h"
#import "Reachability/Reachability.h"
static HudView *aHUD;
@implementation Singlton

+ (Singlton *)sharedManager {
    static Singlton *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        _strComingFromVenueOwnerCommentScreen = nil;
    }
    return self;
}
- (NSString *)getMD5Checksum:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH *2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    NSLog(@"%@",output);
    return  output;
}
-(BOOL)validEmail:(NSString*)email
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+]+@([A-Za-z0-9]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

-(BOOL)check_null_data:(NSString*)strdata
{
    
    if (strdata==nil||[strdata isKindOfClass:[NSNull class]]||strdata.length==0||[strdata isEqualToString:@""])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
-(BOOL)isSpace:(NSString *)strData
{
    NSRange whiteSpacePassword = [strData rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpacePassword.location != NSNotFound)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}
-(void)alert:(UIViewController *)view title: (NSString *) title message: (NSString *) message email: (NSString *) email
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Re-send Verification Link" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self CallResendingAction];
                                                             
                                                          }];
    
    [alert addAction:defaultAction];
    [view presentViewController:alert animated:YES completion:nil];
  
    
}

-(void)CallResendingAction
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"CallEmailVerify"
     object:self];
}
- (void)alert: (UIViewController *) view title: (NSString *) title message: (NSString *) message {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [view presentViewController:alert animated:YES completion:nil];
}
//Convert image height width
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (CGFloat)getLabelHeight:(NSString*)label
{
    CGSize constraint = CGSizeMake(283, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label boundingRectWithSize:constraint
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}
                                             context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}
-(float)calculateHeightForLbl:(NSString*)text width:(float)width{
    CGSize constraint = CGSizeMake(width,20000.0f);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:12]}
                                            context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}
-(void) setLoginAndSignUpStatus:(BOOL) value {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:@"Login_SignUp"];
    [defaults synchronize];
}
- (BOOL) getLoginAndSignUpStatus {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL defaultValue = [defaults boolForKey:@"Login_SignUp"];
    
    return defaultValue;
    
}
-(void)imageProfileRounded:(UIImageView *)imageView withFlot:(float)rdeius withCheckLayer:(BOOL)status
{
    imageView.layer.backgroundColor=[[UIColor clearColor] CGColor];
    imageView.layer.cornerRadius=rdeius;
    if (status==YES) {
        
        imageView.layer.borderWidth=2.0;
        imageView.layer.borderColor=[[UIColor whiteColor] CGColor];
    }
    imageView.layer.masksToBounds = YES;
}
- (void)showHUD{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(aHUD == nil){
            aHUD = [[HudView alloc]init];
            [aHUD loadingViewInView:[[UIApplication sharedApplication] keyWindow] text:@"Loading"];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    });
}


-(void)GettingKonnectVenues
{
    [[Singlton sharedManager]showHUD];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    
    [[dynamoDBObjectMapper scan:[KN_VenueProfileSetup class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
             [[Singlton sharedManager]killHUD];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [Singlton sharedManager].arrKonnectVenues = [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueProfileSetup *chat in paginatedOutput.items)
                 {
                     [[Singlton sharedManager].arrKonnectVenues addObject:chat.dictionaryValue];
                 }
                 
             });
             
         }
         
         return nil;
         
     }];
    
    
}
- (void)killHUD{
    if(aHUD != nil ){
        [aHUD.loadingView removeFromSuperview];
        [[[UIApplication sharedApplication] keyWindow] setUserInteractionEnabled:YES];
        aHUD = nil;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}
-(NSString *)changeStringToDate:(NSString *)strEventDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *myDate = [formatter dateFromString:strEventDate];
    [formatter setDateFormat:@"MMMM d,yyyy"];
    NSString *strFate =[formatter stringFromDate:myDate];
    return strFate;

}
-(NSDate *)convertStringToDate:(NSString *)strEventDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSDate *myDate = [formatter dateFromString:strEventDate];
    return myDate;
    
}
-(NSString *)convertDateToString:(NSDate *)strEventDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSString *strFate =[formatter stringFromDate:strEventDate];
    return strFate;
    
}
-(BOOL)DateChekDifference:(NSDate *)beginedate andDate:(NSDate*)endDate
{
    NSComparisonResult result;
    
    result = [beginedate compare:endDate]; // comparing two dates
    
    if(result == NSOrderedAscending)
        return YES;
    else if(result == NSOrderedDescending)
        return NO;
    else
       return YES;
    
}
-(NSNumber *)ConvertDateToTimeStamWithDate:(NSDate *)Date
{
   NSTimeInterval timeInSeconds = [Date timeIntervalSince1970];
   NSNumber *NumberCreatedAt = [NSNumber numberWithDouble:timeInSeconds];
    return NumberCreatedAt;
}
-(BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

/*-(void) SettingANSForPushNotification:(NSString *)strUserId AndEmailId:(NSString *)strEmail
{
//    AWSSNSCreatePlatformEndpointInput *endPointInput = [[AWSSNSCreatePlatformEndpointInput alloc] init];
//    endPointInput.platformApplicationArn = AWSSNSARN;
//    endPointInput.token = [Singlton sharedManager].strDeviceToken;
//    endPointInput.customUserData = strEmail;
//    [endPointInput.attributes setValue:@"true" forKey:@"Enabled"];
//    AWSSNS *sns = [AWSSNS defaultSNS];
//    [[sns createPlatformEndpoint:endPointInput] continueWithBlock:^id(AWSTask *task) {
//        if(task.error != nil)
//        {
//            NSLog(@"%@", task.error);
//        }
//        else
//        {
//            NSLog(@"success!");
//        // NSString *strEndPointARN = [task.result valueForKey:@"endpointArn"];
//            [self UpdateEndPointARNInDB:[task.result valueForKey:@"endpointArn"] AndUserId:strUserId];
//            
//            
//        }
//        return nil;
//    }];
}*/

-(void) SettingANSForPushNotification:(NSString *)strUserId AndEmailId:(NSString *)strEmail
{
    NSString *strPlatform ;
    if ([[NSString stringWithFormat:@"%@",AWSSNSARN] rangeOfString:@"SANDBOX"].location == NSNotFound)
    {
        strPlatform = @"ios";
    } else
    {
        strPlatform = @"iosdev";
    }
    if([Singlton sharedManager].strDeviceToken.length == 0 || [Singlton sharedManager].strDeviceToken == nil)
    {
        [Singlton sharedManager].strDeviceToken = @"12345678";
    }
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    NSDictionary *parameters = @{@"UserId":strUserId,@"Token":[Singlton sharedManager].strDeviceToken,@"Platform":strPlatform};
    
   
    [[lambdaInvoker invokeFunction: [UserMode isEqualToString:@"Test"] ? @"KON_registerForPushNotification":@"KONProd_registerForPushNotification"
                        JSONObject:parameters] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            dispatch_async(dispatch_get_main_queue(), ^{
            });
            
            NSLog(@"Error while registering for SNS: %@", task.error);
        }
        if (task.result) {
            NSLog(@"Successfully registered for SNS: %@", task.result);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
            });
        }
        return nil;
    }];
    
}

-(void)deleteEndPointARNByDeviceToken:(NSString *)strEndPointARN
{
    // [[NSUserDefaults standardUserDefaults]setValue:@"User" forKey:@"UserType"];
    NSDictionary  *dictUserInfo;
    if([[[NSUserDefaults standardUserDefaults]valueForKey:@"UserType"]isEqualToString:@"User"])
    {
         dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"loginUser"]mutableCopy];
    }
    else if([[[NSUserDefaults standardUserDefaults]valueForKey:@"UserType"]isEqualToString:@"VenueUser"])
    {
         dictUserInfo = [[[NSUserDefaults standardUserDefaults]valueForKey:@"UserDetail"]mutableCopy];
    }
    AWSLambdaInvoker *lambdaInvoker = [AWSLambdaInvoker defaultLambdaInvoker];
    
    
    NSDictionary *parameters = @{@"UserId":[dictUserInfo valueForKey:@"UserId"]};
    [[lambdaInvoker invokeFunction:[UserMode isEqualToString:@"Test"] ? @"KON_unregisterForPushNotification":@"KONProd_unregisterForPushNotification"
                        JSONObject:parameters] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"Error while unregistering from SNS: %@", task.error);
               // [self deleteEndPointARNByDeviceToken:@""];
            });
        }
        if (task.result) {
           dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Successfully unregistered from SNS: %@", task.result);
               [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserDetail"];
               [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"loginUser"];
               [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserType"];
               [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"DefaultArray"];
               [[NSUserDefaults standardUserDefaults]synchronize];
             
               
               
               
            });
        }
        return nil;
    }];
    
}

-(void)UpdateEndPointARNInDB:(NSString *)strEndPointARN AndUserId:(NSString *)strUserId
{
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
    
    AWSDynamoDBAttributeValue *hashKeyValue = [AWSDynamoDBAttributeValue new];
    hashKeyValue.S = strUserId;
    
    updateInput.tableName = [UserMode isEqualToString:@"Test"] ? @"Staging_User" : @"User";
    updateInput.key = @{ @"UserId" : hashKeyValue};
    // End Point ARN
    AWSDynamoDBAttributeValue *newEndPointARN = [AWSDynamoDBAttributeValue new];
    newEndPointARN.S = strEndPointARN;
    
    AWSDynamoDBAttributeValueUpdate *valueUpdateForEndPointARN = [AWSDynamoDBAttributeValueUpdate new];
    valueUpdateForEndPointARN.value = newEndPointARN;
    valueUpdateForEndPointARN.action = AWSDynamoDBAttributeActionPut;
    
    updateInput.attributeUpdates = @{@"EndPointARN": valueUpdateForEndPointARN};
    updateInput.returnValues = AWSDynamoDBReturnValueUpdatedNew;
    
    [[dynamoDB updateItem:updateInput]continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"The request failed. Error: [%@]", task.error);
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self killHUD];
            });
        }
        if (task.result) {
            //Do something with result.
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self killHUD];

            });
        }
        return nil;
    }];
}

-(BOOL)CheckInterConnectivity
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        return NO;
    }
    else
    {
        //connection available
        return YES;
    }
}
@end
