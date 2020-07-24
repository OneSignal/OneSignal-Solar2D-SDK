/**
 * Modified MIT License
 *
 * Copyright 2015 OneSignal
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * 1. The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * 2. All copies of substantial portions of the Software may only be used in connection
 * with services provided by OneSignal.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.onesignal;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;

import org.json.JSONObject;

import android.os.Bundle;
import android.content.Context;
import android.content.Intent;
import android.content.BroadcastReceiver;

import android.util.Log;

// We disable Corona's GCM Receiver in OneSignal.init to keep OneSiganl notifications from double posting.
// This was added to let non-OneSignal GCM notifications to still be processed like normal through Corona.
//   - This filters out our OneSignal notifications from going through Corona's processing.

public class CoronaGCMFilterProxyReceiver extends BroadcastReceiver {

    private boolean isOneSignalGCM(Intent intent) throws Throwable {
        Bundle bundle = intent.getExtras();

        if (bundle.isEmpty())
            return false;

        if (bundle.containsKey("custom")) {
            JSONObject customJSON = new JSONObject(bundle.getString("custom"));
            return customJSON.has("i");
        }

        return false;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            if (isOneSignalGCM(intent))
                return;

            // Runs the following line with reflection
            // new GoogleCloudMessagingServices(context).process(intent);
            Class cl = Class.forName("com.ansca.corona.notifications.GoogleCloudMessagingServices");
            Constructor con = cl.getConstructor(Context.class);
            Object obj = con.newInstance(context);

            Method method = cl.getDeclaredMethod("process", Intent.class);
            method.setAccessible(true);
            method.invoke(obj, intent);
        } catch(Throwable t) {
            Log.e("CORONA_GCM_PROXY", "Could not call 'com.ansca.corona.notifications.GoogleCloudMessagingServices'", t);
        }
    }
}