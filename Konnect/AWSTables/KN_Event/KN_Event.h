//
//  KN_Event.h
//  Konnect
//
//  Created by Balraj Randhawa on 06/12/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
@interface KN_Event : AWSDynamoDBObjectModel<AWSDynamoDBModeling>
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *VenueId;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *Description;
@property (nonatomic, strong) NSString *Type;
@property (nonatomic, strong) NSString *EventDate;
@property (nonatomic, strong) NSString *StartTime;
@property (nonatomic, strong) NSString *EndTime;
@property (nonatomic, strong) NSSet *Special;
@property (nonatomic, strong) NSString *Image;
@property (nonatomic, strong) NSString *Latitude;
@property (nonatomic, strong) NSString *Longitude;
@property (nonatomic, strong) NSNumber *CreatedAt;
@property (nonatomic, strong) NSNumber *UpdatedAt;
@end
