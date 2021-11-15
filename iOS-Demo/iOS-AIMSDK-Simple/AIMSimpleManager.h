//
//  AIMSimpleManager.h
//  iOS-AIMSDK-Simple
//
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>
#import <libdps/DPSAuthListener.h>
#import "AIMSimpleDefines.h"

#import "AIMSimpleManagerContainer.h"
#import "AIMSimpleConversationService.h"
#import "AIMSimpleMessageService.h"
#import "AIMManagerContainerDelegate.h"

NS_ASSUME_NONNULL_BEGIN
@class DPSPubManager;
@class DPSAuthToken;
@class AIMAuthService;

@interface AIMSimpleManager : NSObject <DPSAuthListener,NSURLSessionDelegate>

@property (nonatomic, strong) AIMSimpleConversationService *conversationService;
@property (nonatomic, strong) AIMSimpleMessageService *messageService;

@property (nonatomic, strong) DPSPubManager *manager;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) DPSAuthToken *authToken;

@property (class, nonatomic, nullable) AIMSimpleManager *lastSimpleManager;
@property (nonatomic, weak) id <DPSPubManagerContainerDelegate> delegate;
/**
 * @初始化创建SimpleManager对象
 *
 * @param managerContainer  AIMSimpleManager对应归属的AIMSimpleManagerContainer
 */
- (instancetype)initWithContainer:(AIMSimpleManagerContainer *)managerContainer;
/**
 * @创建IMManager对象
 *
 * @param userId  AIMSimpleManager中IMManager对应的用户信息userId
 */
- (void)createIMManager:(NSString *)userId success:(void (^)(DPSPubManager *))success failed:(void (^)(DPSError *))failed;
/**
 * @对应的IMManager进行登录操作
 */
- (void)doLogin;
/**
 * @IMManager登出操作
 *
 * @param completion 登出操作状态回调
 */
- (void)logoutWithCompletion:(AIMNullableCompletion)completion;
/**
 * @添加监听器操作
 */
- (void)addListeners;
/**
 * @添加监听器操作
 */
- (void)removeListeners;
/**
 * @向业务方服务器发起token请求
 *
 * @param completion 请求状态回调
 */
- (void)requestTokenWithCompletion:(AIMNSNullableCompletion)completion;

@end
NS_ASSUME_NONNULL_END
