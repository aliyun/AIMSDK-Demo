//
//  AIMSimpleManagerContainer.h
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/6/23.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AIMManagerContainerDelegate.h"

NS_ASSUME_NONNULL_BEGIN
@class DPSError;
@class AIMSimpleManager;
@class AIMSimpleLogger;

//NSNotificationCenter消息通知切换当前SimpleManager对应的key
FOUNDATION_EXTERN NSString * const kSwitchLastSimpleManagerKey;
FOUNDATION_EXTERN NSNotificationName const AIMSwitchLastSimpleManagerNotification;

typedef void (^AIMCompletion)(NSError *_Nullable error);

@interface AIMSimpleManagerContainer : NSObject<DPSPubManagerContainerDelegate>
/**
 * container容器中simpleManager个数
 */
@property (nonatomic,readonly) NSUInteger count;
/**
 * @初始化创建AIMSimpleManager对象
 * @param  userId 用户名
*/
- (void)addSimpleManagerWithUserId:(NSString *)userId;
/**
 * @释放SimpleManager对象，并从容器中删除
 * 添加SimpleManager对象到容器中，并通过NSNotificationCenter把最近的SimpleManager设置为新添加对象
 * @params userId 用户名
*/
- (void)removeSimpleManagerWithUserId:(NSString *)userId;
/**
 * @添加SimpleManager对象到容器
 * 添加SimpleManager对象到容器中，并通过NSNotificationCenter把最近的SimpleManager设置为新添加对象
 * @params simpleManager 包含用户个人信息的simpleManager对象
*/
- (void)addSimpleManager:(AIMSimpleManager *)simpleManager;
/**
 * @添加SimpleManager对象到容器
 * 添加SimpleManager对象到容器中，并通过NSNotificationCenter把最近的SimpleManager设置为新添加对象
 * @params simpleManager 包含用户个人信息的simpleManager对象
*/
- (void)removeSimpleManager:(AIMSimpleManager *)simpleManager;
/**
 * @清空SimpleManager容器
*/
- (void)clearManagerContainer;
/**
 * @判断SimpleManager对象是否在容器中
 *
 * @params simpleManager 包含用户个人信息的simpleManager对象
 * @return 对应用户是否存在于容器中的布尔结果
*/
- (BOOL)isAlreadyInitalizedSimpleManager:(AIMSimpleManager *)simpleManager;
/**
 * @判断SimpleManager对象是否在容器中
 *
 * @params userId 用户名
 * @return 对应用户是否存在于容器中的布尔结果
*/
- (BOOL)isAlreadyInitalizedSimpleManagerByUserId:(NSString *)userId;
/**
 * @根据用户名返回对应的AIMSimpleManager
 *
 * @params userId 用户名
 * @return 包含用户个人信息的simpleManager对象
*/
- (AIMSimpleManager *)simpleManagerByUserId:(NSString *)userId;
/**
 * @返回存储SimpleManager的可变数组
 *
 * @return 返回整个container的容器NSMutableArray
*/
- (NSMutableArray<AIMSimpleManager *> *)simpleManagerContainer;

@end
NS_ASSUME_NONNULL_END
