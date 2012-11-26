//
//  ApplifierImpactVideoViewController.m
//  ApplifierImpact
//
//  Created by bluesun on 11/26/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "../ApplifierImpact.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"

#import "ApplifierImpactVideoViewController.h"
#import "ApplifierImpactVideoPlayer.h"
#import "ApplifierImpactVideoView.h"

@interface ApplifierImpactVideoViewController ()
  @property (nonatomic, strong) ApplifierImpactVideoView *videoView;
  @property (nonatomic, strong) ApplifierImpactVideoPlayer *videoPlayer;
  @property (nonatomic, assign) ApplifierImpactCampaign *campaignToPlay;
  @property (nonatomic, strong) UILabel *progressLabel;
  @property (nonatomic, assign) dispatch_queue_t videoControllerQueue;
  @property (nonatomic, strong) NSURL *currentPlayingVideoUrl;
@end

@implementation ApplifierImpactVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.videoControllerQueue = dispatch_queue_create("com.applifier.impact.videocontroller", NULL);
    }
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self _attachVideoView];
}

- (void)dealloc {
  dispatch_release(self.videoControllerQueue);
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.videoView setFrame:self.view.bounds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (NSUInteger)supportedInterfaceOrientations {
  AILOG_DEBUG(@"");
  return UIInterfaceOrientationMaskLandscape;
}


#pragma mark - Public

- (void)playCampaign:(ApplifierImpactCampaign *)campaignToPlay {
  AILOG_DEBUG(@"");
  NSURL *videoURL = [[ApplifierImpactCampaignManager sharedInstance] getVideoURLForCampaign:campaignToPlay];
  
	if (videoURL == nil) {
		AILOG_DEBUG(@"Video not found!");
		return;
	}
  
  self.currentPlayingVideoUrl = videoURL;
  
  dispatch_async(self.videoControllerQueue, ^{
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.currentPlayingVideoUrl];
    [self _createVideoView];
    [self _createVideoPlayer];
    [self _attachVideoPlayer];
    [self.videoPlayer preparePlayer];
    [self.videoPlayer replaceCurrentItemWithPlayerItem:item];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoPlayer playSelectedVideo];
    });
  });
}


#pragma mark - Video View

- (void)_createVideoView {
  if (self.videoView == nil) {
    self.videoView = [[ApplifierImpactVideoView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  }
}

- (void)_attachVideoView {
  if (self.videoView != nil && ![self.videoView.superview isEqual:self.view]) {
    [self.view addSubview:self.videoView];
  }
}

- (void)_detachVideoView {
  if (self.videoView != nil && self.videoView.superview != nil) {
    [self.videoView removeFromSuperview];
  }
}


#pragma mark - Video player

- (void)forceStopVideoPlayer {
  [self _destroyVideoPlayer];
}

- (void)_createVideoPlayer {
  if (self.videoPlayer == nil) {
    self.videoPlayer = [[ApplifierImpactVideoPlayer alloc] initWithPlayerItem:nil];
    self.videoPlayer.delegate = self;
  }
}

- (void)_attachVideoPlayer {
  if (self.videoView != nil) {
    [self.videoView setPlayer:self.videoPlayer];
  }
}

- (void)_destroyVideoPlayer {
  if (self.videoPlayer != nil) {
    self.currentPlayingVideoUrl = nil;
    [self.videoPlayer clearPlayer];
    self.videoPlayer.delegate = nil;
    self.videoPlayer = nil;
  }
}

- (void)_detachVideoPlayer {
  [self.videoView setPlayer:nil];
}

- (void)videoPositionChanged:(CMTime)time {
  [self _updateTimeRemainingLabelWithTime:time];
}

- (void)videoPlaybackStarted {
  AILOG_DEBUG(@"");
}

- (void)videoStartedPlaying {
  AILOG_DEBUG(@"");
  [self.delegate videoPlayerStartedPlaying];
}

- (void)videoPlaybackEnded {
  AILOG_DEBUG(@"");
  self.campaignToPlay.viewed = YES;
  [self.delegate videoPlayerPlaybackEnded];
  [self _detachVideoPlayer];
  [self _destroyVideoPlayer];
}


#pragma mark - Video Progress Label

- (void)_createProgressLabel {
  if (self.progressLabel == nil) {
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.progressLabel.backgroundColor = [UIColor clearColor];
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.font = [UIFont systemFontOfSize:12.0];
    self.progressLabel.textAlignment = UITextAlignmentRight;
    self.progressLabel.shadowColor = [UIColor blackColor];
    self.progressLabel.shadowOffset = CGSizeMake(0, 1.0);
    self.progressLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.progressLabel];
  }
}

- (void)_updateTimeRemainingLabelWithTime:(CMTime)currentTime {
	Float64 duration = [self _currentVideoDuration];
	Float64 current = CMTimeGetSeconds(currentTime);
	NSString *descriptionText = [NSString stringWithFormat:NSLocalizedString(@"This video ends in %.0f seconds.", nil), duration - current];
	self.progressLabel.text = descriptionText;
}

- (void)_displayProgressLabel {
	CGFloat padding = 10.0;
	CGFloat height = 30.0;
	CGRect labelFrame = CGRectMake(padding, self.view.frame.size.height - height, self.view.frame.size.width - (padding * 2.0), height);
	self.progressLabel.frame = labelFrame;
	self.progressLabel.hidden = NO;
	[self.view bringSubviewToFront:self.progressLabel];
}

- (Float64)_currentVideoDuration {
	CMTime durationTime = self.videoPlayer.currentItem.asset.duration;
	Float64 duration = CMTimeGetSeconds(durationTime);
	
	return duration;
}

- (NSValue *)_valueWithDuration:(Float64)duration {
	CMTime time = CMTimeMakeWithSeconds(duration, NSEC_PER_SEC);
	return [NSValue valueWithCMTime:time];
}

@end
