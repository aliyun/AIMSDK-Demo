package com.alibaba.ark.aimsdk.simple;

import android.graphics.Color;
import android.os.Handler;
import android.os.Looper;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.BackgroundColorSpan;
import android.widget.TextView;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.prefs.BackingStoreException;


public class Logger {
    static private TextView mLogView;

    static void initViewLogView(TextView logView) {
        mLogView = logView;
    }

    static void clearLog() {
        if (mLogView == null) {
            return;
        }
        mLogView.setText("");
    }

    static void e(final String str) {
        log(str, true);
    }

    static void i(final String str) {
        log(str, false);
    }

    static private void log(final String logLine, final boolean isError) {
        if (mLogView == null) {
            return;
        }
        if (Looper.myLooper() != Looper.getMainLooper()) {
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    log(logLine, isError);
                }
            });
            return;
        }

        SimpleDateFormat sdf = new SimpleDateFormat("mm:ss:SSS", Locale.getDefault());
        String time = sdf.format(new Date());
        SpannableString textSpanned1 = new SpannableString(time);
        if (isError) {
            textSpanned1.setSpan(new BackgroundColorSpan(Color.RED),
                    0, time.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        } else {
            textSpanned1.setSpan(new BackgroundColorSpan(Color.LTGRAY),
                    0, time.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        }

        mLogView.append(textSpanned1);
        mLogView.append(": ");
        mLogView.append(logLine);
        mLogView.append("\n");
    }
}
