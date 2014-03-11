
//
//  ApplifierImpactCache.h
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApplifierImpactCacheManager;
@class ApplifierImpactCampaign;

@protocol ApplifierImpactCacheManagerDelegate <NSObject>
@optional
- (void)cache:(ApplifierImpactCacheManager *)cache failedToCacheCampaign:(ApplifierImpactCampaign *)campaign;
- (void)cache:(ApplifierImpactCacheManager *)cache cancelledCaching:(ApplifierImpactCampaign *)campaign;

@required
- (void)cache:(ApplifierImpactCacheManager *)cache finishedCachingCampaign:(ApplifierImpactCampaign *)campaign;

@end

@interface ApplifierImpactCacheManager : NSObject

@property (nonatomic, weak) id<ApplifierImpactCacheManagerDelegate> delegate;

- (void)cacheCampaign:(ApplifierImpactCampaign *)campaignToCache;
- (NSURL *)localVideoURLForCampaign:(ApplifierImpactCampaign *)campaign;
- (BOOL)campaignExistsInQueue:(ApplifierImpactCampaign *)campaign;
- (BOOL)isCampaignVideoCached:(ApplifierImpactCampaign *)campaign;
- (void)cancelAllDownloads;

@end
