//
//  KN_SavedCards.m
//  Konnect
//
//  Created by Balraj on 02/02/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import "KN_SavedCards.h"

@implementation KN_SavedCards
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"Staging_SavedCards";
    else
        return @"Payment";
    
}

+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
