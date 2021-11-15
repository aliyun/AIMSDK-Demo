
//
//  ViewController.m
//  iOS-AIMSDK-Simple
//
//  Copyright © 2019 The Alibaba DingTalk Authors. All rights reserved.
//
#import <libaim/AIMPubConversation.h>
#import <libdps/DPSAuthService.h>
#import <libaim/AIMPubConvService.h>
#import <libaim/AIMPubModule.h>
#import "ViewController.h"
#import "AIMEnvironmentConfiguration.h"
#import "AIMSimpleManager.h"
#import "AIMSimpleManagerContainer.h"
#import "AIMSimpleDefines.h"
#import "AIMSimpleEngine.h"
#import "AIMSimpleConversationService.h"
#import "AIMSimpleMessageService.h"
#import "AIMSimpleLogger.h"
#import "AIMSimpleViewPresenter.h"
#import "NSNotificationCenter+PostNotificationWithKeyAndValue.h"

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // initial the status on UI and converationArray for selected user, in case of callback exception
    self.userIDLabel.text = @"empty";
    self.receiverIDLabel.text = @"empty";
    self.managerContainer = [AIMSimpleManagerContainer new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lastSimpleManagerShouldSwitch:) name:AIMSwitchLastSimpleManagerNotification object:nil];
    
    [AIMSimpleLogger initWithTextView:self.logInfoTextView];
    [AIMSimpleViewPresenter initWithMainViewControl:self];
    AIM_WEAK_SELF
    self.callBackUIActivedManagerLabelBlock = ^(NSString *uidText) {
        dispatch_async_on_main_queue(^{
            if (uidText != nil) {
                weakSelf.userIDLabel.text = uidText;
            } else {
                weakSelf.userIDLabel.text = @"empty";
            }
        });
    };
    self.callBackUIActivedReceiverLabelBlock = ^(NSString *uidText) {
        dispatch_async_on_main_queue(^{
            if (uidText != nil) {
                weakSelf.receiverIDLabel.text = uidText;
            } else {
                weakSelf.receiverIDLabel.text = @"empty";
            }
        });
    };
    self.callBackUIActivatedConversationBlock = ^(AIMPubConversation *conversation) {
        if (conversation != nil) {
            if (conversation.userids != nil && conversation.userids.count > 0) {
                weakSelf.callBackUIActivedReceiverLabelBlock(conversation.userids[1]);
            } else {
                weakSelf.callBackUIActivedReceiverLabelBlock(conversation.appCid);
            }
            NSString* userID = [AIMSimpleManager.lastSimpleManager.manager getUserId];
            AIMPubModule* module = [AIMPubModule getModuleInstance:userID];
            AIMPubConvService* convService = [module getConvService];
            
            AIMSimpleManager.lastSimpleManager.conversationService.activatedConversation = conversation;
            [convService setActiveCid:conversation.appCid];
        } else {
            weakSelf.callBackUIActivedReceiverLabelBlock(nil);
        }
    };
}

- (IBAction)buttonPressed:(UIButton *)sender {
    // remain empty, for univerisal handle of button click event
}

- (IBAction)loginButton:(UIButton *)sender {
    NSString *userId = self.userIDLabel.text;
    if ([userId isEqual:@"empty"]) {
        [AIMSimpleLogger errorInfo:@"please enter the user id first!"];
        return;
    } else if (![userId isEqualToString:AIMSimpleManager.lastSimpleManager.userId]) {
        [AIMSimpleLogger errorInfo:@"the user id is not matched with lastSimpleManager!"];
    } else {
        [AIMSimpleManager.lastSimpleManager doLogin];
    }
}

- (IBAction)logoutButton:(UIButton *)sender {
    if (AIMSimpleManager.lastSimpleManager == nil) {
        [AIMSimpleLogger errorInfo:@"None of the manager is initlized"];
        return;
    }
    AIM_WEAK_SELF
    [AIMSimpleManager.lastSimpleManager logoutWithCompletion:^(DPSError *_Nullable error) {
        if (error == nil) {
            [AIMSimpleViewPresenter showAlert:@"log out success"];
            [AIMSimpleLogger logInfo:@"log out success"];
            // clear the entered conversation list components
            weakSelf.callBackUIActivatedConversationBlock(nil);
        } else {
            [AIMSimpleViewPresenter showAlert:[NSString stringWithFormat:@"log out failed with info:%@", error]];
            [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"log out failed with info:%@", error]];
        }
    }];
}

