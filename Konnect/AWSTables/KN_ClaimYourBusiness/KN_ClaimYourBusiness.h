//
//  KN_ClaimYourBusiness.h
//  Konnect
//
//  Created by Simpalm_mac on 22/11/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface KN_ClaimYourBusiness : AWSDynamoDBObjectModel<AWSDynamoDBModeling>
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *VenueId;
@property (nonatomic, strong) NSString *Venuename;
@property (nonatomic, strong) NSString *OpenHours;
@property (nonatomic, strong) NSString *CloseHours;
@property (nonatomic, strong) NSString *Venueaddress;
@property (nonatomic, strong) NSString *Email;
@property (nonatomic, strong) NSString *Firstname;
@property (nonatomic, strong) NSString *Lastname;
@property (nonatomic, strong) NSString *PhoneNumber;
@property (nonatomic, strong) NSNumber *EmailVerification;
@property (nonatomic, strong) NSString *VenueLatitude;
@property (nonatomic, strong) NSString *VenueLongitude;
@property (nonatomic, strong) NSNumber *CreatedAt;
@property (nonatomic, strong) NSNumber *UpdatedAt;
@property (nonatomic, strong) NSSet *strImgPath;
@end



