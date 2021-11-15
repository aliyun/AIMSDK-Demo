//
//  ViewController.h
//  iOS-AIMSDK-Simple
//
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AIMSimpleManagerContainer.h"

typedef void (^CallBackUIActivedReceiverLabelBlock)(NSString *uidText);
typedef void (^CallBackUIActivedManagerLabelBlock)(NSString *uidText);
typedef void (^CallBackUIActivatedConversationBlock)(AIMPubConversation *conversation);

@class AIMPubConversation;
@interface ViewController : UIViewController<UIActionSheetDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, copy)CallBackUIActivedReceiverLabelBlock callBackUIActivedReceiverLabelBlock;
@property (nonatomic, copy)CallBackUIActivedManagerLabelBlock callBackUIActivedManagerLabelBlock;
@property (nonatomic, copy)CallBackUIActivatedConversationBlock callBackUIActivatedConversationBlock;

@property (nonatomic) AIMSimpleManagerContainer *managerContainer;

@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *receiverIDLabel;
@property (weak, nonatomic) IBOutlet UITextView *logInfoTextView;
//engine related click action
- (IBAction)startEngineButton:(UIButton *)sender;
- (IBAction)releaseEngineButton:(UIButton *)sender;
- (IBAction)clearLogButton:(UIButton *)sender;
//manager related button click action
- (IBAction)createManagerButton:(UIButton *)sender;
- (IBAction)releaseManagerButton:(UIButton *)sender;
- (IBAction)resetLocalDBButton:(UIButton *)sender;
- (IBAction)switchManagerButton:(UIButton *)sender;
//login/logout related button click action
- (IBAction)loginButton:(UIButton *)sender;
- (IBAction)logoutButton:(UIButton *)sender;
//conversation service related button click action
- (IBAction)createConversationButton:(UIButton *)sender;
- (IBAction)listConversationButton:(UIButton *)sender;
- (IBAction)enterConversationButton:(UIButton *)sender;
//message service related button click action
- (IBAction)sendMsgButton:(UIButton *)sender;
- (IBAction)sendImageButton:(UIButton *)sender;
- (IBAction)downloadImageButton:(UIButton *)sender;
//universal button click action
- (IBAction)buttonPressed:(UIButton *)sender;
- (IBAction)shareLogButton:(UIButton *)sender;

@end

