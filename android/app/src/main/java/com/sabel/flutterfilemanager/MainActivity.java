package com.sabel.flutterfilemanager;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.StrictMode;
import android.util.Log;
import android.webkit.MimeTypeMap;

import org.apache.commons.io.FileUtils;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import jcifs.smb.NtlmPasswordAuthentication;
import jcifs.smb.SmbFile;
import jcifs.smb.SmbFileOutputStream;

public class MainActivity extends FlutterActivity {
    private static Context mContext = null;
    private static final String METHOD_CHANNEL = "openFileChannel";
    private static final String UPLOAD_CHANNEL = "uploadChannel";
    private static String ip; //= "192.168.2.47";
    private static String password; //= "Few@HuPhot0$";
    private static String username; //= "-svc-HHU.PU";
    private static String strPCPath; //= "smb://192.168.2.47/NotificationPhotosUpload/";
    private static final String strSdcardPath = Environment.getExternalStorageDirectory()+"/Pictures";
    private static final String Agentry = "/data/data/com.sabel.flutterfilemanager/app_flutter/upload.db";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        mContext = this;

        new MethodChannel(getFlutterView(), METHOD_CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        if (methodCall.method.equals("openFile")) {
                            String path = methodCall.argument("path");
                            openFile(mContext, path);
                            result.success("");
                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );

        new MethodChannel(getFlutterView(), UPLOAD_CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        try{
                            selectData();
                        }
                        catch (SQLiteException e){
                            Log.e(getClass().getSimpleName(),
                                    "Could not select the database");
                        }
                        if (methodCall.method.equals("uploadFile")) {
                            String path = methodCall.argument("path");
                            openFile(mContext, path);
                            result.success("Success");
                            VerifyUser();
                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );
    }

    private void openFile(Context context, String path) {
        try {
            if (!path.contains("file://")) {
                path = "file://" + path;
            }
            String[] nameType = path.split("\\.");
            String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(nameType[1]);

            Intent intent = new Intent();
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setAction(Intent.ACTION_VIEW);
            intent.setDataAndType(Uri.parse(path), mimeType);
            context.startActivity(intent);
        } catch (Exception e) {
            System.out.println(e);
        }
    }

    public void VerifyUser() {
        try {
            String path = "smb://" + ip + "/";
            NtlmPasswordAuthentication auth = new NtlmPasswordAuthentication("FEWADOM", username, password);
            // SmbSession.logon(UniAddress.getByName(ip),auth);
            File folder = new File(strSdcardPath);
            File[] listOfFiles = folder.listFiles();

            for (int i = 0; i < listOfFiles.length; i++) {
                if (listOfFiles[i].isFile()) {
                    System.out.println("File " + listOfFiles[i].getName());
                } else if (listOfFiles[i].isDirectory()) {
                    System.out.println("Directory " + listOfFiles[i].getName());
                }
            }
            for (int i = 0; i < listOfFiles.length; i++) {
                if (!listOfFiles[i].toString().toLowerCase().isEmpty()) {
                    uploadToSmb(strPCPath,listOfFiles[i]);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            Log.e("", "", e);
        }
    }

    public static void uploadToSmb(String destinationPath, File localFile) {
        final byte[] BUFFER = new byte[10 * 8024];
        ByteArrayInputStream inputStream = null;
        SmbFileOutputStream sfos = null;
        try {
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);
            int lenghtOfFile = (int) localFile.length();
            byte[] data = FileUtils.readFileToByteArray(localFile);
            inputStream = new ByteArrayInputStream(data);
            String path = destinationPath + localFile.getName();
            NtlmPasswordAuthentication auth = new NtlmPasswordAuthentication("FEWADOM", username, password);
            SmbFile remoteFile1 = new SmbFile(path, auth);
            sfos = new SmbFileOutputStream(remoteFile1);
            long total = 0;
            int count;
            while ((count = inputStream.read(BUFFER)) > 0) {
                total += count;
                // publishing the progress....
                // After this onProgressUpdate will be called
                int percentage = (int) ((total / (float) lenghtOfFile) * 100);
                //publishProgress(percentage);
                // publishProgress((int) ((total * 100) / lenghtOfFile));
                // writing data to file
                sfos.write(BUFFER, 0, count);

            }
            sfos.flush();
            inputStream.close();
            sfos.close();

            if(localFile.delete()){
                System.out.println(localFile.getName() + " is deleted!");
            }else{
                System.out.println("Delete operation is failed.");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    //Copy files to Server
    public boolean downloadConfigFileFromServer(String strPCPath, String strSdcardPath) {
        SmbFile smbFileToDownload = null;
        try {
            File localFilePath = new File(strSdcardPath);

            // create sdcard path if not exist.
            if (!localFilePath.isDirectory()) {
                localFilePath.mkdir();
            }
            try {
                NtlmPasswordAuthentication auth = new NtlmPasswordAuthentication("FEWADOM", username, password);
                //SmbSession.logon(UniAddress.getByName(ip),auth);
                smbFileToDownload = new SmbFile(strPCPath,auth);
                String smbFileName = smbFileToDownload.getName();
                if (!smbFileName.toLowerCase().isEmpty()) {
                    InputStream inputStream = smbFileToDownload.getInputStream();

                    //only folder's path of the sdcard and append the file name after.
                    localFilePath = new File(strSdcardPath + "/" + smbFileName);

                    OutputStream out = new FileOutputStream(localFilePath);
                    byte buf[] = new byte[1024];
                    int len;
                    while ((len = inputStream.read(buf)) > 0) {
                        out.write(buf, 0, len);
                    }
                    out.flush();
                    out.close();
                    inputStream.close();
                    return true;
                } else
                    return false;
            }// End try
            catch (Exception e) {
                e.printStackTrace();
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }

    }// End downloadConfigFileFromServer Method.

    private void selectData() throws SQLiteException {
        SQLiteDatabase DataDB = null;
        Log.i("INFO", "Exporting the Site Note Report");
        try {
            DataDB = SQLiteDatabase.openDatabase(Agentry, null, 0x0000);
            Cursor c = DataDB
                    .rawQuery(
                            "select * from DATA;",
                            null);
            if (c != null) {
                if (c.moveToFirst()) {
                    do {
                        ip = c.getString(c
                                .getColumnIndex("ipAddress"));
                        strPCPath = c.getString(c
                                .getColumnIndex("folderPath"));
                        username = c.getString(c
                                .getColumnIndex("userName"));
                        password = c.getString(c
                                .getColumnIndex("passWord"));
                    } while (c.moveToNext());
                }
                c.close();
                Log.i("INFO", "Site Note Report Exported");
                DataDB.close();
            }
        } catch (SQLiteException se) {
            Log.e(getClass().getSimpleName(),
                    "Could not create or Open the database");
            //DataDB.close();
        }
    }
}
