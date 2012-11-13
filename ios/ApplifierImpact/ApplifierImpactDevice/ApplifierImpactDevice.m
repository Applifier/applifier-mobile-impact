//
//  ApplifierImpactDevice.m
//  ApplifierImpact
//
//  Created by bluesun on 10/19/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <CommonCrypto/CommonDigest.h>

#import <SystemConfiguration/SystemConfiguration.h>

#import "ApplifierImpactDevice.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactOpenUDID/ApplifierImpactOpenUDID.h"

@implementation ApplifierImpactDevice

+ (NSString *)_substringOfString:(NSString *)string toIndex:(NSInteger)index
{
	if (index > [string length])
	{
		AILOG_DEBUG(@"Index %d out of bounds for string '%@', length %d.", index, string, [string length]);
		return nil;
	}
	
	return [string substringToIndex:index];
}

+ (NSString *)advertisingIdentifier
{
	NSString *identifier = nil;
	
	Class advertisingManagerClass = NSClassFromString(@"ASIdentifierManager");
	if ([advertisingManagerClass respondsToSelector:@selector(sharedManager)])
	{
		id advertisingManager = [[advertisingManagerClass class] performSelector:@selector(sharedManager)];
		BOOL enabled = YES; // Not sure what to do with this value.
    
		if ([advertisingManager respondsToSelector:@selector(isAdvertisingTrackingEnabled)])
		{
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[advertisingManagerClass instanceMethodSignatureForSelector:@selector(isAdvertisingTrackingEnabled)]];
			[invocation setSelector:@selector(isAdvertisingTrackingEnabled)];
			[invocation setTarget:advertisingManager];
			[invocation invoke];
			[invocation getReturnValue:&enabled];
		}
		
		AILOG_DEBUG(@"Ad tracking %@.", enabled ? @"enabled" : @"disabled");
    
		if ([advertisingManager respondsToSelector:@selector(advertisingIdentifier)])
		{
			id advertisingIdentifier = [advertisingManager performSelector:@selector(advertisingIdentifier)];
			if (advertisingIdentifier != nil && [advertisingIdentifier respondsToSelector:@selector(UUIDString)])
			{
				id uuid = [advertisingIdentifier performSelector:@selector(UUIDString)];
				if ([uuid isKindOfClass:[NSString class]])
					identifier = uuid;
			}
		}
	}
	
	return identifier;
}

+ (BOOL)canUseTracking
{
  Class advertisingManagerClass = NSClassFromString(@"ASIdentifierManager");
	if ([advertisingManagerClass respondsToSelector:@selector(sharedManager)])
	{
		id advertisingManager = [[advertisingManagerClass class] performSelector:@selector(sharedManager)];
		BOOL enabled = YES; // Not sure what to do with this value.
    
		if ([advertisingManager respondsToSelector:@selector(isAdvertisingTrackingEnabled)])
		{
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[advertisingManagerClass instanceMethodSignatureForSelector:@selector(isAdvertisingTrackingEnabled)]];
			[invocation setSelector:@selector(isAdvertisingTrackingEnabled)];
			[invocation setTarget:advertisingManager];
			[invocation invoke];
			[invocation getReturnValue:&enabled];
      
      return enabled;
		}
  }
  
  return YES;
}

+ (NSString *)machineName
{
	size_t size;
  sysctlbyname("hw.machine", NULL, &size, NULL, 0);
  char *answer = malloc(size);
	sysctlbyname("hw.machine", answer, &size, NULL, 0);
	NSString *result = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
	free(answer);
	
	return result;
}

+ (NSString *)analyticsMachineName
{
	NSString *machine = [self machineName];
	if ([machine isEqualToString:@"iPhone1,1"])
		return @"iphone";
	else if ([machine isEqualToString:@"iPhone1,2"])
		return @"iphone3g";
	else if ([machine isEqualToString:@"iPhone2,1"])
		return @"iphone3gs";
	else if ([[self _substringOfString:machine toIndex:7] isEqualToString:@"iPhone3"])
		return @"iphone4";
	else if ([[self _substringOfString:machine toIndex:7] isEqualToString:@"iPhone4"])
		return @"iphone4s";
	else if ([[self _substringOfString:machine toIndex:7] isEqualToString:@"iPhone5"])
		return @"iphone5";
	else if ([machine isEqualToString:@"iPod1,1"])
		return @"ipodtouch1gen";
	else if ([machine isEqualToString:@"iPod2,1"])
		return @"ipodtouch2gen";
	else if ([machine isEqualToString:@"iPod3,1"])
		return @"ipodtouch3gen";
	else if ([machine isEqualToString:@"iPod4,1"])
		return @"ipodtouch4gen";
	else if ([[self _substringOfString:machine toIndex:5] isEqualToString:@"iPad1"])
		return @"ipad1";
	else if ([[self _substringOfString:machine toIndex:5] isEqualToString:@"iPad2"])
		return @"ipad2";
	else if ([[self _substringOfString:machine toIndex:5] isEqualToString:@"iPad3"])
		return @"ipad3";
  
	return @"iosUnknown";
}

