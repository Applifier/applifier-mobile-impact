//
//  ApplifierImpactUnity3DWrapper.m
//  ApplifierImpactUnity
//
//  Created by Pekka Palmu on 3/8/13.
//  Copyright (c) 2013 Pekka Palmu. All rights reserved.
//

#import "ApplifierImpactUnity3DWrapper.h"
#import "AppController.h"

static ApplifierImpactUnity3DWrapper *applifierImpact = NULL;

void UnitySendMessage(const char* obj, const char* method, const char* msg);
void UnityPause(bool pause);

extern "C" {
    NSString* ImpactCreateNSString (const char* string) {
        return string ? [NSString stringWithUTF8String: string] : [NSString stringWithUTF8String: ""];
    }
    
    char* ImpactMakeStringCopy (const char* string) {
        if (string == NULL)
            return NULL;
        char* res = (char*)malloc(strlen(string) + 1);
        strcpy(res, string);
        return res;
    }
}

@interface ApplifierImpactUnity3DWrapper () <ApplifierImpactDelegate>
    @property (nonatomic, strong) NSString* gameObjectName;
    @property (nonatomic, strong) NSString* gameId;
@end

@implementation ApplifierImpactUnity3DWrapper

- (id)initWithGameId:(NSString*)gameId testModeOn:(bool)testMode debugModeOn:(bool)debugMode withGameObjectName:(NSString*)gameObjectName {
    self = [super init];
    
    if (self != nil) {
        self.gameObjectName = gameObjectName;
        self.gameId = gameId;
        NSLog(@"Game object name=%@, gameId=%@", self.gameObjectName, self.gameId);
        [[ApplifierImpact sharedInstance] setDelegate:self];
        [[ApplifierImpact sharedInstance] setDebugMode:YES];
        [[ApplifierImpact sharedInstance] setTestMode:YES];
        [[ApplifierImpact sharedInstance] startWithGameId:gameId andViewController:UnityGetGLViewController()];
    }
    
    return self;
}

- (void)applifierImpact:(ApplifierImpact *)applifierImpact completedVideoWithRewardItemKey:(NSString *)rewardItemKey {
    NSLog(@"applifierImpact");
    UnitySendMessage(ImpactMakeStringCopy([self.gameObjectName UTF8String]), "onVideoCompleted", [rewardItemKey UTF8String]);
}

- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactWillOpen");
}

- (void)applifierImpactDidOpen:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactDidOpen");
    UnitySendMessage(ImpactMakeStringCopy([self.gameObjectName UTF8String]), "onImpactOpen", "");
    UnityPause(true);
}

- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactWillClose");
}

- (void)applifierImpactDidClose:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactDidClose");
    UnityPause(false);
    UnitySendMessage(ImpactMakeStringCopy([self.gameObjectName UTF8String]), "onImpactClose", "");
}

- (void)applifierImpactWillLeaveApplication:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactWillLeaveApplication");
}

- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactVideoStarted");
    UnitySendMessage(ImpactMakeStringCopy([self.gameObjectName UTF8String]), "onVideoStarted", "");
}

- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactCampaignsAreAvailable");
    UnitySendMessage(ImpactMakeStringCopy([self.gameObjectName UTF8String]), "onCampaignsAvailable", "");
}

- (void)applifierImpactCampaignsFetchFailed:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactCampaignsFetchFailed");
    UnitySendMessage(ImpactMakeStringCopy([self.gameObjectName UTF8String]), "onCampaignsFetchFailed", "");
}