- (IBAction)switchManagerButton:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ManagerList"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSMutableArray<AIMSimpleManager *> *managerListArray = [self.managerContainer simpleManagerContainer];
    for (AIMSimpleManager *managerElem in managerListArray) {
        [alertController addAction:[UIAlertAction actionWithTitle:managerElem.userId
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_Nonnull action) {
            [[NSNotificationCenter defaultCenter] postNotificationWithNotificationName:AIMSwitchLastSimpleManagerNotification contentKey:kSwitchLastSimpleManagerKey contentValue:managerElem.userId];
        }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)resetLocalDBButton:(UIButton *)sender {
    NSString *resetUserId = AIMSimpleManager.lastSimpleManager.userId;
    // stop the engine, in case any manager is still running
    [[AIMSimpleEngine shareInstance] releaseSimpleEngine];
    
    NSString *paths = [[AIMEnvironmentConfiguration shareInstance] dataPath];
    
    NSString* appID = [[AIMEnvironmentConfiguration shareInstance] appID];
    [DPSPubEngine resetUserDataWithBlock:paths userId:resetUserId appId:appID onSuccess:^{
        [AIMSimpleViewPresenter showAlert:@"reset cache success"];
        [AIMSimpleLogger logInfo:@"clean cache successfully!"];
        [self.managerContainer clearManagerContainer];
        
    } onFailure:^(DPSError * _Nonnull error) {
        [AIMSimpleViewPresenter showAlert:@"reset failed"];
        [AIMSimpleLogger errorInfo:[NSString stringWithFormat:@"clean cache failed with info: %@", error]];
        [self.managerContainer clearManagerContainer];
    }];
}

- (IBAction)createManagerButton:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter uid"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // define the confirm button
    [alertController
     addAction:[UIAlertAction
                actionWithTitle:@"Enter"
                style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *_Nonnull action) {
        UITextField *titleTextField = alertController.textFields.firstObject;
        NSString *uidContent = [NSString stringWithFormat:@"%@", titleTextField.text];
        [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"%@", uidContent]];
        if (titleTextField.text != nil) {
            [AIMSimpleLogger
             logInfo:[NSString stringWithFormat:@"%@", titleTextField.text]];
            
            DPSPubEngine *engine = [DPSPubEngine getDPSEngine];
            if (engine != nil) {
                [self.managerContainer
                 addSimpleManagerWithUserId:titleTextField.text];
            } else {
                [AIMSimpleLogger logInfo:@"Please create engine first!"];
            }
        }
    }]];
    // define the cancel button
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    // define the text box with default user name
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.text = @"test001";
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)releaseManagerButton:(UIButton *)sender {
    if (AIMSimpleManager.lastSimpleManager.manager == nil) {
        [AIMSimpleLogger errorInfo:@"no manager available!!"];
        return;
    } else {
        NSString *userId = AIMSimpleManager.lastSimpleManager.userId;
        [self.managerContainer removeSimpleManagerWithUserId:userId];
    }
}

- (IBAction)clearLogButton:(UIButton *)sender {
    [AIMSimpleLogger clearLog];
}

- (IBAction)releaseEngineButton:(UIButton *)sender {
    [[AIMSimpleEngine shareInstance] releaseSimpleEngine];
    [self.managerContainer clearManagerContainer];
}

- (IBAction)startEngineButton:(UIButton *)sender {
    [[AIMSimpleEngine shareInstance] startSimpleEngine];
}

