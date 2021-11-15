//
//  AIMSimpleEngine.h
//  iOS-AIMSDK-Simple
//
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libdps/DPSPubAuthTokenCallback.h>
#import <libdps/DPSPubEngineListener.h>
#import <libdps/DPSEngineStartListener.h>
#import <libdps/DPSLogHandler.h>
#import "AIMSimpleDefines.h"


NS_ASSUME_NONNULL_BEGIN
@class AIMSimpleLogger;

@interface AIMSimpleEngine : NSObject <DPSPubEngineListener, DPSEngineStartListener, DPSPubAuthTokenCallback, DPSLogHandler>

+ (instancetype)shareInstance;

- (void)startSimpleEngine;

- (void)startSimpleEngineWithCompletion:(AIMNullableCompletion)completion;

- (void)configureSimpleEngine;

- (void)releaseSimpleEngine;

@end
NS_ASSUME_NONNULL_END
