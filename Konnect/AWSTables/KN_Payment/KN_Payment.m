//
//  KN_Payment.m
//  Konnect
//
//  Created by Balraj on 02/02/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import "KN_Payment.h"

@implementation KN_Payment
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"Staging_Payment";
    else
        return @"Payment";
    
}

+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
