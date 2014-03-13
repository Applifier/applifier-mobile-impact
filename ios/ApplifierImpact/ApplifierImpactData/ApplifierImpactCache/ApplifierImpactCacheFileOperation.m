//
//  ApplifierImpactCacheOperation.m
//  testApp
//
//  Created by Sergey D on 3/10/14.
//  Copyright (c) 2014 applifier. All rights reserved.
//

#import "ApplifierImpactCacheFileOperation.h"

@interface ApplifierImpactCacheFileOperation () <NSURLConnectionDelegate> {
@private
  BOOL _operationFinished;
  BOOL _failedToDownload;
  NSFileHandle * _fileHandle;
  NSURLConnection * _connection;
  NSTimer * _timer;
  long long downloadedFileSize;
  unsigned int elapsedTime;
}

@end

@implementation ApplifierImpactCacheFileOperation

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
  if ([self.delegate respondsToSelector:@selector(operationStarted:)]) {
    [self.delegate operationStarted:self];
  }
  _failedToDownload = YES;
  NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:nil];
  long long size = [attributes fileSize];
  if (size != self.expectedFileSize) {
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
    NSURLRequest * request = [NSURLRequest requestWithURL:self.downloadURL];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self threadBlocked:^BOOL{
      @synchronized(self) {
        return _operationFinished != YES;
      }
    }];
    [_fileHandle closeFile];
  }
  
  attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:nil];
  size = [attributes fileSize];
  if (size != self.expectedFileSize || _failedToDownload) {
    if ([self.delegate respondsToSelector:@selector(operationFailed:)]) {
      [self.delegate operationFailed:self];
    }
  } else {
    if ([self.delegate respondsToSelector:@selector(operationFinished:)]) {
      [self.delegate operationFinished:self];
    }
  }
}

- (void)cancel {
  [_connection cancel];
  [_fileHandle closeFile];
  _fileHandle = nil;
  if ([self.delegate respondsToSelector:@selector(operationCancelled:)]) {
    [self.delegate operationCancelled:self];
  }
}

- (void)tick:(NSTimer *)ticker {
  elapsedTime++;
  NSLog(@"Speed %lld kb/s", (long long)downloadedFileSize/(long long)(elapsedTime * 1024));
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  if (!_timer) {
    _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target:self
                                            selector:@selector(tick:)
                                            userInfo:nil
                                             repeats:YES];
  }
  [_fileHandle writeData:data];
  downloadedFileSize += [data length];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  @synchronized(self) {
    _operationFinished = YES;
    _failedToDownload = NO;
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  @synchronized(self) {
     _failedToDownload = YES;
    _operationFinished = YES;
  }
}

- (void)dealloc {
  self.downloadURL = nil;
  self.filePath = nil;
  self.directoryPath = nil;
}

@end
