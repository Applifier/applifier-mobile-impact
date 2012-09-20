//
//  ApplifierImpactiOS4.m
//  ImpactProto
//
//  Created by Johan Halin on 9/4/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <CommonCrypto/CommonDigest.h>

#import "ApplifierImpactiOS4.h"
#import "ApplifierImpactCampaignManager.h"
#import "ApplifierImpactCampaign.h"
#import "ApplifierImpactRewardItem.h"
#import "ApplifierImpactOpenUDID.h"
#import "ApplifierImpactAnalyticsUploader.h"
#import "ApplifierImpactViewManager.h"

NSString * const kApplifierImpactVersion = @"1.0";

@interface ApplifierImpactiOS4 () <ApplifierImpactCampaignManagerDelegate, UIWebViewDelegate, UIScrollViewDelegate, ApplifierImpactViewManagerDelegate>
@property (nonatomic, strong) ApplifierImpactCampaignManager *campaignManager;
@property (nonatomic, strong) ApplifierImpactAnalyticsUploader *analyticsUploader;
@property (nonatomic, strong) ApplifierImpactViewManager *viewManager;
@property (nonatomic, strong) ApplifierImpactRewardItem *rewardItem;
@property (nonatomic, strong) NSString *applifierID;
@property (nonatomic, strong) NSString *campaignJSON;
@property (nonatomic, strong) NSString *machineName;
@property (nonatomic, strong) NSString *md5AdvertisingIdentifier;
@property (nonatomic, strong) NSString *md5MACAddress;
@property (nonatomic, strong) NSString *md5OpenUDID;
@property (nonatomic, strong) NSString *campaignQueryString;
@property (nonatomic, strong) NSThread *backgroundThread;
@property (nonatomic, strong) NSArray *campaigns;
@property (nonatomic, assign) BOOL webViewInitialized;
@end

@implementation ApplifierImpactiOS4

#pragma mark - Private

- (NSString *)_advertisingIdentifier
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

- (NSString *)_machineName
{
	size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname("hw.machine", answer, &size, NULL, 0);
	NSString *result = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	
	return result;
}

- (NSString *)_substringOfString:(NSString *)string toIndex:(NSInteger)index
{
	if (index > [string length])
		return nil;
	
	return [string substringToIndex:index];
}

