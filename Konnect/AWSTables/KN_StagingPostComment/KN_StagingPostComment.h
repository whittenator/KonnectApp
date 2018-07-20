//
//  KN_StagingPostComment.h
//  Konnect
//
//  Created by Balraj on 03/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
@interface KN_StagingPostComment : AWSDynamoDBObjectModel<AWSDynamoDBModeling>
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *PostId;
@property (nonatomic, strong) NSString *UserName;
@property (nonatomic, strong) NSString *UserImage;
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *PostComment;
@property (nonatomic, strong) NSNumber *UpdatedAt;
@property (nonatomic, strong) NSNumber *CreatedAt;
@end
