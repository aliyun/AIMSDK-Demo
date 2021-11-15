//
//  AIMSimpleMessageService.h
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/6/28.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libaim/AIMPubMsgSendMsgListener.h>
#import <libaim/AIMPubMsgListener.h>
#import <libaim/AIMPubMsgChangeListener.h>

NS_ASSUME_NONNULL_BEGIN
@class AIMPubMsgSendMessage;
@class AIMPubConversation;
@class AIMSimpleManager;

@interface AIMSimpleMessageService : NSObject<AIMPubMsgSendMsgListener, AIMPubMsgListener, AIMPubMsgChangeListener>

@property (nonatomic, weak) AIMSimpleManager *mySimpleManager;
// 变更回调block
@property (nonatomic, copy) dispatch_block_t changedCallBack;

@property(nonatomic, copy) NSString *sMediaID;

- (instancetype)initWithSimpleManager:(AIMSimpleManager *)simpleManager;

- (void)sendText:(NSString *)text withConversation:(AIMPubConversation *)conversation;

- (AIMPubMsgSendMessage *)makeMsgSendMessageWithContent:(AIMPubMsgContent *)content WithConversation:(AIMPubConversation *)conversation;

- (void)sendMessage:(AIMPubMsgSendMessage *)msgSendMessage;

- (void)sendImage:(NSString *)imagePath
 withConversation:(AIMPubConversation *)conversation;

- (void)downloadImage;

- (void)callBackChangedOnMainThread;

@end
NS_ASSUME_NONNULL_END
