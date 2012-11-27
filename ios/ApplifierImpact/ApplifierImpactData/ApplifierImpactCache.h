//
//  ApplifierImpactCache.h
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApplifierImpactCache;
@class ApplifierImpactCampaign;

@protocol ApplifierImpactCacheDelegate <NSObject>

@required
- (void)cache:(ApplifierImpactCache *)cache finishedCachingCampaign:(ApplifierImpactCampaign *)campaign;
- (void)cacheFinishedCachingCampaigns:(ApplifierImpactCache *)cache;

@end

@interface ApplifierImpactCache : NSObject

@property (nonatomic, assign) id<ApplifierImpactCacheDelegate> delegate;

- (void)cacheCampaigns:(NSArray *)campaigns;
- (NSURL *)localVideoURLForCampaign:(ApplifierImpactCampaign *)campaign;
- (BOOL)campaignExistsInQueue:(ApplifierImpactCampaign *)campaign;
- (void)cancelAllDownloads;
- (BOOL)isCampaignVideoCached:(ApplifierImpactCampaign *)campaign;

@end
