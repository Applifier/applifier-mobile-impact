//
//  ApplifierImpactCache.h
//  ImpactProto
//
//  Created by Johan Halin on 9/6/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApplifierImpactCache;
@class ApplifierImpactCampaign;

@protocol ApplifierImpactCacheDelegate <NSObject>

- (void)cache:(ApplifierImpactCache *)cache finishedCachingCampaign:(ApplifierImpactCampaign *)campaign;
- (void)cacheFinishedCachingCampaigns:(ApplifierImpactCache *)cache;

@end

@interface ApplifierImpactCache : NSObject

@property (nonatomic, assign) id<ApplifierImpactCacheDelegate> delegate;

- (void)cacheCampaigns:(NSArray *)campaigns;
- (NSURL *)localVideoURLForCampaign:(ApplifierImpactCampaign *)campaign;

@end
