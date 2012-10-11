//
//  ApplifierImpact.h
//  ApplifierImpact
//
//  Created by Johan Halin on 9/4/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define IMPACT_DEBUG_MODE_ENABLED 1

#define AILOG_LOG(levelName, fmt, ...) NSLog((@"%@ [T:0x%x %@] %s:%d " fmt), levelName, (unsigned int)[NSThread currentThread], ([[NSThread currentThread] isMainThread] ? @"M" : @"S"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define AILOG_ERROR(fmt, ...) AILOG_LOG(@"ERROR", fmt, ##__VA_ARGS__)

#if IMPACT_DEBUG_MODE_ENABLED
#define AILOG_DEBUG(fmt, ...) AILOG_LOG(@"DEBUG", fmt, ##__VA_ARGS__)
#define AIAssert(condition) do { if ( ! (condition)) { AILOG_ERROR(@"Expected condition '%s' to be true.", #condition); abort(); } } while(0)
#define AIAssertV(condition, value) do { if ( ! (condition)) { AILOG_ERROR(@"Expected condition '%s' to be true.", #condition); abort(); } } while(0)
#else
#define AILOG_DEBUG(...)
#define AIAssert(condition) do { if ( ! (condition)) { AILOG_ERROR(@"Expected condition '%s' to be true.", #condition); return; } } while(0)
#define AIAssertV(condition, value) do { if ( ! (condition)) { AILOG_ERROR(@"Expected condition '%s' to be true.", #condition); return value; } } while(0)
#endif


//
//  All delegate methods and public methods in this header are based on the tentative iOS specification document,
//  and will probably change during development.
//

@class ApplifierImpact;
@class SKStoreProductViewController;

@protocol ApplifierImpactDelegate <NSObject>

@required
- (void)applifierImpact:(ApplifierImpact *)applifierImpact completedVideoWithRewardItemKey:(NSString *)rewardItemKey;
- (UIViewController *)viewControllerForPresentingViewControllersForImpact:(ApplifierImpact *)applifierImpact;

@optional
- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact;

@end

@interface ApplifierImpact : NSObject

@property (nonatomic, assign) id<ApplifierImpactDelegate> delegate;

+ (id)sharedInstance;
- (void)startWithApplifierID:(NSString *)applifierID;
- (UIView *)impactAdView;
- (BOOL)canShowImpact;
- (void)stopAll;
- (void)trackInstall;
- (void)refresh;

@end
