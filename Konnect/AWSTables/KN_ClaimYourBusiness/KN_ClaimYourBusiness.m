//
//  KN_ClaimYourBusiness.m
//  Konnect
//
//  Created by Simpalm_mac on 22/11/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "KN_ClaimYourBusiness.h"

@implementation KN_ClaimYourBusiness
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"Staging_ClaimYourBusiness";
    else
        return @"ClaimYourBusiness";
    
}
+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
