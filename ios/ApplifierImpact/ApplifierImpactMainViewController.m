//
//  ApplifierImpactAdViewController.m
//  ApplifierImpact
//
//  Created by bluesun on 11/21/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactMainViewController.h"
#import "ApplifierImpact.h"

#import "ApplifierImpactVideo/ApplifierImpactVideoView.h"
#import "ApplifierImpactWebView/ApplifierImpactWebAppController.h"
#import "ApplifierImpactVideo/ApplifierImpactVideo.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "ApplifierImpactProperties/ApplifierImpactProperties.h"

@interface ApplifierImpactMainViewController ()
  @property (nonatomic, strong) UILabel *progressLabel;
  @property (nonatomic, strong) ApplifierImpactVideoView *videoView;
  @property (nonatomic, strong) ApplifierImpactVideo *player;
  @property (nonatomic, strong) UIViewController *storeController;
@end

@implementation ApplifierImpactMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      // Add notification listener
      NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
      [notificationCenter addObserver:self selector:@selector(notificationHandler:) name:UIApplicationDidEnterBackgroundNotification object:nil];
      
      // "init" WebAppController
      [ApplifierImpactWebAppController sharedInstance];
      [[ApplifierImpactWebAppController sharedInstance] setDelegate:self];
    }
    return self;
}

