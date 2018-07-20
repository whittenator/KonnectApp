//
//  KN_User.m
//  Konnect
//
//  Created by Balraj Randhawa on 08/11/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "KN_User.h"

@implementation KN_User
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"Staging_User";
    else
        return @"User";
}

+ (NSString *)hashKeyAttribute {
    return @"UserId";
}
@end
