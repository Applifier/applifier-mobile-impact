//
//  ApplifierImpactUnity3DWrapper.m
//  ApplifierImpactUnity
//
//  Created by Pekka Palmu on 3/8/13.
//  Copyright (c) 2013 Pekka Palmu. All rights reserved.
//

#import "ApplifierImpactUnity3DWrapper.h"

@implementation ApplifierImpactUnity3DWrapper
- (BOOL)initWithGameId:(const char *)gameId andWithGameObjectName:(const char *)gameObjectName {
}
@end

static ApplifierImpactUnity3DWrapper *applifierImpact = NULL;

extern "C" {
    void init (const char *gameObjectName, const char *gameId) {
        if (applifierImpact == NULL) {
            applifierImpact = [[ApplifierImpactUnity3DWrapper alloc] initWithGameId:gameId andWithGameObjectName:gameObjectName];
            [applifierImpact setGameObjectName:gameObjectName];
        }
    }
    
	bool showImpact (bool openAnimated, bool noOfferscreen, string gamerSID) {
        
    }
	
	void hideImpact () {
        
    }
	
	bool isSupported () {
        
    }
	
	char* getSDKVersion () {
        
    }
    
	bool canShowCampaigns () {
        
    }
    
	bool canShowImpact () {
        
    }
	
	void stopAll () {
        
    }
    
	bool hasMultipleRewardItems () {
        
    }
	
	char* getRewardItemKeys () {
        
    }
    
	char* getDefaultRewardItemKey () {
        
    }
	
	char* getCurrentRewardItemKey () {
        
    }
    
	bool setRewardItemKey (const char * rewardItemKey) {
        
    }
	
	void setDefaultRewardItemAsRewardItem () {
        
    }
    
	char* getRewardItemDetailsWithKey (string rewardItemKey) {
        
    }
}