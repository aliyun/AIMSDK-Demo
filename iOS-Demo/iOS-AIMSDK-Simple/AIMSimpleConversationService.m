//
//  AIMSimpleConversationService.m
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/6/24.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <libaim/AIMPubConversation.h>
#import <libdps/DPSPubManager.h>
#import <libaim/AIMPubConvService.h>
#import <libaim/AIMPubConvCreateSingleConvParam.h>
#import "AIMSimpleConversationService.h"
#import "AIMSimpleLogger.h"
#import "AIMEnvironmentConfiguration.h"
#import "AIMSimpleManagerContainer.h"
#import "AIMSimpleManager.h"
#import "AIMSimpleViewPresenter.h"
#import <libaim/AIMPubModule.h>

@implementation AIMSimpleConversationService

- (instancetype)initWithSimpleManager:(AIMSimpleManager *)simpleManager {
    self = [super init];
    if (self) {
        self.mySimpleManager = simpleManager;
        self.conversationCollectionList = [NSMutableArray<AIMPubConversation *> new];
    }
    return self;
}

- (void)createSingleConversationWithUid:(NSString *)uid completion:(nonnull AIMNullableCompletion)completion {
    AIMNullableCompletion callback = ^(DPSError *_Nonnull error) {
        if (completion != nil) {
            completion(error);
        }
    };
    
    [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"create conversation with user id: %@", uid]];

    AIMPubConvCreateSingleConvParam *param = [AIMPubConvCreateSingleConvParam new];
    NSString *oppositeUserId = uid;
    NSString *ownUserId = [AIMSimpleManager.lastSimpleManager.manager getUserId];
    
    //param.appCid = [AIMPubConvService generateStandardAppCid:ownUserId receiverId:oppositeUserId];
    //param.ext = @{};
    //param.ctx = @{};

    NSArray *userIds = @[ownUserId, oppositeUserId];
    param.uids = userIds;
    AIM_WEAK_SELF
    NSString* userID = [AIMSimpleManager.lastSimpleManager.manager getUserId];
    AIMPubModule* module = [AIMPubModule getModuleInstance:userID];
    AIMPubConvService* convService = [module getConvService];
    [convService createSingleConversationWithBlock:param
                                         onSuccess:^(AIMPubConversation * _Nonnull conv) {
                                             weakSelf.activatedConversation = conv;
                                             [AIMSimpleLogger
                                              logInfo:[NSString stringWithFormat:@"create single conversation success!%@", conv.userids]];
                                             callback(nil);
                                         } onFailure:^(DPSError * _Nonnull error) {
                                             callback(error);
                                         }];
}

/**
 *in ListLocalConversationsWithOffsetWithBlock we have to specify the offset and count of conversations for calling the
 *functions, here we set 200 as default
 */
- (void)loadConversationsWithCompletion:(AIMNullableCompletion)completion {
    AIMNullableCompletion callBack = ^(DPSError *_Nonnull error) {
        if (completion != nil) {
            completion(error);
            if (error != nil) {
                NSString *message = [NSString stringWithFormat:@"failed in loading conversations：%@", error];
                [AIMSimpleLogger errorInfo:[NSString stringWithFormat:@"%@", message]];
            }
        }
    };

    AIM_WEAK_SELF
    NSString* userID = [AIMSimpleManager.lastSimpleManager.manager getUserId];
    AIMPubModule* module = [AIMPubModule getModuleInstance:userID];
    AIMPubConvService* convService = [module getConvService];
    
    
    [convService listLocalConversationsWithOffsetWithBlock:0
        count:200
        onSuccess:^(NSArray<AIMPubConversation *> *_Nonnull conversations) {
            [weakSelf updateConversations:conversations];
            callBack(nil);
        }
        onFailure:^(DPSError *_Nonnull error) {
            callBack(error);
        }];
}

