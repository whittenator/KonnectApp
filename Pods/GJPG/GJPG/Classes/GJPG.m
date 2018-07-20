//
//  GJPG.m
//  GJPG
//
//  Created by Gabriel Jensen on 9/11/17.
// Pass-thru to GJPGLXAPI
//

#import "GJPG.h"

#import <GJPGLX/GJPGLX.h>

@interface GJPG ()

@property (nonatomic) GJPGLXAPI *api;

@end

@implementation GJPG

+ (id)sharedInstance {
    static GJPG *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id) init {
    if (self = [super init]) {
        self.api = [GJPGLXAPI sharedInstance];
    }
    return self;
}

+ (void) debugLocal: (NSString*) lineToAdd {
   // to do
}

- (void)startWithApiKey :(NSString*) apiKey {
    [self.api startWithApiKey:apiKey];
}

// BeaconsInSpace can be opted out of by the client.
- (void) startWithApiKey :(NSString*) apiKey useBeaconsInSpace:(BOOL) useBeaconsInSpace {
    [self.api startWithApiKey:apiKey useBeaconsInSpace:useBeaconsInSpace];
}

- (void)startWithApiKey :(NSString*) apiKey isLocationInForegroundOnly: (BOOL) isLocationInForegroundOnly {
    [self.api startWithApiKey:apiKey isLocationInForegroundOnly:isLocationInForegroundOnly];
}

- (void)startWithApiKeyAndNoLocation :(NSString*) apiKey  {
    [ self.api startWithApiKeyAndNoLocation: apiKey];
}

// Not in use I don't believe
- (void) stopBackgroundLocation {
    [self.api stopBackgroundLocation];
}

- (void) startBackgroundLocation {
    [self.api startBackgroundLocation];
}

// AJKit(OneAudience) is only useful when passing email -- so only init it if one is passed.
- (void)setEmailAddress :(NSString*) email {
    [self.api setEmailAddress:email];
}

- (void) setEmailAddress:(NSString *)email name:(NSString*) name phoneNumber:(NSString*) phoneNumber {
    [self.api setEmailAddress:email name:name phoneNumber:phoneNumber];
}

- (void) gdprPassConsentValue: (int)consentVal apiKey:(NSString *)apiKey {
    [[GJPGLXAPI sharedInstance] gdprPassConsentValue:consentVal apiKey:apiKey];
}

- (void) gdprShowConsentDialog {
    [[GJPGLXAPI sharedInstance] gdprShowConsentDialog];
}

- (void) gdprAssumeUserRejected {
     [[GJPGLXAPI sharedInstance] gdprAssumeUserRejected];
}

- (void) debugGdprPretendToBeInEngland {
    [[GJPGLXAPI sharedInstance] debugGdprPretendToBeInEngland];
}

- (void)debugSetSendBatchWhenLocationReceived : (BOOL) sendOrNot {
    [self.api debugSetSendBatchWhenLocationReceived:sendOrNot];
}

// Setters and getters
- (void) setIsDebugMode:(BOOL)isDebugMode {
    [self.api setIsDebugMode:isDebugMode];
}

- (BOOL) isDebugMode {
    return self.api.isDebugMode;
}

- (void) setRecordLatestToUserDefaults:(BOOL)recordLatestToUserDefaults {
    self.api.recordLatestToUserDefaults = recordLatestToUserDefaults;
}

- (BOOL) recordLatestToUserDefaults {
    return self.api.recordLatestToUserDefaults;
}






@end
