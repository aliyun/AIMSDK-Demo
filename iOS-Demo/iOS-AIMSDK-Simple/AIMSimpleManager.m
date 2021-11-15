//
//  AIMSimpleManager.m
//  iOS-AIMSDK-Simple
//
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <libdps/DPSAuthToken.h>
#import <libdps/DPSPubManager.h>
#import <libdps/DPSAuthService.h>
#import <libaim/AIMPUbMsgService.h>
#import <libaim/AIMPubConvService.h>
#import <libdps/DPSConnectionStatus.h>
#import "AIMSimpleManager.h"
#import "AIMSimpleDefines.h"
#import "AIMSimpleLogger.h"
#import "AIMEnvironmentConfiguration.h"
#import "AIMSimpleConversationService.h"
#import "AIMSimpleViewPresenter.h"
#import "AIMSimpleEngine.h"
#import <libaim/AIMPubModule.h>

static AIMSimpleManager *lastSimpleManager = nil;

@implementation AIMSimpleManager

- (instancetype)initWithContainer:(AIMSimpleManagerContainer *)managerContainer {
    self = [super init];
    if(self) {
        self.conversationService = [[AIMSimpleConversationService alloc] initWithSimpleManager:self];
        self.messageService = [[AIMSimpleMessageService alloc] initWithSimpleManager:self];
        self.authToken = [DPSAuthToken new];
        self.delegate = managerContainer;
    }

    return self;
}

+ (void)setLastSimpleManager:(AIMSimpleManager *)lastSimpleManagerInstance {
    lastSimpleManager = lastSimpleManagerInstance;
}

+ (AIMSimpleManager *)lastSimpleManager {
    return lastSimpleManager;
}

- (void)createIMManager:(NSString *)userId
                success:(void (^)(DPSPubManager *))success
                 failed:(void (^)(DPSError *))failed {
    [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"create manager with user id: %@", userId]];
    
    AIM_WEAK_SELF
    if (userId) {
        [[AIMSimpleEngine shareInstance] startSimpleEngineWithCompletion:^(DPSError * _Nullable error) {
            if (error) {
                [AIMSimpleLogger errorInfo:[[NSString alloc]initWithFormat:@"%@", error]];
                return;
            }
            
            [[DPSPubEngine getDPSEngine] createDPSManagerWithBlock:userId
            onSuccess:^(DPSPubManager *_Nullable manager) {
                if (manager) {
                    dispatch_async_on_main_queue(^{
                        AIM_STRONG_WEAK_SELF_AND_RETURN_IF_NULL
                        strongSelf.manager = manager;
                        strongSelf.userId = userId;
                        AIMSimpleManager.lastSimpleManager = strongSelf;
                        [strongSelf removeListeners];
                        [strongSelf addListeners];
                        if(success) {
                            success(manager);
                        }
                    });
                }
            }
            onFailure:^(DPSError *_Nonnull error) {
                if (error) {
                    if(failed) {
                        dispatch_async_on_main_queue(^{
                            failed(error);
                        });
                    }
                }
            }];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
}

- (void)requestTokenWithCompletion:(AIMNSNullableCompletion)completion {
    AIMNSNullableCompletion callBack = ^(NSError *error) {
        if (completion) {
            if (error) {
                [AIMSimpleLogger errorInfo:[NSString stringWithFormat:@"%@", error]];
                completion(error);
            } else {
                completion(nil);
            }
        }
    };

    AIMEnvironmentConfiguration *configuration = [AIMEnvironmentConfiguration shareInstance];

    NSString *tokenUrl = configuration.tokenUrl;
    NSString *appKey = configuration.appKey;
    NSString *deviceId = configuration.deviceId;
    NSString *domain = configuration.appID;

    NSString *reqUrl = [NSString stringWithFormat:@"%@?domain=%@&appuid=%@&deviceId=%@&appkey=%@&unit=nanTong", tokenUrl,
                                                  domain, self.userId, deviceId, appKey];
    
    [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"token request url==>%@", reqUrl]];

    NSURL *url = [NSURL URLWithString:reqUrl];
    NSURLSession *session =
        [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                      delegate:self
                                 delegateQueue:[NSOperationQueue mainQueue]];
    AIM_WEAK_SELF
    NSURLSessionDataTask *dataTask = [session
          dataTaskWithURL:url
        completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            if (error == nil) {
                NSError *jsonError = nil;
                NSDictionary *dataInfo = nil;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:(&jsonError)];
                // Normal Case: return an Array object
                if ([jsonObject isKindOfClass:[NSArray class]]) {
                    jsonObject = ((NSArray *)jsonObject).firstObject;
                }

                // Abnormal Case: return Dictionary, error from the server
                if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                    dataInfo = jsonObject;
                }
                AIM_STRONG_WEAK_SELF_AND_RETURN_IF_NULL
                dispatch_async_on_main_queue(^{
                    if (jsonError == nil) {
                        [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"~~~~~~~~~~~~~~~~Token Request "
                                                                            @"Begin~~~~~~~~~~~~~~~~~~~~~~~~~~"]];
                        [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"%@", dataInfo]];
                        [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"~~~~~~~~~~~~~~~~Token Request "
                                                                            @"End~~~~~~~~~~~~~~~~~~~~~~~~~~"]];

                        strongSelf.authToken.accessToken = dataInfo[@"accessToken"];
                        strongSelf.authToken.refreshToken = dataInfo[@"refreshToken"];
                    }

                    NSError *resultError = jsonError;
                    if (resultError == nil) {
                        if (strongSelf.authToken.accessToken.length == 0 || strongSelf.authToken.refreshToken.length == 0) {
                            resultError =
                                [NSError errorWithDomain:@""
                                                    code:-2
                                                userInfo:@{NSLocalizedDescriptionKey: @"fetch token with empty value"}];
                        }
                    }
                    callBack(resultError);
                });
            } else {
                callBack(error);
            }
        }];
    [dataTask resume];
}