+ (NSString *)macAddress
{
	NSString *interface = @"en0";
	int mgmtInfoBase[6];
	char *msgBuffer = NULL;
	
	// Setup the management Information Base (mib)
	mgmtInfoBase[0] = CTL_NET; // Request network subsystem
	mgmtInfoBase[1] = AF_ROUTE; // Routing table info
	mgmtInfoBase[2] = 0;
	mgmtInfoBase[3] = AF_LINK; // Request link layer information
	mgmtInfoBase[4] = NET_RT_IFLIST; // Request all configured interfaces
	
	// With all configured interfaces requested, get handle index
	if ((mgmtInfoBase[5] = if_nametoindex([interface UTF8String])) == 0)
	{
		AILOG_DEBUG(@"Couldn't get MAC address for interface '%@', if_nametoindex failed.", interface);
		return nil;
	}
	
	size_t length;
	
	// Get the size of the data available (store in len)
	if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
	{
		AILOG_DEBUG(@"Couldn't get MAC address for interface '%@', sysctl for mgmtInfoBase length failed.", interface);
		return nil;
	}
	
	// Alloc memory based on above call
	if ((msgBuffer = malloc(length)) == NULL)
	{
		AILOG_DEBUG(@"Couldn't get MAC address for interface '%@', malloc for %zd bytes failed.", interface, length);
		return nil;
	}
	
	// Get system information, store in buffer
	if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
	{
		free(msgBuffer);
		
		AILOG_DEBUG(@"Couldn't get MAC address for interface '%@', sysctl for mgmtInfoBase data failed.", interface);
		return nil;
	}
	
	// Map msgbuffer to interface message structure
	struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
	
	// Map to link-level socket structure
	struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
	
	// Copy link layer address data in socket structure to an array
	unsigned char macAddress[6];
	memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
	
	// Read from char array into a string object, into MAC address format
	NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
	
	// Release the buffer memory
	free(msgBuffer);
	
	return macAddressString;
}

+ (NSString *)_md5StringFromString:(NSString *)string
{
	if (string == nil)
	{
		AILOG_DEBUG(@"Input is nil.");
		return nil;
	}
	
	const char *ptr = [string UTF8String];
	unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
	CC_MD5(ptr, strlen(ptr), md5Buffer);
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x",md5Buffer[i]];
	
	return output;
}

+ (NSString *)md5OpenUDIDString
{
	return [ApplifierImpactDevice _md5StringFromString:[ApplifierImpactOpenUDID value]];
}

+ (NSString *)md5MACAddressString
{
	return [self _md5StringFromString:[self macAddress]];
}

+ (NSString *)md5AdvertisingIdentifierString
{
	NSString *adId = [self advertisingIdentifier];
	if (adId == nil)
	{
		AILOG_DEBUG(@"Advertising identifier not available.");
		return nil;
	}
	
	return [self _md5StringFromString:adId];
}

+ (NSString *)currentConnectionType
{
	NSString *wifiString = @"wifi";
	NSString *cellularString = @"cellular";
	NSString *connectionString = nil;
	
	SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, "applifier.com");
	if (reachabilityRef != NULL)
	{
		SCNetworkReachabilityFlags flags;
		if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
		{
			if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
			{
				// if target host is reachable and no connection is required
				//  then we'll assume (for now) that you're on Wi-Fi
				connectionString = wifiString;
			}
			
			if ((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0 || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)
			{
				// ... and the connection is on-demand (or on-traffic) if the
				//     calling application is using the CFSocketStream or higher APIs
				
				if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
				{
					// ... and no [user] intervention is needed
					connectionString = wifiString;
				}
			}
			
			if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0)
			{
				// ... but WWAN connections are OK if the calling application
				//     is using the CFNetwork (CFSocketStream?) APIs.
				connectionString = cellularString;
			}
      
			if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
			{
				// if target host is not reachable
				connectionString = nil;
			}
		}
    
		CFRelease(reachabilityRef);
	}
	
	return connectionString;
}

+ (NSString *)softwareVersion {
  return [[UIDevice currentDevice] systemVersion];
}

@end
