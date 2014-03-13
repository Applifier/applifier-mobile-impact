//
//  ApplifierImpactCacheOperation.h
//  testApp
//
//  Created by Sergey D on 3/10/14.
//  Copyright (c) 2014 applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplifierImpactCampaign.h"

typedef enum {
  ResourceTypeTrailerVideo = 0,
} ResourceType;

@class ApplifierImpactCacheFileOperation;

@protocol ApplifierImpactFileCacheOperationDelegate <NSObject>

@optional
- (void)operationStarted:(ApplifierImpactCacheFileOperation *)cacheOperation;
- (void)operationFinished:(ApplifierImpactCacheFileOperation *)cacheOperation;
- (void)operationFailed:(ApplifierImpactCacheFileOperation *)cacheOperation;
- (void)operationCancelled:(ApplifierImpactCacheFileOperation *)cacheOperation;

@end

@interface ApplifierImpactCacheFileOperation : NSOperation

@property (nonatomic, strong) NSURL * downloadURL;
@property (nonatomic, copy)   NSString * filePath, * directoryPath;
@property (nonatomic, assign) id <ApplifierImpactFileCacheOperationDelegate> delegate;
@property (nonatomic, assign) NSUInteger expectedFileSize;
@property (nonatomic, copy)   NSString * operationKey;
@property (nonatomic, assign) ResourceType resourceType;

@end