extern "C" {
    void init (const char *gameId, bool testMode, bool debugMode, const char *gameObjectName) {
        NSLog(@"init");
        if (applifierImpact == NULL) {
            applifierImpact = [[ApplifierImpactUnity3DWrapper alloc] initWithGameId:ImpactCreateNSString(gameId) testModeOn:testMode debugModeOn:debugMode withGameObjectName:ImpactCreateNSString(gameObjectName)];
            NSLog(@"gameId=%@, gameObjectName=%@", ImpactCreateNSString(gameId), ImpactCreateNSString(gameObjectName));
        }
    }
    
	bool showImpact (bool openAnimated, bool noOfferscreen, const char *gamerSID) {
        NSLog(@"showImpact");
        NSNumber *noOfferscreenObjectiveC = [NSNumber numberWithBool:noOfferscreen];
        NSNumber *openAnimatedObjectiveC = [NSNumber numberWithBool:openAnimated];
        
        if ([[ApplifierImpact sharedInstance] canShowAds] && [[ApplifierImpact sharedInstance] canShowImpact]) {
            NSDictionary *props = @{kApplifierImpactOptionGamerSIDKey: ImpactCreateNSString(gamerSID), kApplifierImpactOptionNoOfferscreenKey: noOfferscreenObjectiveC, kApplifierImpactOptionOpenAnimatedKey: openAnimatedObjectiveC};
            return [[ApplifierImpact sharedInstance] showImpact:props];
        }
        
        return false;
    }
	
	void hideImpact () {
        NSLog(@"showImpact");
        [[ApplifierImpact sharedInstance] hideImpact];
    }
	
	bool isSupported () {
        NSLog(@"isSupported");
        return [ApplifierImpact isSupported];
    }
	
	const char* getSDKVersion () {
        NSLog(@"getSDKVersion");
        return ImpactMakeStringCopy([[ApplifierImpact getSDKVersion] UTF8String]);
    }
    
	bool canShowCampaigns () {
        NSLog(@"canShowCampaigns");
        return [[ApplifierImpact sharedInstance] canShowAds];
    }
    
	bool canShowImpact () {
        NSLog(@"canShowImpact");
        return [[ApplifierImpact sharedInstance] canShowImpact];
    }
	
	void stopAll () {
        NSLog(@"stopAll");
        [[ApplifierImpact sharedInstance] stopAll];
    }
    
	bool hasMultipleRewardItems () {
        NSLog(@"hasMultipleRewardItems");
        return [[ApplifierImpact sharedInstance] hasMultipleRewardItems];
    }
	
	const char* getRewardItemKeys () {
        NSLog(@"getRewardItemKeys");
        NSArray *keys = [[ApplifierImpact sharedInstance] getRewardItemKeys];
        NSString *keyString = @"";
        
        for (NSString *key in keys) {
            if ([keyString length] <= 0) {
                keyString = [NSString stringWithFormat:@"%@", key];
            }
            else {
                keyString = [NSString stringWithFormat:@"%@;%@", keyString, key];
            }
        }
        
        return ImpactMakeStringCopy([keyString UTF8String]);
    }
    
	const char* getDefaultRewardItemKey () {
        NSLog(@"getDefaultRewardItemKey");
        return ImpactMakeStringCopy([[[ApplifierImpact sharedInstance] getDefaultRewardItemKey] UTF8String]);
    }
	 
	const char* getCurrentRewardItemKey () {
        NSLog(@"getCurrentRewardItemKey");
        return ImpactMakeStringCopy([[[ApplifierImpact sharedInstance] getCurrentRewardItemKey] UTF8String]);
    }
    
	bool setRewardItemKey (const char *rewardItemKey) {
        NSLog(@"setRewardItemKey");
        return [[ApplifierImpact sharedInstance] setRewardItemKey:ImpactCreateNSString(rewardItemKey)];
    }
	
	void setDefaultRewardItemAsRewardItem () {
        NSLog(@"setDefaultRewardItemAsRewardItem");
        [[ApplifierImpact sharedInstance] setDefaultRewardItemAsRewardItem];
    }
    
	const char* getRewardItemDetailsWithKey (const char *rewardItemKey) {
        NSLog(@"getRewardItemDetailsWithKey");
        if (rewardItemKey != NULL) {
            NSDictionary *details = [[ApplifierImpact sharedInstance] getRewardItemDetailsWithKey:ImpactCreateNSString(rewardItemKey)];
            return ImpactMakeStringCopy([[NSString stringWithFormat:@"%@;%@", [details objectForKey:kApplifierImpactRewardItemNameKey], [details objectForKey:kApplifierImpactRewardItemPictureKey]] UTF8String]);
        }
        
        return ImpactMakeStringCopy("");
    }
    
    const char *getRewardItemDetailsKeys () {
        return ImpactMakeStringCopy([[NSString stringWithFormat:@"%@;%@", kApplifierImpactRewardItemNameKey, kApplifierImpactRewardItemPictureKey] UTF8String]);
    }
}

@end