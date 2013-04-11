//
//  ApplifierImpactNoWebViewEndScreenViewController.m
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/11/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import "ApplifierImpactNoWebViewEndScreenViewController.h"
#import "../ApplifierImpact.h"

@interface ApplifierImpactNoWebViewEndScreenViewController ()
  @property (nonatomic, strong) UIButton *closeButton;
@end

@implementation ApplifierImpactNoWebViewEndScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      [self.view setBackgroundColor:[UIColor brownColor]];
      [self createCloseButton];
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


#pragma mark - View creation

- (void)createBackgroundImage {
  
}

- (void)createCloseButton {
  AILOG_DEBUG(@"createCloseButton");
  self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
  [self.closeButton setTitle:@"close" forState:UIControlStateNormal];
  [self.view addSubview:self.closeButton];
  [self.view bringSubviewToFront:self.closeButton];
}

- (void)createRewatchButton {
  
}

- (void)createDownloadButton {
  
}

@end
