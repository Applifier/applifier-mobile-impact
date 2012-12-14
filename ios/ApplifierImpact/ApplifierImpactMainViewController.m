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
#import "ApplifierImpactProperties/ApplifierImpactProperties.h"
#import "ApplifierImpactDevice/ApplifierImpactDevice.h"

@interface ApplifierImpactMainViewController ()
  @property (nonatomic, strong) ApplifierImpactVideoViewController *videoController;
  @property (nonatomic, strong) UIViewController *storeController;
  @property (nonatomic, strong) void (^closeHandler)(void);
  @property (nonatomic, strong) void (^openHandler)(void);
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
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:@"start" data:@{}];
  }
  
  [self.delegate mainControllerWillClose];

  if (![[ApplifierImpactDevice analyticsMachineName] isEqualToString:kApplifierImpactDeviceIosUnknown]) {
    if (self.closeHandler == nil) {
      self.closeHandler = ^(void) {
        AILOG_DEBUG(@"Setting start view after close");
        [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:@"start" data:@{}];
        [self.delegate mainControllerDidClose];
      };
    }
  }
  else {
    [self.delegate mainControllerDidClose];
  }
  
  [[[ApplifierImpactProperties sharedInstance] currentViewController] dismissViewControllerAnimated:animated completion:self.closeHandler];
}

- (BOOL)openImpact:(BOOL)animated {
  AILOG_DEBUG(@"");
  
  if ([[ApplifierImpactProperties sharedInstance] currentViewController] == nil) return NO;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate mainControllerWillOpen];
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:@"start" data:@{}];
    
    if (![[ApplifierImpactDevice analyticsMachineName] isEqualToString:kApplifierImpactDeviceIosUnknown]) {
      if (self.openHandler == nil) {
        self.openHandler = ^(void) {
          AILOG_DEBUG(@"Running openhandler after opening view");
          [self.delegate mainControllerDidOpen];
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
  });
  
  return YES;
}

- (BOOL)mainControllerVisible {
  if (self.view.superview != nil) {
    return YES;
  }
  
  return NO;
}


#pragma mark - Video

- (void)videoPlayerStartedPlaying {
  [self.delegate mainControllerStartedPlayingVideo];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:@"hideSpinner" data:@{@"textKey":@"buffering"}];
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:@{}];
  [self presentViewController:self.videoController animated:NO completion:nil];
}

- (void)videoPlayerEncounteredError {
  AILOG_DEBUG(@"");
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:@"hideSpinner" data:@{@"textKey":@"buffering"}];
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

  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:@"showSpinner" data:@{@"textKey":@"buffering"}];
  
  [self _createVideoController];
  [self.videoController playCampaign:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
}

- (void)_createVideoController {
  self.videoController = [[ApplifierImpactVideoViewController alloc] initWithNibName:nil bundle:nil];
  self.videoController.delegate = self;
}

- (void)_destroyVideoController {
  self.videoController.delegate = nil;
  self.videoController = nil;
}

- (void)_dismissVideoController {
  [self dismissViewControllerAnimated:NO completion:nil];
  [self _destroyVideoController];
}


#pragma mark - Notification receiver

- (void)notificationHandler: (id) notification {
  NSString *name = [notification name];

  AILOG_DEBUG(@"notification: %@", name);
  
  if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
    [[ApplifierImpactWebAppController sharedInstance] setWebViewInitialized:NO];
    [self.videoController forceStopVideoPlayer];
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
	
  if (![self _canOpenStoreProductViewController]) {
		NSString *clickUrl = [data objectForKey:@"clickUrl"];
    if (clickUrl == nil) return;
    AILOG_DEBUG(@"Cannot open store product view controller, falling back to click URL.");
		[[ApplifierImpactWebAppController sharedInstance] openExternalUrl:clickUrl];
		return;
	}
  
  Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
  if ([storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)] == YES) {
    if (![[data objectForKey:@"iTunesId"] isKindOfClass:[NSString class]]) return;
    NSString *gameId = nil;
    gameId = [data valueForKey:@"iTunesId"];
    if (gameId == nil || [gameId length] < 1) return;
    NSDictionary *productParams = @{SKStoreProductParameterITunesItemIdentifier:gameId};
    self.storeController = [[storeProductViewControllerClass alloc] init];
    
    if ([self.storeController respondsToSelector:@selector(setDelegate:)]) {
      [self.storeController performSelector:@selector(setDelegate:) withObject:self];
    }
    
    void (^storeControllerComplete)(BOOL result, NSError *error) = ^(BOOL result, NSError *error) {
      AILOG_DEBUG(@"RESULT: %i", result);
      if (result) {
        [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:@"hideSpinner" data:@{@"textKey":@"loading"}];
        dispatch_async(dispatch_get_main_queue(), ^{
          [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.storeController animated:YES completion:nil];
        });
      }
      else {
        AILOG_DEBUG(@"Loading product information failed: %@", error);
      }
    };
    
    [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:@"showSpinner" data:@{@"textKey":@"loading"}];
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
    [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:@"start" data:@{}];
  });
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