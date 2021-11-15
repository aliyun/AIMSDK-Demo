//
//  AIMSimpleMessageService.m
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/6/28.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//
#import <libaim/AIMPubMsgSendMessage.h>
#import <libaim/AIMPubConversation.h>
#import <libaim/AIMPubMsgService.h>
#import "AIMSimpleMessageService.h"
#import "AIMEnvironmentConfiguration.h"
#import "AIMSimpleLogger.h"
#import "AIMSimpleViewPresenter.h"
#import "AIMSimpleDefines.h"
#import "AIMSimpleDefines.h"
#import "AIMSimpleManagerContainer.h"
#import "AIMSimpleManager.h"
#import "AIMPubMessage+messageContent.h"
#import <libaim/AIMPubModule.h>
#import <libaim/AIMPubMsgService.h>
#import <UIKit/UIImagePickerController.h>
#import <libaim/AIMMediaAuthInfo.h>
#import <libaim/AIMMediaService.h>

@implementation AIMSimpleMessageService

- (instancetype)initWithSimpleManager:(AIMSimpleManager *)simpleManager {
    self = [super init];
    if(self){
        self.mySimpleManager = simpleManager;
        self.sMediaID = [NSMutableString stringWithString:@""];
    }
    return self;
}

/**
 * entry function for sending text service from AIMSimpleMessageService
 * AIMPubMsgContent consist of AIMPubMsgTextContent and AIMMsgContentTypeContentTypeText
 */
- (void)sendText:(NSString *)text
withConversation:(AIMPubConversation *)conversation {
    AIMPubMsgTextContent *msgTextContent = [self makeAIMPubMsgTextContentWithText:text];

    AIMPubMsgContent *messageContent = [self makeAIMPubMsgContentWithMsgTextContent:msgTextContent];

    AIMPubMsgSendMessage *msgSendMessage = [self makeMsgSendMessageWithContent:messageContent WithConversation:conversation];

    [self sendMessage:msgSendMessage];
}

- (void)sendImage:(NSString *)imagePath
 withConversation:(AIMPubConversation *)conversation {
    AIMMsgImageContent *imageContent = [AIMMsgImageContent new];
    imageContent.localPath = imagePath;
    imageContent.type = AIMMsgImageCompressTypeImageCompressTypeOriginal;
    imageContent.fileType = AIMMsgImageFileTypeImageFileTypeJPG;
    imageContent.mimeType = @"image/jpeg";
    
    AIMPubMsgContent *content = [AIMPubMsgContent new];
    content.contentType = AIMMsgContentTypeContentTypeImage;
    content.imageContent = imageContent;
    
    AIMPubMsgSendMessage *msgSendMessage = [self makeMsgSendMessageWithContent:content WithConversation:conversation];
    
    [self sendMessage:msgSendMessage];
}

- (void) getMessageContent:(AIMPubMessage *)msg {
    if (!msg) {
        return;
    }
    
    if (msg.content.contentType == AIMMsgContentTypeContentTypeText) {
        [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"message content: %@", msg.content.textContent.text]];
        return;
    }
    
    if (msg.content.contentType == AIMMsgContentTypeContentTypeImage) {
        NSString *mediaID = msg.content.imageContent.mediaId;
        if (mediaID) {
            [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"message media id is: %@", mediaID]];
            self.sMediaID = mediaID;
        }
    }
    
}

- (NSURL *) applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)downloadImage {
    if(!self.sMediaID) {
        [AIMSimpleLogger errorInfo:@"cannot found media id so far"];
        return;
    }
    
    AIMPubModule *module = [AIMPubModule getModuleInstance:AIMSimpleManager.lastSimpleManager.userId];
    
    if (!module) {
        [AIMSimpleLogger errorInfo:@"cannot found AIMPubModule"];
        return;
    }
    
    AIMMediaService *mediaService = [module getMediaService];
    
    if (!mediaService) {
        [AIMSimpleLogger errorInfo:@"cannot found mediaService"];
        return;
    }
    
    
    
    NSURL *folder = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"aim_images/"];
    
    NSString *imagePath = [folder.path stringByAppendingString:self.sMediaID];
    
    BOOL isFolder = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:folder.path isDirectory:&isFolder] == NO)
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtURL:folder withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Create folder Error: %@", error.localizedDescription);
            return;
        }
    }
    
    
    AIMMediaAuthInfo *authInfo = [AIMMediaAuthInfo new];
    NSString *url = [mediaService transferMediaIdToAuthImageUrl:self.sMediaID size:AIMImageSizeTypeIstThumb authInfo:authInfo];
    
    if ([url isEqual: @""]) {
        [AIMSimpleLogger errorInfo:@"cannot find specific media url"];
        return;
    }
    
    AIMDownloadFileParam *param = [AIMDownloadFileParam new];
    param.downloadUrl = url;
    param.path = imagePath;
    
    [mediaService downloadFileWithBlock:param onCreate:^(NSString * _Nonnull taskId) {
        [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"DownloadFile onCreate: %@", taskId]];
    } onStart:^{
        [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"DownloadFile start"]];
    } onProgress:^(int64_t currentSize, int64_t totalSize) {
        [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"DownloadFile progress: %lld:%lld", currentSize, totalSize]];
        
    } onSuccess:^(NSString * _Nonnull path) {
        [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"DownloadFile success: %@", path]];
        
    } onFailure:^(DPSError * _Nonnull error) {
        [AIMSimpleLogger errorInfo:[NSString stringWithFormat:@"DownloadFile failed with info: %@", error]];
    }];
}

