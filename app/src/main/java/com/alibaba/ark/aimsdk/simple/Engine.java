package com.alibaba.ark.aimsdk.simple;

import android.provider.Settings;
import android.util.Log;

import com.alibaba.dingpaas.aim.AIMPubModule;
import com.alibaba.dingpaas.base.DPSAuthTokenExpiredReason;
import com.alibaba.dingpaas.base.DPSAuthTokenGotCallback;
import com.alibaba.dingpaas.base.DPSEngineStartListener;
import com.alibaba.dingpaas.base.DPSEnvType;
import com.alibaba.dingpaas.base.DPSErrClientCode;
import com.alibaba.dingpaas.base.DPSError;
import com.alibaba.dingpaas.base.DPSLogHandler;
import com.alibaba.dingpaas.base.DPSLogLevel;
import com.alibaba.dingpaas.base.DPSModuleInfo;
import com.alibaba.dingpaas.base.DPSResetUserDataListener;
import com.alibaba.dingpaas.base.DPSPubAuthTokenCallback;
import com.alibaba.dingpaas.base.DPSPubEngine;
import com.alibaba.dingpaas.base.DPSPubEngineListener;
import com.alibaba.dingpaas.base.DPSPubSettingService;

import java.io.File;
import java.util.Locale;

public class Engine {
    public static String deviceId;

    static private void configAIMEngine() {
        DPSPubEngine engine = DPSPubEngine.getDPSEngine();
        if (engine == null) {
            Logger.e("Failed to config aim engine");
            return;
        }

        engine.setLogHandler(DPSLogLevel.DPS_LOG_LEVEL_DEBUG, new DPSLogHandler() {
            @Override
            public void onLog(DPSLogLevel aimLogLevel, String s) {
                switch (aimLogLevel) {
                    case DPS_LOG_LEVEL_DEBUG:
                        Log.d("AIMSDK-Simple", s);
                        break;
                    case DPS_LOG_LEVEL_WARNING:
                        Log.w("AIMSDK-Simple", s);
                        break;
                    case DPS_LOG_LEVEL_INFO:
                        Log.i("AIMSDK-Simple", s);
                        break;
                    default:
                        Log.e("AIMSDK-Simple", s);
                }
            }
        });

        DPSPubSettingService setting = engine.getSettingService();
        String dataPath = MainActivity.getContext().getExternalCacheDir().getPath() + "/uid";
        // Set data path where database will be created in this folder
        setting.setDataPath(dataPath);
        File file = new File(dataPath);
        if (!file.exists()) {
            file.mkdir();
        }

        // App Key
        setting.setAppKey(Environments.APP_KEY);
        // App ID
        setting.setAppID(Environments.APP_ID);
        // App Name
        setting.setAppName(MainActivity.getContext().getResources().getString(R.string.app_name));
        // App version
        setting.setAppVersion(BuildConfig.VERSION_NAME);
        // Device id (Simple way below)
        deviceId = Settings.Secure.getString(MainActivity.getContext().getContentResolver(), Settings.Secure.ANDROID_ID);
        setting.setDeviceId(deviceId);
        // Device name
        setting.setDeviceName(android.os.Build.MODEL);
        // Device type
        setting.setDeviceType(android.os.Build.BRAND);
        // Local
        setting.setDeviceLocale(Locale.getDefault().getLanguage());
        // OS Name
        setting.setOSName("Android");
        // OS version
        setting.setOSVersion(android.os.Build.VERSION.RELEASE);
        // Auth Token callback
        setting.setAuthTokenCallback(new DPSPubAuthTokenCallback() {
            @Override
            public void onCallback(String userId, DPSAuthTokenGotCallback onGot, DPSAuthTokenExpiredReason reason) {
                Auth.getToken(userId, onGot);
            }
        });
        setting.setEnvType(DPSEnvType.ENV_TYPE_PRE_RELEASE);
        initServices();
    }

    static private void initServices() {
        DPSPubEngine engine = DPSPubEngine.getDPSEngine();
        if (engine == null) {
            Logger.e("Failed to config aim engine");
            return;
        }
        DPSModuleInfo imInfo = AIMPubModule.getModuleInfo();
        engine.registerModule(imInfo);

//        DPSModuleInfo myInfo = MyModule.GetModuleInfo();
//        engine.registerModule(myInfo);
    }

    static public void startEngine() {
        Logger.i("Start create engine");
        DPSPubEngine.createDPSEngine();
        Logger.i("End  create engine");
        DPSPubEngine engine = DPSPubEngine.getDPSEngine();
        if (engine == null) {
            Logger.e("Engine create failed");
            return;
        }

        // Config engine first
        configAIMEngine();

        Logger.i("Engine start...");
        engine.setListener(new DPSPubEngineListener() {
            @Override
            public void onDBError(String aimUserId, DPSError aimError) {
                Logger.e("DB error" + aimError.toString());
                DPSErrClientCode code = DPSErrClientCode.forValue(aimError.code);
                switch (code) {
                    case DB_FULL:
                        Logger.e("DB full");
                        break;
                    case DB_MAILFORMED:
                        Logger.e("Need app restart to restore, DB broken");
                        break;
                    case DB_NO_MEMORY:
                        Logger.e("No memory");
                        break;
                }
            }
        });
        engine.start(new DPSEngineStartListener() {
            @Override
            public void onSuccess() {
                Logger.i("Succeed to start engine");
            }

            @Override
            public void onFailure(DPSError aimError) {
                Logger.e("Failed to start engine:" + aimError.toString());
            }
        });
    }

    static public void stopEngine() {
        Logger.i("Start stop engine");
        DPSPubEngine.releaseDPSEngine();
        Logger.i("End  stop engine");
    }

    static public void resetUserData(String uid) {
        String dataPath = MainActivity.getContext().getExternalCacheDir().getPath() + "/uid";
        DPSPubEngine.resetUserData(dataPath, uid, Environments.APP_ID, new DPSResetUserDataListener() {
            @Override
            public void onSuccess() {
                Logger.i("Reset succeed");
            }

            @Override
            public void onFailure(DPSError aimError) {
                Logger.e("Failed to reset " + aimError.toString());
            }
        });
    }
}
