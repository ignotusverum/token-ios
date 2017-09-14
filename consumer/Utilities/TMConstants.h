//
//  TMConstants.h
//  venue
//
//  Created by Vladislav Zagorodnyuk on 1/20/16
//  Copyright (c) 2016 Human Ventures Co. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0f)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0f)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0f)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0f)

#define IS_IOS_8_OR_GREATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

NSString * const TMHostName;
NSString * const TMClientType;
NSString * const TMManifestURL;
NSString * const TMMacroEnviroment;
NSString * const TMSegmentTrackingID;

NSString * const TM_UI_TEST_MODE;

NSString * const TMFontName;
NSString * const TMBoldFontName;
NSString * const TMLightFontName;
NSString * const TMItalicFontName;
NSString * const TMMediumFontName;
NSString * const TMAccessTokenKey;

NSString * const TMAppVersionKey;                   // storing the bundle version to compare for update transition
NSString * const TMAppLastUpdateCheckDateKey;       // last date checked for updates
NSString * const TMAppUpdateFoundKey;               // an update is currently available

NSString * const TMStripeKey;

NSString * const TMOAuthClientID;
NSString * const TMOAuthClientSecret;
