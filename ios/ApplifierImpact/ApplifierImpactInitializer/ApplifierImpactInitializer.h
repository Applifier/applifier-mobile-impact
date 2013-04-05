//
//  ApplifierImpactInitializer.h
//  ApplifierImpact
//
//  Created by Pekka Palmu on 4/5/13.
//  Copyright (c) 2013 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ApplifierImpactInitializerDelegate <NSObject>

@required
- (void)initComplete;
- (void)initFailed;
@end

@interface ApplifierImpactInitializer : NSObject
  @property (nonatomic, assign) id<ApplifierImpactInitializerDelegate> delegate;
  @property (nonatomic, strong) NSThread *backgroundThread;
  @property (nonatomic, assign) dispatch_queue_t queue;

- (void)init:(NSDictionary *)options;

@end
