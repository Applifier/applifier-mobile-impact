//
//  ApplifierImpact.m
//  ApplifierImpact
//
//  Created by Johan Halin on 9/4/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpact.h"
#import "ApplifierImpactiOS4.h"

@implementation ApplifierImpact

#pragma mark - Private

- (id)initApplifierInstance
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

#pragma mark - Public

static ApplifierImpact *sharedApplifierInstance = nil;

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
}

+ (id)sharedInstance
{
	@synchronized(self)
	{
		if (sharedApplifierInstance == nil)
		{
			if ([self respondsToSelector:@selector(autoContentAccessingProxy)]) // check if we're on at least iOS 4.0
				sharedApplifierInstance = [[ApplifierImpactiOS4 alloc] initApplifierInstance];
			else
				sharedApplifierInstance = [[self alloc] initApplifierInstance];
		}
	}
	
	return sharedApplifierInstance;
}

- (void)startWithApplifierID:(NSString *)applifierID
{
	AILOG_DEBUG(@"Disabled on older versions of iOS.");
}

- (UIView *)impactAdView
{
	AILOG_DEBUG(@"Disabled on older versions of iOS.");

	return nil;
}

- (BOOL)canShowImpact
{
	AILOG_DEBUG(@"Disabled on older versions of iOS.");

	return NO;
}

- (void)stopAll
{
	AILOG_DEBUG(@"Disabled on older versions of iOS.");
}

- (void)trackInstall
{
	AILOG_DEBUG(@"Disabled on older versions of iOS.");
}

- (void)refresh
{
	AILOG_DEBUG(@"Disabled on older versions of iOS.");
}

@end
