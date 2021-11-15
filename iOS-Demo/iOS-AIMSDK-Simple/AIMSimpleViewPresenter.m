//
//  AIMSimpleViewPresenter.m
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/7/12.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AIMSimpleViewPresenter.h"
#import "AIMSimpleDefines.h"

static UIViewController *simpleMainViewController;

@implementation AIMSimpleViewPresenter
+ (void)initWithMainViewControl:(UIViewController *)mainViewControl {
    simpleMainViewController = mainViewControl;
}

/**
 show alert over the main screen on UI, set dispatch_async_on_main_queue as default, in case of any interruption
 */
+ (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIView *firstSubview = alert.view.subviews.firstObject;
    UIView *alertContentView = firstSubview.subviews.firstObject;
    for (UIView *subSubView in alertContentView.subviews) {
        subSubView.backgroundColor = [UIColor colorWithRed:141 / 255.0f green:0 / 255.0f blue:100 / 255.0f alpha:0.5f];
    }
    NSMutableAttributedString *AS = [[NSMutableAttributedString alloc] initWithString:message];
    [AS addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, AS.length)];
    [alert setValue:AS forKey:@"attributedTitle"];
    dispatch_async_on_main_queue(^{
      [simpleMainViewController presentViewController:alert animated:YES completion:nil];

      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES
                                  completion:^{
                                  }];
      });
    });
}

@end
