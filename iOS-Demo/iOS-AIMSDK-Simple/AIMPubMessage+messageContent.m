//
//  AIMPubMessage+messageContent.m
//  iOS-AIMSDK-Simple
//
//  Created by longgong on 2020/7/13.
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <libaim/AIMMsgContentType.h>
#import "AIMPubMessage+messageContent.h"

@implementation AIMPubMessage (messageContent)

- (NSString *)messageContent {
    if (self.content.contentType == AIMMsgContentTypeContentTypeText) {
        return self.content.textContent.text;
    } else {
        NSString *retInfo = [NSString stringWithFormat:@"msg type: %ld", self.content.contentType];
        return retInfo;
    }
}

@end
