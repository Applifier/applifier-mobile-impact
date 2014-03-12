//
//  ApplifierImpactCacheOperation.m
//  testApp
//
//  Created by Sergey D on 3/10/14.
//  Copyright (c) 2014 applifier. All rights reserved.
//

#import "ApplifierImpactCacheCampaignOperation.h"

@interface ApplifierImpactCacheVideoOperation : NSOperation {
  
}

@property (nonatomic, weak) NSURL * videoURL;

@end

@implementation ApplifierImpactCacheVideoOperation

- (void)threadBlocked:(BOOL (^)())isThreadBlocked {
	@autoreleasepool {
		NSPort *port = [[NSPort alloc] init];
		[port scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		while(isThreadBlocked()) {
			@autoreleasepool {
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
			}
		}
	}
}

- (void)main {
  sleep(10);
}

#pragma mark - NSURLConnectionDelegate

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//	NSHTTPURLResponse *httpResponse = nil;
//
//    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//        httpResponse = (NSHTTPURLResponse *)response;
//    }
//
//	NSString *resumeStatus = [self.currentDownload objectForKey:kApplifierImpactCacheResumeKey];
//	BOOL resumeExpected = [resumeStatus isEqualToString:kApplifierImpactCacheDownloadResumeExpected];
//
//	if (resumeExpected && [httpResponse statusCode] == 200) {
//		AILOG_DEBUG(@"Resume expected but got status code 200, restarting download.");
//
//		[self.fileHandle truncateFileAtOffset:0];
//	}
//	else if ([httpResponse statusCode] == 206) {
//		AILOG_DEBUG(@"Resuming download.");
//	}
//
//	NSNumber *contentLength = [[httpResponse allHeaderFields] objectForKey:@"Content-Length"];
//	if (contentLength != nil) {
//		long long size = [contentLength longLongValue];
//		[self _saveCurrentlyDownloadingCampaignToIndexWithFilesize:size];
//		NSDictionary *fsAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[self _cachePath] error:nil];
//
//        if (fsAttributes != nil) {
//			long long freeSpace = [[fsAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
//
//            if (size > freeSpace) {
//				AILOG_DEBUG(@"Not enough space, canceling download. (%lld needed, %lld free)", size, freeSpace);
//				[connection cancel];
//				[self _downloadFinishedWithFailure:YES];
//			}
//		}
//	}
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [self.fileHandle writeData:data];
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//	[self _downloadFinishedWithFailure:NO];
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//	AILOG_DEBUG(@"%@", error);
//	[self _downloadFinishedWithFailure:YES];
//}


@end

@interface ApplifierImpactCacheCampaignOperation () {
@private
  NSOperationQueue * _internalQueue;
}


@end

@implementation ApplifierImpactCacheCampaignOperation

- (void)threadBlocked:(BOOL (^)())isThreadBlocked {
	@autoreleasepool {
		NSPort *port = [[NSPort alloc] init];
		[port scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		while(isThreadBlocked()) {
			@autoreleasepool {
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
			}
		}
	}
}

- (id)init
{
  self = [super init];
  if (self) {
    _internalQueue = [[NSOperationQueue alloc]init];
    [_internalQueue setMaxConcurrentOperationCount:1];
  }
  return self;
}

- (void)main {
  [self.delegate operationStarted:self];
  ApplifierImpactCacheVideoOperation * cacheVideoOperation = [ApplifierImpactCacheVideoOperation new];
  cacheVideoOperation.videoURL = self.campaignToCache.trailerDownloadableURL;
  [_internalQueue addOperation:cacheVideoOperation];
  [self threadBlocked:^BOOL{
    @synchronized(_internalQueue){
      return _internalQueue.operationCount != 0;
    }
  }];
  [self.delegate operationFinished:self];
}

@end
