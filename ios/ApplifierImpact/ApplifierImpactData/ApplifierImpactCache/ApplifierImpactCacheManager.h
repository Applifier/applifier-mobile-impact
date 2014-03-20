
//
//  ApplifierImpactCache.h
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplifierImpactCacheFileOperation.h"


@class ApplifierImpactCacheManager;
@class ApplifierImpactCampaign;

@protocol ApplifierImpactCacheManagerDelegate <NSObject>
@optional
- (void)startedCaching:(ResourceType)resourceType forCampaign:(ApplifierImpactCampaign *)campaign;
- (void)finishedCaching:(ResourceType)resourceType forCampaign:(ApplifierImpactCampaign *)campaign;
- (void)failedCaching:(ResourceType)resourceType forCampaign:(ApplifierImpactCampaign *)campaign;
- (void)cancelledCaching:(ResourceType)resourceType forCampaign:(ApplifierImpactCampaign *)campaign;
- (void)cachingQueueEmpty;
@end

@interface ApplifierImpactCacheManager : NSObject

@property (nonatomic, weak) id <ApplifierImpactCacheManagerDelegate> delegate;

- (BOOL)cache:(ResourceType)resourceType forCampaign:(ApplifierImpactCampaign *)campaign;
- (BOOL)campaignExistsInQueue:(ApplifierImpactCampaign *)campaign withResourceType:(ResourceType)resourceType;

- (NSURL *)localURLFor:(ResourceType)resourceType ofCampaign:(ApplifierImpactCampaign *)campaign;
- (BOOL)is:(ResourceType)resourceType cachedForCampaign:(ApplifierImpactCampaign *)campaign;

- (void)cancelCacheForCampaign:(ApplifierImpactCampaign *)campaign withResourceType:(ResourceType)resourceType;
- (void)cancelAllDownloads;

+ sharedInstance;

@end
