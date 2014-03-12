//
//  ApplifierImpactCacheOperation.m
//  testApp
//
//  Created by Sergey D on 3/10/14.
//  Copyright (c) 2014 applifier. All rights reserved.
//

#import "ApplifierImpactCacheCampaignOperation.h"

@interface ApplifierImpactCacheVideoOperation : NSOperation <NSURLConnectionDelegate>  {
  @private
  BOOL _operationFinished;
  NSFileHandle * _fileHandle;
  NSURLConnection * _connection;
}

@property (nonatomic, weak) NSURL * videoURL;
@property (nonatomic, copy) NSString * filePath;
@property (nonatomic, copy) NSString * directoryPath;

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
  _operationFinished = NO;
  BOOL isDir = NO;
  if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
    [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
  }
  if (![[NSFileManager defaultManager] fileExistsAtPath:self.directoryPath isDirectory:&isDir]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:self.directoryPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
  }
  [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:nil attributes:nil];
  _fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
  NSURLRequest * request = [NSURLRequest requestWithURL:self.videoURL];
  _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  [self threadBlocked:^BOOL{
    @synchronized(self) {
      return _operationFinished != YES;
    }
  }];
  [_fileHandle closeFile];
}

- (void)cancel {
  [_connection cancel];
  [_fileHandle closeFile];
  _fileHandle = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSHTTPURLResponse *httpResponse = nil;

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
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_fileHandle writeData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  @synchronized(self) {
    _operationFinished = YES;
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  @synchronized(self) {
    _operationFinished = YES;
  }
}


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
  cacheVideoOperation.filePath = self.filePathURL;
  cacheVideoOperation.directoryPath = self.directoryPath;
  [_internalQueue addOperation:cacheVideoOperation];
  [self threadBlocked:^BOOL{
    @synchronized(_internalQueue){
      return _internalQueue.operationCount != 0;
    }
  }];
  [self.delegate operationFinished:self];
}

-(void)cancel {
  [_internalQueue cancelAllOperations];
  [self threadBlocked:^BOOL{
    @synchronized(_internalQueue){
      return _internalQueue.operationCount != 0;
    }
  }];
  [self.delegate operationCancelled:self];
}

- (void)dealloc {
  self.filePathURL = nil;
  self.directoryPath = nil;
}

@end
