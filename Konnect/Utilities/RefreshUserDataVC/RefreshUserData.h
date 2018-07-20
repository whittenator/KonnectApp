//
//  RefreshUserData.h
//  Festi
//
//  Created by Anoop Kumar Jain on 2/6/17.
//  Copyright © 2017 Simpalm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import "KN_User.h"
#import "Singlton.h"

@interface RefreshUserData : NSObject
- (void)refreshUserDataByEmail:(NSString*)email;
+ (RefreshUserData *)sharedInstance;

@end
