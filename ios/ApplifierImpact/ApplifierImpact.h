//
//  ApplifierImpact.h
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define AILOG_LOG(levelName, fmt, ...) if ([[ApplifierImpact sharedInstance] isDebugMode]) NSLog((@"%@ [T:0x%x %@] %s:%d " fmt), levelName, (unsigned int)[NSThread currentThread], ([[NSThread currentThread] isMainThread] ? @"M" : @"S"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define AILOG_ERROR(fmt, ...) AILOG_LOG(@"ERROR", fmt, ##__VA_ARGS__)

#define AILOG_DEBUG(fmt, ...) AILOG_LOG(@"DEBUG", fmt, ##__VA_ARGS__)
#define AIAssert(condition) do { if ([[ApplifierImpact sharedInstance] isDebugMode] && !(condition)) { AILOG_ERROR(@"Expected condition '%s' to be true.", #condition); abort(); } } while(0)
#define AIAssertV(condition, value) do { if ([[ApplifierImpact sharedInstance] isDebugMode] && !(condition)) { AILOG_ERROR(@"Expected condition '%s' to be true.", #condition); abort(); } } while(0)

extern NSString * const kApplifierImpactRewardItemPictureKey;
extern NSString * const kApplifierImpactRewardItemNameKey;

extern NSString * const kApplifierImpactOptionNoOfferscreenKey;
extern NSString * const kApplifierImpactOptionOpenAnimatedKey;
extern NSString * const kApplifierImpactOptionGamerSIDKey;
extern NSString * const kApplifierImpactOptionMuteVideoSounds;
extern NSString * const kApplifierImpactOptionVideoUsesDeviceOrientation;

typedef enum {
  kApplifierImpactModeDefault,
  kApplifierImpactModeNoWebView,
} ApplifierImpactMode;

@class ApplifierImpact;
@class SKStoreProductViewController;

@protocol ApplifierImpactDelegate <NSObject>

@required
- (void)applifierImpact:(ApplifierImpact *)applifierImpact completedVideoWithRewardItemKey:(NSString *)rewardItemKey videoWasSkipped:(BOOL)skipped;

@optional
- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactDidOpen:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactDidClose:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactWillLeaveApplication:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact;
- (void)applifierImpactCampaignsFetchFailed:(ApplifierImpact *)applifierImpact;
@end

@interface ApplifierImpact : NSObject

@property (nonatomic, weak) id<ApplifierImpactDelegate> delegate;

+ (ApplifierImpact *)sharedInstance;
+ (BOOL)isSupported;
+ (NSString *)getSDKVersion;

- (void)setTestDeveloperId:(NSString *)developerId;
- (void)setTestOptionsId:(NSString *)optionsId;
- (void)setDebugMode:(BOOL)debugMode;
- (void)setImpactMode:(ApplifierImpactMode)impactMode;
- (void)setTestMode:(BOOL)testModeEnabled;

- (BOOL)isDebugMode;
- (BOOL)startWithGameId:(NSString *)gameId andViewController:(UIViewController *)viewController;
- (BOOL)startWithGameId:(NSString *)gameId;
- (void)setViewController:(UIViewController *)viewController showImmediatelyInNewController:(BOOL)applyImpact;
- (BOOL)canShowCampaigns;
- (BOOL)canShowImpact;
- (BOOL)setZone:(NSString *)zoneId;
- (BOOL)setZone:(NSString *)zoneId withRewardItem:(NSString *)rewardItemKey;
- (BOOL)showImpact:(NSDictionary *)options;
- (BOOL)showImpact;
- (BOOL)hideImpact;
- (void)stopAll;
- (BOOL)hasMultipleRewardItems;
- (NSArray *)getRewardItemKeys;
- (NSString *)getDefaultRewardItemKey;
- (NSString *)getCurrentRewardItemKey;
- (BOOL)setRewardItemKey:(NSString *)rewardItemKey;
- (void)setDefaultRewardItemAsRewardItem;
- (NSDictionary *)getRewardItemDetailsWithKey:(NSString *)rewardItemKey;
@end
