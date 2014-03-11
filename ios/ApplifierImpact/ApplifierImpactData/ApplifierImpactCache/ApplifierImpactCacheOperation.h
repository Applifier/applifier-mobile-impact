//
//  ApplifierImpactCacheOperation.h
//  testApp
//
//  Created by Sergey D on 3/10/14.
//  Copyright (c) 2014 applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplifierImpactCampaign.h"

@class ApplifierImpactCacheOperation;

@protocol ApplifierImpactCacheOperationDelegate <NSObject>

@optional
- (void)operationStarted:(ApplifierImpactCacheOperation *)cacheOperation;

@required
- (void)operationFinished:(ApplifierImpactCacheOperation *)cacheOperation;
- (void)operationFailed:(ApplifierImpactCacheOperation *)cacheOperation;
- (void)operationCancelled:(ApplifierImpactCacheOperation *)cacheOperation;

@end

@interface ApplifierImpactCacheOperation : NSOperation

@property (nonatomic, strong) ApplifierImpactCampaign * campaignToCache;
@property (nonatomic, assign) id <ApplifierImpactCacheOperationDelegate> delegate;

@end
