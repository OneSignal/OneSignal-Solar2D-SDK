local metadata =
{
    plugin =
    {
        format = 'jar',
        manifest =
        {
            permissions =
            {
                { name = ".permission.C2D_MESSAGE", protectionLevel = "signature" },
            },
            usesPermissions =
            {
                "android.permission.INTERNET",
                "android.permission.ACCESS_NETWORK_STATE",
                "com.google.android.c2dm.permission.RECEIVE",
                ".permission.C2D_MESSAGE",
                "android.permission.WAKE_LOCK",
                "android.permission.VIBRATE",
                "android.permission.RECEIVE_BOOT_COMPLETED"
            },
            applicationChildElements =
            {
                [[
                <meta-data android:name="com.onesignal.BadgeCount" android:value="DISABLE" />
                <receiver android:name="com.onesignal.NotificationOpenedReceiver" />
                <receiver
                    android:name="com.onesignal.GcmBroadcastReceiver"
                    android:permission="com.google.android.c2dm.permission.SEND" >
                  <intent-filter>
                      <action android:name="com.google.android.c2dm.intent.RECEIVE" />
                      <category android:name="@USER_ACTIVITY_PACKAGE@" />
                  </intent-filter>
                </receiver>
                <receiver
                    android:name="com.onesignal.CoronaGCMFilterProxyReceiver"
                    android:permission="com.google.android.c2dm.permission.SEND" >
                   <intent-filter>
                       <action android:name="com.google.android.c2dm.intent.RECEIVE" />
                       <category android:name="@USER_ACTIVITY_PACKAGE@" />
                    </intent-filter>
                </receiver>
                <service android:name="com.onesignal.NotificationRestoreService" />
      ​
                <service android:name="com.onesignal.GcmIntentService" />
                <service android:name="com.onesignal.GcmIntentJobService"
                         android:permission="android.permission.BIND_JOB_SERVICE" />
      ​
                <service android:name="com.onesignal.RestoreJobService"
                    android:permission="android.permission.BIND_JOB_SERVICE" />
      ​
                <service android:name="com.onesignal.RestoreKickoffJobService"
                    android:permission="android.permission.BIND_JOB_SERVICE" />
      ​
                <service android:name="com.onesignal.SyncService" android:stopWithTask="true" />
                <service android:name="com.onesignal.SyncJobService"
                    android:permission="android.permission.BIND_JOB_SERVICE" />
      ​
                <activity android:name="com.onesignal.PermissionsActivity" android:theme="@android:style/Theme.Translucent.NoTitleBar" />
                <receiver android:name="com.onesignal.BootUpReceiver">
                    <intent-filter>
                        <action android:name="android.intent.action.ACTION_BOOT_COMPLETED" />
                        <action android:name="android.intent.action.BOOT_COMPLETED" />
                        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                    </intent-filter>
                </receiver>
                <receiver android:name="com.onesignal.UpgradeReceiver" >
                    <intent-filter>
                        <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                    </intent-filter>
                </receiver>
                ]]
            },
        },
    },
    coronaManifest = {
        dependencies = {
            ["shared.firebase.messaging"] = "com.coronalabs",
            ["shared.android.support.v4"] = "com.coronalabs",
            ["shared.android.support.v7.cardview"] = "com.coronalabs"
        },
    },
}
​
return metadata