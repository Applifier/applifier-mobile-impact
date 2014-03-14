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
- (void)operationStarted:(ApplifierImpactCacheOperation *)cacheOperation;
- (void)operationFinished:(ApplifierImpactCacheOperation *)cacheOperation;
- (void)operationFailed:(ApplifierImpactCacheOperation *)cacheOperation;
- (void)operationCancelled:(ApplifierImpactCacheOperation *)cacheOperation;

@end

@interface ApplifierImpactCacheOperation : NSOperation

@property (nonatomic, assign) id <ApplifierImpactCacheOperationDelegate> delegate;
@property (nonatomic, assign) NSUInteger expectedFileSize;
@property (nonatomic, copy)   NSString * operationKey;
@property (nonatomic, assign) ResourceType resourceType;

@end
