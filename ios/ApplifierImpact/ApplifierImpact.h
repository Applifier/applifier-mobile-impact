//
//  ApplifierImpact.h
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define IMPACT_DEBUG_MODE_ENABLED 0

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

@class ApplifierImpact;
@class SKStoreProductViewController;

@protocol ApplifierImpactDelegate <NSObject>

@required
- (void)applifierImpact:(ApplifierImpact *)applifierImpact completedVideoWithRewardItemKey:(NSString *)rewardItemKey;

@optional
- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact;

@end

@interface ApplifierImpact : NSObject

@property (nonatomic, assign) id<ApplifierImpactDelegate> delegate;

+ (ApplifierImpact *)sharedInstance;
+ (BOOL)isSupported;
- (void)setTestMode:(BOOL)testModeEnabled;
- (void)startWithGameId:(NSString *)gameId andViewController:(UIViewController *)viewController;
- (void)startWithGameId:(NSString *)gameId;
- (void)setViewController:(UIViewController *)viewController showImmediatelyInNewController:(BOOL)applyImpact;
- (BOOL)canShowImpact;
- (BOOL)showImpact;
- (BOOL)hideImpact;
- (void)stopAll;
- (void)trackInstall;

@end
