//
//  NSNotificationCenter+PostNotificationWithKeyAndValue.m
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/8/19.
//  Copyright © 2020 Alibaba. All rights reserved.
//

#import "NSNotificationCenter+PostNotificationWithKeyAndValue.h"

@implementation NSNotificationCenter (PostNotificationWithKeyAndValue)

- (void)postNotificationWithNotificationName:(NSNotificationName)notificationName contentKey:(NSString *)contentKey contentValue:(id)contentValue {
    if (!notificationName) {
        NSLog(@"notification name is empty");
        return;
    }
    if (!contentKey) {
        NSLog(@"content key is empty");
        return;
    }
    if (!contentValue) {
        NSLog(@"content value is empty");
        return;
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:notificationName object:nil userInfo:@{contentKey:contentValue}];
}

@end
