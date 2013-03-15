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
#import "ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "ApplifierImpactDevice/ApplifierImpactDevice.h"
#import "ApplifierImpactData/ApplifierImpactAnalyticsUploader.h"
#import "ApplifierImpactProperties/ApplifierImpactProperties.h"

@interface ApplifierImpactMainViewController ()
  @property (nonatomic, strong) ApplifierImpactVideoViewController *videoController;
  @property (nonatomic, strong) UIViewController *storeController;
  @property (nonatomic, strong) void (^closeHandler)(void);
  @property (nonatomic, strong) void (^openHandler)(void);
  @property (nonatomic, assign) BOOL isOpen;
@end

@implementation ApplifierImpactMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  
    if (self) {
      // Add notification listener
      NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
      [notificationCenter addObserver:self selector:@selector(notificationHandler:) name:UIApplicationDidEnterBackgroundNotification object:nil];
      
      // Start WebAppController
      [ApplifierImpactWebAppController sharedInstance];
      [[ApplifierImpactWebAppController sharedInstance] setDelegate:self];
    }
  
    return self;
}

- (void)dealloc {
	AILOG_DEBUG(@"");
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self _destroyVideoController];
}

- (void)viewDidLoad {
	AILOG_DEBUG(@"");
  [self.view setBackgroundColor:[UIColor blackColor]];
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}


#pragma mark - Orientation handling

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
  AILOG_DEBUG(@"");
  return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
  return YES;
}


#pragma mark - Public

- (BOOL)closeImpact:(BOOL)forceMainThread withAnimations:(BOOL)animated {
  AILOG_DEBUG(@"");
  
  if ([[ApplifierImpactProperties sharedInstance] currentViewController] == nil) return NO;
  
  if (forceMainThread) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _dismissMainViewController:forceMainThread withAnimations:animated];
    });
  }
  else {
    [self _dismissMainViewController:forceMainThread withAnimations:animated];
  }
  
  return YES;
}

- (void)_dismissMainViewController:(BOOL)forcedToMainThread withAnimations:(BOOL)animated {
  if (self.videoController.view.superview != nil) {
    [self dismissViewControllerAnimated:NO completion:nil];
  }
  
  if (!forcedToMainThread) {
    AILOG_DEBUG(@"Setting startview right now. No time for block completion");
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeStart data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIClose}];
  }
  
  [self.delegate mainControllerWillClose];
  
  if (![ApplifierImpactDevice isSimulator]) {
    if (self.closeHandler == nil) {
      __unsafe_unretained typeof(self) weakSelf = self;
      self.closeHandler = ^(void) {
        AILOG_DEBUG(@"Setting start view after close");
        [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeStart data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIClose}];
        
        if (weakSelf != NULL) {
          weakSelf.isOpen = NO;
          [weakSelf.delegate mainControllerDidClose];
        }
      };
    }
  }
  else {
    self.isOpen = NO;
    [self.delegate mainControllerDidClose];
  }
  
  [[[ApplifierImpactProperties sharedInstance] currentViewController] dismissViewControllerAnimated:animated completion:self.closeHandler];
}

- (BOOL)openImpact:(BOOL)animated inState:(ApplifierImpactViewState)state {
  AILOG_DEBUG(@"");
  
  if ([[ApplifierImpactProperties sharedInstance] currentViewController] == nil) return NO;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSString *openingViewForWebView = kApplifierImpactWebViewViewTypeStart;
    if (state == kApplifierImpactViewStateVideoPlayer)
      openingViewForWebView = kApplifierImpactWebViewViewTypeNone;
    
    [self.delegate mainControllerWillOpen];
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:openingViewForWebView data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIOpen, kApplifierImpactItemKeyKey:[[ApplifierImpactCampaignManager sharedInstance] getCurrentRewardItem].key}];
    
    if (![ApplifierImpactDevice isSimulator]) {
      if (self.openHandler == nil) {
        __unsafe_unretained typeof(self) weakSelf = self;
        self.openHandler = ^(void) {
          AILOG_DEBUG(@"Running openhandler after opening view");
          if (weakSelf != NULL)
            [weakSelf.delegate mainControllerDidOpen];
          
          if (state == kApplifierImpactViewStateVideoPlayer) {
            [[ApplifierImpactMainViewController sharedInstance] showPlayerAndPlaySelectedVideo:YES];
          }
        };
      }
    }
    else {
      [self.delegate mainControllerDidOpen];
    }
    
    [[[ApplifierImpactProperties sharedInstance] currentViewController] presentViewController:self animated:animated completion:self.openHandler];
    
    if (![[[[ApplifierImpactWebAppController sharedInstance] webView] superview] isEqual:self.view]) {
      [self.view addSubview:[[ApplifierImpactWebAppController sharedInstance] webView]];
      [[[ApplifierImpactWebAppController sharedInstance] webView] setFrame:self.view.bounds];
    }
    
    if (state == kApplifierImpactViewStateVideoPlayer && [ApplifierImpactDevice isSimulator]) {
      [self showPlayerAndPlaySelectedVideo:YES];
    }
  });
  
  self.isOpen = YES;
  return YES;
}

- (BOOL)mainControllerVisible {
  if (self.view.superview != nil || self.isOpen) {
    return YES;
  }
  
  return NO;
}


#pragma mark - Video

- (void)videoPlayerStartedPlaying {
  [self.delegate mainControllerStartedPlayingVideo];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIActionVideoStartedPlaying, kApplifierImpactItemKeyKey:[[ApplifierImpactCampaignManager sharedInstance] getCurrentRewardItem].key,
      kApplifierImpactWebViewEventDataCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  [self presentViewController:self.videoController animated:NO completion:nil];
}

