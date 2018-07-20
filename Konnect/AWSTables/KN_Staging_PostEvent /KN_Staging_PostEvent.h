//
//  KN_Staging_PostEvent.h
//  Konnect
//
//  Created by Balraj on 28/12/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
@interface KN_Staging_PostEvent : AWSDynamoDBObjectModel<AWSDynamoDBModeling>
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *EventId;
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *PostComment;
@property (nonatomic, strong) NSString *commentCount;
@property (nonatomic, strong) NSString *Type;
@property (nonatomic, strong) NSString *Image;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *UserImage;
@property (nonatomic, strong) NSString *Video;
@property (nonatomic, strong) NSString *PostAddress;
@property (nonatomic, strong) NSNumber *UpdatedAt;
@property (nonatomic, strong) NSNumber *CreatedAt;
@end