- (void)doLogin {
    DPSPubEngine *engine = [DPSPubEngine getDPSEngine];
    if (engine == nil) {
        [AIMSimpleLogger errorInfo:@"Please create the engine first!"];
        return;
    }

    if (self) {
        [[self.manager getAuthService] login];
    } else {
        [AIMSimpleLogger errorInfo:@"Please create the manager first!"];
        return;
    }
};

- (void)logoutWithCompletion:(AIMNullableCompletion)completion {
    AIMNullableCompletion callBack = ^(DPSError *error) {
        if (completion != nil) {
            completion(error);
            if (error != nil) {
                [AIMSimpleLogger errorInfo:[NSString stringWithFormat:@"log out failed with info:%@", error]];
            } else {
                [AIMSimpleLogger logInfo:@"log out success!"];
                [self.conversationService.conversationCollectionList removeAllObjects];
            }
        }
    };

    DPSPubEngine *engine = [DPSPubEngine getDPSEngine];
    if (engine == nil) {
        [AIMSimpleLogger errorInfo:@"engine is null"];
        return;
    }

    if (self.manager == nil) {
        [AIMSimpleLogger errorInfo:@"manager is null"];
        return;
    }
    DPSAuthService *authService = [self.manager getAuthService];

    if (authService == nil) {
        [AIMSimpleLogger errorInfo:@"auth service is not running"];
        return;
    }
    
    [authService logoutWithBlock:^{
        dispatch_async_on_main_queue(^{
            callBack(nil);
        });
    } onFailure:^(DPSError * _Nonnull error) {
        dispatch_async_on_main_queue(^{
            callBack(error);
        });
    }];
}

- (void)addListeners {
    NSString* userID = [AIMSimpleManager.lastSimpleManager.manager getUserId];
    AIMPubModule* module = [AIMPubModule getModuleInstance:userID];
    AIMPubConvService* convService = [module getConvService];
    AIMPubMsgService* msgService = [module getMsgService];

    [[self.manager getAuthService] addListener:self];
    [msgService addMsgListener:self.messageService];
    [msgService addMsgChangeListener:self.messageService];
    [convService addConvChangeListener:self.conversationService];
    [convService addConvListListener:self.conversationService];
}

