//
//  ApplifierImpactURLProtocol.h
//  ApplifierImpact
//
//  Created by bluesun on 10/10/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/NSJSONSerialization.h>
#import <CoreFoundation/CFString.h>
#import "ApplifierImpact.h"

@interface ApplifierImpactURLProtocol : NSURLProtocol
+ (NSString *)stringWithUriEncoding:(NSString *)string;
+ (NSString *)stringWithoutUriEncoding:(NSString *)string;
@end
