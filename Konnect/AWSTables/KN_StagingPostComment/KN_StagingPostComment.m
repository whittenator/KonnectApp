//
//  KN_StagingPostComment.m
//  Konnect
//
//  Created by Balraj on 03/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import "KN_StagingPostComment.h"

@implementation KN_StagingPostComment
+ (NSString *)dynamoDBTableName {
    
    if([UserMode isEqualToString:@"Test"])
        return @"Staging_PostComment";
    else
        return @"PostComment";
    
}

+ (NSString *)hashKeyAttribute {
    return @"Id";
}
@end
