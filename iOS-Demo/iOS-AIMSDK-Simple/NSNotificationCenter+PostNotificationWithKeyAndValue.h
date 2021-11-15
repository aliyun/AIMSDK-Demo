//
//  NSNotificationCenter+PostNotificationWithKeyAndValue.h
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/8/19.
//  Copyright © 2020 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (PostNotificationWithKeyAndValue)

- (void)postNotificationWithNotificationName:(NSNotificationName)notificationName contentKey:(NSString *)contentKey contentValue:(id)contentValue;

@end

NS_ASSUME_NONNULL_END