- (IBAction)sendMsgButton:(UIButton *)sender {
    // set the messageContent to default value, flexible to be changed
    NSString *messageContent = [NSString stringWithFormat:@"hello world!"];
    AIMSimpleConversationService *conversationService = AIMSimpleManager.lastSimpleManager.conversationService;
    if (conversationService == nil) {
        [AIMSimpleLogger errorInfo:@"Please make sure user is already initilized!"];
    } else {
        AIMSimpleMessageService *messageService = AIMSimpleManager.lastSimpleManager.messageService;
        [messageService sendText:messageContent withConversation:conversationService.activatedConversation];
    }
}

- (IBAction)sendImageButton:(UIButton *)sender {
    [AIMSimpleLogger logInfo:@"ready to send image"];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)downloadImageButton:(UIButton *)sender {
    AIMSimpleMessageService *messageService = AIMSimpleManager.lastSimpleManager.messageService;
    if (messageService == nil) {
        [AIMSimpleLogger errorInfo:@"Please make sure user is already initilized!"];
    } else {
        [messageService downloadImage];
    }
    
}

- (IBAction)enterConversationButton:(UIButton *)sender {
    NSMutableArray<AIMPubConversation *> *allConversations = AIMSimpleManager.lastSimpleManager.conversationService.conversationCollectionList;
    if (allConversations.count == 0) {
        [AIMSimpleViewPresenter showAlert:@"conversation List is empty!"];
        [AIMSimpleLogger errorInfo:[NSString stringWithFormat:@"conversation List is empty!"]];
    } else {
        UIAlertController *alertConvController =
        [UIAlertController alertControllerWithTitle:@"Conversation List"
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        
        for (AIMPubConversation *conversitonElem in allConversations) {
            NSString *myTitle = conversitonElem.appCid;
            AIM_WEAK_SELF
            [alertConvController
             addAction:[UIAlertAction actionWithTitle:myTitle
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *_Nonnull action) {
                weakSelf.callBackUIActivatedConversationBlock(conversitonElem);
            }]];
        };
        
        
        [alertConvController setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alertConvController popoverPresentationController];
        popPresenter.sourceView = sender;
        popPresenter.sourceRect = sender.bounds;
        
        [self presentViewController:alertConvController animated:TRUE completion:nil];
        [alertConvController
         addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    }
}

- (IBAction)listConversationButton:(UIButton *)sender {
    AIMSimpleConversationService *conversationServiceInstance = AIMSimpleManager.lastSimpleManager.conversationService;
    if (!conversationServiceInstance) {
        [AIMSimpleLogger errorInfo:@"conversation service is not initialized"];
    }
    
    AIM_WEAK_SELF
    [conversationServiceInstance loadConversationsWithCompletion:^(DPSError *_Nullable error) {
        if (error != nil) {
            [AIMSimpleViewPresenter showAlert:@"load conversation failed!"];
            [AIMSimpleLogger errorInfo:[NSString stringWithFormat:@"load conversation failed with info:%@\n", error]];
        } else {
            [AIMSimpleViewPresenter showAlert:@"load conversation success!"];
            [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"load conversation sucesss with details:\n"]];
            NSMutableArray<AIMPubConversation *> *allConversations =
            conversationServiceInstance.conversationCollectionList;
            for (AIMPubConversation *conversitonElem in allConversations) {
                [AIMSimpleLogger
                 logInfo:[NSString stringWithFormat:@"cid:%@ users:%@ convType:%d\n", conversitonElem.appCid,
                          conversitonElem.userids, (int)conversitonElem.type]];
            }
            
            if (allConversations.count > 0 && allConversations[0].userids.count >= 2) {
                weakSelf.callBackUIActivatedConversationBlock(allConversations[0]);
            } else {
                weakSelf.callBackUIActivatedConversationBlock(nil);
            }
        }
    }];
}

