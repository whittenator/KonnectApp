//
//  RefreshUserData.m
//  Festi
//
//  Created by Ankit Panwar on 2/6/17.
//  Copyright © 2017 Simpalm. All rights reserved.
//

#import "RefreshUserData.h"

@implementation RefreshUserData
static RefreshUserData* _sharedMySingleton = nil;

+ (RefreshUserData *)sharedInstance{
    @synchronized([RefreshUserData class])
    {
        if (!_sharedMySingleton)
            _sharedMySingleton = [[self alloc] init];
        
        return _sharedMySingleton;
    }
    return nil;
}

- (void)refreshUserDataByEmail:(NSString*)email
{
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper load:[KN_User class] hashKey:[[Singlton sharedManager] getMD5Checksum:email] rangeKey:nil]
     continueWithBlock:^id(AWSTask *task) {
         if (task.result) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 KN_User *UserDetail = task.result;
                 NSMutableDictionary *dictUser = [[NSMutableDictionary alloc]init];
                 [dictUser setObject:[UserDetail valueForKey:@"Email"] forKey:@"Email"];
                 [dictUser setObject:[UserDetail valueForKey:@"EmailVerification"] forKey:@"EmailVerification"];
                 [dictUser setObject:[UserDetail valueForKey:@"PushEnabled"] forKey:@"PushEnabled"];
                 [dictUser setObject:[UserDetail valueForKey:@"SubscriptionStatus"] forKey:@"SubscriptionStatus"];
                 [dictUser setObject:[UserDetail valueForKey:@"VerificationCode"] forKey:@"VerificationCode"];
                 [dictUser setObject:[UserDetail valueForKey:@"UserId"] forKey:@"UserId"];
                 [dictUser setObject:[UserDetail valueForKey:@"isFirstTimeLogin"] forKey:@"isFirstTimeLogin"];
                 NSArray *arrayFollower = [[UserDetail valueForKey:@"Followers"] allObjects];
                 NSArray *arrayFollowing = [[UserDetail valueForKey:@"Following"] allObjects];
                 [dictUser setObject:arrayFollower forKey:@"Followers"];
                 [dictUser setObject:arrayFollowing forKey:@"Following"];
                 
                 [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"UserDetail"];
                 [[NSUserDefaults standardUserDefaults]synchronize];
                 
                 [[NSUserDefaults standardUserDefaults] setObject:dictUser forKey:@"UserDetail"];
             });
             //Do something with the result.
         }
         return nil;
     }];
}



@end
