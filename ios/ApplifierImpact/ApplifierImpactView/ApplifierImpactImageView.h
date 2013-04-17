//
//  ApplifierImpactImageView.h
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/17/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplifierImpactImageView : UIImageView <NSURLConnectionDelegate>
  - (void)loadImageFromURL:(NSURL*)url;
@end
