//
//  ApplifierImpactVideoView.h
//  ApplifierImpact
//
//  Created by bluesun on 11/21/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ApplifierImpactVideoView : UIView {
}

@property (nonatomic) AVPlayer *player;

- (void)setPlayer:(AVPlayer *)player;
- (void)setVideoFillMode:(NSString *)fillMode;
- (AVPlayer*)player;
+ (Class)layerClass;

@end