- (void)removeListeners {
    NSString* userID = [AIMSimpleManager.lastSimpleManager.manager getUserId];
    AIMPubModule* module = [AIMPubModule getModuleInstance:userID];
    AIMPubConvService* convService = [module getConvService];
    AIMPubMsgService* msgService = [module getMsgService];
    [[self.manager getAuthService] removeListener:self];
    [msgService removeMsgListener:self.messageService];
    [msgService removeMsgChangeListener:self.messageService];
    [convService removeConvListListener:self.conversationService];
    [convService removeConvChangeListener:self.conversationService];
}

#pragma mark -AIMPubAuthListener
/**
 * 连接状态事件
 * @param status      网络状态
 */
- (void)onConnectionStatusChanged:(DPSConnectionStatus)status {
    NSString *connectionStatus = [NSString new];
    switch (status) {
        case DPSConnectionStatusCsUnconnected:
            connectionStatus = @"Disconnected";
            break;
        case DPSConnectionStatusCsConnecting:
            connectionStatus = @"Try connecting";
            break;
        case DPSConnectionStatusCsConnected:
            connectionStatus = @"Connected, not login";
            break;
        case DPSConnectionStatusCsAuthing:
            connectionStatus = @"OnLoginProgress";
            break;
        case DPSConnectionStatusCsAuthed:
            connectionStatus = @"Login success";
            break;
        default:
            break;
    };
  
    dispatch_async_on_main_queue(^{
        [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"network status: %@",connectionStatus]];
      [AIMSimpleViewPresenter showAlert:[NSString stringWithFormat:@"network status: %@", connectionStatus]];
    });
}
/**
 * 登录token获取失败事件
 * @param errorCode  获取登录token失败错误值
 * @param errorMsg   获取登录token失败错误信息
 */
- (void)onGetAuthCodeFailed:(int32_t)errorCode errorMsg:(nonnull NSString *)errorMsg {
    dispatch_async_on_main_queue(^{
      [AIMSimpleLogger errorInfo:@"fetch token failed from callback"];
    });
    
}
/**
 * 本地登录事件
 * 如果本地已有登录信息，创建账号后会立即回调；反之会等待网络登录成功之后回调
 */
- (void)onLocalLogin {
    dispatch_async_on_main_queue(^{
      [AIMSimpleViewPresenter showAlert:@"Login success!"];
    });
    
}
/**
 * 被踢事件
 * @param message     被踢下线时附带的消息
 */
- (void)onKickout:(nonnull NSString *)message {
    dispatch_async_on_main_queue(^{
      [AIMSimpleViewPresenter showAlert:[NSString stringWithFormat:@"Manager has been kicked out!%@", message]];
    });
    if([self.delegate respondsToSelector:@selector(removeFromManagerContainerWithTarget:)]) {
        [self.delegate removeFromManagerContainerWithTarget:self];
    }
}
/**
 * 其他端设备在（离）线情况
 * @param type        事件类型（1：事件通知，包括上下线，2：状态通知，在线状态）
 * @param deviceType 设备类型
 * （0:default,1:web,2:Android,3:iOS,4:Mac,5:Windows,6:iPad）
 * @param status      设备状态（1：上线或在线，2：下线或离线）
 * @param time        时间（上线或下线时间）
 */
- (void)onDeviceStatus:(int32_t)type deviceType:(int32_t)deviceType status:(int32_t)status time:(int64_t)time {
}
/**
 * 下载资源cookie变更事件
 * @param cookie      新cookie
 */
- (void)onMainServerCookieRefresh:(nonnull NSString *)cookie {
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:@"dd_sid" forKey:NSHTTPCookieName];
    [cookieProperties setObject:cookie forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@".dingtalk.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    // 30 days expire
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];

    NSHTTPCookie *nsCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:nsCookie];
}

@end
