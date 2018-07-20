//
//  KN_Notification.m
//  Konnect
//
//  Created by Simpalm_mac on 09/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import "KN_Notification.h"

@implementation KN_Notification

+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"Staging_Notification";
    else
        return @"Notification";
    
}

+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
