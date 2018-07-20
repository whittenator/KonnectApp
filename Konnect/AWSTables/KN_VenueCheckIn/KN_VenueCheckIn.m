//
//  KN_VenueCheckIn.m
//  Konnect
//
//  Created by Balraj on 19/12/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "KN_VenueCheckIn.h"

@implementation KN_VenueCheckIn
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"Staging_VenueCheckIn";
    else
        return @"VenueCheckIn";
    
}

+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
