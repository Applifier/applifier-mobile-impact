//
//  ApplifierImpactCacheOperation.h
//  testApp
//
//  Created by Sergey D on 3/10/14.
//  Copyright (c) 2014 applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplifierImpactCampaign.h"

static NSString * const kApplifierImpactCacheCampaignKey = @"kApplifierImpactCacheCampaignKey";
static NSString * const kApplifierImpactCacheConnectionKey = @"kApplifierImpactCacheConnectionKey";
static NSString * const kApplifierImpactCacheFilePathKey = @"kApplifierImpactCacheFilePathKey";
static NSString * const kApplifierImpactCacheURLRequestKey = @"kApplifierImpactCacheURLRequestKey";
static NSString * const kApplifierImpactCacheIndexKey = @"kApplifierImpactCacheIndexKey";
static NSString * const kApplifierImpactCacheResumeKey = @"kApplifierImpactCacheResumeKey";

static NSString * const kApplifierImpactCacheDownloadResumeExpected = @"kApplifierImpactCacheDownloadResumeExpected";
static NSString * const kApplifierImpactCacheDownloadNewDownload = @"kApplifierImpactCacheDownloadNewDownload";

static NSString * const kApplifierImpactCacheEntryCampaignIDKey = @"kApplifierImpactCacheEntryCampaignIDKey";
static NSString * const kApplifierImpactCacheEntryFilenameKey = @"kApplifierImpactCacheEntryFilenameKey";
static NSString * const kApplifierImpactCacheEntryFilesizeKey = @"kApplifierImpactCacheEntryFilesizeKey";

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
@property (nonatomic, copy) NSString * filePathURL, * directoryPath;
@property (nonatomic, assign) id <ApplifierImpactCacheOperationDelegate> delegate;

@end
