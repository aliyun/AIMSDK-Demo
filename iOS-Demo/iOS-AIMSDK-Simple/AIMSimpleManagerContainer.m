//
//  AIMSimpleManagerContainer.m
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/6/23.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//
#import "AIMSimpleManagerContainer.h"
#import "AIMSimpleManager.h"
#import "AIMEnvironmentConfiguration.h"
#import "AIMSimpleLogger.h"

#import "NSNotificationCenter+PostNotificationWithKeyAndValue.h"

@interface AIMSimpleManagerContainer ()

@property (nonatomic, strong) NSMutableArray<AIMSimpleManager *> *simpleManagerArray;
@property (nonatomic,strong) dispatch_queue_t accessQueue;

@end

NSString * const kSwitchLastSimpleManagerKey = @"switchlastSimpleManagerUserIdKey";
NSNotificationName const AIMSwitchLastSimpleManagerNotification = @"switchLastManagerNotification";

@implementation AIMSimpleManagerContainer
- (instancetype)init {
    self = [super init];
    if (self) {
        _simpleManagerArray = [NSMutableArray array];
        _accessQueue = dispatch_queue_create([NSString stringWithFormat:@"<%@: %p>", NSStringFromClass([self class]), self].UTF8String, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSUInteger)count {
    __block NSUInteger retVal;
    AIM_WEAK_SELF
    dispatch_barrier_sync(self.accessQueue, ^{
        AIM_STRONG_WEAK_SELF_AND_RETURN_IF_NULL
        retVal = strongSelf.simpleManagerArray.count;
    });
    return retVal;
}

- (void)addSimpleManagerWithUserId:(NSString *)userId {
    if (!userId) {
        [AIMSimpleLogger errorInfo:@"userId is nil"];
        return;
    }
    
    BOOL isInitlized = [self isAlreadyInitalizedSimpleManagerByUserId:userId];
    
    if (isInitlized) {
        [AIMSimpleLogger errorInfo:@"the specific user is already initilized"];
        return;
    }
        
    AIMSimpleManager *simpleManagerInstance = [[AIMSimpleManager alloc] initWithContainer:self];
    AIM_WEAK_SELF
    [simpleManagerInstance createIMManager:userId
        success:^(DPSPubManager *_Nonnull manager) {
            AIM_STRONG_WEAK_SELF_AND_RETURN_IF_NULL
            simpleManagerInstance.manager = manager;
            simpleManagerInstance.userId = userId;
            [strongSelf addSimpleManager:simpleManagerInstance];
        }
        failed:^(DPSError *_Nonnull error) {
        [AIMSimpleLogger errorInfo:[NSString stringWithFormat:@"create manager failed with info:%@", error]];
    }];
}

- (void)addSimpleManager:(AIMSimpleManager *)simpleManager {
    if (!simpleManager) {
        [AIMSimpleLogger errorInfo:@"the simpleManager is nil"];
        return;
    }
    
    if (!simpleManager.userId) {
        [AIMSimpleLogger errorInfo:@"the userId of simpleManager is nil"];
        return;
    }
    AIM_WEAK_SELF
    dispatch_barrier_sync(self.accessQueue, ^{
        AIM_STRONG_WEAK_SELF_AND_RETURN_IF_NULL
        [strongSelf.simpleManagerArray addObject:simpleManager];
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationWithNotificationName:AIMSwitchLastSimpleManagerNotification contentKey:kSwitchLastSimpleManagerKey contentValue:simpleManager.userId];
}


- (void)removeSimpleManagerWithUserId:(NSString *)userId {
    
    if (!userId) {
        [AIMSimpleLogger errorInfo:@"userId is nil"];
        return;
    }
    
    BOOL isInitlized = [self isAlreadyInitalizedSimpleManagerByUserId:userId];

    if (!isInitlized) {
        [AIMSimpleLogger errorInfo:@"manager is not created!"];
        return;
    }
    AIM_WEAK_SELF
    [[DPSPubEngine getDPSEngine] releaseDPSManagerWithBlock:userId onSuccess:^{
        AIM_STRONG_WEAK_SELF_AND_RETURN_IF_NULL
        AIMSimpleManager *simpleManagerInstance = [strongSelf simpleManagerByUserId:userId];
        [strongSelf removeSimpleManager:simpleManagerInstance];
    } onFailure:^(DPSError * _Nonnull error) {
        [AIMSimpleLogger errorInfo:[NSString stringWithFormat:@"release manager failed with error: %@", error]];
    }];    
}

- (void)clearManagerContainer {
    AIM_WEAK_SELF
    dispatch_barrier_sync(self.accessQueue, ^{
        AIM_STRONG_WEAK_SELF_AND_RETURN_IF_NULL
        [strongSelf.simpleManagerArray removeAllObjects];
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationWithNotificationName:AIMSwitchLastSimpleManagerNotification contentKey:kSwitchLastSimpleManagerKey contentValue:@""];
}

- (BOOL)isAlreadyInitalizedSimpleManager:(AIMSimpleManager *)simpleManager {
    if (!simpleManager) {
        return NO;
    }
    if (!simpleManager.userId) {
        return NO;
    }
    
    NSArray <AIMSimpleManager *> *loopSimpleManagerArray = [self.simpleManagerArray copy];
    for (AIMSimpleManager *simpleManagerElem in [loopSimpleManagerArray reverseObjectEnumerator]) {
        if (simpleManagerElem.userId) {
            BOOL isSameManager = [simpleManagerElem.userId isEqual:simpleManager.userId];
            if (isSameManager) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)isAlreadyInitalizedSimpleManagerByUserId:(NSString *)userId {
    if (!userId) {
        return NO;
    }
    
    NSArray <AIMSimpleManager *> *loopSimpleManagerArray = [self.simpleManagerArray copy];
    for (AIMSimpleManager *simpleManagerElem in [loopSimpleManagerArray reverseObjectEnumerator]) {
        if (simpleManagerElem.userId) {
            BOOL isSameManager = [simpleManagerElem.userId isEqual:userId];
            if (isSameManager) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (AIMSimpleManager *)simpleManagerByUserId:(NSString *)userId {
    if (!userId) {
        [AIMSimpleLogger errorInfo:@"corresponding simpleManager not founded in the container"];
        return nil;
    }
    
    NSArray <AIMSimpleManager *> *loopSimpleManagerArray = [self.simpleManagerArray copy];
    for (AIMSimpleManager *simpleManagerElem in [loopSimpleManagerArray reverseObjectEnumerator]) {
        if (simpleManagerElem.userId) {
            BOOL isSameManager = [simpleManagerElem.userId isEqual:userId];
            if (isSameManager) {
                return simpleManagerElem;
            }
        }
    }

    return nil;
}

- (void)removeSimpleManager:(AIMSimpleManager *)simpleManager {
    if (!simpleManager) {
        [AIMSimpleLogger errorInfo:@"simpleManager is nil"];
        return;
    }
    if (!simpleManager.userId) {
        [AIMSimpleLogger errorInfo:@"the userId of simpleManager is nil"];
        return;
    }
    
    NSArray <AIMSimpleManager *> *loopSimpleManagerArray = [self.simpleManagerArray copy];
    for (AIMSimpleManager *simpleManagerElem in [loopSimpleManagerArray reverseObjectEnumerator]) {
        if (simpleManagerElem.userId) {
            BOOL isSameManager = [simpleManagerElem.userId isEqual:simpleManager.userId];
            if (isSameManager) {
                AIM_WEAK_SELF
                dispatch_barrier_sync(self.accessQueue, ^{
                    AIM_STRONG_WEAK_SELF_AND_RETURN_IF_NULL
                    [strongSelf.simpleManagerArray removeObject:simpleManagerElem];
                });
                if ([self.simpleManagerArray count] > 0) {
                    AIMSimpleManager.lastSimpleManager = [loopSimpleManagerArray objectAtIndex:0];
                    
                    NSString *activatedUserId = [loopSimpleManagerArray objectAtIndex:0].userId;
                    [[NSNotificationCenter defaultCenter] postNotificationWithNotificationName:AIMSwitchLastSimpleManagerNotification contentKey:kSwitchLastSimpleManagerKey contentValue:activatedUserId];
                } else {
                    AIMSimpleManager.lastSimpleManager = nil;
                    [[NSNotificationCenter defaultCenter] postNotificationWithNotificationName:AIMSwitchLastSimpleManagerNotification contentKey:kSwitchLastSimpleManagerKey contentValue:@""];
                }
                return;
            }
        }
    }
        
    [AIMSimpleLogger errorInfo:@"simpleManager not founded in the container"];
}

- (NSMutableArray<AIMSimpleManager *> *)simpleManagerContainer {
    if (self.simpleManagerArray) {
        return self.simpleManagerArray;
    }
    else {
        return nil;
    }
}

#pragma mark DPSPubManagerContainerDelegate
/**
 * 从容器中移除对应AIMSimpleManager
 * 判断Manager是否已经在容器中，若存在，进行相应的移除，并通过NSNotificationCenter回调到UI层，切换最近的Manager ID
 * @params simpleManagerTarget 用户对象实例
 */
- (void)removeFromManagerContainerWithTarget:(id)simpleManagerTarget {
    if (!simpleManagerTarget) {
        [AIMSimpleLogger errorInfo:@"simpleManagerTarget is nil"];
        return;
    }
    if ([simpleManagerTarget isKindOfClass:AIMSimpleManager.class]) {
        [AIMSimpleLogger errorInfo:@"simpleManager is not an AIMSimpleManager object"];
        return;
    }
    
    AIMSimpleManager *simpleManagerInstance = simpleManagerTarget;
    NSArray <AIMSimpleManager *> *loopSimpleManagerArray = [self.simpleManagerArray copy];
    for (AIMSimpleManager *simpleManagerElem in [loopSimpleManagerArray reverseObjectEnumerator]) {
        if (simpleManagerElem.userId) {
            BOOL isSameManager = [simpleManagerElem.userId isEqual:simpleManagerInstance.userId];
            if (isSameManager) {
                [self removeSimpleManager:simpleManagerElem];
                if ([loopSimpleManagerArray count] > 0) {
                    AIMSimpleManager.lastSimpleManager = [loopSimpleManagerArray objectAtIndex:0];
                    NSString *activatedUserId = AIMSimpleManager.lastSimpleManager.userId;
                    [[NSNotificationCenter defaultCenter] postNotificationWithNotificationName:AIMSwitchLastSimpleManagerNotification contentKey:kSwitchLastSimpleManagerKey contentValue:activatedUserId];
                } else {
                    AIMSimpleManager.lastSimpleManager = nil;
                    [[NSNotificationCenter defaultCenter] postNotificationWithNotificationName:AIMSwitchLastSimpleManagerNotification contentKey:kSwitchLastSimpleManagerKey contentValue:@""];
                }
                return;
            }
        }
    }
    [AIMSimpleLogger errorInfo:@"simpleManager not founded in the container"];
}

@end
