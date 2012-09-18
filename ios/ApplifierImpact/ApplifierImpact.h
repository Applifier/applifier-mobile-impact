//
//  ApplifierImpact.h
//  ApplifierImpact
//
//  Created by Johan Halin on 9/4/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AILOG_DEBUG_LOGGING_ENABLED 1

#define AILOG_LOG(levelName, fmt, ...) NSLog((@"%@ [T:0x%x %@] %s:%d " fmt), levelName, (unsigned int)[NSThread currentThread], ([[NSThread currentThread] isMainThread] ? @"M" : @"S"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#if AILOG_DEBUG_LOGGING_ENABLED
#define AILOG_DEBUG(fmt, ...) AILOG_LOG(@"DEBUG", fmt, ##__VA_ARGS__)
#else
#define AILOG_DEBUG(...)
#endif

#define AILOG_ERROR(fmt, ...) AILOG_LOG(@"ERROR", fmt, ##__VA_ARGS__)

//
//  All delegate methods and public methods in this header are based on the tentative iOS specification document,
//  and will probably change during development.
//

@class ApplifierImpact;

@protocol ApplifierImpactDelegate <NSObject>

@optional
- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactVideoCompleted:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact;
- (void)applifierImpact:(ApplifierImpact *)applifierImpact wantsToShowAdView:(UIView *)adView;

@end

@interface ApplifierImpact : NSObject

@property (nonatomic, assign) id<ApplifierImpactDelegate> delegate;

+ (id)sharedInstance;

- (void)startWithApplifierID:(NSString *)applifierID;
- (BOOL)showImpact;
- (BOOL)hasCampaigns;
- (void)stopAll;

@end
