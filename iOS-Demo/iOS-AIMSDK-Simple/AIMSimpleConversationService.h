//
//  AIMSimpleConversationService.h
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/6/24.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libaim/AIMPubConvListListener.h>
#import <libaim/AIMPubConvChangeListener.h>
#import <libaim/AIMPubConversation.h>
#import "AIMSimpleDefines.h"

NS_ASSUME_NONNULL_BEGIN
@class AIMPubConversation;
@class AIMSimpleManager;

@interface AIMSimpleConversationService : NSObject<AIMPubConvListListener, AIMPubConvChangeListener>

@property (nonatomic, strong) NSMutableArray<AIMPubConversation *> *conversationCollectionList;

@property (nonatomic, weak) AIMSimpleManager *mySimpleManager;

@property (nonatomic, weak) AIMPubConversation *activatedConversation;
// 变更回调block
@property (nonatomic, copy) dispatch_block_t changedCallBack;

- (instancetype)initWithSimpleManager:(AIMSimpleManager *)simpleManager;

- (void)loadConversationsWithCompletion:(AIMNullableCompletion)completion;

- (void)createSingleConversationWithUid:(NSString *)uid completion:(AIMNullableCompletion)completion;

- (void)addConversations:(NSArray<AIMPubConversation *> *_Nonnull)conversations;

- (void)updateConversations:(NSArray<AIMPubConversation *> *_Nonnull)conversations;

- (void)removeConversations:(NSArray<AIMPubConversation *> *_Nonnull)conversations;

- (void)callBackChangedOnMainThread;

@end
NS_ASSUME_NONNULL_END
