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
  NSFileHandle * _fileHandle;
  NSURLConnection * _connection;
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
#warning TODO check file size - if it is ok then finish operation
  
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
  if ([self.delegate respondsToSelector:@selector(operationFinished:)]) {
    [self.delegate operationFinished:self];
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

#pragma mark - NSURLConnectionDelegate

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

- (void)dealloc {
  self.operationKey = nil;
  self.downloadURL = nil;
  self.filePath = nil;
  self.directoryPath = nil;
}

@end
