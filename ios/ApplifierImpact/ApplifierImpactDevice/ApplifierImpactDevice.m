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
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"

#import <dlfcn.h>
#import <mach-o/dyld.h>

/* The encryption info struct and constants are missing from the iPhoneSimulator SDK,
 * but not from the iPhoneOS or Mac OS X SDKs. Since one doesn't ever ship a Simulator
 * binary, we'll just provide the definitions here.
 */

#if TARGET_IPHONE_SIMULATOR && !defined(LC_ENCRYPTION_INFO)
#define LC_ENCRYPTION_INFO 0x21

struct encryption_info_command {
  uint32_t cmd;
  uint32_t cmdsize;
  uint32_t cryptoff;
  uint32_t cryptsize;
  uint32_t cryptid;
};
#endif

int main(int argc, char *argv[]);

@implementation ApplifierImpactDevice

+ (NSString *)_substringOfString:(NSString *)string toIndex:(NSInteger)index {
	if (index > [string length])
	{
		AILOG_DEBUG(@"Index %d out of bounds for string '%@', length %d.", index, string, [string length]);
		return nil;
	}
	
	return [string substringToIndex:index];
}

+ (BOOL)isJailbroken {
#if TARGET_IPHONE_SIMULATOR
  return NO;
#else
  static BOOL seen = NO;
  static BOOL cached = NO;
  
  if (seen == YES) {
    return cached;
  }
  
  seen = YES;
  BOOL isJailbroken = NO;
  
  // Check for Cydia, should cover most cases
#if 1
  isJailbroken = [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"];
#else
  NSURL* url = [NSURL URLWithString:@"cydia://package/com.example.package"];
  isJailbroken = [[UIApplication sharedApplication] canOpenURL:url];
#endif
  
  if (isJailbroken == NO) {
    // Sandbox limitation check, can you actually open the file for reading?
    FILE *f = fopen("/bin/bash", "r");
    
    if (!(errno == ENOENT)) {
      isJailbroken = YES;
    }
    fclose(f);
  }
  
  cached = isJailbroken;
  return isJailbroken;
#endif
}

+ (BOOL)isEncrypted {
  static BOOL seen = NO;
  static BOOL cached = NO;
  
  if (seen == YES) {
    return cached;
  }
  seen = YES;
  
  const struct mach_header *header;
  Dl_info dlinfo;
  
  /* Fetch the dlinfo for main() */
  if (dladdr(main, &dlinfo) == 0 || dlinfo.dli_fbase == NULL) {
    AILOG_DEBUG(@"Could not find main() symbol (very odd)");
    return NO;
  }
  header = dlinfo.dli_fbase;
  
  /* Compute the image size and search for a UUID */
  struct load_command *cmd = (struct load_command *) (header+1);
  
  for (uint32_t i = 0; cmd != NULL && i < header->ncmds; i++) {
    /* Encryption info segment */
    if (cmd->cmd == LC_ENCRYPTION_INFO) {
      struct encryption_info_command *crypt_cmd = (struct encryption_info_command *) cmd;
      /* Check if binary encryption is enabled */
      if (crypt_cmd->cryptid < 1) {
        /* Disabled, probably pirated */
        return NO;
      }
      
      /* Probably not pirated? */
      cached = YES;
      return YES;
    }
    
    cmd = (struct load_command *) ((uint8_t *) cmd + cmd->cmdsize);
  }
  
  /* Encryption info not found */
  return NO;
}

+ (NSString *)advertisingIdentifier {
	NSString *identifier = nil;
	
	Class advertisingManagerClass = NSClassFromString(@"ASIdentifierManager");
	if ([advertisingManagerClass respondsToSelector:@selector(sharedManager)]) {
		id advertisingManager = [[advertisingManagerClass class] performSelector:@selector(sharedManager)];
		BOOL enabled = YES; // Not sure what to do with this value.
    
		if ([advertisingManager respondsToSelector:@selector(isAdvertisingTrackingEnabled)]) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[advertisingManagerClass instanceMethodSignatureForSelector:@selector(isAdvertisingTrackingEnabled)]];
			[invocation setSelector:@selector(isAdvertisingTrackingEnabled)];
			[invocation setTarget:advertisingManager];
			[invocation invoke];
			[invocation getReturnValue:&enabled];
		}
		
		//AILOG_DEBUG(@"Ad tracking %@.", enabled ? @"enabled" : @"disabled");
    
		if ([advertisingManager respondsToSelector:@selector(advertisingIdentifier)]) {
			id advertisingIdentifier = [advertisingManager performSelector:@selector(advertisingIdentifier)];
			if (advertisingIdentifier != nil && [advertisingIdentifier respondsToSelector:@selector(UUIDString)]) {
				id uuid = [advertisingIdentifier performSelector:@selector(UUIDString)];
				if ([uuid isKindOfClass:[NSString class]])
					identifier = uuid;
			}
		}
	}
	
	return identifier;
}

