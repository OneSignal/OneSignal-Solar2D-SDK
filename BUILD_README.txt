## README


#### Getting this Android Build ERROR?
```shell
BUILD FAILED
/Users/Kasten/android-sdk/tools/ant/build.xml:470: The following error occurred while executing this line:
/Applications/CoronaEnterprise/Corona/android/lib/Corona/build.xml:46: sdk.dir is missing. Make sure to generate local.properties using 'android update project' or to inject it through an env var
```

Run this:
```shell
cd /Applications/CoronaEnterprise/Corona/android/lib/Corona
android update lib-project --path . --target android-10
```

This needs to be run each time you update Corona Entprise before doing a SDK build for some reason.