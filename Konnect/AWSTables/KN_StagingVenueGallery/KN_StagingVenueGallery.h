//
//  KN_StagingVenueGallery.h
//  Konnect
//
//  Created by Balraj on 12/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
@interface KN_StagingVenueGallery : AWSDynamoDBObjectModel<AWSDynamoDBModeling>
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *VenueId;
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *PostComment;
@property (nonatomic, strong) NSString *Type;
@property (nonatomic, strong) NSString *Image;
@property (nonatomic, strong) NSString *UserImage;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *Video;
@property (nonatomic, strong) NSNumber *UpdatedAt;
@property (nonatomic, strong) NSNumber *CreatedAt;
@end
