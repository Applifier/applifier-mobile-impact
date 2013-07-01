//
//  ApplifierImpactInitializer.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/5/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactInitializer.h"
#import "../ApplifierImpact.h"

@implementation ApplifierImpactInitializer

- (void)initImpact:(NSDictionary *)options {
  if (self.queue == nil)
    [self createQueue];
  if (self.backgroundThread == nil)
    [self createBackgroundThread];
  [ApplifierImpactDevice launchReachabilityCheck];
}

- (void)reInitialize {
}

- (void)deInitialize {
  [[ApplifierImpactCampaignManager sharedInstance] performSelector:@selector(cancelAllDownloads) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
}

- (void)createBackgroundThread {
  if (self.queue != nil && self.backgroundThread == nil) {
    dispatch_sync(self.queue, ^{
      AILOG_DEBUG(@"Starting background thread");
      self.backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(_backgroundRunLoop:) object:nil];
      [self.backgroundThread start];
    });
  }
}

- (void)createQueue {
  if (self.queue == nil) {
    self.queue = dispatch_queue_create("com.applifier.impact.initializer", NULL);
  }
}

- (void)_backgroundRunLoop:(id)dummy {
	@autoreleasepool {
		NSPort *port = [[NSPort alloc] init];
		[port scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		while([[NSThread currentThread] isCancelled] == NO) {
			@autoreleasepool {
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
			}
		}
	}
}

- (void)dealloc {
  [ApplifierImpactDevice clearReachabilityCheck];
  dispatch_release(self.queue);
}

- (BOOL)initWasSuccessfull {
  return NO;
}

- (void)checkForVersionAndShowAlertDialog {
  AILOG_DEBUG(@"");
  
  if (![[ApplifierImpactProperties sharedInstance] sdkIsCurrent]) {
    AILOG_DEBUG(@"Got different sdkVersions, checking further.");
    
    if (![ApplifierImpactDevice isEncrypted]) {
      if ([ApplifierImpactDevice isJailbroken]) {
        AILOG_DEBUG(@"Build is not encrypted, but device seems to be jailbroken. Not showing version alert");
        return;
      }
      else {
        // Build is not encrypted and device is not jailbroken, alert dialog is shown that SDK is not the latest version.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Applifier Impact SDK"
                                                        message:@"The Applifier Impact SDK you are running is not the current version, please update your SDK"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
      }
    }
  }
}

- (void)initCampaignManager {
	AIAssert(![NSThread isMainThread]);
	AILOG_DEBUG(@"");
  [[ApplifierImpactCampaignManager sharedInstance] setDelegate:self];
	[self refreshCampaignManager];
}

- (void)refreshCampaignManager {
	AIAssert(![NSThread isMainThread]);
	[[ApplifierImpactProperties sharedInstance] refreshCampaignQueryString];
	[[ApplifierImpactCampaignManager sharedInstance] updateCampaigns];
}

- (void)initAnalyticsUploader {
	AIAssert(![NSThread isMainThread]);
	AILOG_DEBUG(@"");
	[[ApplifierImpactAnalyticsUploader sharedInstance] retryFailedUploads];
}


@end