- (AIMPubMsgTextContent *)makeAIMPubMsgTextContentWithText:(NSString *)text {
    AIMPubMsgTextContent *msgTextContent = [AIMPubMsgTextContent new];

    msgTextContent.text = text;

    return msgTextContent;
}

- (AIMPubMsgContent *)makeAIMPubMsgContentWithMsgTextContent:(AIMPubMsgTextContent *)msgtextContent {
    AIMPubMsgContent *msgContent = [AIMPubMsgContent new];

    msgContent.contentType = AIMMsgContentTypeContentTypeText;
    msgContent.textContent = msgtextContent;

    return msgContent;
}

- (AIMPubMsgSendMessage *)makeMsgSendMessageWithContent:(AIMPubMsgContent *)msgContent
                                    WithConversation:(AIMPubConversation *)conversation {
    if (msgContent == nil) {
        return nil;
    }

    AIMPubMsgSendMessage *sendMessage = [AIMPubMsgSendMessage new];
    sendMessage.receivers = conversation.userids;
    sendMessage.appCid = conversation.appCid;
    sendMessage.content = msgContent;

    return sendMessage;
}

- (void)sendMessage:(AIMPubMsgSendMessage *)msgSendMessage {
    if (msgSendMessage == nil) {
        return;
    }
    NSString* userID = [AIMSimpleManager.lastSimpleManager.manager getUserId];
    AIMPubModule* module = [AIMPubModule getModuleInstance:userID];
    AIMPubMsgService* msgService = [module getMsgService];
    
    [msgService sendMessageWithBlock:msgSendMessage onProgress:^(double progress) {
        
    } onSuccess:^(AIMPubMessage * _Nonnull msg) {
        [AIMSimpleViewPresenter showAlert:@"sending message success"];
        [AIMSimpleLogger logInfo:@"send message success"];
    } onFailure:^(DPSError * _Nonnull error) {
        NSString *errorDetail = [NSString stringWithFormat:@"sending message failed with error：%@", error];
        [AIMSimpleLogger errorInfo:[NSString stringWithFormat:@"%@", errorDetail]];
    } userData:@{}];
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

- (void)showDetailLogInfoFromNewMessageArray:(nonnull NSArray<AIMPubNewMessage *> *)newMsgs
                                   WithTitle:(nonnull NSString *)title {
    [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"-----%@ messageCount: %lu------", title, newMsgs.count]];

    NSMutableString *msgsDetailInfo = [[NSMutableString alloc] initWithFormat:@"changed message list:"];

    for (AIMPubNewMessage *newMsg in newMsgs) {
        [msgsDetailInfo appendFormat:@"%@, ", newMsg.msg.appCid];
    }

    [AIMSimpleLogger logInfo:msgsDetailInfo];
}

- (void)showDetailLogInfoFromMessageArray:(nonnull NSArray<AIMPubMessage *> *)msgs
                                WithTitle:(nonnull NSString *)title {
    [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"-----Event:%@ messageCount: %lu------", title, msgs.count]];

    NSMutableString *msgsDetailInfo = [[NSMutableString alloc] initWithFormat:@"changed message list:"];

    for (AIMPubMessage *msg in msgs) {
        [msgsDetailInfo appendFormat:@"%@, ", msg.appCid];
    }

    [AIMSimpleLogger logInfo:msgsDetailInfo];
}

#pragma mark AIMPubMsgSendMsgListener

/**
 * 发送进度（图片、视频、文件）progress: 0.0~1.0
 * @param progress 进度 0.0~1.0
 */
- (void)onProgress:(double)progress {
    [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"Send Message progress: %f", progress]];
}

/**
 * 处理成功
 * @param msg 发送成功的消息
 */
- (void)onSuccess:(nonnull AIMPubMessage *)msg {
    [AIMSimpleViewPresenter showAlert:@"Send Message success!"];
    [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"Send Message success!"]];
}

/**
 * 处理失败，返回失败原因
 * @param error 失败信息
 */
- (void)onFailure:(nonnull DPSError *)error {
    [AIMSimpleViewPresenter showAlert:@"Send Message failed!"];
    [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"Send Message failed: %@", error]];
}

#pragma mark - AIMPubMsgListener

