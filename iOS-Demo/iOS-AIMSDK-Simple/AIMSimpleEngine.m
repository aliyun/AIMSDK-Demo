//
//  AIMSimpleEngine.m
//  iOS-AIMSDK-Simple
//
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <libdps/DPSPubSettingService.h>
#import <libdps/DPSPubAuthTokenCallback.h>
#import <libdps/DPSAuthToken.h>
#import <libdps/DPSErrClientCode.h>
#import "AIMSimpleEngine.h"
#import "AIMSimpleLogger.h"
#import "AIMSimpleManager.h"
#import "AIMSimpleManagerContainer.h"
#import "AIMEnvironmentConfiguration.h"
#import "AIMSimpleViewPresenter.h"
#import <libdps/DPSAuthTokenGotCallback.h>
#import <libaim/AIMPubModule.h>

@implementation AIMSimpleEngine

+ (instancetype)shareInstance {
    static AIMSimpleEngine *sharedSimpleEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSimpleEngine = [AIMSimpleEngine new];
    });
    return sharedSimpleEngine;
}

- (void)startSimpleEngine {
    DPSPubEngine *engine = [DPSPubEngine createDPSEngine];
    if (engine == nil) {
        [AIMSimpleLogger errorInfo:@"get engine failed"];
        return;
    }
    [AIMSimpleViewPresenter showAlert:@"start engine success"];
    [AIMSimpleLogger logInfo:@"get engine success"];
    
    [self configureSimpleEngine];
    DPSPubEngine *engineInstance = [DPSPubEngine getDPSEngine];
    [engineInstance start:self];
}

- (void)startSimpleEngineWithCompletion:(AIMNullableCompletion)completion {
    AIMNullableCompletion callBack = ^(DPSError *_Nullable error) {
        if (completion) {
            completion(error);
        }
    };
    
    DPSPubEngine *engine = [DPSPubEngine createDPSEngine];
    if (engine == nil) {
        [AIMSimpleLogger errorInfo:@"get engine failed"];
        return;
    }
    [AIMSimpleLogger logInfo:@"get engine success"];
    
    [self configureSimpleEngine];
    DPSPubEngine *engineInstance = [DPSPubEngine getDPSEngine];
    [engineInstance startWithBlock:^{
        if (completion) {
            callBack(nil);
        }
    } onFailure:^(DPSError * _Nonnull error) {
        if (completion) {
            callBack(error);
        }
    }];
}
/**
 configure engine with information from AIMEnvironmentConfiguration
 set default uploading address as empty, can be modified later for file
 uploading service
 */
- (void)configureSimpleEngine {
    DPSPubEngine *engineInstance = [DPSPubEngine getDPSEngine];
    DPSPubSettingService *settingService = [engineInstance getSettingService];
    
    AIMEnvironmentConfiguration *configurationInstance = [AIMEnvironmentConfiguration shareInstance];
    
    [settingService setAppKey:configurationInstance.appKey];
    [settingService setAppID:configurationInstance.appID];
    [settingService setDataPath:[configurationInstance dataPath]];
    [settingService setAppName:[configurationInstance appName]];
    [settingService setAppVersion:[configurationInstance appVersion]];
    [settingService setAppLocale:[configurationInstance appLocale]];
    [settingService setOSName:[configurationInstance osName]];
    [settingService setOSVersion:[configurationInstance osVersion]];
    [settingService setDeviceName:[configurationInstance deviceName]];
    [settingService setDeviceType:[configurationInstance deviceType]];
    [settingService setDeviceLocale:[configurationInstance deviceLocale]];
    [settingService setDeviceId:configurationInstance.deviceId];
    [settingService setTimeZone:[configurationInstance timeZoneName]];
    [settingService setEnvType:DPSEnvTypeEnvTypeOnline];
    AIM_WEAK_SELF [settingService setAuthTokenCallback:weakSelf];
    
    DPSModuleInfo* info = [AIMPubModule getModuleInfo];
    [engineInstance registerModule:info];
    
    [DPSPubEngine setLogHandler:DPSLogLevelDPSLOGLEVELDEBUG handler:self];
}

