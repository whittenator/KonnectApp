//
//  KN_Staging_PostEvent.m
//  Konnect
//
//  Created by Balraj on 28/12/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "KN_Staging_PostEvent.h"

@implementation KN_Staging_PostEvent
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"Staging_PostEvent";
    else
        return @"PostEvent";
    
}

+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
