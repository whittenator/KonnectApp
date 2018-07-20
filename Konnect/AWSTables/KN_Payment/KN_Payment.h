//
//  KN_Payment.h
//  Konnect
//
//  Created by Balraj on 02/02/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface KN_Payment : AWSDynamoDBObjectModel<AWSDynamoDBModeling>
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *PaymentType;
@property (nonatomic, strong) NSString *PurchaseDescrption;
@property (nonatomic, strong) NSString *Amount;
@property (nonatomic, strong) NSNumber *UpdatedAt;
@property (nonatomic, strong) NSNumber *CreatedAt;
@end
