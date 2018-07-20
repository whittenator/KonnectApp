//
//  KN_Subscription.h
//  Konnect
//
//  Created by Balraj Randhawa on 14/11/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
@interface KN_Subscription :  AWSDynamoDBObjectModel<AWSDynamoDBModeling>
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *StartDate;
@property (nonatomic, strong) NSString *EndDate;
@property (nonatomic, strong) NSString *PlanType;
@property (nonatomic, strong) NSNumber *CreatedAt;
@property (nonatomic, strong) NSNumber *UpdatedAt;
@end