- (void)dealloc {
	AILOG_DEBUG(@"");
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
	AILOG_DEBUG(@"");
  [super viewDidLoad];
  [self _createProgressLabel];
  [self _createVideoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (NSUInteger)supportedInterfaceOrientations {
  AILOG_DEBUG(@"");
  return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Public

- (BOOL)closeImpact {
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:@"start" data:@{}];
  [[[ApplifierImpactProperties sharedInstance] currentViewController] dismissViewControllerAnimated:NO completion:nil];
  return YES;
}

- (BOOL)openImpact {
  AILOG_DEBUG(@"");
  [[[ApplifierImpactProperties sharedInstance] currentViewController] presentViewController:self animated:NO completion:nil];
  
  if (![self.videoView.superview isEqual:self.view]) {
    [self.view addSubview:self.videoView];
    [self.videoView setFrame:self.view.bounds];
    self.videoView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  }
  
  if (![self.progressLabel.superview isEqual:self.view]) {
    [self.view addSubview:self.progressLabel];
    [self.progressLabel setFrame:self.view.bounds];
  }
  
  if (![[[[ApplifierImpactWebAppController sharedInstance] webView] superview] isEqual:self.view]) {
    [self.view addSubview:[[ApplifierImpactWebAppController sharedInstance] webView]];
    [[[ApplifierImpactWebAppController sharedInstance] webView] setFrame:self.view.bounds];
  }
  
  return YES;
}

- (BOOL)mainControllerVisible {
  if (self.view.superview != nil) {
    return YES;
  }
  
  return NO;
}


#pragma mark - Video

- (void)showPlayerAndPlaySelectedVideo:(BOOL)checkIfWatched {
	AILOG_DEBUG(@"");
  
  if ([[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed && checkIfWatched) {
    AILOG_DEBUG(@"Trying to watch a campaign that is already viewed!");
    return;
  }
  
	NSURL *videoURL = [[ApplifierImpactCampaignManager sharedInstance] getVideoURLForCampaign:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
  
	if (videoURL == nil) {
		AILOG_DEBUG(@"Video not found!");
		return;
	}
  
	AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoURL];

  if (self.player == nil) {
    self.player = [[ApplifierImpactVideo alloc] initWithPlayerItem:item];
    self.player.delegate = self;
    [_videoView setPlayer:self.player];
  }
  else {
    [self.player replaceCurrentItemWithPlayerItem:item];
  }
  
  [self.view bringSubviewToFront:self.videoView];
  [self.player playSelectedVideo];
}

- (void)hidePlayer {
  if (self.player != nil) {
    self.progressLabel.hidden = YES;
    [self.view sendSubviewToBack:self.videoView];
  }
}

- (Float64)_currentVideoDuration {
	CMTime durationTime = self.player.currentItem.asset.duration;
	Float64 duration = CMTimeGetSeconds(durationTime);
	
	return duration;
}

- (NSValue *)_valueWithDuration:(Float64)duration {
	CMTime time = CMTimeMakeWithSeconds(duration, NSEC_PER_SEC);
	return [NSValue valueWithCMTime:time];
}


#pragma mark - ApplifierImpactVideoDelegate

- (void)videoPositionChanged:(CMTime)time {
  [self _updateTimeRemainingLabelWithTime:time];
}

- (void)videoPlaybackStarted {
  [self _displayProgressLabel];
  [self.delegate mainControllerStartedPlayingVideo];
  [[ApplifierImpactWebAppController sharedInstance] webView].userInteractionEnabled = NO;
}

- (void)videoPlaybackEnded {
  [[ApplifierImpactWebAppController sharedInstance] webView].userInteractionEnabled = YES;
  [self.delegate mainControllerVideoEnded];
	[self hidePlayer];
	
  NSDictionary *data = @{@"campaignId":[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id};
  
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:data];
	[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed = YES;
}


#pragma mark - Video Progress Label

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


#pragma mark - Notification receiver

- (void)notificationHandler: (id) notification {
  NSString *name = [notification name];

  AILOG_DEBUG(@"notification: %@", name);
  
  if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
    [[ApplifierImpactWebAppController sharedInstance] webView].userInteractionEnabled = YES;
    if (self.player != nil) {
      AILOG_DEBUG(@"Destroying player");
      [self.player destroyPlayer];
      [self hidePlayer];
    }
    
    [self closeImpact];
  }
}


#pragma mark - AppStore opening

- (BOOL)_canOpenStoreProductViewController {
	Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
	return [storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)];
}

- (void)openAppStoreWithData:(NSDictionary *)data {
	AILOG_DEBUG(@"");
	
  if (![self _canOpenStoreProductViewController]) {
		NSString *clickUrl = [data objectForKey:@"clickUrl"];
    if (clickUrl == nil) return;
    AILOG_DEBUG(@"Cannot open store product view controller, falling back to click URL.");
		[[ApplifierImpactWebAppController sharedInstance] openExternalUrl:clickUrl];
		return;
	}
  
  Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
  if ([storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)] == YES) {
    NSString *gameId = [data objectForKey:@"iTunesId"];
    if (gameId == nil || [gameId length] < 1) return;
    NSDictionary *productParams = @{SKStoreProductParameterITunesItemIdentifier:gameId};
    self.storeController = [[storeProductViewControllerClass alloc] init];
    
    if ([self.storeController respondsToSelector:@selector(setDelegate:)]) {
      [self.storeController performSelector:@selector(setDelegate:) withObject:self];
    }
    
    void (^storeControllerComplete)(BOOL result, NSError *error) = ^(BOOL result, NSError *error) {
      AILOG_DEBUG(@"RESULT: %i", result);
      if (result) {
        [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:@"hideSpinner" data:@{@"campaignId":[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
        [[ApplifierImpactMainViewController sharedInstance] presentModalViewController:self.storeController animated:YES];
      }
      else {
        AILOG_DEBUG(@"Loading product information failed: %@", error);
      }
    };
    
    [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:@"showSpinner" data:@{@"campaignId":[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
    SEL loadProduct = @selector(loadProductWithParameters:completionBlock:);
    if ([self.storeController respondsToSelector:loadProduct]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      [self.storeController performSelector:loadProduct withObject:productParams withObject:storeControllerComplete];
#pragma clang diagnostic pop
    }
  }
}


#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
	AILOG_DEBUG(@"");
  [[ApplifierImpactMainViewController sharedInstance] dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - WebAppController

- (void)webAppReady {
  [self.delegate mainControllerWebViewInitialized];
}


#pragma mark - Shared Instance

static ApplifierImpactMainViewController *sharedImpactMainViewController = nil;

+ (id)sharedInstance {
	@synchronized(self) {
		if (sharedImpactMainViewController == nil) {
      sharedImpactMainViewController = [[ApplifierImpactMainViewController alloc] initWithNibName:nil bundle:nil];
		}
	}
	
	return sharedImpactMainViewController;
}


#pragma mark - Private view creations

- (void)_createProgressLabel {
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

- (void)_createVideoView {
  self.videoView = [[ApplifierImpactVideoView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

@end