- (void)addConversations:(NSArray<AIMPubConversation *> *_Nonnull)conversations {
    if (conversations.count == 0) {
        return;
    }
    AIM_WEAK_SELF
    [conversations
     enumerateObjectsUsingBlock:^(AIMPubConversation *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [weakSelf.conversationCollectionList addObject:obj];
    }];
    [self sortConversatons:weakSelf.conversationCollectionList];
    
}

- (void)updateConversations:(NSArray<AIMPubConversation *> *_Nonnull)conversations {
    if (conversations.count == 0) {
        return;
    }
    AIM_WEAK_SELF
    [self.conversationCollectionList removeAllObjects];

    [conversations enumerateObjectsUsingBlock:^(AIMPubConversation *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [weakSelf.conversationCollectionList addObject:obj];
    }];

    [self sortConversatons:weakSelf.conversationCollectionList];
}

- (void)removeConversations:(NSArray<AIMPubConversation *> *_Nonnull)conversations {
    if (conversations.count == 0) {
        return;
    }
    AIM_WEAK_SELF
    [conversations
        enumerateObjectsUsingBlock:^(AIMPubConversation *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [weakSelf.conversationCollectionList removeObject:obj];
        }];

    [self sortConversatons:weakSelf.conversationCollectionList];
}

- (void)sortConversatons:(NSMutableArray<AIMPubConversation *> *)conversations {
    if (conversations.count == 0) {
        return;
    }

    [conversations
        sortUsingComparator:^NSComparisonResult(AIMPubConversation *_Nonnull obj1, AIMPubConversation *_Nonnull obj2) {
            if (obj1.topRank > 0 && obj2.topRank > 0) {
                // 都是置顶会话,按照modifyTime降序排列
                if (obj1.modifyTime > obj2.modifyTime) {
                    return NSOrderedAscending;
                } else if (obj1.modifyTime < obj2.modifyTime) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            } else {
                // 其他情况，优先topRank降序，然后modifyTime降序
                if (obj1.topRank > obj2.topRank) {
                    return NSOrderedAscending;
                } else if (obj1.topRank < obj2.topRank) {
                    return NSOrderedDescending;
                } else {
                    if (obj1.modifyTime > obj2.modifyTime) {
                        return NSOrderedAscending;
                    } else if (obj1.modifyTime < obj2.modifyTime) {
                        return NSOrderedDescending;
                    } else {
                        return NSOrderedSame;
                    }
                }
            }
        }];
}

- (void)callBackChangedOnMainThread {
    AIM_WEAK_SELF
    dispatch_async_on_main_queue(^{
        AIM_STRONG_WEAK_SELF_AND_RETURN_IF_NULL
        if (strongSelf.changedCallBack) {
            strongSelf.changedCallBack();
        }
    });
}

#pragma mark - AIMPubConvListListener

/**
 * 新增会话
 * @param convs 新增的会话集合
 */
- (void)onAddedConversations:(nonnull NSArray<AIMPubConversation *> *)convs {
    dispatch_async_on_main_queue(^{
      [AIMSimpleViewPresenter showAlert:@"new conversation added"];
    });
  
    [self addConversations:convs];
    [self callBackChangedOnMainThread];
}

/**
 * 删除会话
 * @param cids 删除的会话cid集合
 */
- (void)onRemovedConversations:(nonnull NSArray<NSString *> *)cids {
    dispatch_async_on_main_queue(^{
      NSMutableArray<AIMPubConversation *> *conversations = [self conversationCollectionList];

      __block NSMutableArray *arrayNeedRemove = [NSMutableArray array];
      [conversations enumerateObjectsUsingBlock:^(AIMPubConversation *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
          if ([cids containsObject:obj.appCid]) {
              [arrayNeedRemove addObject:obj];
          }
      }];

      [self removeConversations:arrayNeedRemove];
      [self callBackChangedOnMainThread];
    });
}

/**
 * 所有会话被更新替换
 * @param convs 更新后的会话集合
 */
- (void)onRefreshedConversations:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self updateConversations:convs];
    [self callBackChangedOnMainThread];
}

