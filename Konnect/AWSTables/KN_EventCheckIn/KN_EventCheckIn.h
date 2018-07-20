//
//  KN_EventCheckIn.h
//  Konnect
//
//  Created by Balraj on 20/12/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
@interface KN_EventCheckIn : AWSDynamoDBObjectModel<AWSDynamoDBModeling>
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *EventId;
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *Status;
@property (nonatomic, strong) NSNumber *CheckedInTime;
@property (nonatomic, strong) NSNumber *CheckedOutTime;
@property (nonatomic, strong) NSNumber *UpdatedAt;
@property (nonatomic, strong) NSNumber *CreatedAt;
@end
