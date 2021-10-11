package com.alibaba.ark.aimsdk.simple;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.text.InputType;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.content.Context;

import java.util.ArrayList;

public class UIUtil {
    public interface InputListener {
        void onReceived(String value);
    }

    static void getUserInput(Context context, String description, String defaultValue, final InputListener listener) {
        final EditText etName = new EditText(context);
//        etName.setInputType(InputType.TYPE_CLASS_NUMBER);
        etName.setText(defaultValue);
        final AlertDialog dialog = new AlertDialog.Builder(context)
                .setTitle(description)
                .setView(etName)
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                })
                .setPositiveButton("Done", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        String value = etName.getText().toString();
                        if (listener != null && value != null && value.length() > 0) {
                            listener.onReceived(value);
                        }
                    }
                })
                .create();
        dialog.show();
    }

    static void selectList(final Context context, ArrayList<String> values, String title, final InputListener listener) {
        AlertDialog.Builder builderSingle = new AlertDialog.Builder(context);
        builderSingle.setTitle(title);

        final ArrayAdapter<String> arrayAdapter = new ArrayAdapter<String>(context, android.R.layout.select_dialog_singlechoice);
        for (String value : values) {
            arrayAdapter.add(value);
        }

        builderSingle.setNegativeButton("cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });

        builderSingle.setAdapter(arrayAdapter, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                String strName = arrayAdapter.getItem(which);
                if (listener != null) {
                    listener.onReceived(strName);
                }
            }
        });
        builderSingle.show();
    }
}
