//
//  AIMSimpleLogger.h
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/6/29.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UITextView.h>

NS_ASSUME_NONNULL_BEGIN

@interface AIMSimpleLogger : UITextView

+ (void)initWithTextView:(UITextView *)textView;

+ (void)clearLog;

+ (void)logInfo:(NSString *)logContent status:(BOOL)isError;

+ (void)errorInfo:(NSString *)logContent;

+ (void)logInfo:(NSString *)logContent;

@end
NS_ASSUME_NONNULL_END
