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

FREObject getRewardItemKeys(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	NSLog(@"getRewardItemKeys");
    NSArray *rewardItemKeys = [[ApplifierImpact sharedInstance] getRewardItemKeys];
    NSString *rewardItemKeyString = @"";
    FREObject retRewardKeys = nil;
    
    for (int i = 0; i < [rewardItemKeys count]; i++) {
        rewardItemKeyString = [NSString stringWithFormat:@"%@%@", rewardItemKeyString, [rewardItemKeys objectAtIndex:i]];
        if (i + i < [rewardItemKeys count])
            rewardItemKeyString = [NSString stringWithFormat:@"%@%@", rewardItemKeyString, @";"];
    }
    
    const uint8_t* c_rewardItemKeyString = (const uint8_t*)[rewardItemKeyString UTF8String];
    FRENewObjectFromUTF8(sizeof(c_rewardItemKeyString), c_rewardItemKeyString, retRewardKeys);
    
    return retRewardKeys;
}

FREObject getDefaultRewardItemKey(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    NSLog(@"getDefaultRewardItemKey");
    const uint8_t* defaultRewardItem = (const uint8_t*)[[[ApplifierImpact sharedInstance] getDefaultRewardItemKey] UTF8String];
    FREObject retDefaultRewardItem = nil;
    FRENewObjectFromUTF8(sizeof(defaultRewardItem), defaultRewardItem, retDefaultRewardItem);
    
    return retDefaultRewardItem;
}

FREObject getCurrentRewardItemKey(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    NSLog(@"getCurrentRewardItemKey");
    const uint8_t* currentRewardItem = (const uint8_t*)[[[ApplifierImpact sharedInstance] getCurrentRewardItemKey] UTF8String];
    FREObject retCurrentRewardItem = nil;
    FRENewObjectFromUTF8(sizeof(currentRewardItem), currentRewardItem, retCurrentRewardItem);
    
    return retCurrentRewardItem;
}

FREObject setRewardItemKey(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    NSLog(@"setRewardItemKey");
    
    uint32_t rewardItemKeyLength;
    const uint8_t *rewardItemKeyCString;
    NSString *rewardItemKey = nil;
    
    uint32_t success = false;
    FREObject retBool = nil;
    
    if (FRE_OK == FREGetObjectAsUTF8(argv[0], &rewardItemKeyLength, &rewardItemKeyCString)) {
        rewardItemKey = [NSString stringWithUTF8String:(char*)rewardItemKeyCString];
        success = [[ApplifierImpact sharedInstance] setRewardItemKey:rewardItemKey];
        FRENewObjectFromBool(success, &retBool);
    }
    
    return retBool;
}

FREObject setDefaultRewardItemAsRewardItem(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	NSLog(@"setDefaultRewardItemAsRewardItem");
    [[ApplifierImpact sharedInstance] setDefaultRewardItemAsRewardItem];    
    return NULL;
}

FREObject getRewardItemDetailsWithKey(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    NSLog(@"getCurrentRewardItemKey");
    
    uint32_t rewardItemKeyLength;
    const uint8_t *rewardItemKeyCString;
    NSString *rewardItemKey = nil;
    NSDictionary *rewardItemDetails = nil;
    NSString *rewardItemDetailsString = @"";
    FREObject retDetails = nil;
    
    if (FRE_OK == FREGetObjectAsUTF8(argv[0], &rewardItemKeyLength, &rewardItemKeyCString)) {
        rewardItemKey = [NSString stringWithUTF8String:(char*)rewardItemKeyCString];
        rewardItemDetails = [[ApplifierImpact sharedInstance] getRewardItemDetailsWithKey:rewardItemKey];
        
        if (rewardItemDetails != NULL) {
            rewardItemDetailsString = [NSString stringWithFormat:@"%@;%@", [rewardItemDetails objectForKey:kApplifierImpactRewardItemNameKey], [rewardItemDetails objectForKey:kApplifierImpactRewardItemPictureKey]];
        }
        
    }
    
    const uint8_t* rewardItemDetailsCString = (const uint8_t*)[rewardItemDetailsString UTF8String];
    FRENewObjectFromUTF8(sizeof(rewardItemDetailsCString), rewardItemDetailsCString, retDetails);
    
    return retDetails;
}


/* Initializers and Finalizers */

void ApplifierImpactMobileContextInitializer (void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
	NSLog(@"ApplifierImpactMobileContextInitializer");
    applifierImpactFREContext = ctx;
    *numFunctionsToTest = 18;
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

    func[12].name = (const uint8_t*) "getRewardItemKeys";
    func[12].functionData = NULL;
    func[12].function = &getRewardItemKeys;

    func[13].name = (const uint8_t*) "getDefaultRewardItemKey";
    func[13].functionData = NULL;
    func[13].function = &getDefaultRewardItemKey;

    func[14].name = (const uint8_t*) "getCurrentRewardItemKey";
    func[14].functionData = NULL;
    func[14].function = &getCurrentRewardItemKey;

    func[15].name = (const uint8_t*) "setRewardItemKey";
    func[15].functionData = NULL;
    func[15].function = &setRewardItemKey;

    func[16].name = (const uint8_t*) "setDefaultRewardItemAsRewardItem";
    func[16].functionData = NULL;
    func[16].function = &setDefaultRewardItemAsRewardItem;
    
    func[17].name = (const uint8_t*) "getRewardItemDetailsWithKey";
    func[17].functionData = NULL;
    func[17].function = &getRewardItemDetailsWithKey;
    
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