- (void)videoPlayerEncounteredError {
  AILOG_DEBUG(@"");
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventVideoCompleted data:@{kApplifierImpactNativeEventCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id}];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowError data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyVideoPlaybackError}];
  [self _dismissVideoController];
}

- (void)videoPlayerPlaybackEnded {
  [self.delegate mainControllerVideoEnded];
  [self _dismissVideoController];
}

- (void)showPlayerAndPlaySelectedVideo:(BOOL)checkIfWatched {
	AILOG_DEBUG(@"");
    
  if ([[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed && checkIfWatched) {
    AILOG_DEBUG(@"Trying to watch a campaign that is already viewed!");
    return;
  }

  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyBuffering}];
  
  [self _createVideoController];
  [self.videoController playCampaign:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
}

- (void)_createVideoController {
  self.videoController = [[ApplifierImpactVideoViewController alloc] initWithNibName:nil bundle:nil];
  self.videoController.delegate = self;
}

- (void)_destroyVideoController {
  if (self.videoController != nil) {
    [self.videoController forceStopVideoPlayer];
    self.videoController.delegate = nil;
  }
  
  self.videoController = nil;
}

- (void)_dismissVideoController {
  if ([self.presentedViewController isEqual:self.videoController])
    [self dismissViewControllerAnimated:NO completion:nil];
  
  [self _destroyVideoController];
}


#pragma mark - Notification receiver

- (void)notificationHandler: (id) notification {
  NSString *name = [notification name];

  AILOG_DEBUG(@"Notification: %@", name);
  
  if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
    [[ApplifierImpactWebAppController sharedInstance] setWebViewInitialized:NO];
    [self.videoController forceStopVideoPlayer];
    
    if (self.isOpen)
      [self closeImpact:NO withAnimations:NO];
  }
}


#pragma mark - AppStore opening

- (BOOL)_canOpenStoreProductViewController {
	Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
	return [storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)];
}

- (void)openAppStoreWithData:(NSDictionary *)data {
	AILOG_DEBUG(@"");
	
  if (![self _canOpenStoreProductViewController] || [[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].bypassAppSheet == YES) {
		NSString *clickUrl = [data objectForKey:@"clickUrl"];
    if (clickUrl == nil) return;
    AILOG_DEBUG(@"Cannot open store product view controller, falling back to click URL.");
    [[ApplifierImpactAnalyticsUploader sharedInstance] sendOpenAppStoreRequest:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
    
    if (self.delegate != nil) {
      [self.delegate mainControllerWillLeaveApplication];
    }
    
		[[ApplifierImpactWebAppController sharedInstance] openExternalUrl:clickUrl];
		return;
	}
  
  Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
  if ([storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)] == YES) {
    if (![[data objectForKey:@"iTunesId"] isKindOfClass:[NSString class]]) return;
    NSString *gameId = nil;
    gameId = [data valueForKey:@"iTunesId"];
    if (gameId == nil || [gameId length] < 1) return;
    
    /*
      FIX: This _could_ bug someday. The key @"id" is written literally (and 
      not using SKStoreProductParameterITunesItemIdentifier), so that
      with some compiler options (or linker flags) you wouldn't get errors.
      
      The way this could bug someday is that Apple changes the contents of 
      SKStoreProductParameterITunesItemIdentifier.
     
      HOWTOFIX: Find a way to reflect global constant SKStoreProductParameterITunesItemIdentifier
      by using string value and not the constant itself.
    */
    NSDictionary *productParams = @{@"id":gameId};
    
    self.storeController = [[storeProductViewControllerClass alloc] init];
    
    if ([self.storeController respondsToSelector:@selector(setDelegate:)]) {
      [self.storeController performSelector:@selector(setDelegate:) withObject:self];
    }
    
    void (^storeControllerComplete)(BOOL result, NSError *error) = ^(BOOL result, NSError *error) {
      AILOG_DEBUG(@"RESULT: %i", result);
      if (result) {
        [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventHideSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyLoading}];
        dispatch_async(dispatch_get_main_queue(), ^{
          [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.storeController animated:YES completion:nil];
          [[ApplifierImpactAnalyticsUploader sharedInstance] sendOpenAppStoreRequest:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
        });
      }
      else {
        AILOG_DEBUG(@"Loading product information failed: %@", error);
      }
    };
    
    [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:kApplifierImpactNativeEventShowSpinner data:@{kApplifierImpactTextKeyKey:kApplifierImpactTextKeyLoading}];
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
  dispatch_async(dispatch_get_main_queue(), ^{
    [self checkForVersionAndShowAlertDialog];
    
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeNone data:@{kApplifierImpactWebViewAPIActionKey:kApplifierImpactWebViewAPIInitComplete, kApplifierImpactItemKeyKey:[[ApplifierImpactCampaignManager sharedInstance] getCurrentRewardItem].key}];
  });
}

- (void)checkForVersionAndShowAlertDialog {
  if ([[ApplifierImpactProperties sharedInstance] expectedSdkVersion] != nil && ![[[ApplifierImpactProperties sharedInstance] expectedSdkVersion] isEqualToString:[[ApplifierImpactProperties sharedInstance] impactVersion]]) {
    AILOG_DEBUG(@"Got different sdkVersions, checking further.");
    
    if (![ApplifierImpactDevice isEncrypted]) {
      if ([ApplifierImpactDevice isJailbroken]) {
        AILOG_DEBUG(@"Build is not encrypted, but device seems to be jailbroken. Not showing version alert");
        return;
      }
      else {
        // Build is not encrypted and device is not jailbroken, alert dialog is shown that SDK is not the latest version.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Applifier Impact SDK"
                                                        message:@"The Applifier Impact SDK you are running is not the current version, please update your SDK"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
      }
    }
  }
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

@end