+ (BOOL)canUseTracking {
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

+ (NSString *)macAddress {
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
	if ((mgmtInfoBase[5] = if_nametoindex([interface UTF8String])) == 0) {
		AILOG_DEBUG(@"Couldn't get MAC address for interface '%@', if_nametoindex failed.", interface);
		return nil;
	}
  
	size_t length;
  
	// Get the size of the data available (store in len)
	if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) {
		AILOG_DEBUG(@"Couldn't get MAC address for interface '%@', sysctl for mgmtInfoBase length failed.", interface);
		return nil;
	}
  
	// Alloc memory based on above call
	if ((msgBuffer = malloc(length)) == NULL) {
		AILOG_DEBUG(@"Couldn't get MAC address for interface '%@', malloc for %zd bytes failed.", interface, length);
		return nil;
	}
  
	// Get system information, store in buffer
	if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0) {
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

+ (NSString *)machineName {
	size_t size;
  sysctlbyname("hw.machine", NULL, &size, NULL, 0);
  char *answer = malloc(size);
	sysctlbyname("hw.machine", answer, &size, NULL, 0);
	NSString *result = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
	free(answer);
	
	return result;
}

+ (NSArray *)getDeviceModelAsStringComponents {
  NSString *modelString = [[[UIDevice currentDevice] model] lowercaseString];
  if (modelString != nil) {
    if ([modelString rangeOfString:@" "].location != NSNotFound) {
      NSArray *components = [modelString componentsSeparatedByString:@" "];
      return components;
    }
    else {
      return [[NSArray alloc] initWithObjects:modelString, nil];
    }
  }
  
  return nil;
}

+ (BOOL)isSimulator {
  NSArray *components = [ApplifierImpactDevice getDeviceModelAsStringComponents];
  if (components != nil && [components count] > 0) {
    for (NSString *component in components) {
      if ([component isEqualToString:kApplifierImpactDeviceSimulator]) {
        return YES;
      }
    }
  }

  return NO;
}

+ (NSString *)analyticsMachineName {
	NSString *machine = [self machineName];
  
	if ([machine isEqualToString:@"iPhone1,1"])
		return kApplifierImpactDeviceIphone;
	else if ([machine isEqualToString:@"iPhone1,2"])
		return kApplifierImpactDeviceIphone3g;
	else if ([machine isEqualToString:@"iPhone2,1"])
		return kApplifierImpactDeviceIphone3gs;
	else if ([machine length] > 6 && [[self _substringOfString:machine toIndex:7] isEqualToString:@"iPhone3"])
		return kApplifierImpactDeviceIphone4;
	else if ([machine length] > 6 && [[self _substringOfString:machine toIndex:7] isEqualToString:@"iPhone4"])
		return kApplifierImpactDeviceIphone4s;
	else if ([machine length] > 6 && [[self _substringOfString:machine toIndex:7] isEqualToString:@"iPhone5"])
		return kApplifierImpactDeviceIphone5;
	else if ([machine isEqualToString:@"iPod1,1"])
		return kApplifierImpactDeviceIpodTouch1gen;
	else if ([machine isEqualToString:@"iPod2,1"])
		return kApplifierImpactDeviceIpodTouch2gen;
	else if ([machine isEqualToString:@"iPod3,1"])
		return kApplifierImpactDeviceIpodTouch3gen;
	else if ([machine isEqualToString:@"iPod4,1"])
		return kApplifierImpactDeviceIpodTouch4gen;
	else if ([machine isEqualToString:@"iPod5,1"])
		return kApplifierImpactDeviceIpodTouch5gen;
	else if ([machine length] > 4 && [[self _substringOfString:machine toIndex:5] isEqualToString:@"iPad1"])
		return kApplifierImpactDeviceIpad1;
	else if ([machine length] > 4 && [[self _substringOfString:machine toIndex:5] isEqualToString:@"iPad2"])
		return kApplifierImpactDeviceIpad2;
	else if ([machine length] > 4 && [[self _substringOfString:machine toIndex:5] isEqualToString:@"iPad3"])
		return kApplifierImpactDeviceIpad3;
  
  // Okay, it's a simulator, detect whether it's iPhone or iPad
  
  NSArray *components = [ApplifierImpactDevice getDeviceModelAsStringComponents];
  if (components != nil && [components count] > 0) {
    for (NSString *component in components) {
      if ([component isEqualToString:kApplifierImpactDeviceIpad]) {
        return kApplifierImpactDeviceIpad;
      }
      if ([component isEqualToString:kApplifierImpactDeviceIphone]) {
        return kApplifierImpactDeviceIphone;
      }
      if ([component isEqualToString:kApplifierImpactDeviceIpod]) {
        return kApplifierImpactDeviceIpod;
      }
    }
  }

  // If everything else fails..
  
	return kApplifierImpactDeviceIosUnknown;
}

+ (NSString *)_md5StringFromString:(NSString *)string {
	if (string == nil) {
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

+ (NSString *)md5MACAddressString {
	return [self _md5StringFromString:[self macAddress]];
}

+ (NSString *)md5OpenUDIDString {
	return [ApplifierImpactDevice _md5StringFromString:[ApplifierImpactOpenUDID value]];
}

+ (NSString *)md5AdvertisingIdentifierString {
	NSString *adId = [self advertisingIdentifier];
	if (adId == nil) {
		AILOG_DEBUG(@"Advertising identifier not available.");
		return nil;
	}
	
	return [self _md5StringFromString:adId];
}

static NSString *wifiString = @"wifi";
static NSString *cellularString = @"cellular";
static NSString *connectionString = @"none";

static void reachabilityCallBack(SCNetworkReachabilityRef reachabilityRef, SCNetworkReachabilityFlags flags, void * info) {
  AIAssert(![NSThread isMainThread]);
  if (reachabilityRef != NULL) {
		SCNetworkReachabilityFlags flags;
		if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
			if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
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
				connectionString = @"none";
			}
		}
  }
}

static SCNetworkReachabilityRef reachabilityRef = nil;

+ (void)launchReachabilityCheck {
  [self clearReachabilityCheck];
  reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, "applifier.com");
  SCNetworkReachabilitySetCallback(reachabilityRef, reachabilityCallBack, NULL);
  SCNetworkReachabilitySetDispatchQueue(reachabilityRef, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
}

+ (void)clearReachabilityCheck {
  if(reachabilityRef != NULL) {
    CFRelease(reachabilityRef);
    reachabilityRef = NULL;
  }
}
  
+ (NSString *)currentConnectionType {
	@synchronized(self) {
    return connectionString;
  }
}

+ (NSString *)softwareVersion {
  return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)md5DeviceId {
  return [ApplifierImpactDevice md5AdvertisingIdentifierString] != nil ? [ApplifierImpactDevice md5AdvertisingIdentifierString] : [ApplifierImpactDevice md5OpenUDIDString];
}

+ (int)getIOSMajorVersion {
  
  return [[[self softwareVersion] substringToIndex:1] intValue];
}

+ (NSNumber *)getIOSExactVersion {
  NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
  [f setNumberStyle:NSNumberFormatterDecimalStyle];
  NSNumber *myNumber = [f numberFromString:[self softwareVersion]];
  return myNumber;
}

+ (NSString *)ODIN1 {
  // Step 1: Get MAC address
  int                 mib[6];
  size_t              len;
  char                *buf;
  unsigned char       *ptr;
  struct if_msghdr    *ifm;
  struct sockaddr_dl  *sdl;
  
  mib[0] = CTL_NET;
  mib[1] = AF_ROUTE;
  mib[2] = 0;
  mib[3] = AF_LINK;
  mib[4] = NET_RT_IFLIST;
  
  if ((mib[5] = if_nametoindex("en0")) == 0) {
    //NSLog(@"ODIN-1.1: if_nametoindex error");
    return nil;
  }
  
  if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
    //NSLog(@"ODIN-1.1: sysctl 1 error");
    return nil;
  }
  
  if ((buf = malloc(len)) == NULL) {
    //NSLog(@"ODIN-1.1: malloc error");
    return nil;
  }
  
  if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
    //NSLog(@"ODIN-1.1: sysctl 2 error");
    free(buf);
    return nil;
  }
  
  ifm = (struct if_msghdr *)buf;
  sdl = (struct sockaddr_dl *)(ifm + 1);
  ptr = (unsigned char *)LLADDR(sdl);
  
  //NSLog(@"MAC Address: %02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5));
  // Step 2: Take the SHA-1 of the MAC address
  //NSData *data = [NSData dataWithBytes:ptr length:6];
  
  CFDataRef data = CFDataCreate(NULL, (uint8_t*)ptr, 6);
  unsigned char messageDigest[CC_SHA1_DIGEST_LENGTH];
  
  CC_SHA1(CFDataGetBytePtr((CFDataRef)data),
          CFDataGetLength((CFDataRef)data),
          messageDigest);
  
  CFMutableStringRef string = CFStringCreateMutable(NULL, 40);
  for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
    CFStringAppendFormat(string,
                         NULL,
                         (CFStringRef)@"%02X",
                         messageDigest[i]);
  }
  
  CFStringLowercase(string, CFLocaleGetSystem());
  //NSLog(@"ODIN-1: %@", string);
  
  CFRelease(data);
  free(buf);
  
  return (__bridge NSString*)string;
}


@end
