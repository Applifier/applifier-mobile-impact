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

@interface ApplifierImpactMainViewController ()
  @property (nonatomic, strong) ApplifierImpactVideoViewController *videoController;
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
      
      // init VideoController
      self.videoController = [[ApplifierImpactVideoViewController alloc] initWithNibName:nil bundle:nil];
      self.videoController.delegate = self;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Orientation handling
// FIX: not following developers orientations
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
  AILOG_DEBUG(@"");
  return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Public

- (BOOL)closeImpact {
  AILOG_DEBUG(@"");
  if (self.videoController.view.superview != nil) {
    [self dismissViewControllerAnimated:NO completion:nil];
  }
  [[[ApplifierImpactProperties sharedInstance] currentViewController] dismissViewControllerAnimated:YES completion:nil];
  return YES;
}

- (BOOL)openImpact {
  AILOG_DEBUG(@"");
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:@"start" data:@{}];
  [[[ApplifierImpactProperties sharedInstance] currentViewController] presentViewController:self animated:YES completion:nil];
  
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

- (void)videoPlayerStartedPlaying {
  [self.delegate mainControllerStartedPlayingVideo];
  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:@"hideSpinner" data:@{@"textKey":@"buffering"}];
  [[ApplifierImpactWebAppController sharedInstance] setWebViewCurrentView:kApplifierImpactWebViewViewTypeCompleted data:@{}];
  [self presentViewController:self.videoController animated:NO completion:nil];
}

- (void)videoPlayerPlaybackEnded {
  [self.delegate mainControllerVideoEnded];
  [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)showPlayerAndPlaySelectedVideo:(BOOL)checkIfWatched {
	AILOG_DEBUG(@"");
    
  if ([[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].viewed && checkIfWatched) {
    AILOG_DEBUG(@"Trying to watch a campaign that is already viewed!");
    return;
  }

  [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:@"showSpinner" data:@{@"textKey":@"buffering"}];
  [self.videoController playCampaign:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign]];
}


#pragma mark - Notification receiver

- (void)notificationHandler: (id) notification {
  NSString *name = [notification name];

  AILOG_DEBUG(@"notification: %@", name);
  
  if ([name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
    [self.videoController forceStopVideoPlayer];
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
        [[ApplifierImpactWebAppController sharedInstance] sendNativeEventToWebApp:@"hideSpinner" data:@{@"textKey":@"loading"}];
        [[ApplifierImpactMainViewController sharedInstance] presentViewController:self.storeController animated:YES completion:nil];
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