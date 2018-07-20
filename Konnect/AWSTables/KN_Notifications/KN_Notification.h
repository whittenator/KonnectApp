//
//  KN_Notification.h
//  Konnect
//
//  Created by Simpalm_mac on 09/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface KN_Notification : AWSDynamoDBObjectModel<AWSDynamoDBModeling>
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *Item;
@property (nonatomic, strong) NSString *ItemId;
@property (nonatomic, strong) NSString *NotificationBy;
@property (nonatomic, strong) NSString *Type;
@property (nonatomic, strong) NSString *NotificationTo;
@property (nonatomic, strong) NSString *NotificationStatus;
@property (nonatomic, strong) NSNumber *UpdatedAt;
@property (nonatomic, strong) NSNumber *CreatedAt;

@end
