
//
//  ApplifierImpactCache.h
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApplifierImpactCacheManager;
@class ApplifierImpactCampaign;

@protocol ApplifierImpactCacheDelegate <NSObject>

@required
- (void)cache:(ApplifierImpactCacheManager *)cache finishedCachingCampaign:(ApplifierImpactCampaign *)campaign;
- (void)cacheFinishedCachingCampaigns:(ApplifierImpactCacheManager *)cache;

@end

@interface ApplifierImpactCacheManager : NSObject

@property (nonatomic, weak) id<ApplifierImpactCacheDelegate> delegate;

- (void)cacheCampaign:(ApplifierImpactCampaign *)campaignToCache;
- (NSURL *)localVideoURLForCampaign:(ApplifierImpactCampaign *)campaign;
- (BOOL)campaignExistsInQueue:(ApplifierImpactCampaign *)campaign;
- (BOOL)isCampaignVideoCached:(ApplifierImpactCampaign *)campaign;
- (void)cancelAllDownloads;

@end
