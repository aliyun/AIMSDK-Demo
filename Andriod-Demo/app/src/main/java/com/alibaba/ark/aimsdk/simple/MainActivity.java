package com.alibaba.ark.aimsdk.simple;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.MediaStore;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;


import com.alibaba.dingpaas.aim.AIMPubConvGetConvListener;
import com.alibaba.dingpaas.aim.AIMPubConversation;
import com.alibaba.dingpaas.base.DPSPubEngine;
import com.alibaba.dingpaas.base.DPSError;
import com.alibaba.dingpaas.base.DPSPubManager;
import com.alibaba.dingpaas.base.DPSPubManagerCreateListener;

import java.util.ArrayList;


public class MainActivity extends AppCompatActivity {
    private static MainActivity sContext;
    public static final int CHOOSE_PHOTO = 2;

    Button mStartEngineButton;
    Button mStopEngineButton;
    TextView mLogView;
    Button mCreateManagerButton;
    Button mReleaseManagerButton;
    Button mClearButton;
    Button mLoginButton;
    Button mLogoutButton;
    Button mResetUserDataButton;
    Button mListConvsButton;
    Button mEnterConvButton;
    Button mSelectUserButton;
    Button mSendHelloWorldButton;
    Button mCreateConvButton;
    Button mSendImageButton;
    Button mDownloadImgButton;

    String mCurrentUserId;

    static {
        Log.d("MainActivity", "=========loadLibrary start");
        System.loadLibrary("sqlite3");
        System.loadLibrary("openssl");
        System.loadLibrary("gaea");
        System.loadLibrary("fml");
        System.loadLibrary("dps");
        System.loadLibrary("aim");

        Log.d("MainActivity", "=========loadLibrary end");
    }

    public static MainActivity getContext() {
        return sContext;
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        sContext = this;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initViews();
    }

