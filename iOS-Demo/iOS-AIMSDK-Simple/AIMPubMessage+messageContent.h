//
//  AIMPubMessage+messageContent.h
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/7/13.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <libdps/DPSPubManager.h>
#import <libaim/AIMPubMessage.h>

NS_ASSUME_NONNULL_BEGIN

@interface AIMPubMessage (messageContent)

- (NSString *)messageContent;

@end

NS_ASSUME_NONNULL_END
