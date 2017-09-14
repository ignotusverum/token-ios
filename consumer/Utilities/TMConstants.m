//
//  TMConstants.m
//  venue
//
//  Created by Vladislav Zagorodnyuk on 1/20/16
//  Copyright (c) 2016 Human Ventures Co. All rights reserved.
//

#import "TMConstants.h"

#ifdef TM_MACRO_ENVIRONMENT
NSString * const TMHostName = TM_MACRO_HOST_NAME;
NSString * const TMManifestURL = TM_MACRO_MANIFEST_URL;
NSString * const TMMacroEnviroment = TM_MACRO_ENVIRONMENT;
NSString * const TMSegmentTrackingID = TM_MACRO_SEGMENT_TRACKING_ID;
#else
NSString * const TMMactoEnviroment = "Dev"
NSString * const TMManifestURL = @"token.plist";
NSString * const TMHostName = @"internal-test-mobile-api.sendtoken.com";
NSString * const TMSegmentTrackingID = @"SUEyXiJkcte00kWcNQ3kAuEF7DaGND1B";
#endif

NSString * const TMAccessTokenKey = @"TMAccessTokenKey";

NSString * const TM_UI_TEST_MODE = TM_MACRO_UI_TEST_MODE;

NSString * const TMAppVersionKey = @"TMAppVersionKey"; // storing the bundle version to compare for update transition
NSString * const TMAppUpdateFoundKey = @"TMAppUpdateFoundKey"; // an update is currently available
NSString * const TMAppLastUpdateCheckDateKey = @"TMAppLastUpdateCheckDateKey"; // last date checked for updates
NSString * const TMLastNotifictationRequestedKey = @"TMLastNotifictationRequestedKey"; // last date notification service requested

NSString * const TMOAuthClientID = @"TMOAuthClientID";
NSString * const TMOAuthClientSecret = @"TMOAuthClientSecret";