    private void initViews() {
        // log view
        mLogView = findViewById(R.id.log_view);
        mClearButton = findViewById(R.id.clear_button);
        mLogView.setMovementMethod(new ScrollingMovementMethod());
        Logger.initViewLogView(mLogView);
        mClearButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Logger.clearLog();
            }
        });


        // Engine
        mStartEngineButton = findViewById(R.id.start_engine);
        mStopEngineButton = findViewById(R.id.stop_engine);
        mStartEngineButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Engine.startEngine();
            }
        });

        mStopEngineButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Engine.stopEngine();
            }
        });

        // Reset user data
        mResetUserDataButton = findViewById(R.id.reset_user_data);
        mResetUserDataButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                selectUserAndDo(new SelectUserFinishInterface() {
                    @Override
                    public void selectDone(String uid) {
                        DPSPubEngine.releaseDPSEngine();
                        Engine.resetUserData(uid);
                    }
                });
            }
        });

        // Manager
        mCreateManagerButton = findViewById(R.id.create_manager);
        mReleaseManagerButton = findViewById(R.id.release_manager);
        mSelectUserButton = findViewById(R.id.select_user);
        mSelectUserButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                selectUserAndDo(new SelectUserFinishInterface() {
                    @Override
                    public void selectDone(String uid) {
                        mSelectUserButton.setText(uid);
                        mCurrentUserId = uid;
                    }
                });
            }
        });
        mCreateManagerButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                UIUtil.getUserInput(MainActivity.this, "Please input user id", "test001", new UIUtil.InputListener() {
                    @Override
                    public void onReceived(final String value) {
                        Manager.createManager(value, new DPSPubManagerCreateListener() {
                            @Override
                            public void onSuccess(final DPSPubManager aimManager) {
                                new Handler(Looper.getMainLooper()).post(new Runnable() {
                                    @Override
                                    public void run() {
                                        mSelectUserButton.setText(value);
                                        mCurrentUserId = aimManager.getUserId();
                                    }
                                });
                            }

                            @Override
                            public void onFailure(DPSError aimError) {

                            }
                        });
                    }
                });
            }
        });
        mReleaseManagerButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                selectUserAndDo(new SelectUserFinishInterface() {
                    @Override
                    public void selectDone(final String uid) {
                        Manager.releaseManager(uid);
                    }
                });
            }
        });

        // Login
        mLoginButton = findViewById(R.id.login_button);
        mLoginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Auth.login(mCurrentUserId);
            }
        });

        // Logout
        mLogoutButton = findViewById(R.id.logout_button);
        mLogoutButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Auth.logOut(mCurrentUserId);
            }
        });

        // Convs
        mListConvsButton = findViewById(R.id.list_conversation);
        mListConvsButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Conversation.listAllConvs(mCurrentUserId, new AIMPubConvGetConvListener() {
                    @Override
                    public void onSuccess(ArrayList<AIMPubConversation> convs) {
                        Logger.i("Got convs:");
                        for (AIMPubConversation conv : convs) {
                            Logger.i("cid: " + conv.appCid + " users:" + conv.userids + " convType:" + conv.getType());
                        }
                    }

                    @Override
                    public void onFailure(DPSError aimError) {

                    }
                });
            }
        });

        mCreateConvButton = findViewById(R.id.create_single_conversation);
        mCreateConvButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                UIUtil.getUserInput(MainActivity.this, "Enter other uid", "", new UIUtil.InputListener() {
                    @Override
                    public void onReceived(String value) {
                        Conversation.createSingleConversation(mCurrentUserId, value);
                    }
                });
            }
        });

        // Enter convs
        mEnterConvButton = findViewById(R.id.enter_conv);
        mEnterConvButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Conversation.listAllConvs(mCurrentUserId, new AIMPubConvGetConvListener() {
                    @Override
                    public void onSuccess(ArrayList<AIMPubConversation> convs) {
                        ArrayList<String> values = new ArrayList<>();
                        for (AIMPubConversation conv : convs) {
                            values.add(conv.appCid);
                        }
                        UIUtil.selectList(MainActivity.this, values, "Select conversation", new UIUtil.InputListener() {
                            @Override
                            public void onReceived(String cid) {
                                Conversation.enterConversation(mCurrentUserId, cid);
                            }
                        });
                    }

                    @Override
                    public void onFailure(DPSError dpsError) {

                    }

                });
            }
        });

        // Send Hello World
        mSendHelloWorldButton = findViewById(R.id.send_message);
        mSendHelloWorldButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Conversation.listAllConvs(mCurrentUserId, new AIMPubConvGetConvListener() {
                    @Override
                    public void onSuccess(final ArrayList<AIMPubConversation> convs) {
                        ArrayList<String> values = new ArrayList<>();
                        for (AIMPubConversation conv : convs) {
                            values.add(conv.appCid);
                        }
                        UIUtil.selectList(MainActivity.this, values, "Send to", new UIUtil.InputListener() {
                            @Override
                            public void onReceived(String cid) {
                                AIMPubConversation conv = new AIMPubConversation();
                                for (AIMPubConversation tmpConv : convs) {
                                    if (tmpConv.appCid == cid) {
                                        conv = tmpConv;
                                    }
                                }
                                Message.sendHelloWorld(mCurrentUserId, conv);
                            }
                        });
                    }

                    @Override
                    public void onFailure(DPSError aimError) {

                    }
                });
            }
        });

        // Send Image
        mSendImageButton = findViewById(R.id.send_image);
        mSendImageButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // Start gallery
                Intent intentToPickPic = new Intent(Intent.ACTION_PICK, null);
                intentToPickPic.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*");
                startActivityForResult(intentToPickPic, CHOOSE_PHOTO);
            }
        });

        mDownloadImgButton = findViewById(R.id.download_img);
        mDownloadImgButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Message.downloadImg(mCurrentUserId);
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {
            case CHOOSE_PHOTO:
                if (data != null && data.getData() != null) {
                    final String path = FileUtil.getFilePathByUri(MainActivity.this, data.getData());

                    // Check read file permission
                    if (Build.VERSION.SDK_INT >= 23) {
                        int REQUEST_CODE_CONTACT = 101;
                        String[] permissions = {
                                Manifest.permission.WRITE_EXTERNAL_STORAGE};
                        //验证是否许可权限
                        for (String str : permissions) {
                            if (MainActivity.this.checkSelfPermission(str) != PackageManager.PERMISSION_GRANTED) {
                                //申请权限
                                MainActivity.this.requestPermissions(permissions, REQUEST_CODE_CONTACT);
                            } else {
                                //这里就是权限打开之后自己要操作的逻辑
                            }
                        }
                    }


                    Conversation.listAllConvs(mCurrentUserId, new AIMPubConvGetConvListener() {
                        @Override
                        public void onSuccess(final ArrayList<AIMPubConversation> convs) {
                            ArrayList<String> values = new ArrayList<>();
                            for (AIMPubConversation conv : convs) {
                                values.add(conv.appCid);
                            }
                            UIUtil.selectList(MainActivity.this, values, "Send to", new UIUtil.InputListener() {
                                @Override
                                public void onReceived(String cid) {
                                    AIMPubConversation conv = new AIMPubConversation();
                                    for (AIMPubConversation tmpConv : convs) {
                                        if (tmpConv.appCid == cid) {
                                            conv = tmpConv;
                                        }
                                    }
                                    Message.sendImage(mCurrentUserId, conv, path);
                                }
                            });
                        }

                        @Override
                        public void onFailure(DPSError aimError) {

                        }
                    });
                }
                break;
            default:
                break;
        }
    }

    interface SelectUserFinishInterface {
        void selectDone(String uid);
    }

    private void selectUserAndDo(final SelectUserFinishInterface runnable) {
        final DPSPubEngine engine = DPSPubEngine.getDPSEngine();
        if (engine == null || runnable == null) {
            return;
        }
        ArrayList<String> users = engine.getUserIds();
        if (users.size() > 1) {
            UIUtil.selectList(MainActivity.this, users, "Select User", new UIUtil.InputListener() {
                @Override
                public void onReceived(String value) {
                    runnable.selectDone(value);
                }
            });
        } else if (users.size() == 1) {
            runnable.selectDone(users.get(0));
        }
    }
}
