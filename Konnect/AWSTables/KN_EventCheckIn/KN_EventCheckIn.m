//
//  KN_EventCheckIn.m
//  Konnect
//
//  Created by Balraj on 20/12/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "KN_EventCheckIn.h"

@implementation KN_EventCheckIn
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"Staging_EventCheckIn";
    else
        return @"EventCheckIn";
    
}

+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
