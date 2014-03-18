//
//  ApplifierImpactAppSheet.m
//  ApplifierImpact
//
//  Created by Ville Orkas on 13/03/14.
//  Copyright (c) 2014 Applifier. All rights reserved.
//

#import "ApplifierImpact.h"
#import "ApplifierImpactAppSheetManager.h"
#import "ApplifierImpactCampaignManager.h"
#import "ApplifierImpactAnalyticsUploader.h"

@implementation CustomStoreProductViewController

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return [UIApplication sharedApplication].statusBarOrientation;
}

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
  return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return YES;
}

@end

@interface ApplifierImpactAppSheetManager ()
@property (nonatomic, strong) NSMutableDictionary *appSheetCache;
@end

@implementation ApplifierImpactAppSheetManager

static ApplifierImpactAppSheetManager *sharedAppSheetManager = nil;

+ (id)sharedInstance {
	@synchronized(self) {
		if (sharedAppSheetManager == nil) {
      sharedAppSheetManager = [[ApplifierImpactAppSheetManager alloc] init];
    }
	}
	
	return sharedAppSheetManager;
}

- (id)init {
	if ((self = [super init])) {
    _appSheetCache = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)preloadAppSheetWithId:(NSString *)iTunesId {
  AILOG_DEBUG(@"");
  if ([ApplifierImpactAppSheetManager canOpenStoreProductViewController]) {
    AILOG_DEBUG(@"Can open storeProductViewController");
    if (![iTunesId isKindOfClass:[NSString class]] || iTunesId == nil || [iTunesId length] < 1) return;

    NSDictionary *productParams = @{@"id":iTunesId};
    id storeController = [[CustomStoreProductViewController alloc] init];
    if ([storeController respondsToSelector:@selector(setDelegate:)]) {
      [storeController performSelector:@selector(setDelegate:) withObject:self];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [storeController loadProductWithParameters:productParams completionBlock:^(BOOL result, NSError *error) {
        if (result) {
          AILOG_DEBUG(@"Preloading product information succeeded for id: %@.", iTunesId);
          [_appSheetCache setValue:storeController forKey:iTunesId];
        } else {
          AILOG_DEBUG(@"Preloading product information failed for id: %@ with error: %@", iTunesId, error);
        }
      }];
    });
  }
}

- (id)getAppSheetController:(NSString *)iTunesId {
  return [_appSheetCache valueForKey:iTunesId];
}

- (void)openAppSheetWithId:(NSString *)iTunesId toViewController:(UIViewController *)targetViewController withCompletionBlock:(void (^)(BOOL result, NSError *error))completionBlock {
  if ([ApplifierImpactAppSheetManager canOpenStoreProductViewController]) {
    if (![iTunesId isKindOfClass:[NSString class]] || iTunesId == nil || [iTunesId length] < 1) return;
    
    NSDictionary *productParams = @{@"id":iTunesId};
    id storeController = [[CustomStoreProductViewController alloc] init];
    if ([storeController respondsToSelector:@selector(setDelegate:)]) {
      [storeController performSelector:@selector(setDelegate:) withObject:self];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [storeController loadProductWithParameters:productParams completionBlock:^(BOOL result, NSError *error) {
        completionBlock(result, error);
        dispatch_async(dispatch_get_main_queue(), ^{
          if(result) {
            [targetViewController presentViewController:storeController animated:YES completion:nil];
          }
        });
      }];
    });
  }
}

+ (BOOL)canOpenStoreProductViewController {
  Class storeProductViewControllerClass = NSClassFromString(@"SKStoreProductViewController");
  return [storeProductViewControllerClass instancesRespondToSelector:@selector(loadProductWithParameters:completionBlock:)];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
  AILOG_DEBUG(@"");
  if (viewController.presentingViewController != nil) {
    [viewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
  }
}

@end