/**
 blocking for releasing engine
 */
- (void)releaseSimpleEngine {
    [AIMSimpleLogger logInfo:@"beginning release engine"];
    [DPSPubEngine releaseDPSEngine];
    [AIMSimpleLogger logInfo:@"finishing release engine"];
    [AIMSimpleViewPresenter showAlert:@"release engine success"];
}


- (void)onLog:(DPSLogLevel)logLevel logContent:(nonnull NSString *)logContent {
    NSLog(@"%@", logContent);
}

/**
 *对应于上方的设置回调操作
 *corresponding to the SetAuthTokenCallback action above
 *AIMSimpleManager is a cutomized data structure which
 *encapsulates DPSPubManager, AIMUserId, authToken and conversationListArray w.r.t. DPSPubManager
 */
#pragma mark DPSAuthTokenCallback

- (void)onCallback:(nonnull NSString *)userId onGot:(nullable DPSAuthTokenGotCallback *)onGot reason:(DPSAuthTokenExpiredReason)reason {
    [AIMSimpleManager.lastSimpleManager requestTokenWithCompletion:^(NSError *error) {
        if (error == nil) {
            DPSAuthToken *authToken = [[DPSAuthToken alloc] init];
            
            authToken.accessToken = AIMSimpleManager.lastSimpleManager.authToken.accessToken;
            authToken.refreshToken = AIMSimpleManager.lastSimpleManager.authToken.refreshToken;
            
            [onGot onSuccess:authToken];
        } else {
            [onGot onFailure:(int32_t)error.code errorMsg:error.localizedDescription];
        }
    }];
}

#pragma mark DPSPubEngineListener

/**
 * DB升级事件
 * @param uid 用户id
 */
- (void)onDBUpgradeStart:(nonnull NSString *)uid {
    [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"DB upgrade start for user: %@", uid]];
}

/**
 * DB升级进度
 * @param uid 用户id
 * @param progress 进度（0～1）
 */
- (void)onDBUpgradeProgress:(nonnull NSString *)uid progress:(double)progress {
    [AIMSimpleLogger
     logInfo:[NSString stringWithFormat:@"DB upgrade progress for user: %@ with progress: %f", uid, progress]];
}

/**
 * DB错误回调, 在数据库无法继续工作时发生此回调
 * @param uid 用户id
 * @param error 错误类型
 * error.code类型:
 * DB_FULL: 磁盘满，需提示用户进行磁盘清理操作，否则IM功能异常
 * DB_MAILFORMED:
 * 数据库异常，需在下次启动前调用engine.ResetUserData接口进行数据清理重置
 * DB_NO_MEMORY: 内存不足
 */
- (void)onDBError:(nonnull NSString *)uid error:(nonnull DPSError *)error {
    [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"DB error: %@", error]];
    switch (error.domain) {
        case DPSErrDomainDPSERRDOMAINCLIENT:
            [AIMSimpleLogger errorInfo:@"DB error from client side"];
            break;
        case DPSErrDomainDPSERRDOMAINSERVER:
            [AIMSimpleLogger errorInfo:@"DB error from server side, please consult server side"];
            break;
        default:
            break;
    }
    
    switch (error.code) {
        case DPSErrClientCodeDBFull:
            [AIMSimpleLogger errorInfo:@"DB full"];
            break;
        case DPSErrClientCodeDBMailformed:
            [AIMSimpleLogger errorInfo:@"Need app restart to restore, DB broken"];
            break;
        case DPSErrClientCodeDBNoMemory:
            [AIMSimpleLogger errorInfo:@"No memory"];
        default:
            break;
    }
}

#pragma mark DPSPubEngineStartListener
- (void)onSuccess {
    [AIMSimpleLogger logInfo:@"start engine success"];
}

- (void)onFailure:(DPSError *)error {
    [AIMSimpleLogger errorInfo:[NSString stringWithFormat:@"start engine failed:%@", error]];
}

@end
