local metadata =
{
    plugin =
    {
        format = 'jar',
        manifest =
        {
            permissions =
            {
                { name = ".permission.RECEIVE_ADM_MESSAGE", protectionLevel = "signature" },
            },
            usesPermissions =
            {
                "android.permission.INTERNET",
                "android.permission.ACCESS_NETWORK_STATE",
                "com.amazon.device.messaging.permission.RECEIVE",
                ".permission.RECEIVE_ADM_MESSAGE",
                "android.permission.WAKE_LOCK",
                "android.permission.VIBRATE",
                "android.permission.RECEIVE_BOOT_COMPLETED"
            },
            applicationChildElements =
            {
                [[
                <receiver android:name="com.onesignal.NotificationOpenedReceiver" />
                <receiver
                    android:name="com.onesignal.CoronaGCMFilterProxyReceiver"
                    android:permission="com.google.android.c2dm.permission.SEND" >
                   <intent-filter>
                       <action android:name="com.google.android.c2dm.intent.RECEIVE" />
                       <category android:name="@USER_ACTIVITY_PACKAGE@" />
                    </intent-filter>
                </receiver>
                <service android:name="com.onesignal.NotificationRestoreService" />
                <service android:name="com.onesignal.RestoreJobService"
                    android:permission="android.permission.BIND_JOB_SERVICE" />

               <service android:name="com.onesignal.RestoreKickoffJobService"
                  android:permission="android.permission.BIND_JOB_SERVICE" />
      ​
               <service android:name="com.onesignal.SyncService" android:stopWithTask="true" />
               <service android:name="com.onesignal.SyncJobService"
                  android:permission="android.permission.BIND_JOB_SERVICE" />

                <amazon:enable-feature android:name="com.amazon.device.messaging" android:required="false" xmlns:amazon="http://schemas.amazon.com/apk/res/android"/>
                <service android:name="com.onesignal.ADMMessageHandler" android:exported="false" />
                <receiver
                   android:name="com.onesignal.ADMMessageHandler$Receiver"
                   android:permission="com.amazon.device.messaging.permission.SEND" >
                   <intent-filter>
                       <action android:name="com.amazon.device.messaging.intent.REGISTRATION" />
                       <action android:name="com.amazon.device.messaging.intent.RECEIVE" />
                       <category android:name="@USER_ACTIVITY_PACKAGE@" />
                    </intent-filter>
                </receiver>
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
            ["shared.android.support.v4"] = "com.coronalabs",
            ["shared.android.support.v7.cardview"] = "com.coronalabs"
        },
    },
}
​
return metadata