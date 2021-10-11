package com.alibaba.ark.aimsdk.simple;

import com.alibaba.dingpaas.aim.AIMDownloadFileListener;
import com.alibaba.dingpaas.aim.AIMDownloadFileParam;
import com.alibaba.dingpaas.aim.AIMImageSizeType;
import com.alibaba.dingpaas.aim.AIMMediaAuthInfo;
import com.alibaba.dingpaas.aim.AIMMediaService;
import com.alibaba.dingpaas.aim.AIMPubMsgContent;
import com.alibaba.dingpaas.aim.AIMMsgContentType;
import com.alibaba.dingpaas.aim.AIMMsgImageCompressType;
import com.alibaba.dingpaas.aim.AIMMsgImageContent;
import com.alibaba.dingpaas.aim.AIMMsgImageFileType;
import com.alibaba.dingpaas.aim.AIMMsgSendMediaProgress;
import com.alibaba.dingpaas.aim.AIMPubMsgTextContent;
import com.alibaba.dingpaas.aim.AIMPubConversation;
import com.alibaba.dingpaas.aim.AIMPubMessage;
import com.alibaba.dingpaas.aim.AIMPubModule;
import com.alibaba.dingpaas.aim.AIMPubMsgChangeListener;
import com.alibaba.dingpaas.aim.AIMPubMsgListener;
import com.alibaba.dingpaas.aim.AIMPubMsgSendMessage;
import com.alibaba.dingpaas.aim.AIMPubMsgSendMsgListener;
import com.alibaba.dingpaas.aim.AIMPubMsgService;
import com.alibaba.dingpaas.aim.AIMPubNewMessage;
import com.alibaba.dingpaas.base.DPSError;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;

public class Message {
    private static String sMediaID = "";

