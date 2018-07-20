//
//  KN_Event.m
//  Konnect
//
//  Created by Balraj Randhawa on 06/12/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "KN_Event.h"

@implementation KN_Event
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"Staging_Event";
    else
        return @"Event";
    
}

+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
