//
//  ApplifierImpactCacheOperation.m
//  testApp
//
//  Created by Sergey D on 3/10/14.
//  Copyright (c) 2014 applifier. All rights reserved.
//

#import "ApplifierImpactCacheOperation.h"

@implementation ApplifierImpactCacheOperation
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