    public static void registerEvents(String uid) {
        AIMPubModule manager = AIMPubModule.getModuleInstance(uid);
        if (manager == null) {
            return;
        }
        Logger.i("Register msg events");
        AIMPubMsgService msgService = manager.getMsgService();
        if (msgService == null) {
            return;
        }
        msgService.addMsgChangeListener(new AIMPubMsgChangeListener() {
            /**
             * 消息未读数变更，作为消息的发送者，表示单聊对方或者群聊群内其他成员
             * 没有读取该条消息的人数，如果未读数是0，表示所有人已读
             * @param msgs 发生变化的消息(有效字段cid/mid/unread_count）
             */
            @Override
            public void onMsgUnreadCountChanged(ArrayList<AIMPubMessage> msgs) {
                Logger.i("OnMsgUnreadCountChanged msgs: " + msgs.size());
                for (AIMPubMessage msg : msgs) {
                    Logger.i("mid: " + msg.mid + " unreadCount:" + msg.unreadCount);
                }
            }

            /**
             * 消息未读数变更，作为消息的接收者，多端同步消息已读状态
             * @param msgs 发生变化的消息(有效字段cid/mid/is_read）
             */
            @Override
            public void onMsgReadStatusChanged(ArrayList<AIMPubMessage> msgs) {
                Logger.i("OnMsgReadStatusChanged msgs: " + msgs.size());
                for (AIMPubMessage msg : msgs) {
                    Logger.i("mid: " + msg.mid + " un-read count:" + msg.unreadCount);
                }
            }

            /**
             * 消息扩展信息变更
             * @param msgs 发生变化的消息(有效字段cid/mid/extension)
             */
            @Override
            public void onMsgExtensionChanged(ArrayList<AIMPubMessage> msgs) {
                Logger.i("OnMsgExtensionChanged msgs: " + msgs.size());
                for (AIMPubMessage msg : msgs) {
                    Logger.i("mid: " + msg.mid + " extension:" + msg.extension);
                }
            }

            /**
             * 消息本地扩展信息变更
             * @param msgs 发生变化的消息(有效字段cid/mid/local_extension)
             */
            @Override
            public void onMsgLocalExtensionChanged(ArrayList<AIMPubMessage> msgs) {
                Logger.i("OnMsgLocalExtensionChanged msgs: " + msgs.size());
                for (AIMPubMessage msg : msgs) {
                    Logger.i("mid: " + msg.mid + " local extension:" + msg.localExtension);
                }
            }

            /**
             * 业务方自定义消息扩展信息变更
             * @param msgs 发生变化的消息(有效字段cid/mid/user_extension字段)
             */
            @Override
            public void onMsgUserExtensionChanged(ArrayList<AIMPubMessage> msgs) {
                Logger.i("OnMsgUserExtensionChanged msgs: " + msgs.size());
                for (AIMPubMessage msg : msgs) {
                    Logger.i("mid: " + msg.mid + " user extension:" + msg.userExtension);
                }
            }

            /**
             * 消息被撤回
             * @param msgs 发生变化的消息(有效字段cid/mid/is_recall字段)
             */
            @Override
            public void onMsgRecalled(ArrayList<AIMPubMessage> msgs) {
                Logger.i("OnMsgRecalled msgs: " + msgs.size());
                for (AIMPubMessage msg : msgs) {
                    Logger.i("mid: " + msg.mid + " recalled:" + getMsgContent(msg));
                }
            }

            /**
             * 消息状态变更，比如：消息状态从发送中变成了发送失败
             * @param msgs
             * 发生变化的消息(有效字段status/mid/created_at/unread_count/receiver_count/content)
             */
            @Override
            public void onMsgStatusChanged(ArrayList<AIMPubMessage> msgs) {
                Logger.i("OnMsgStatusChanged msgs: " + msgs.size());
                for (AIMPubMessage msg : msgs) {
                    Logger.i("mid: " + msg.mid + " status:" + msg.status);
                }
            }

            /**
             * 消息发送进度变更
             * @param progress 发送进度
             */
            @Override
            public void onMsgSendMediaProgressChanged(AIMMsgSendMediaProgress progress) {
                Logger.i("OnMsgSendMediaProgressChanged progress: " + progress);
            }
        });

        msgService.addMsgListener(new AIMPubMsgListener() {
            /**
             * 消息新增
             * 发送消息或收到推送消息时，触发该回调
             * 当从服务端拉取历史消息时，不会触发该回调
             * @param msgs 新增消息
             */
            @Override
            public void onAddedMessages(ArrayList<AIMPubNewMessage> msgs) {
                Logger.i("OnAddedMessages msgs: " + msgs.size());
                for (AIMPubNewMessage msg : msgs) {
                    Logger.i("type: " + msg.type + " content:" + getMsgContent(msg.msg));
                }
            }

            /**
             * 消息删除
             * @param msgs 变更消息
             */
            @Override
            public void onRemovedMessages(ArrayList<AIMPubMessage> msgs) {
                Logger.i("OnRemovedMessages msgs: " + msgs.size());
                for (AIMPubMessage msg : msgs) {
                    Logger.i("mid: " + msg.mid + " content:" + getMsgContent(msg));
                }
            }

            /**
             * 当消息数据库内有消息添加时，触发该回调
             * 包括发送，推送及拉取历史消息
             * 注意：
             * 1. 不保证传入消息 msgs 的顺序
             * 2. OnStored 回调的顺序也不保证消息组间的顺序
             * @param msgs 变更消息
             */
            @Override
            public void onStoredMessages(ArrayList<AIMPubMessage> msgs) {
                Logger.i("OnStoredMessages msgs: " + msgs.size());
                for (AIMPubMessage msg : msgs) {
                    Logger.i("mid: " + msg.mid + " content:" + getMsgContent(msg));
                }
            }
        });
    }

    public static void sendHelloWorld(String uid, AIMPubConversation conv) {
        AIMPubModule manager = AIMPubModule.getModuleInstance(uid);
        if (manager == null) {
            return;
        }
        AIMPubMsgService msgService = manager.getMsgService();
        if (msgService == null) {
            return;
        }
        if (conv == null) {
            return;
        }
        AIMPubMsgTextContent textContent = new AIMPubMsgTextContent();
        Date date = new Date();
        textContent.text = "Hello " + date;

        AIMPubMsgContent msgContent = new AIMPubMsgContent();
        msgContent.contentType = AIMMsgContentType.CONTENT_TYPE_TEXT;
        msgContent.textContent = textContent;

        AIMPubMsgSendMessage sendMessage = new AIMPubMsgSendMessage();
        sendMessage.content = msgContent;
        sendMessage.receivers = conv.userids;
        sendMessage.appCid = conv.appCid;

        Logger.i("Send message begin");
        msgService.sendMessage(sendMessage, new AIMPubMsgSendMsgListener() {
            @Override
            public void onProgress(double progress) {
                Logger.i("Send Message progress: " + progress);
            }

            @Override
            public void onSuccess(AIMPubMessage message) {
                Logger.i("Send Message succeed");
            }

            @Override
            public void onFailure(DPSError aimError) {
                Logger.i("Send Message failed:" + aimError);
            }
        }, null);
    }