- (void)showDetailLogInfoFromConversationArray:(nonnull NSArray<AIMPubConversation *> *)convs
                                     WithTitle:(nonnull NSString *)title {
    [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"-----%@ conversationCount: %lu------", title, convs.count]];

    NSMutableString *convsDetailInfo = [[NSMutableString alloc] initWithFormat:@"changed conversation list:"];

    for (AIMPubConversation *conversationElem in convs) {
        [convsDetailInfo appendFormat:@"%@, ", conversationElem.appCid];
    }

    [AIMSimpleLogger logInfo:convsDetailInfo];
}

#pragma mark - AIMPubConvChangeListener

/**
 * 会话状态变更
 * @param convs 全量的会话结构
 */
- (void)onConvStatusChanged:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self showDetailLogInfoFromConversationArray:convs WithTitle:@"OnConvStatusChanged"];
}

/**
 * 会话最后一条消息变更
 * @param convs 全量的会话结构
 * 特殊场景:消息撤回时,last_msg中只有recall和mid有效。
 */
- (void)onConvLastMessageChanged:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self showDetailLogInfoFromConversationArray:convs WithTitle:@"OnConvLastMessageChanged"];
}

/**
 * 会话biztype变更
 * @param convs  全量的会话结构
 */
- (void)onConvBizTypeChanged:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self showDetailLogInfoFromConversationArray:convs WithTitle:@"OnConvBizTypeChanged"];
}

/**
 * 会话未读消息数变更
 * @param convs 全量的会话结构
 */
- (void)onConvUnreadCountChanged:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self showDetailLogInfoFromConversationArray:convs WithTitle:@"OnConvUnreadCountChanged"];
}

/**
 * 会话extension变更
 * @param convs 全量的会话结构
 */
- (void)onConvExtensionChanged:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self showDetailLogInfoFromConversationArray:convs WithTitle:@"OnConvExtensionChanged"];
}

/**
 * 会话local extension变更
 * @param convs 全量的会话结构
 */
- (void)onConvLocalExtensionChanged:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self showDetailLogInfoFromConversationArray:convs WithTitle:@"OnConvLocalExtensionChanged"];
}

/**
 * 会话user extension变更
 * @param convs 全量的会话结构
 */
- (void)onConvUserExtensionChanged:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self showDetailLogInfoFromConversationArray:convs WithTitle:@"OnConvUserExtensionChanged"];
}

/**
 * 会话是否通知的状态变更
 * @param convs 全量的会话结构
 */
- (void)onConvNotificationChanged:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self showDetailLogInfoFromConversationArray:convs WithTitle:@"OnConvNotificationChanged"];
}

/**
 * 会话置顶状态变更
 * @param convs 全量的会话结构
 */
- (void)onConvTopChanged:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self showDetailLogInfoFromConversationArray:convs WithTitle:@"OnConvTopChanged"];
}

/**
 * 会话消息被清空
 * @param convs 有效字段cid
 */
- (void)onConvClearMessage:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self showDetailLogInfoFromConversationArray:convs WithTitle:@"OnConvClearMessage"];
}

/**
 * 会话草稿变更
 * @param convs 全量的会话结构
 */
- (void)onConvDraftChanged:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self showDetailLogInfoFromConversationArray:convs WithTitle:@"OnConvDraftChanged"];
}

/**
 * 接收到正在输入事件
 * @param cid      会话id
 * @param command   TypingCommand
 * @param type TypingMessageContent
 */
- (void)onConvTypingEvent:(nonnull NSString *)cid
                  command:(AIMConvTypingCommand)command
                     type:(AIMConvTypingMessageContent)type {
    [AIMSimpleLogger
        logInfo:[NSString stringWithFormat:@"OnConvTypingEvent cid: %@, command: %ld, type: %ld", cid, command, type]];
}

/**
 * 会话utags字段变更
 * param convs 全量会话数据
 */
- (void)onConvUTagsChanged:(nonnull NSArray<AIMPubConversation *> *)convs {
    [self showDetailLogInfoFromConversationArray:convs WithTitle:@"OnConvUTagsChanged"];
}

@end
