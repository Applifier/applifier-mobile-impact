//
//  ApplifierImpactCacheOperation.h
//  testApp
//
//  Created by Sergey D on 3/10/14.
//  Copyright (c) 2014 applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplifierImpactCampaign.h"

@class ApplifierImpactCacheCampaignOperation;

@protocol ApplifierImpactCacheOperationDelegate <NSObject>

@optional
- (void)operationStarted:(ApplifierImpactCacheCampaignOperation *)cacheOperation;

@required
- (void)operationFinished:(ApplifierImpactCacheCampaignOperation *)cacheOperation;
- (void)operationFailed:(ApplifierImpactCacheCampaignOperation *)cacheOperation;
- (void)operationCancelled:(ApplifierImpactCacheCampaignOperation *)cacheOperation;

@end

@interface ApplifierImpactCacheCampaignOperation : NSOperation

@property (nonatomic, assign) ApplifierImpactCampaign * campaignToCache;
@property (nonatomic, assign) id <ApplifierImpactCacheOperationDelegate> delegate;

@end
