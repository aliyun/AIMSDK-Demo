//
//  AIMEnvironmentConfiguration.h
//  iOS-AIMSDK-Simple
//
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import "AIMSimpleDefines.h"

NS_ASSUME_NONNULL_BEGIN
@class DPSAuthToken;

//block definition for fetch token callback
typedef void(^AIMFailed)(NSError *error);

typedef void(^AIMFetchAuthTokenSuccess)(DPSAuthToken *authToken);

typedef void(^AIMFetchAuthTokenBlock)(NSString *userId, AIMFetchAuthTokenSuccess success, AIMFailed failed);

typedef NS_ENUM(short, AIMEnvironment) {
    // 线上环境
    AIMEnvironmenDistribution   = 0,
    // 预发环境
    AIMEnvironmentPrelease      = 1,
    // 日常环境
    AIMEnvironmentDaily         = 2,
};

/**
 Components for requesting token:appKey, tokenUrl, userDomain, bizType
 those can be used flexible latter on
 */
#define DEMO_DEFAUT_APP_KEY @"936ad5a85e104899953888fd957955f3"
#define DEMO_DEFAULT_APP_ID @"aim_demo"
#define DEMO_DEFAUT_TOKEN_URL @"https://impaas-apitest-intercept.public.dingtalk.com/getLoginToken"

@interface AIMEnvironmentConfiguration : NSObject

+ (instancetype)shareInstance;

/**
应用的唯一标识
*/
@property(nonatomic, copy) NSString* _Nonnull appKey;

/**
DingPaaS domain,用户域名
*/
@property(nonatomic, copy) NSString* _Nonnull appID;

/**
 网关长连接服务器地址
*/
@property(nonatomic, copy) NSString* _Nonnull longLinkAddr;

/**
token主机地址： token host
*/
@property(nonatomic, copy) NSString* _Nonnull tokenUrl;

/**
设备id：mocked deviceId based on UUID
*/
@property(nonatomic, copy) NSString* _Nonnull deviceId;

/**
 Demo 默认的业务标识
*/
@property(nonatomic, copy) NSString* _Nonnull bizType;

/**
应用的语言设置, 默认为设备的locale信息
*/
@property(nonatomic, copy) NSString* _Nonnull appLocale;

/**
 *线上环境
 *AIMEnvironmenDistribution   = 0,
 *预发环境
 *AIMEnvironmentPrelease      = 1,
 *日常环境
 *AIMEnvironmentDaily            = 2,
 */
@property (nonatomic) AIMEnvironment environment;

/**
默认数据存储地址
*/
@property(nonatomic, copy) NSString* _Nonnull dataPath;

/**
应用日志信息存储位置
*/
@property(nonatomic, copy) NSString* _Nonnull logPath;

/**
时区名称
*/
@property(nonatomic, copy) NSString* _Nonnull timeZoneName;

/**
应用名称
*/
@property(nonatomic, copy) NSString* _Nonnull appName;

/**
应用版本
*/
@property(nonatomic, copy) NSString* _Nonnull appVersion;

/**
设备名称
*/
@property(nonatomic, copy) NSString* _Nonnull deviceName;

/**
设备类型
*/
@property(nonatomic, copy) NSString* _Nonnull deviceType;

/**
系统名称
*/
@property(nonatomic, copy) NSString* _Nonnull osName;

/**
系统版本
*/
@property(nonatomic, copy) NSString* _Nonnull osVersion;

/**
设备的语言设置
*/
@property(nonatomic, copy) NSString* _Nonnull deviceLocale;

/**
 获取token的回调block
 当SDK需要业务方设置获取auth token时，会回调这个block,业务方调用对应获取
 auth token的接口，然后将结果回调到SDK
*/
@property (nonatomic, copy) AIMFetchAuthTokenBlock fetchTokenBlock;

@end
NS_ASSUME_NONNULL_END







