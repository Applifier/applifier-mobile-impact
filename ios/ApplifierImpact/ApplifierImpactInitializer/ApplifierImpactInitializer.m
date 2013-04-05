//
//  ApplifierImpactInitializer.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/5/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactInitializer.h"

@implementation ApplifierImpactInitializer

- (void)init:(NSDictionary *)options {
  if (self.queue == nil)
    [self createQueue];
  if (self.backgroundThread == nil)
    [self createBackgroundThread];
}

- (void)createBackgroundThread {
  if (self.queue != nil && self.backgroundThread == nil) {
    dispatch_async(self.queue, ^{
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
  dispatch_release(self.queue);
}

@end
