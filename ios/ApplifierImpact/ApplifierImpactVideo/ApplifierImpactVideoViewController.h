//
//  ApplifierImpactVideoViewController.h
//  ApplifierImpact
//
//  Created by bluesun on 11/26/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplifierImpactVideoPlayer.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"

@protocol ApplifierImpactVideoControllerDelegate <NSObject>

@required
- (void)videoPlayerStartedPlaying;
- (void)videoPlayerPlaybackEnded;
@end

@interface ApplifierImpactVideoViewController : UIViewController <ApplifierImpactVideoPlayerDelegate>
@property (nonatomic, assign) id<ApplifierImpactVideoControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isPlaying;
- (void)playCampaign:(ApplifierImpactCampaign *)campaignToPlay;
- (void)forceStopVideoPlayer;
@end
