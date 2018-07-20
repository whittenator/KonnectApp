//
//  KN_VenueRating.m
//  Konnect
//
//  Created by Simpalm_mac on 30/11/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "KN_VenueRating.h"

@implementation KN_VenueRating
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"Staging_VenueRating";
    else
        return @"VenueRating";
    
}
+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
