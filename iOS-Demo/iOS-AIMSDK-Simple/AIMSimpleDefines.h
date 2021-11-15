//
//  AIMSimpleDefines.h
//  iOS-AIMSDK-Simple
//
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#ifndef AIMSimpleDefines_h
#define AIMSimpleDefines_h

/**
 those headers are heavily used in common
*/
#import <libdps/DPSPubEngine.h>
#import <libdps/DPSPubManager.h>
#import <libdps/DPSError.h>

#define AIM_WEAK_SELF __weak __typeof__(self) weakSelf = self;
#define AIM_STRONG_WEAK_SELF __strong __typeof__(weakSelf) strongSelf = weakSelf;
#define AIM_STRONG_WEAK_SELF_AND_RETURN_IF_NULL \
__strong typeof(weakSelf) strongSelf = weakSelf;  \
if (self == nil) {  \
    return; \
}

typedef NS_ENUM(NSInteger, AIMSimpleErrCode) {
    /**
     * 空入参错误
     */
    AIMSimpleErrCodeInCompleteParams,
    /**
     * 空入参错误
     */
    AIMSimpleErrCodeduplicateInstance,
};

typedef NS_ENUM(NSInteger, AIMSimpleErrDomain) {
  /**
   * 客户端错误
   */
  AIMSimpleErrDomainDomainClient,
  /**
   * 服务端错误
   */
  AIMSimpleErrDomainServer
};

/**
 inline methods for those tasks that must be run on the main thread, e.g.,everything that interacts with the UI
 */
static inline void dispatch_async_on_main_queue(void (^_Nullable block)(void)) {
    if (block == nil) {
        return;
    }

    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/**
 type define for types of completion
 */
typedef void (^AIMNSNullableCompletion)(NSError *_Nullable error);
typedef void (^AIMNSNoNullCompletion)(NSError *_Nonnull error);
typedef void (^AIMNullableCompletion)(DPSError *_Nullable error);
typedef void (^AIMNoNullCompletion)(DPSError *_Nonnull error);

#endif /* AIMSimpleDefines_h */
