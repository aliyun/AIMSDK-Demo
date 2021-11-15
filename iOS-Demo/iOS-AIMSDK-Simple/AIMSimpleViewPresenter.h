//
//  AIMSimpleViewPresenter.h
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/7/12.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AIMSimpleViewPresenter : NSObject

+ (void)initWithMainViewControl:(UIViewController *)mainViewControl;

+ (void)showAlert:(NSString *)message;

@end
NS_ASSUME_NONNULL_END
    
