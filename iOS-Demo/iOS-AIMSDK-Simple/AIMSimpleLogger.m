//
//  AIMSimpleLogger.m
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/6/29.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <UIKit/NSAttributedString.h>
#import "AIMSimpleLogger.h"
#import "AIMSimpleDefines.h"
#import "AIMEnvironmentConfiguration.h"

@implementation AIMSimpleLogger

static UITextView *simplelogInfoTextView;
static UIViewController *simpleMainViewController;

+ (void)initWithTextView:(UITextView *)textView {
    simplelogInfoTextView = textView;
    simplelogInfoTextView.layoutManager.allowsNonContiguousLayout = NO;
}

+ (void)clearLog {
    if (simplelogInfoTextView == nil) {
        return;
    }
    dispatch_async_on_main_queue(^{
      [simplelogInfoTextView setText:nil];
    });
}

+ (void)logInfo:(NSString *)logContent
         status:(BOOL)isError {
    if (simplelogInfoTextView == nil) {
        return;
    }

    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSString *textViewText = [[dateFormatter stringFromDate:currentDate] stringByAppendingString:@":"];
    NSString *fullText = [textViewText stringByAppendingString:logContent];
    
    NSMutableString *mutableFullText = [fullText mutableCopy];
    [mutableFullText appendString:@"\r\n"];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:mutableFullText];
    //写入本地日志文件中
    NSOutputStream *stream = [[NSOutputStream alloc] initToFileAtPath:[[AIMEnvironmentConfiguration shareInstance] logPath] append:YES];
    [stream open];
    NSData *data = [fullText dataUsingEncoding:NSUTF8StringEncoding];
    [stream write:data.bytes maxLength:data.length];
    [stream close];
    
    if (isError) {
        [attributedText addAttribute:NSBackgroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, attributedText.length)];
    }
    dispatch_async_on_main_queue(^{
      NSMutableAttributedString *currentAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:simplelogInfoTextView.attributedText];
      [currentAttributedText appendAttributedString:attributedText];
      simplelogInfoTextView.attributedText = currentAttributedText;
      [simplelogInfoTextView scrollRangeToVisible:NSMakeRange(simplelogInfoTextView.text.length, 1)];
    });
}

+ (void)errorInfo:(NSString *)logContent {
    [self logInfo:logContent status:YES];
}
+ (void)logInfo:(NSString *)logContent {
    [self logInfo:logContent status:NO];
}

@end
