//
//  ApplifierImpactNoWebViewEndScreenViewController.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/11/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactNoWebViewEndScreenViewController.h"
#import "../ApplifierImpact.h"
#import "../ApplifierImpactProperties/ApplifierImpactConstants.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaignManager.h"
#import "../ApplifierImpactCampaign/ApplifierImpactCampaign.h"
#import "../ApplifierImpactView/ApplifierImpactMainViewController.h"

@interface ApplifierImpactNoWebViewEndScreenViewController ()
  @property (nonatomic, strong) UIButton *closeButton;
  @property (nonatomic, strong) UIButton *rewatchButton;
  @property (nonatomic, strong) UIButton *downloadButton;
@end

@implementation ApplifierImpactNoWebViewEndScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      [self.view setBackgroundColor:[UIColor brownColor]];
      [self createCloseButton];
      [self createRewatchButton];
      [self createDownloadButton];
    }
    return self;
}

- (void)initController {

}

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button actions

- (void)downloadButtonClicked {
  NSDictionary *data = @{kApplifierImpactCampaignStoreIDKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].itunesID,
                         kApplifierImpactWebViewEventDataClickUrlKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].clickURL,
                         kApplifierImpactCampaignIDKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id};
  
  [[ApplifierImpactMainViewController sharedInstance] applyOptionsToCurrentState:data];
  AILOG_DEBUG(@"");
}

- (void)rewatchButtonClicked {
  AILOG_DEBUG(@"");
  
  if ([[ApplifierImpactCampaignManager sharedInstance] selectedCampaign] != nil) {
    NSDictionary *data = @{kApplifierImpactWebViewEventDataRewatchKey:@true,
                           kApplifierImpactWebViewEventDataCampaignIdKey:[[ApplifierImpactCampaignManager sharedInstance] selectedCampaign].id};
    [[ApplifierImpactMainViewController sharedInstance] changeState:kApplifierImpactViewStateTypeVideoPlayer withOptions:data];
  }
}

- (void)closeButtonClicked {
  AILOG_DEBUG(@"");
  [[ApplifierImpactMainViewController sharedInstance] closeImpact:YES withAnimations:YES withOptions:nil];
}


#pragma mark - View creation

- (void)createBackgroundImage {
  
}

- (void)createCloseButton {
  AILOG_DEBUG(@"");
  self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
  [self.closeButton setBackgroundColor:[UIColor blackColor]];
  [self.closeButton setTitle:@"close" forState:UIControlStateNormal];
  [self.view addSubview:self.closeButton];
  self.closeButton.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width - 50, 0);
  self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
  [self.view bringSubviewToFront:self.closeButton];
  
  [self.closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createRewatchButton {
  AILOG_DEBUG(@"");
  self.rewatchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
  [self.rewatchButton setBackgroundColor:[UIColor blackColor]];
  [self.rewatchButton setTitle:@"rewatch" forState:UIControlStateNormal];
  [self.view addSubview:self.rewatchButton];
  self.rewatchButton.transform = CGAffineTransformMakeTranslation(0, 0);
  self.rewatchButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
  [self.view bringSubviewToFront:self.rewatchButton];
  
  [self.rewatchButton addTarget:self action:@selector(rewatchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createDownloadButton {
  AILOG_DEBUG(@"");
  self.downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
  [self.downloadButton setBackgroundColor:[UIColor greenColor]];
  [self.downloadButton setTitle:@"download" forState:UIControlStateNormal];
  [self.view addSubview:self.downloadButton];
  self.downloadButton.transform = CGAffineTransformMakeTranslation((self.view.bounds.size.width / 2) - (120 / 2), self.view.bounds.size.height - 100);
  self.downloadButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
  [self.view bringSubviewToFront:self.downloadButton];
  
  [self.downloadButton addTarget:self action:@selector(downloadButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

@end
