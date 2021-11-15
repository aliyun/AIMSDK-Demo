//
//  AIMEnvironmentConfiguration.m
//  iOS-AIMSDK-Simple
//
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIDevice.h>
#import <libdps/DPSAuthToken.h>
#import "AIMEnvironmentConfiguration.h"


@implementation AIMEnvironmentConfiguration

+ (instancetype)shareInstance {
    static AIMEnvironmentConfiguration *sharedConfiguaration = nil;
    static dispatch_once_t onceToken;
    //create the singeleton instance of Environment Configuration
    dispatch_once(&onceToken, ^{
      sharedConfiguaration = [AIMEnvironmentConfiguration new];
    });
    return sharedConfiguaration;
}

- (NSString *)appKey {
    return [NSString stringWithFormat:@"%@", DEMO_DEFAUT_APP_KEY];
}

- (NSString *)appID {
    return [NSString stringWithFormat:@"%@", DEMO_DEFAULT_APP_ID];
}

- (NSString *)tokenUrl {
    return [NSString stringWithFormat:@"%@", DEMO_DEFAUT_TOKEN_URL];
}

- (NSString *)appLocale {
    return [NSString stringWithFormat:@"%@", NSLocale.preferredLanguages.firstObject];
}

- (NSString *)dataPath {
    static NSString *dataDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            if (paths != nil) {
                NSString *documentsDirectory = [paths objectAtIndex:0];
                dataDirectory = [documentsDirectory stringByAppendingPathComponent:@"AIMData"];
                
                // if path doesn't exist, then create the default path
                if (![[NSFileManager defaultManager] fileExistsAtPath:dataDirectory]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:dataDirectory withIntermediateDirectories:YES attributes:nil error:nil];
                }
            }
        }
    });
    return dataDirectory;
}

- (NSString *)logPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths firstObject];
    
    if (documentsDirectory == nil) {
        NSLog(@"日志文件夹为空");
        return nil;
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/log.txt", documentsDirectory];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    return filePath;
}

- (NSString *)appName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *displayName = infoDictionary[@"CFBundleDisplayName"];

    if (displayName.length > 0) {
        return displayName;
    } else {
        return infoDictionary[@"CFBundleName"];
    }
}

- (NSString *)appVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *versionString = infoDictionary[@"CFBundleShortVersionString"];
    if (versionString.length == 0) {
        versionString = infoDictionary[@"CFBundleVersion"];
    }

    return versionString;
}

- (NSString *)deviceId {
    static NSString *deviceId = nil;
    NSString *key = @"MockDeviceId";

    deviceId = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (deviceId.length == 0) {
        deviceId = [NSUUID UUID].UUIDString;

        NSString *prefix = nil;
#if TARGET_IPHONE_SIMULATOR //Simulator option
        prefix = @"iOS_Simulator_";
#elif TARGET_OS_IPHONE //Device option
        prefix = @"iOS_Device_";
#endif
        deviceId = [prefix stringByAppendingString:deviceId];
        [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:key];
    }
    return deviceId;
}

- (NSString *)osName {
    return [UIDevice currentDevice].systemName;
}

- (NSString *)osVersion {
    return [UIDevice currentDevice].systemVersion;
}

- (NSString *)deviceName {
    return [UIDevice currentDevice].name;
}

- (NSString *)deviceType {
    return [UIDevice currentDevice].model;
}

- (NSString *)deviceLocale {
    return NSLocale.preferredLanguages.firstObject;
}

- (NSString *)timeZoneName {
    //use system timezone as default
    return [NSTimeZone systemTimeZone].name;
}

@end
