//
//  DPSPubManagerContainerDelegate.h
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/8/12.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AIMSimpleManager;
@protocol DPSPubManagerContainerDelegate <NSObject>

- (void) removeFromManagerContainerWithTarget : (id) simpleManagerTarget;

@end

NS_ASSUME_NONNULL_END
