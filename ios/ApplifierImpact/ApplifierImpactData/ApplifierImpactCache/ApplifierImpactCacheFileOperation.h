//
//  ApplifierImpactCacheOperation.h
//  testApp
//
//  Created by Sergey D on 3/10/14.
//  Copyright (c) 2014 applifier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplifierImpactCacheOperation.h"

@interface ApplifierImpactCacheFileOperation : ApplifierImpactCacheOperation

@property (nonatomic, strong) NSURL * downloadURL;
@property (nonatomic, copy)   NSString * filePath, * directoryPath;


@end
