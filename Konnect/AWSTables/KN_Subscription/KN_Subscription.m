//
//  KN_Subscription.m
//  Konnect
//
//  Created by Balraj Randhawa on 14/11/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "KN_Subscription.h"

@implementation KN_Subscription
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"staging_subscription";
    else
        return @"subscription";
    
}

+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
