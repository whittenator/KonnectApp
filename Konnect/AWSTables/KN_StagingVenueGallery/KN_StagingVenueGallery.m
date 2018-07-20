//
//  KN_StagingVenueGallery.m
//  Konnect
//
//  Created by Balraj on 12/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import "KN_StagingVenueGallery.h"

@implementation KN_StagingVenueGallery
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"Staging_VenueGallery";
    else
        return @"VenueGallery";
    
}

+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
