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
    UnitySendMessage([self.gameObjectName UTF8String], "onVideoCompleted", [rewardItemKey UTF8String]);
}

- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactWillOpen");
}

- (void)applifierImpactDidOpen:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactDidOpen");
    UnitySendMessage([self.gameObjectName UTF8String], "onImpactOpen", "");
    UnityPause(true);
}

- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactWillClose");
}

- (void)applifierImpactDidClose:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactDidClose");
    UnityPause(false);
    UnitySendMessage([self.gameObjectName UTF8String], "onImpactClose", "");
}

- (void)applifierImpactWillLeaveApplication:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactWillLeaveApplication");
}

- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactVideoStarted");
    UnitySendMessage([self.gameObjectName UTF8String], "onVideoStarted", "");
}

- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactCampaignsAreAvailable");
    UnitySendMessage([self.gameObjectName UTF8String], "onCampaignsAvailable", "");
}

- (void)applifierImpactCampaignsFetchFailed:(ApplifierImpact *)applifierImpact {
    NSLog(@"applifierImpactCampaignsFetchFailed");
    UnitySendMessage([self.gameObjectName UTF8String], "onCampaignsFetchFailed", "");
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
        return false;
    }
	
	void hideImpact () {
        NSLog(@"showImpact");
    }
	
	bool isSupported () {
        NSLog(@"hideImpact");
        return false;
    }
	
	char* getSDKVersion () {
        NSLog(@"getSDKVersion");
        return "moi";
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
    }
    
	bool hasMultipleRewardItems () {
        NSLog(@"hasMultipleRewardItems");
        return false;
    }
	
	char* getRewardItemKeys () {
        NSLog(@"getRewardItemKeys");
        return "moi,moi,moi";
    }
    
	char* getDefaultRewardItemKey () {
        NSLog(@"getDefaultRewardItemKey");
        return "ship";
    }
	
	char* getCurrentRewardItemKey () {
        NSLog(@"getCurrentRewardItemKey");
        return "ship";
    }
    
	bool setRewardItemKey (const char *rewardItemKey) {
        NSLog(@"setRewardItemKey");
        return false;
    }
	
	void setDefaultRewardItemAsRewardItem () {
        NSLog(@"setDefaultRewardItemAsRewardItem");
    }
    
	char* getRewardItemDetailsWithKey (const char *rewardItemKey) {
        NSLog(@"getRewardItemDetailsWithKey");
        return "moi,moi,moi";
    }
}

@end

