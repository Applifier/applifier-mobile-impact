//
//  ApplifierImpactDevice.h
//  ApplifierImpact
//
//  Created by bluesun on 10/19/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplifierImpactDevice : NSObject

+ (NSString *)advertisingIdentifier;
+ (BOOL)canUseTracking;
+ (NSString *)machineName;
+ (NSString *)analyticsMachineName;
+ (NSString *)currentConnectionType;
+ (NSString *)softwareVersion;

+ (NSString *)md5DeviceId;
+ (NSString *)md5OpenUDIDString;
+ (NSString *)md5AdvertisingIdentifierString;
+ (NSString *)md5MACAddressString;

+ (int)getIOSMajorVersion;
+ (NSNumber *)getIOSExactVersion;

+ (BOOL)isSimulator;

@end