    public static void sendImage(String uid, AIMPubConversation conv, String path) {
        AIMPubModule manager = AIMPubModule.getModuleInstance(uid);
        if (manager == null) {
            return;
        }
        AIMPubMsgService msgService = manager.getMsgService();
        if (msgService == null) {
            return;
        }
        if (conv == null) {
            return;
        }

        // Test image file read/write permission
//        try {
//            File fl = new File(path);
//            FileInputStream fin = new FileInputStream(fl);
//            BufferedReader reader = new BufferedReader(new InputStreamReader(fin));
//            StringBuilder sb = new StringBuilder();
//            String line = null;
//            while ((line = reader.readLine()) != null) {
//                sb.append(line).append("\n");
//            }
//            reader.close();
//
//
//        } catch (Exception e) {
//            Log.e("", e.toString());
//
//        }



        AIMMsgImageContent imageContent = new AIMMsgImageContent();
        imageContent.localPath = path;
        imageContent.type = AIMMsgImageCompressType.IMAGE_COMPRESS_TYPE_ORIGINAL;
        imageContent.fileType = AIMMsgImageFileType.IMAGE_FILE_TYPE_JPG;
        imageContent.mimeType = "image/jpeg";
        AIMPubMsgContent content = new AIMPubMsgContent();
        content.contentType = AIMMsgContentType.CONTENT_TYPE_IMAGE;
        content.imageContent = imageContent;

        AIMPubMsgSendMessage sendMessage = new AIMPubMsgSendMessage();
        sendMessage.appCid = conv.appCid;
        sendMessage.content = content;
        sendMessage.receivers = conv.userids;

        Logger.i("Send message begin");
        msgService.sendMessage(sendMessage, new AIMPubMsgSendMsgListener() {
            @Override
            public void onProgress(double progress) {
                Logger.i("Send Message progress: " + progress);
            }

            @Override
            public void onSuccess(AIMPubMessage message) {
                Logger.i("Send Message succeed");
            }

            @Override
            public void onFailure(DPSError aimError) {
                Logger.i("Send Message failed:" + aimError);
            }
        }, null);
    }

    public static String getMsgContent(AIMPubMessage msg) {
        if (msg == null) {
            return null;
        }
        if (msg.content.contentType == AIMMsgContentType.CONTENT_TYPE_TEXT) {
            return msg.content.textContent.text;
        } else {
            if (msg.content.contentType == AIMMsgContentType.CONTENT_TYPE_IMAGE) {
                String str = "msg type: " + msg.content.contentType;
                str += "\n\t";
                // 可以通过MediaService进行下载
                str += "media_id:" +  msg.content.imageContent.mediaId;
                str += "\n\t";
                str += "local_path:" + msg.content.imageContent.localPath;
                str += "\n\t";
                // 通过其他网络库下载，需要鉴权（种cookie，比较麻烦，不建议使用）
                str += "url:" + msg.content.imageContent.originalUrl;
                if (!msg.content.imageContent.mediaId.isEmpty()) {
                    Message.sMediaID = msg.content.imageContent.mediaId;
                }
                return str;
            }
            return "msg type: " + msg.content.contentType;
        }
    }

    public static void downloadImg(String uid) {
        String mediaId = Message.sMediaID;
        if (mediaId.isEmpty()) {
            Logger.e("No mediaId found");
            return;
        }
        Logger.i("Download mediaId: " + mediaId);
        AIMPubModule manager = AIMPubModule.getModuleInstance(uid);
        if (manager == null) {
            return;
        }
        AIMMediaService mediaService = manager.getMediaService();
        if (mediaService == null) {
            return;
        }
        String imagePath = "/sdcard/aim_images/";
        File file = new File(imagePath);
        if (!file.exists()) {
            file.mkdir();
        }
        // 设置文件名
        imagePath += mediaId;

        // 通过 MediaID 获取图片url
        AIMMediaAuthInfo info = new AIMMediaAuthInfo();
        String url = mediaService.transferMediaIdToAuthImageUrl(mediaId, AIMImageSizeType.IST_THUMB, info);
        // 开始下载图片
        AIMDownloadFileParam param = new AIMDownloadFileParam();
        param.downloadUrl = url;
        param.path = imagePath;
        mediaService.downloadFile(param, new AIMDownloadFileListener() {
            @Override
            public void onCreate(String taskID) {
                Logger.i("DownloadFile onCreate " + taskID);
            }

            @Override
            public void onStart() {
                Logger.i("DownloadFile start");
            }

            @Override
            public void onProgress(long current_size, long total_size) {
                Logger.i("DownloadFile progress: " + current_size + " : " + total_size);
            }

            @Override
            public void onSuccess(String path) {
                Logger.i("DownloadFile succeed:" + path);
            }

            @Override
            public void onFailure(DPSError aimError) {
                Logger.e("DownloadFile error: " + aimError);
            }
        });
    }
}
