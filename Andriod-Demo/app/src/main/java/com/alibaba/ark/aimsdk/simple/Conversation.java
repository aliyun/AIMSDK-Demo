package com.alibaba.ark.aimsdk.simple;

import android.os.Handler;
import android.os.Looper;

import com.alibaba.dingpaas.aim.AIMConvTypingCommand;
import com.alibaba.dingpaas.aim.AIMConvTypingMessageContent;
import com.alibaba.dingpaas.aim.AIMPubConvChangeListener;
import com.alibaba.dingpaas.aim.AIMPubConvCreateSingleConvListener;
import com.alibaba.dingpaas.aim.AIMPubConvCreateSingleConvParam;
import com.alibaba.dingpaas.aim.AIMPubConvGetConvListener;
import com.alibaba.dingpaas.aim.AIMPubConvListListener;
import com.alibaba.dingpaas.aim.AIMPubConvService;
import com.alibaba.dingpaas.aim.AIMPubConversation;
import com.alibaba.dingpaas.aim.AIMPubMessage;
import com.alibaba.dingpaas.aim.AIMPubModule;
import com.alibaba.dingpaas.aim.AIMPubMsgListLocalMsgsListener;
import com.alibaba.dingpaas.aim.AIMPubMsgListPreviousMsgsListener;
import com.alibaba.dingpaas.aim.AIMPubMsgService;
import com.alibaba.dingpaas.base.DPSError;

import java.util.ArrayList;

public class Conversation {
    public static void registerEvents(String uid) {
        AIMPubModule manager = AIMPubModule.getModuleInstance(uid);
        if (manager == null) {
            return;
        }
        Logger.i("Register conv events");
        AIMPubConvService convService = manager.getConvService();
        convService.addConvChangeListener(new AIMPubConvChangeListener() {
            /**
             * 会话状态变更
             * @param convs 全量的会话结构
             */
            @Override
            public void onConvStatusChanged(ArrayList<AIMPubConversation> convs) {
                Logger.i("OnConvStatusChanged: convs:" + convs.size());
                for (AIMPubConversation conv : convs) {
                    Logger.i("cid: " + conv.appCid + " status:" + conv.status);
                }
            }

            /**
             * 会话最后一条消息变更
             * @param convs 全量的会话结构
             * 特殊场景:消息撤回时,last_msg中只有recall和mid有效。
             */
            @Override
            public void onConvLastMessageChanged(ArrayList<AIMPubConversation> convs) {
                Logger.i("OnConvLastMessageChanged: convs:" + convs.size());
                for (AIMPubConversation conv : convs) {
                    Logger.i("cid: " + conv.appCid + " mid:" + conv.lastMsg.getMid());
                }
            }

            /**
             * 会话未读消息数变更
             * @param convs 全量的会话结构
             */
            @Override
            public void onConvUnreadCountChanged(ArrayList<AIMPubConversation> convs) {
                Logger.i("OnConvUnreadCountChanged: convs:" + convs.size());
                for (AIMPubConversation conv : convs) {
                    Logger.i("cid: " + conv.appCid + " unread count:" + conv.getRedPoint());
                }
            }

            /**
             * 会话extension变更
             * @param convs 全量的会话结构
             */
            @Override
            public void onConvExtensionChanged(ArrayList<AIMPubConversation> convs) {
                Logger.i("OnConvExtensionChanged: convs:" + convs.size());
                for (AIMPubConversation conv : convs) {
                    Logger.i("cid: " + conv.appCid + " extension:" + conv.extension);
                }
            }

            /**
             * 会话local extension变更
             * @param convs 全量的会话结构
             */
            @Override
            public void onConvLocalExtensionChanged(ArrayList<AIMPubConversation> convs) {
                Logger.i("OnConvLocalExtensionChanged: convs:" + convs.size());
                for (AIMPubConversation conv : convs) {
                    Logger.i("cid: " + conv.appCid + " local extension:" + conv.localExtension);
                }
            }

            /**
             * 会话user extension变更
             * @param convs 全量的会话结构
             */
            @Override
            public void onConvUserExtensionChanged(ArrayList<AIMPubConversation> convs) {
                Logger.i("OnConvUserExtensionChanged: convs:" + convs.size());
                for (AIMPubConversation conv : convs) {
                    Logger.i("cid: " + conv.appCid + " user extension:" + conv.userExtension);
                }
            }

            /**
             * 会话是否通知的状态变更
             * @param convs 全量的会话结构
             */
            @Override
            public void onConvNotificationChanged(ArrayList<AIMPubConversation> convs) {
                Logger.i("OnConvNotificationChanged: convs:" + convs.size());
                for (AIMPubConversation conv : convs) {
                    Logger.i("cid: " + conv.appCid + " mute Notification:" + conv.muteNotification);
                }
            }

            /**
             * 会话置顶状态变更
             * @param convs 全量的会话结构
             */
            @Override
            public void onConvTopChanged(ArrayList<AIMPubConversation> convs) {
                Logger.i("OnConvTopChanged: convs:" + convs.size());
                for (AIMPubConversation conv : convs) {
                    Logger.i("cid: " + conv.appCid + " top:" + conv.topRank);
                }
            }

            /**
             * 会话草稿变更
             * @param convs 全量的会话结构
             */
            @Override
            public void onConvDraftChanged(ArrayList<AIMPubConversation> convs) {
                Logger.i("OnConvDraftChanged: convs:" + convs.size());
                for (AIMPubConversation conv : convs) {
                    Logger.i("cid: " + conv.appCid + " draft:" + conv.draft);
                }
            }

            /**
             * 接收到正在输入事件
             * @param cid  	会话id
             * @param command   TypingCommand
             * @param type TypingMessageContent
             */
            @Override
            public void onConvTypingEvent(String cid, AIMConvTypingCommand command, AIMConvTypingMessageContent type) {
                Logger.i("OnConvTypingEvent: convs:" + cid + " command:" + command + " " + type);
            }

            /**
             * 会话消息被清空
             * @param convs 有效字段cid
             */
            @Override
            public void onConvClearMessage(ArrayList<AIMPubConversation> convs) {
                Logger.i("OnConvClearMessage: convs:" + convs.size());
                for (AIMPubConversation conv : convs) {
                    Logger.i("cid: " + conv.appCid);
                }
            }
        });

        convService.addConvListListener(new AIMPubConvListListener() {
            /**
             * 新增会话
             * @param convs 新增的会话集合
             */
            @Override
            public void onAddedConversations(ArrayList<AIMPubConversation> convs) {
                Logger.i("OnConvUTagsChanged: convs:" + convs.size());
                for (AIMPubConversation conv : convs) {
                    Logger.i("cid: " + conv.appCid);
                }
            }

            /**
             * 删除会话
             * @param cids 删除的会话cid集合
             */
            @Override
            public void onRemovedConversations(ArrayList<String> cids) {
                Logger.i("OnRemovedConversations: cids:" + cids);
            }

            /**
             * 所有会话被更新替换
             * @param convs 更新后的会话集合
             */
            @Override
            public void onRefreshedConversations(ArrayList<AIMPubConversation> convs) {
                Logger.i("OnRefreshedConversations: convs:" + convs.size());
                for (AIMPubConversation conv : convs) {
                    Logger.i("cid: " + conv.appCid);
                }
            }
        });
    }