- (NSString *)_analyticsMachineName
{
	NSString *machine = [self _machineName];
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

- (NSString *)_macAddress
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

- (NSString *)_md5StringFromString:(NSString *)string
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

- (NSString *)_md5OpenUDIDString
{
	return [self _md5StringFromString:[ApplifierImpactOpenUDID value]];
}

- (NSString *)_md5MACAddressString
{
	return [self _md5StringFromString:[self _macAddress]];
}

- (NSString *)_md5AdvertisingIdentifierString
{
	return [self _md5StringFromString:[self _advertisingIdentifier]];
}

- (NSString *)_currentConnectionType
{
	// FIXME: find out where to get this
	return @"TODO";
}

- (NSString *)_queryString
{
	NSString *advertisingIdentifier = self.md5AdvertisingIdentifier != nil ? [NSString stringWithFormat:@"&advertisingTrackingId=%@", self.md5AdvertisingIdentifier] : @"";
	
	return [NSString stringWithFormat:@"?openUdid=%@&macAddress=%@%@&iosVersion=%@&device=%@&sdkVersion=%@&gameId=%@&type=ios&connection=%@", self.md5OpenUDID, self.md5MACAddress, advertisingIdentifier, [[UIDevice currentDevice] systemVersion], self.machineName, kApplifierImpactVersion, self.applifierID, [self _currentConnectionType]];
}

- (void)_backgroundRunLoop:(id)dummy
{
	@autoreleasepool
	{
		NSPort *port = [[NSPort alloc] init];
		[port scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		while([[NSThread currentThread] isCancelled] == NO)
		{
			@autoreleasepool
			{
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
			}
		}
	}
}

- (void)_startCampaignManager
{
	self.campaignManager = [[ApplifierImpactCampaignManager alloc] init];
	self.campaignManager.delegate = self;
	self.campaignManager.queryString = self.campaignQueryString;
	[self.campaignManager updateCampaigns];
}

- (void)_logPositionString:(NSString *)string
{
	if (string == nil)
	{
		AILOG_DEBUG(@"Input is nil.");
		return;
	}
	
	// FIXME
//	[self.analyticsUploader sendViewReportForCampaign:self.selectedCampaign positionString:string];
}

- (void)_logVideoAnalyticsWithPosition:(VideoAnalyticsPosition)videoPosition campaign:(ApplifierImpactCampaign *)campaign
{
	if (campaign == nil)
	{
		AILOG_DEBUG(@"Campaign is nil.");
		return;
	}
	
	NSString *positionString = nil;
	if (videoPosition == kVideoAnalyticsPositionStart)
		positionString = @"video_start";
	else if (videoPosition == kVideoAnalyticsPositionFirstQuartile)
		positionString = @"first_quartile";
	else if (videoPosition == kVideoAnalyticsPositionMidPoint)
		positionString = @"mid_point";
	else if (videoPosition == kVideoAnalyticsPositionThirdQuartile)
		positionString = @"third_quartile";
	else if (videoPosition == kVideoAnalyticsPositionEnd)
		positionString = @"video_end";
	
	NSString *trackingId = self.md5AdvertisingIdentifier != nil ? self.md5AdvertisingIdentifier : self.md5OpenUDID;
	NSString *query = [NSString stringWithFormat:@"applicationId=%@&type=%@&trackingId=%@&providerId=%@", self.applifierID, positionString, trackingId, campaign.id];

	[self.analyticsUploader performSelector:@selector(sendViewReportWithQueryString:) onThread:self.backgroundThread withObject:query waitUntilDone:NO];
}

- (void)_startAnalyticsUploader
{
	self.analyticsUploader = [[ApplifierImpactAnalyticsUploader alloc] init];
	[self.analyticsUploader retryFailedUploads];
}

- (void)_notifyDelegateOfCampaignAvailability
{
	if (self.campaigns != nil && self.rewardItem != nil && self.webViewInitialized)
	{
		if ([self.delegate respondsToSelector:@selector(applifierImpactCampaignsAreAvailable:)])
			[self.delegate applifierImpactCampaignsAreAvailable:self];
	}
}

#pragma mark - Public

- (void)startWithApplifierID:(NSString *)applifierID
{
	if ( ! [NSThread isMainThread])
	{
		AILOG_ERROR(@"-startWithApplifierID: must be run on main thread.");
		return;
	}
	
	if (applifierID == nil || [applifierID length] == 0)
	{
		AILOG_ERROR(@"Applifier ID empty or not set.");
		return;
	}
	
	if (self.applifierID != nil)
		return;
	
	self.applifierID = applifierID;
	self.backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(_backgroundRunLoop:) object:nil];
	[self.backgroundThread start];
	
	self.machineName = [self _analyticsMachineName];
	self.md5AdvertisingIdentifier = [self _md5AdvertisingIdentifierString];
	self.md5MACAddress = [self _md5MACAddressString];
	self.md5OpenUDID = [self _md5OpenUDIDString];
	self.campaignQueryString = [self _queryString];
	
	self.viewManager = [[ApplifierImpactViewManager alloc] init];
	self.viewManager.delegate = self;
	[self.viewManager start];
	
	[self performSelector:@selector(_startCampaignManager) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
	[self performSelector:@selector(_startAnalyticsUploader) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
}

- (UIView *)impactAdView
{
	if ( ! [NSThread isMainThread])
	{
		AILOG_ERROR(@"Must be run on main thread.");
		return nil;
	}
	
	if ([self.campaigns count] > 0)
	{
		UIView *adView = [self.viewManager adView];
		if (adView != nil)
		{
			if ([self.delegate respondsToSelector:@selector(applifierImpactWillOpen:)])
				[self.delegate applifierImpactWillOpen:self];

			return adView;
		}
	}
	
	return nil;
}

- (BOOL)canShowImpact
{
	if ( ! [NSThread isMainThread])
	{
		AILOG_ERROR(@"Must be run on main thread.");
		return NO;
	}

	return ([self.campaigns count] > 0 && self.webViewInitialized);
}

- (void)stopAll
{
	if ( ! [NSThread isMainThread])
	{
		AILOG_ERROR(@"-stopAll must be run on main thread.");
		return;
	}
	
	[self.campaignManager performSelector:@selector(cancelAllDownloads) onThread:self.backgroundThread withObject:nil waitUntilDone:NO];
}

- (void)dealloc
{
	self.campaignManager.delegate = nil;
	self.viewManager.delegate = nil;
}

#pragma mark - ApplifierImpactCampaignManagerDelegate

- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager updatedWithCampaigns:(NSArray *)campaigns rewardItem:(ApplifierImpactRewardItem *)rewardItem
{
	if ( ! [NSThread isMainThread])
	{
		AILOG_ERROR(@"Method must be run on main thread.");
		return;
	}
	
	self.campaigns = campaigns;
	self.rewardItem = rewardItem;

	[self _notifyDelegateOfCampaignAvailability];
}

- (void)campaignManager:(ApplifierImpactCampaignManager *)campaignManager downloadedJSON:(NSString *)json
{
	if ( ! [NSThread isMainThread])
	{
		AILOG_ERROR(@"Method must be run on main thread.");
		return;
	}
	
	self.viewManager.campaignJSON = json;
}

#pragma mark - ApplifierImpactViewManagerDelegate

-(ApplifierImpactCampaign *)viewManager:(ApplifierImpactViewManager *)viewManager campaignWithID:(NSString *)campaignID
{
	ApplifierImpactCampaign *foundCampaign = nil;
	
	for (ApplifierImpactCampaign *campaign in self.campaigns)
	{
		if ([campaign.id isEqualToString:campaignID])
		{
			foundCampaign = campaign;
			break;
		}
	}
	
	return foundCampaign;
}

-(NSURL *)viewManager:(ApplifierImpactViewManager *)viewManager videoURLForCampaign:(ApplifierImpactCampaign *)campaign
{
	return [self.campaignManager videoURLForCampaign:campaign];
}

- (void)viewManagerStartedPlayingVideo:(ApplifierImpactViewManager *)viewManager
{
	if ([self.delegate respondsToSelector:@selector(applifierImpactVideoStarted:)])
		[self.delegate applifierImpactVideoStarted:self];
}

- (void)viewManagerVideoEnded:(ApplifierImpactViewManager *)viewManager
{
	if ([self.delegate respondsToSelector:@selector(applifierImpactVideoCompleted:)])
		[self.delegate applifierImpactVideoCompleted:self];
}

- (void)viewManager:(ApplifierImpactViewManager *)viewManager loggedVideoPosition:(VideoAnalyticsPosition)videoPosition campaign:(ApplifierImpactCampaign *)campaign
{
	[self _logVideoAnalyticsWithPosition:videoPosition campaign:campaign];
}

- (void)viewManager:(ApplifierImpactViewManager *)viewManager wantsToPresentProductViewController:(SKStoreProductViewController *)productViewController
{
	if ([self.delegate respondsToSelector:@selector(applifierImpact:wantsToPresentProductViewController:)])
		[self.delegate applifierImpact:self wantsToPresentProductViewController:productViewController];
}

- (void)viewManagerWillCloseAdView:(ApplifierImpactViewManager *)viewManager
{
	if ([self.delegate respondsToSelector:@selector(applifierImpactWillClose:)])
		[self.delegate applifierImpactWillClose:self];
}

- (void)viewManagerWebViewInitialized:(ApplifierImpactViewManager *)viewManager
{
	self.webViewInitialized = YES;
	
	[self _notifyDelegateOfCampaignAvailability];
}

@end