- (IBAction)createConversationButton:(UIButton *)sender {
    UIAlertController *alertConvController = [UIAlertController alertControllerWithTitle:@"Enter uid"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
    if (!AIMSimpleManager.lastSimpleManager) {
        [AIMSimpleLogger errorInfo:@"Please log in first!"];
        return;
    }
    
    [alertConvController
     addAction:[UIAlertAction
                actionWithTitle:@"Create Conversation"
                style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *_Nonnull action) {
        UITextField *titleTextField = alertConvController.textFields.firstObject;
        NSString *oppositeUidContent = [NSString stringWithFormat:@"%@", titleTextField.text];
        [AIMSimpleLogger logInfo:[NSString stringWithFormat:@"%@", oppositeUidContent]];
        if (titleTextField.text == nil) {
            [AIMSimpleLogger errorInfo:@"the forward user id is empty!"];
            return;
        }
        
        [AIMSimpleManager.lastSimpleManager.conversationService
         createSingleConversationWithUid:oppositeUidContent
         completion:^(DPSError *_Nullable error) {
            if (error != nil) {
                [AIMSimpleViewPresenter
                 showAlert:
                 [NSString
                  stringWithFormat:
                  @"create single conversation "
                  @"failed"]];
                [AIMSimpleLogger errorInfo:[NSString
                                          stringWithFormat:
                                          @"create single conversation failed with info:%@\n",
                                          error]];
                
            } else {
                self.callBackUIActivedReceiverLabelBlock(oppositeUidContent);
            }
        }];
        
    }]];
    
    [alertConvController
     addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    
    [alertConvController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.placeholder = @"oppsiteUidName";
    }];
    
    [self presentViewController:alertConvController animated:YES completion:nil];
}

- (IBAction)shareLogButton:(UIButton *)sender {
    NSString *logPath = [AIMEnvironmentConfiguration.shareInstance logPath];
    
    if (logPath == nil) {
        NSString *toast = [NSString stringWithFormat:@"Cannot find logs"];
        [AIMSimpleViewPresenter showAlert:toast];
        [AIMSimpleLogger errorInfo:[NSString
                                  stringWithFormat:
                                  @"Cannot find logs under the path"]];
        return;
    }
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy_MM_dd%HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    NSString *newLogPath = [[NSString stringWithFormat:@"%@_%@",[logPath stringByDeletingPathExtension], dateString] stringByAppendingPathExtension:[logPath pathExtension]];
    
    [[NSFileManager defaultManager] copyItemAtPath:logPath toPath:newLogPath error:nil];
    
    NSURL *logUrl = [NSURL fileURLWithPath:newLogPath];
    if (logUrl == nil) {
        return;
    }
    NSArray *activityItems = [NSArray arrayWithObject:logUrl];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark MainViewControllerDelegate

- (void)lastSimpleManagerShouldSwitch:(NSNotification *)notification {
    if (self.callBackUIActivatedConversationBlock) {
        self.callBackUIActivatedConversationBlock(nil);
    }
    
    NSString *userId = [notification.userInfo objectForKey:kSwitchLastSimpleManagerKey];
    if (userId && [userId isKindOfClass:[NSString class]]) {
        AIMSimpleManager.lastSimpleManager = [self.managerContainer simpleManagerByUserId:userId];
        if (self.callBackUIActivedManagerLabelBlock) {
            self.callBackUIActivedManagerLabelBlock(userId);
        }
    } else {
        if (self.callBackUIActivedManagerLabelBlock) {
            self.callBackUIActivedManagerLabelBlock(nil);
        }
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    NSString *chosenImagePath = [[info objectForKey:UIImagePickerControllerImageURL] path];
    
    AIMSimpleConversationService *conversationService = AIMSimpleManager.lastSimpleManager.conversationService;
    
    if (chosenImagePath == nil) {
        [AIMSimpleViewPresenter showAlert:@"Image Not Found"];
        [AIMSimpleLogger errorInfo:@"Please make sure the image path is correct"];
        return;
    }
    
    if (conversationService == nil) {
        [AIMSimpleViewPresenter showAlert:@"Not Login"];
        [AIMSimpleLogger errorInfo:@"Please make sure user is already initilized!"];
        return;
    }
    
    if (conversationService.activatedConversation == nil) {
        [AIMSimpleViewPresenter showAlert:@"Select conversation"];
        [AIMSimpleLogger errorInfo:@"No activated conversation has been selected"];
        return;
    }
    
    AIMSimpleMessageService *messageService = AIMSimpleManager.lastSimpleManager.messageService;
    [messageService sendImage:chosenImagePath withConversation:conversationService.activatedConversation];
}

@end
