package com.alibaba.ark.aimsdk.simple;

import com.alibaba.dingpaas.base.DPSError;
import com.alibaba.dingpaas.base.DPSPubManagerCreateListener;
import com.alibaba.dingpaas.base.DPSPubEngine;
import com.alibaba.dingpaas.base.DPSPubManager;
import com.alibaba.dingpaas.base.DPSPubManagerCreateListener;
import com.alibaba.dingpaas.base.DPSReleaseManagerListener;
import com.alibaba.dingpaas.base.DPSUserId;

public class Manager {
    public static void createManager(final String uid, final DPSPubManagerCreateListener callback) {
        DPSPubEngine engine = DPSPubEngine.getDPSEngine();
        if (engine == null) {
            Logger.e("engine is null");
            return;
        }
        Logger.i("Create manager");
        engine.createDPSManager(uid, new DPSPubManagerCreateListener() {
            @Override
            public void onSuccess(DPSPubManager aimManager) {
                Logger.i("manager created for " + uid);
                Conversation.registerEvents(uid);
                Message.registerEvents(uid);
                if (callback != null) {
                    callback.onSuccess(aimManager);
                }
            }

            @Override
            public void onFailure(DPSError aimError) {
                Logger.e("manager create failed:" + aimError.toString());
                if (callback != null) {
                    callback.onFailure(aimError);
                }
            }
        });
    }

    public static void releaseManager(final String uid) {
        DPSPubEngine engine = DPSPubEngine.getDPSEngine();
        if (engine == null) {
            Logger.e("engine is null");
            return;
        }

        engine.releaseDPSManager(uid, new DPSReleaseManagerListener() {
            @Override
            public void onSuccess() {
                Logger.i("Release manager succeed for " + uid);
            }

            @Override
            public void onFailure(DPSError aimError) {
                Logger.e("Failed to release manager " + aimError.toString());
            }
        });
    }
}
