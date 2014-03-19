//
//  ApplifierImpactCacheOperation.h
//  ApplifierImpact
//
//  Created by Sergey D on 3/13/14.
//  Copyright (c) 2014 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  ResourceTypeTrailerVideo = 0,
} ResourceType;


@class ApplifierImpactCacheOperation;

@protocol ApplifierImpactCacheOperationDelegate <NSObject>

@required
- (void)cacheOperationStarted:(ApplifierImpactCacheOperation *)cacheOperation;
- (void)cacheOperationFinished:(ApplifierImpactCacheOperation *)cacheOperation;
- (void)cacheOperationFailed:(ApplifierImpactCacheOperation *)cacheOperation;
- (void)cacheOperationCancelled:(ApplifierImpactCacheOperation *)cacheOperation;

@end

@interface ApplifierImpactCacheOperation : NSOperation

@property (nonatomic, assign) id <ApplifierImpactCacheOperationDelegate> delegate;
@property (nonatomic, assign) long long expectedFileSize;
@property (nonatomic, copy)   NSString * operationKey;
@property (nonatomic, assign) ResourceType resourceType;

@end