/**
 * 消息新增
 * 发送消息或收到推送消息时，触发该回调
 * 当从服务端拉取历史消息时，不会触发该回调
 * @param newMsgs 新增消息
 */
- (void)onAddedMessages:(nonnull NSArray<AIMPubNewMessage *> *)newMsgs {
    [self showDetailLogInfoFromNewMessageArray:newMsgs WithTitle:@"OnAddedMessages"];
    for (AIMPubNewMessage *newMsg in newMsgs) {
        [self getMessageContent:newMsg.msg];
    }
}

/**
 * 消息删除
 * @param msgs 变更消息
 */
- (void)onRemovedMessages:(nonnull NSArray<AIMPubMessage *> *)msgs {
    [self showDetailLogInfoFromMessageArray:msgs WithTitle:@"OnRemovedMessages"];
    for (AIMPubMessage *newMsg in msgs) {
        [self getMessageContent:newMsg];
    }
}

/**
 * 当消息数据库内有消息添加时，触发该回调
 * 包括发送，推送及拉取历史消息
 * 注意：
 * 1. 不保证传入消息 msgs 的顺序
 * 2. OnStored 回调的顺序也不保证消息组间的顺序
 * @param msgs 变更消息
 */
- (void)onStoredMessages:(nonnull NSArray<AIMPubMessage *> *)msgs {
    [self showDetailLogInfoFromMessageArray:msgs WithTitle:@"OnStoredMessages"];
    for (AIMPubMessage *newMsg in msgs) {
        [self getMessageContent:newMsg];
    }
}

#pragma mark - AIMPubMsgChangeListener

/**
 * 消息未读数变更，作为消息的发送者，表示单聊对方或者群聊群内其他成员
 * 没有读取该条消息的人数，如果未读数是0，表示所有人已读
 * @param msgs 发生变化的消息(有效字段cid/mid/unread_count）
 */
- (void)onMsgUnreadCountChanged:(nonnull NSArray<AIMPubMessage *> *)msgs {
    [self showDetailLogInfoFromMessageArray:msgs WithTitle:@"OnMsgUnreadCountChanged"];
}

/**
 * 消息未读数变更，作为消息的接收者，多端同步消息已读状态
 * @param msgs 发生变化的消息(有效字段cid/mid/is_read）
 */
- (void)onMsgReadStatusChanged:(nonnull NSArray<AIMPubMessage *> *)msgs {
    [self showDetailLogInfoFromMessageArray:msgs WithTitle:@"OnMsgReadStatusChanged"];
}

/**
 * 消息扩展信息变更
 * @param msgs 发生变化的消息(有效字段cid/mid/extension)
 */
- (void)onMsgExtensionChanged:(nonnull NSArray<AIMPubMessage *> *)msgs {
    [self showDetailLogInfoFromMessageArray:msgs WithTitle:@"OnMsgExtensionChanged"];
}

/**
 * 消息被撤回
 * @param msgs 发生变化的消息(有效字段cid/mid/is_recall字段)
 */
- (void)onMsgRecalled:(nonnull NSArray<AIMPubMessage *> *)msgs {
    [self showDetailLogInfoFromMessageArray:msgs WithTitle:@"OnMsgRecalled"];
}

/**
 * 当消息数据库内有消息添加时，触发该回调
 * 包括发送，推送及拉取历史消息
 * 注意：
 * 1. 不保证传入消息 msgs 的顺序
 * 2. OnStored 回调的顺序也不保证消息组间的顺序
 * @param msgs 变更消息
 */
- (void)onMsgLocalExtensionChanged:(nonnull NSArray<AIMPubMessage *> *)msgs {
    [self showDetailLogInfoFromMessageArray:msgs WithTitle:@"OnMsgLocalExtensionChanged"];
}

/**
 * 业务方自定义消息扩展信息变更
 * @param msgs 发生变化的消息(有效字段cid/mid/user_extension字段)
 */
- (void)onMsgUserExtensionChanged:(nonnull NSArray<AIMPubMessage *> *)msgs {
    [self showDetailLogInfoFromMessageArray:msgs WithTitle:@"OnMsgUserExtensionChanged"];
}

/**
 * 消息状态变更，比如：消息状态从发送中变成了发送失败
 * @param msgs
 * 发生变化的消息(有效字段status/mid/created_at/unread_count/receiver_count/content)
 */
- (void)onMsgStatusChanged:(nonnull NSArray<AIMPubMessage *> *)msgs {
    [self showDetailLogInfoFromMessageArray:msgs WithTitle:@"OnMsgStatusChanged"];
}

/**
 * 消息发送进度变更
 * @param progress 发送进度
 */
- (void)onMsgSendMediaProgressChanged:(nonnull AIMMsgSendMediaProgress *)progress {
    [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"OnMsgSendMediaProgressChanged info: %f", progress.progress]];
}

@end

