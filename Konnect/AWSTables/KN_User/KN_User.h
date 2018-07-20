//
//  KN_User.h
//  Konnect
//
//  Created by Balraj Randhawa on 08/11/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
@interface KN_User :  AWSDynamoDBObjectModel<AWSDynamoDBModeling>
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSNumber *EmailVerification;
@property (nonatomic, strong) NSNumber *FBLogin;
@property (nonatomic, strong) NSString *VerificationCode;
@property (nonatomic, strong) NSNumber *CreatedAt;
@property (nonatomic, strong) NSNumber *UpdatedAt;
@property (nonatomic, strong) NSNumber *PushEnabled;
@property (nonatomic, strong) NSString *DeviceToken;
@property (nonatomic, strong) NSString *UserType;
@property (nonatomic, strong) NSString *Email;
@property (nonatomic, strong) NSString *EndPointARN;
@property (nonatomic, strong) NSString *Password;
@property (nonatomic, strong) NSString *HomeLocation;
@property (nonatomic, strong) NSNumber *SubscriptionStatus;
@property (nonatomic, strong) NSNumber *VenueConnectDate;
@property (nonatomic, strong) NSString *Latitude;
@property (nonatomic, strong) NSString *Longitude;
@property (nonatomic, strong) NSString *Firstname;
@property (nonatomic, strong) NSString *Lastname;
@property (nonatomic, strong) NSString *PhoneNumber;
@property (nonatomic, strong) NSString *UserImage;
@property (nonatomic, strong) NSString *FBProfilePicChanged;
@property (nonatomic, strong) NSString *isFirstTimeLogin;
@property (nonatomic, strong) NSSet *Followers;
@property (nonatomic, strong) NSSet *Following;

@end
