//
//  ApplifierImpactMobileAIRWrapper.m
//  ApplifierImpactMobileAIRWrapper
//
//  Created by bluesun on 12/10/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactMobileAIRWrapper.h"

FREContext applifierImpactFREContext = nil;
ApplifierImpactMobileAIRWrapper *applifierImpactWrapperSharedInstance = nil;

@interface ApplifierImpactMobileAIRWrapper ()
    @property (nonatomic, assign) UIWindow *currentWindow;
@end

@implementation ApplifierImpactMobileAIRWrapper

+ (ApplifierImpactMobileAIRWrapper *)sharedInstance {
    if (applifierImpactWrapperSharedInstance == nil) {
        applifierImpactWrapperSharedInstance = [[ApplifierImpactMobileAIRWrapper allocWithZone:nil] init];
    }
    
    return applifierImpactWrapperSharedInstance;
}

- (void)startWithGameId:(NSString *)gameId {
	NSLog(@"startWithGameId");
    self.currentWindow = [[UIApplication sharedApplication] keyWindow];
    [[ApplifierImpact sharedInstance] setDelegate:self];
    [[ApplifierImpact sharedInstance] startWithGameId:gameId andViewController:self.currentWindow.rootViewController];
}

- (BOOL)show:(NSDictionary *)options {
	NSLog(@"show");
    return [[ApplifierImpact sharedInstance] showImpact];
}

- (BOOL)hide {
	NSLog(@"hide");
    return [[ApplifierImpact sharedInstance] hideImpact];
}


#pragma mark - ApplifierImpactDelegate

- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactCampaignsAreAvailable");
    const uint8_t* eventType = (const uint8_t*) [@"impactInitComplete" UTF8String];
    const uint8_t* value = (const uint8_t*) [@"now" UTF8String];
    FREDispatchStatusEventAsync(applifierImpactFREContext, eventType, value);
}

- (void)applifierImpactCampaignsFetchFailed:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactCampaignsFetchFailed");
    const uint8_t* eventType = (const uint8_t*) [@"impactInitFailed" UTF8String];
    const uint8_t* value = (const uint8_t*) [@"no campaigns" UTF8String];
    FREDispatchStatusEventAsync(applifierImpactFREContext, eventType, value);
}

- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactWillClose");
    const uint8_t* eventType = (const uint8_t*) [@"impactWillClose" UTF8String];
    const uint8_t* value = (const uint8_t*) [@"now" UTF8String];
    FREDispatchStatusEventAsync(applifierImpactFREContext, eventType, value);
}

- (void)applifierImpactDidClose:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactDidClose");
    const uint8_t* eventType = (const uint8_t*) [@"impactDidClose" UTF8String];
    const uint8_t* value = (const uint8_t*) [@"now" UTF8String];
    FREDispatchStatusEventAsync(applifierImpactFREContext, eventType, value);
}

- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactWillOpen");
    const uint8_t* eventType = (const uint8_t*) [@"impactWillOpen" UTF8String];
    const uint8_t* value = (const uint8_t*) [@"now" UTF8String];
    FREDispatchStatusEventAsync(applifierImpactFREContext, eventType, value);
}

- (void)applifierImpactDidOpen:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactDidOpen");
    const uint8_t* eventType = (const uint8_t*) [@"impactDidOpen" UTF8String];
    const uint8_t* value = (const uint8_t*) [@"now" UTF8String];
    FREDispatchStatusEventAsync(applifierImpactFREContext, eventType, value);
}

- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact {
	NSLog(@"applifierImpactVideoStarted");
    const uint8_t* eventType = (const uint8_t*) [@"impactVideoStarted" UTF8String];
    const uint8_t* value = (const uint8_t*) [@"now" UTF8String];
    FREDispatchStatusEventAsync(applifierImpactFREContext, eventType, value);
}

- (void)applifierImpact:(ApplifierImpact *)applifierImpact completedVideoWithRewardItemKey:(NSString *)rewardItemKey {
	NSLog(@"applifierImpact:completedVideoWithRewardItem: -- key: %@", rewardItemKey);
    const uint8_t* eventType = (const uint8_t*) [@"impactVideoCompletedWithReward" UTF8String];
    const uint8_t* value = (const uint8_t*) [rewardItemKey UTF8String];
    FREDispatchStatusEventAsync(applifierImpactFREContext, eventType, value);
}

@end


/* Wrapper methods */

FREObject init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	NSLog(@"init");
    uint32_t gameIdLength;
    const uint8_t *gameIdCString;
    NSString *gameId = nil;
    
    if (FRE_OK == FREGetObjectAsUTF8(argv[0], &gameIdLength, &gameIdCString)) {
        gameId = [NSString stringWithUTF8String:(char*)gameIdCString];
        [[ApplifierImpactMobileAIRWrapper sharedInstance] startWithGameId:gameId];
    }
    
    return NULL;
}

FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	NSLog(@"isSupported");
    uint32_t value = [ApplifierImpact isSupported];
    
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    
    return retBool;
}

