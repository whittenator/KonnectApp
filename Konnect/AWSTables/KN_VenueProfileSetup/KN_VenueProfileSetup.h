//
//  KN_VenueProfileSetup.h
//  Konnect
//
//  Created by Balraj Randhawa on 13/11/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
@interface KN_VenueProfileSetup :  AWSDynamoDBObjectModel<AWSDynamoDBModeling>
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *VenueName;
@property (nonatomic, strong) NSString *Address;
@property (nonatomic, strong) NSString *PhoneNumber;
@property (nonatomic, strong) NSString *StartTime;
@property (nonatomic, strong) NSString *EndTime;
@property (nonatomic, strong) NSString *Special;
@property (nonatomic, strong) NSSet *Image;
@property (nonatomic, strong) NSNumber *AverageRating;
@property (nonatomic, strong) NSString *Latitude;
@property (nonatomic, strong) NSString *Longitude;
@property (nonatomic, strong) NSString *isProfileSetupCompleted;
@property (nonatomic, strong) NSNumber *CreatedAt;
@property (nonatomic, strong) NSNumber *UpdateAt;
@end
