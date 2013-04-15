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
  @property (nonatomic, strong) UIView *progressView;
  @property (nonatomic, assign) dispatch_queue_t videoControllerQueue;
  @property (nonatomic, strong) NSURL *currentPlayingVideoUrl;
@end

@implementation ApplifierImpactVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.videoControllerQueue = dispatch_queue_create("com.applifier.impact.videocontroller", NULL);
      self.isPlaying = NO;
    }
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.view setBackgroundColor:[UIColor blackColor]];
  
  if (self.delegate != nil) {
    [self.delegate videoPlayerReady];
  }
  
  [self _attachVideoView];
}

- (void)dealloc {
  dispatch_release(self.videoControllerQueue);
}

- (void)viewDidDisappear:(BOOL)animated {
  [self _detachVideoPlayer];
  [self _detachVideoView];
  [self _destroyVideoPlayer];
  [self _destroyVideoView];
  [self _destroyProgressLabel];
  
  [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self _makeOrientation];
  [self _createProgressLabel];
  [self.view bringSubviewToFront:self.progressView];
}

- (void)_makeOrientation {
  if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
    double maxValue = fmax(self.view.superview.bounds.size.width, self.view.superview.bounds.size.height);
    double minValue = fmin(self.view.superview.bounds.size.width, self.view.superview.bounds.size.height);
    self.view.bounds = CGRectMake(0, 0, maxValue, minValue);
    self.view.transform = CGAffineTransformMakeRotation(M_PI / 2);
    AILOG_DEBUG(@"NEW DIMENSIONS: %f, %f", minValue, maxValue);
  }
  
  if (self.videoView != nil) {
    [self.videoView setFrame:self.view.bounds];
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
  return NO;
}


#pragma mark - Public

- (void)playCampaign:(ApplifierImpactCampaign *)campaignToPlay {
  AILOG_DEBUG(@"");
  NSURL *videoURL = [[ApplifierImpactCampaignManager sharedInstance] getVideoURLForCampaign:campaignToPlay];
  
	if (videoURL == nil) {
		AILOG_DEBUG(@"Video not found!");
		return;
	}
  
  self.campaignToPlay = campaignToPlay;
  self.currentPlayingVideoUrl = videoURL;
  //__block AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.currentPlayingVideoUrl];
  AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.currentPlayingVideoUrl];
  
  [self _createVideoView];
  [self _createVideoPlayer];
  [self _attachVideoPlayer];
  [self.videoPlayer preparePlayer];
  
  dispatch_async(self.videoControllerQueue, ^{
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

- (void)_destroyVideoView {
  if (self.videoView != nil) {
    [self _detachVideoView];
    self.videoView = nil;
  }
}


#pragma mark - Video player

- (void)forceStopVideoPlayer {
  AILOG_DEBUG(@"");
  // FIX: Wrong order?
  [self _detachVideoPlayer];
  [self _destroyVideoPlayer];
}

- (void)_createVideoPlayer {
  if (self.videoPlayer == nil) {
    AILOG_DEBUG(@"");
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
    AILOG_DEBUG(@"");
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
  self.isPlaying = YES;
  [self.delegate videoPlayerStartedPlaying];
}

- (void)videoPlaybackEnded {
  AILOG_DEBUG(@"");
  //self.campaignToPlay.viewed = YES;
  [self.delegate videoPlayerPlaybackEnded];
  self.isPlaying = NO;
  self.campaignToPlay = nil;
}

- (void)videoPlaybackError {
  AILOG_DEBUG(@"");
  [self.delegate videoPlayerEncounteredError];
  self.isPlaying = NO;
}


#pragma mark - Video Progress Label

- (void)_createProgressLabel {
  AILOG_DEBUG(@"");

  if (self.progressView == nil) {
    self.progressView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.progressView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];
  }
  
  if (self.progressLabel == nil) {
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
    self.progressLabel.backgroundColor = [UIColor clearColor];
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.font = [UIFont systemFontOfSize:12.0];
    self.progressLabel.textAlignment = UITextAlignmentRight;
    self.progressLabel.shadowColor = [UIColor blackColor];
    self.progressLabel.shadowOffset = CGSizeMake(0, 1.0);
    [self.progressView addSubview:self.progressLabel];
    self.progressLabel.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width - 303, self.view.bounds.size.height - 23);
    [self.progressView bringSubviewToFront:self.progressLabel];
    self.progressLabel.hidden = NO;
    self.progressView.hidden = NO;
  }
}

- (void)_destroyProgressLabel {
  if (self.progressLabel != nil) {
    [self.progressLabel removeFromSuperview];
    self.progressLabel = nil;
  }
  if (self.progressView != nil) {
    [self.progressView removeFromSuperview];
    self.progressView = nil;
  }
}

- (void)_updateTimeRemainingLabelWithTime:(CMTime)currentTime {
	Float64 duration = [self _currentVideoDuration];
	Float64 current = CMTimeGetSeconds(currentTime);
	NSString *descriptionText = [NSString stringWithFormat:NSLocalizedString(@"This video ends in %.0f seconds.", nil), duration - current];
	self.progressLabel.text = descriptionText;
}

- (void)_displayProgressLabel {
	self.progressLabel.hidden = NO;
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