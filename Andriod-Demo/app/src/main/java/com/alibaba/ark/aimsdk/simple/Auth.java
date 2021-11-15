package com.alibaba.ark.aimsdk.simple;

import android.util.Log;

import com.alibaba.dingpaas.base.DPSAuthListener;
import com.alibaba.dingpaas.base.DPSAuthService;
import com.alibaba.dingpaas.base.DPSAuthToken;
import com.alibaba.dingpaas.base.DPSAuthTokenGotCallback;
import com.alibaba.dingpaas.base.DPSConnectionStatus;
import com.alibaba.dingpaas.base.DPSError;
import com.alibaba.dingpaas.base.DPSLogoutListener;
import com.alibaba.dingpaas.base.DPSPubEngine;
import com.alibaba.dingpaas.base.DPSPubManager;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.Locale;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

public class Auth {
    public static class MyX509TrustManager implements X509TrustManager {
        @Override
        public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {

        }

        @Override
        public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {

        }

        @Override
        public X509Certificate[] getAcceptedIssuers() {
            return new X509Certificate[0];
        }
    }

    public static void getToken(final String uid, final DPSAuthTokenGotCallback callback) {
        new Thread() {
            @Override
            public void run() {
                try {
                    SSLContext sslcontext = SSLContext.getInstance("SSL");//第一个参数为协议,第二个参数为提供者(可以缺省)
                    TrustManager[] tm = {new MyX509TrustManager()};
                    sslcontext.init(null, tm, new SecureRandom());
                    HostnameVerifier ignoreHostnameVerifier = new HostnameVerifier() {
                        @Override
                        public boolean verify(String s, SSLSession sslsession) {
                            System.out.println("WARNING: Hostname is not matched for cert.");
                            return true;
                        }
                    };
                    HttpsURLConnection.setDefaultHostnameVerifier(ignoreHostnameVerifier);
                    HttpsURLConnection.setDefaultSSLSocketFactory(sslcontext.getSocketFactory());

                    // token url
                    String tokenUrl = String.format(Locale.getDefault(), Environments.TOKEN_URL, Environments.APP_ID, uid, Engine.deviceId, Environments.APP_KEY);
                    Logger.i("token url:" + tokenUrl);

                    URL url = new URL(tokenUrl);
                    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                    connection.setConnectTimeout(5000);
                    connection.connect();
                    InputStream inputStream = connection.getInputStream();
                    InputStreamReader reader = new InputStreamReader(inputStream);
                    BufferedReader bufferedReader = new BufferedReader(reader);
                    String temp;
                    StringBuilder stringBuffer = new StringBuilder();
                    while ((temp = bufferedReader.readLine()) != null) {
                        stringBuffer.append(temp);
                    }
                    final String result = stringBuffer.toString();
                    try {
                        JSONObject jsonObject = new JSONObject(result);
                        String accessToken = jsonObject.optString("accessToken");
                        String refreshToken = jsonObject.optString("refreshToken");
                        Log.e("ssss", "accessToken = " + accessToken + " refreshToken" + refreshToken);
                        if (callback != null) {
                            DPSAuthToken token = new DPSAuthToken();
                            token.accessToken = accessToken;
                            token.refreshToken = refreshToken;
                            callback.onSuccess(token);
                        }
                    } catch (JSONException e) {
                        Logger.e("Result error:" + e.toString());
                        e.printStackTrace();
                        if (callback != null) {
                            callback.onFailure(1, "JSON failed");
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    Logger.e("Failed to connect:" + e.getMessage());
                    if (callback != null) {
                        callback.onFailure(2, "Failed to get token");
                    }
                }
            }
        }.start();
    }

    public static void login(String uid) {
        DPSPubEngine engine = DPSPubEngine.getDPSEngine();
        if (engine == null) {
            Logger.e("engine is null");
            return;
        }
        DPSPubManager manager = engine.getDPSManager(uid);
        if (manager == null) {
            Logger.e("manager is null");
            return;
        }
        DPSAuthService authService = manager.getAuthService();
        if (authService == null) {
            Logger.e("authService is null");
            return;
        }
        DPSConnectionStatus status = authService.getConnectionStatus();
        if (status == DPSConnectionStatus.CS_AUTHED) {
            Logger.e("Already authed, no need login");
            return;
        }
        authService.removeAllListeners();
        authService.addListener(new DPSAuthListener() {
            @Override
            public void onConnectionStatusChanged(DPSConnectionStatus aimConnectionStatus) {
                Logger.i("OnConnectionStatusChanged " + aimConnectionStatus.toString());
            }

            @Override
            public void onGetAuthCodeFailed(int i, String s) {
                Logger.i("OnGetAuthCodeFailed " + s);
            }

            @Override
            public void onLocalLogin() {
                Logger.i("local login succeed");
            }

            @Override
            public void onKickout(String s) {
                Logger.i("OnKickout " + s);
            }

            /**
             * 其他端设备在（离）线情况
             * @param type 事件类型（1：事件通知，包括上下线，2：状态通知，在线状态）
             * @param deviceType 设备类型
             * （0:default,1:web,2:Android,3:iOS,4:Mac,5:Windows,6:iPad）
             * @param status      设备状态（1：上线或在线，2：下线或离线）
             * @param time        时间（上线或下线时间）
             */
            @Override
            public void onDeviceStatus(int type, int deviceType, int status, long time) {
                Logger.i("OnDeviceStatus changed:");
            }

            /**
             * 下载资源cookie变更事件
             * @param cookie      新cookie
             */
            @Override
            public void onMainServerCookieRefresh(String cookie) {
                Logger.i("Cookie refreshed: " + cookie);
            }
        });
        Logger.i("Start login");
        authService.login();
    }

    public static void logOut(String uid) {
        DPSPubEngine engine = DPSPubEngine.getDPSEngine();
        if (engine == null) {
            Logger.e("engine is null");
            return;
        }
        DPSPubManager manager = engine.getDPSManager(uid);
        if (manager == null) {
            Logger.e("manager is null");
            return;
        }
        DPSAuthService authService = manager.getAuthService();
        if (authService == null) {
            Logger.e("authService is null");
            return;
        }
        authService.logout(new DPSLogoutListener() {
            @Override
            public void onSuccess() {
                Logger.i("logout succeed");
            }

            @Override
            public void onFailure(DPSError aimError) {
                Logger.e("Logout failed " + aimError.toString());
            }
        });
    }
}