    public static void listAllConvs(String uid, final AIMPubConvGetConvListener callback) {
        AIMPubModule service = AIMPubModule.getModuleInstance(uid);
        AIMPubConvService convService = service.getConvService();
        if (convService == null) {
            return;
        }
        convService.listLocalConversationsWithOffset(0, 100, new AIMPubConvGetConvListener() {
            @Override
            public void onSuccess(final ArrayList<AIMPubConversation> arrayList) {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            callback.onSuccess(arrayList);
                        }
                    }
                });
            }

            @Override
            public void onFailure(DPSError aimError) {
                Logger.e("Failed to get convs:" + aimError);
            }
        });
    }

    public static void enterConversation(String uid, final String cid) {
        AIMPubModule manager = AIMPubModule.getModuleInstance(uid);
        if (manager == null) {
            return;
        }
        AIMPubConvService convService = manager.getConvService();
        if (convService == null) {
            return;
        }
        final AIMPubMsgService msgService = manager.getMsgService();
        if (msgService == null) {
            return;
        }
        Logger.i("Set active cid:" + cid);
        convService.setActiveCid(cid);
        Logger.i("List local conv messages:");

        // ReadMe: https://yuque.antfin-inc.com/aimsdk/doc/rwx6qd
        msgService.listPreviousLocalMsgs(cid, AIMPubMsgService.AIM_MAX_MSG_CURSOR, 100, new AIMPubMsgListLocalMsgsListener() {
            /**
             * 处理成功，返回连续的消息对象
             * @param msgs 消息列表
             * @param has_more 是否有更多消息
             */
            @Override
            public void onSuccess(ArrayList<AIMPubMessage> msgs, boolean has_more) {
                Logger.i("Local msgs received: " + msgs.size() + " has_more:" + has_more);
                Logger.i("----- Local -----");
                for (AIMPubMessage msg : msgs) {
                    Logger.i(Message.getMsgContent(msg));
                }
                Logger.i("-----Local End-----");
                if (msgs.size() > 0 && msgs.size() < 100) {
                    AIMPubMessage lastMessage = msgs.get(0);
                    msgService.listPreviousMsgs(cid, lastMessage.createdAt, 100, new AIMPubMsgListPreviousMsgsListener() {
                        @Override
                        public void onSuccess(ArrayList<AIMPubMessage> msgs, boolean has_more) {
                            Logger.i("Remote msgs received: " + msgs.size() + " has_more:" + has_more);
                            Logger.i("----- Remote -----");
                            for (AIMPubMessage msg : msgs) {
                                Logger.i(Message.getMsgContent(msg));
                            }
                            Logger.i("-----Remote End-----");
                        }

                        @Override
                        public void onFailure(ArrayList<ArrayList<AIMPubMessage>> arrayList, DPSError aimError) {
                            Logger.i("Failed to get remote msgs: " + aimError);
                        }
                    });
                }
            }

            @Override
            public void onFailure(DPSError aimError) {
                Logger.i("Failed to get local msgs: " + aimError);
            }
        });
    }

    public static void createSingleConversation(String uid, String otherId) {
        AIMPubModule manager = AIMPubModule.getModuleInstance(uid);
        if (manager == null) {
            return;
        }
        AIMPubConvService convService = manager.getConvService();
        if (convService == null) {
            return;
        }
        AIMPubConvCreateSingleConvParam param = new AIMPubConvCreateSingleConvParam();
        param.uids = new ArrayList<>();
        param.uids.add(uid);        // Self
        param.uids.add(otherId);    // Other
        param.appCid = AIMPubConvService.generateStandardAppCid(uid, otherId);

        convService.createSingleConversation(param, new AIMPubConvCreateSingleConvListener() {
            @Override
            public void onSuccess(AIMPubConversation aimConversation) {
                Logger.i("Create single Conv succeed cid:" + aimConversation.appCid);
            }

            @Override
            public void onFailure(DPSError aimError) {
                Logger.e("Failed to create conv " + aimError);
            }
        });
    }
}
