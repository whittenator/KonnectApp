//
//  KN_VenueProfileSetup.m
//  Konnect
//
//  Created by Balraj Randhawa on 13/11/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "KN_VenueProfileSetup.h"
@implementation KN_VenueProfileSetup
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"staging_VenueProfileSetup";
    else
        return @"VenueProfileSetup";
    
}

+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
