//
//  ApplifierImpactBundle.h
//  ApplifierImpact
//
//  Created by Matti Savolainen on 5/3/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ApplifierImpactBundle : NSObject

+ (NSBundle *)bundle;
+ (UIImage *)imageWithName:(NSString *)aName;
+ (UIImage *)imageWithName:(NSString *)aName ofType:(NSString *)aType;
@end