FREObject getSDKVersion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    NSLog(@"getSDKVersion");
    const uint8_t* sdkVersion = (const uint8_t*)[[ApplifierImpact getSDKVersion] UTF8String];
    FREObject retSDKVersion = nil;
    FRENewObjectFromUTF8(sizeof(sdkVersion), sdkVersion, retSDKVersion);
    
    return retSDKVersion;
}

FREObject setDebugMode(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    NSLog(@"setDebugMode");
    uint32_t value;
    
    if (FRE_OK == FREGetObjectAsBool(argv[0], &value)) {
        [[ApplifierImpact sharedInstance] setDebugMode:value];
    }
    
    return NULL;
}

FREObject isDebugMode(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    NSLog(@"isDebugMode");
    uint32_t value = [[ApplifierImpact sharedInstance] isDebugMode];
    
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    
    return retBool;
}

FREObject setTestMode(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	NSLog(@"setTestMode");
    uint32_t value;
    
    if (FRE_OK == FREGetObjectAsBool(argv[0], &value)) {
        [[ApplifierImpact sharedInstance] setTestMode:value];
    }
    
    return NULL;
}

FREObject canShowCampaigns(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	NSLog(@"canShowCampaigns");
    uint32_t value = [[ApplifierImpact sharedInstance] canShowAds];
    
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    
    return retBool;
}

FREObject canShowImpact(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	NSLog(@"canShowImpact");
    uint32_t value = [[ApplifierImpact sharedInstance] canShowImpact];
    
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    
    return retBool;
}

FREObject stopAll(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	NSLog(@"stopAll");
    [[ApplifierImpact sharedInstance] stopAll];
    return NULL;
}

FREObject hasMultipleRewardItems(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	NSLog(@"hasMultipleRewardItems");
    uint32_t value = [[ApplifierImpact sharedInstance] hasMultipleRewardItems];
    
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    
    return retBool;
}

/*
- (BOOL)hasMultipleRewardItems;
- (NSArray *)getRewardItemKeys;
- (NSString *)getDefaultRewardItemKey;
- (NSString *)getCurrentRewardItemKey;
- (BOOL)setRewardItemKey:(NSString *)rewardItemKey;
- (void)setDefaultRewardItemAsRewardItem;
- (NSDictionary *)getRewardItemDetailsWithKey:(NSString *)rewardItemKey;
*/

FREObject showImpact(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	NSLog(@"showImpact");
    uint32_t value = [[ApplifierImpactMobileAIRWrapper sharedInstance] show:NULL];
    
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    
    return retBool;
}

FREObject hideImpact(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	NSLog(@"hideImpact");
    uint32_t value = [[ApplifierImpactMobileAIRWrapper sharedInstance] hide];
    
    FREObject retBool = nil;
    FRENewObjectFromBool(value, &retBool);
    
    return retBool;
}


/* Initializers and Finalizers */

void ApplifierImpactMobileContextInitializer (void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
	NSLog(@"ApplifierImpactMobileContextInitializer");
    applifierImpactFREContext = ctx;
    *numFunctionsToTest = 12;
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);

    func[0].name = (const uint8_t*) "init";
    func[0].functionData = NULL;
    func[0].function = &init;
    
    func[1].name = (const uint8_t*) "isSupported";
    func[1].functionData = NULL;
    func[1].function = &isSupported;

    func[2].name = (const uint8_t*) "getSDKVersion";
    func[2].functionData = NULL;
    func[2].function = &getSDKVersion;

    func[3].name = (const uint8_t*) "setDebugMode";
    func[3].functionData = NULL;
    func[3].function = &setDebugMode;

    func[4].name = (const uint8_t*) "isDebugMode";
    func[4].functionData = NULL;
    func[4].function = &isDebugMode;
    
    func[5].name = (const uint8_t*) "setTestMode";
    func[5].functionData = NULL;
    func[5].function = &setTestMode;

    func[6].name = (const uint8_t*) "canShowCampaigns";
    func[6].functionData = NULL;
    func[6].function = &canShowCampaigns;

    func[7].name = (const uint8_t*) "canShowImpact";
    func[7].functionData = NULL;
    func[7].function = &canShowImpact;

    func[8].name = (const uint8_t*) "stopAll";
    func[8].functionData = NULL;
    func[8].function = &stopAll;
    
    func[9].name = (const uint8_t*) "hasMultipleRewardItems";
    func[9].functionData = NULL;
    func[9].function = &hasMultipleRewardItems;

    func[10].name = (const uint8_t*) "showImpact";
    func[10].functionData = NULL;
    func[10].function = &showImpact;

    func[11].name = (const uint8_t*) "hideImpact";
    func[11].functionData = NULL;
    func[11].function = &hideImpact;

    *functionsToSet = func;
    NSLog(@"ApplifierImpactMobileContextInitializer end");
}

void ApplifierImpactMobileInitializer (void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) {
	NSLog(@"ApplifierImpactMobileInitializer");
    *extDataToSet = NULL;
    *ctxInitializerToSet = &ApplifierImpactMobileContextInitializer;
}

void ApplifierImpactMobileFinalizer (void * extData) {
    return;
}
