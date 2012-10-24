//
//  ApplifierImpactUtils.m
//  ApplifierImpact
//
//  Created by bluesun on 10/23/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactUtils.h"
#import "ApplifierImpact.h"

@implementation ApplifierImpactUtils

+ (NSString *)escapedStringFromString:(NSString *)string
{
	if (string == nil)
	{
		AILOG_DEBUG(@"Input is nil.");
		return nil;
	}
	
	NSString *escapedString = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
	escapedString = [escapedString stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
	NSArray *components = [escapedString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	escapedString = [components componentsJoinedByString:@""];
	
	return escapedString;
}

@end
