//
//  ApplifierImpactUnity3DWrapper.m
//  ApplifierImpactUnity
//
//  Created by Pekka Palmu on 3/8/13.
//  Copyright (c) 2013 Pekka Palmu. All rights reserved.
//

#import "ApplifierImpactUnity3DWrapper.h"
#if UNITY_VERSION >= 420
#import "UnityAppController.h"
#else
#import "AppController.h"
#endif

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
        
        [[ApplifierImpact sharedInstance] setDelegate:self];
        [[ApplifierImpact sharedInstance] setDebugMode:debugMode];
        [[ApplifierImpact sharedInstance] setTestMode:testMode];        
        [[ApplifierImpact sharedInstance] startWithGameId:gameId andViewController:UnityGetGLViewController()];
    }
    
    return self;
}

- (void)applifierImpact:(ApplifierImpact *)applifierImpact completedVideoWithRewardItemKey:(NSString *)rewardItemKey videoWasSkipped:(BOOL)skipped {
    NSString *parameters = [NSString stringWithFormat:@"%@;%@", rewardItemKey, skipped ? @"true" : @"false"];
    UnitySendMessage(ImpactMakeStringCopy([self.gameObjectName UTF8String]), "onVideoCompleted", [parameters UTF8String]);
}

- (void)applifierImpactWillOpen:(ApplifierImpact *)applifierImpact {
}

- (void)applifierImpactDidOpen:(ApplifierImpact *)applifierImpact {
    UnitySendMessage(ImpactMakeStringCopy([self.gameObjectName UTF8String]), "onImpactOpen", "");
    UnityPause(true);
}

- (void)applifierImpactWillClose:(ApplifierImpact *)applifierImpact {
}

- (void)applifierImpactDidClose:(ApplifierImpact *)applifierImpact {
    UnityPause(false);
    UnitySendMessage(ImpactMakeStringCopy([self.gameObjectName UTF8String]), "onImpactClose", "");
}

- (void)applifierImpactWillLeaveApplication:(ApplifierImpact *)applifierImpact {
}

- (void)applifierImpactVideoStarted:(ApplifierImpact *)applifierImpact {
    UnitySendMessage(ImpactMakeStringCopy([self.gameObjectName UTF8String]), "onVideoStarted", "");
}

- (void)applifierImpactCampaignsAreAvailable:(ApplifierImpact *)applifierImpact {
    UnitySendMessage(ImpactMakeStringCopy([self.gameObjectName UTF8String]), "onCampaignsAvailable", "");
}

- (void)applifierImpactCampaignsFetchFailed:(ApplifierImpact *)applifierImpact {
    UnitySendMessage(ImpactMakeStringCopy([self.gameObjectName UTF8String]), "onCampaignsFetchFailed", "");
}


extern "C" {
    void init (const char *gameId, bool testMode, bool debugMode, const char *gameObjectName) {
        if (applifierImpact == NULL) {
            applifierImpact = [[ApplifierImpactUnity3DWrapper alloc] initWithGameId:ImpactCreateNSString(gameId) testModeOn:testMode debugModeOn:debugMode withGameObjectName:ImpactCreateNSString(gameObjectName)];
        }
    }
    
	bool showImpact (const char * rawZoneId, const char * rawRewardItemKey, const char * rawOptionsString) {
        NSString * zoneId = ImpactCreateNSString(rawZoneId);
        NSString * rewardItemKey = ImpactCreateNSString(rawRewardItemKey);
        NSString * optionsString = ImpactCreateNSString(rawOptionsString);
        
        NSMutableDictionary *optionsDictionary = nil;
        if([optionsString length] > 0) {
            optionsDictionary = [[NSMutableDictionary alloc] init];
            [[optionsString componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(id rawOptionPair, NSUInteger idx, BOOL *stop) {
                NSArray *optionPair = [rawOptionPair componentsSeparatedByString:@":"];
                [optionsDictionary setValue:optionPair[1] forKey:optionPair[0]];
            }];
        }

        if ([[ApplifierImpact sharedInstance] canShowCampaigns] && [[ApplifierImpact sharedInstance] canShowImpact]) {
            
            if([rewardItemKey length] > 0) {
                [[ApplifierImpact sharedInstance] setZone:zoneId withRewardItem:rewardItemKey];
            } else {
                [[ApplifierImpact sharedInstance] setZone:zoneId];
            }
            
            return [[ApplifierImpact sharedInstance] showImpact:optionsDictionary];
        }
        
        return false;
    }
	
	void hideImpact () {
        [[ApplifierImpact sharedInstance] hideImpact];
    }
	
	bool isSupported () {
        return [ApplifierImpact isSupported];
    }
	
	const char* getSDKVersion () {
        return ImpactMakeStringCopy([[ApplifierImpact getSDKVersion] UTF8String]);
    }
    
	bool canShowCampaigns () {
        return [[ApplifierImpact sharedInstance] canShowCampaigns];
    }
    
	bool canShowImpact () {
        return [[ApplifierImpact sharedInstance] canShowImpact];
    }
	
	void stopAll () {
        [[ApplifierImpact sharedInstance] stopAll];
    }
    
	bool hasMultipleRewardItems () {
        return [[ApplifierImpact sharedInstance] hasMultipleRewardItems];
    }
	
	const char* getRewardItemKeys () {
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
        return ImpactMakeStringCopy([[[ApplifierImpact sharedInstance] getDefaultRewardItemKey] UTF8String]);
    }
	 
	const char* getCurrentRewardItemKey () {
        return ImpactMakeStringCopy([[[ApplifierImpact sharedInstance] getCurrentRewardItemKey] UTF8String]);
    }
    
	bool setRewardItemKey (const char *rewardItemKey) {
        return [[ApplifierImpact sharedInstance] setRewardItemKey:ImpactCreateNSString(rewardItemKey)];
    }
	
	void setDefaultRewardItemAsRewardItem () {
        [[ApplifierImpact sharedInstance] setDefaultRewardItemAsRewardItem];
    }
    
	const char* getRewardItemDetailsWithKey (const char *rewardItemKey) {
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