//
//  GJPG.h
//  Facade for GJPGAPI
//
//  Created by Gabriel Jensen on 9/11/17.
//

#import <Foundation/Foundation.h>

@interface GJPG : NSObject

+ (instancetype)sharedInstance;

- (void) startWithApiKey :(NSString*) apiKey;
- (void) startWithApiKey :(NSString*) apiKey isLocationInForegroundOnly: (BOOL) isLocationInForegroundOnly;
- (void) startWithApiKey :(NSString*) apiKey useBeaconsInSpace:(BOOL) useBeaconsInSpace;
- (void) startWithApiKeyAndNoLocation :(NSString*) apiKey;
- (void) setEmailAddress :(NSString*) email;
- (void) setEmailAddress:(NSString *) email name:(NSString*) name phoneNumber:(NSString*) phoneNumber;
- (void) debugSetSendBatchWhenLocationReceived : (BOOL) isSending;
- (void) stopBackgroundLocation;
- (void) startBackgroundLocation;
+ (void) debugLocal: (NSString*) lineToAdd;

- (void) gdprPassConsentValue: (int)consentVal apiKey:(NSString *)apiKey;
- (void) gdprShowConsentDialog;
- (void) gdprAssumeUserRejected; // For case where dev doesn't care about europe: assume user has said NO.
- (void) debugGdprPretendToBeInEngland;

@property (nonatomic) BOOL isDebugMode;
@property (nonatomic) BOOL recordLatestToUserDefaults;
@property (nonatomic) BOOL isLocationInForegroundOnly;

@end
