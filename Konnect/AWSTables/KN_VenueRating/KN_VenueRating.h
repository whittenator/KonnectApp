//
//  KN_VenueRating.h
//  Konnect
//
//  Created by Simpalm_mac on 30/11/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface KN_VenueRating : AWSDynamoDBObjectModel<AWSDynamoDBModeling>
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *VenueId;
@property (nonatomic, strong) NSString *VenueComment;
@property (nonatomic, strong) NSString *UserName;
@property (nonatomic, strong) NSString *Email;
@property (nonatomic, strong) NSNumber *CreatedAt;
@property float VenueRatingValue;

@end
