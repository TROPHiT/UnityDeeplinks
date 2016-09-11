package com.trophit;

import com.unity3d.player.UnityPlayerActivity;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Window;


public class DeeplinkActivity extends Activity {
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        Log.d(getClass().getName(), "onCreate " + intent.getAction() + " " + intent.getDataString());
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        
        Class<?> cls = getMainActivityClass();
        if (cls != null) {
            Intent newIntent = new Intent(this, cls);
            this.startActivity(newIntent);
            onDeeplink(intent);
        }
        finish();
    }
    
    protected void onDeeplink(Intent intent) {
        if (Intent.ACTION_VIEW.equals(intent.getAction())) {
            String deeplink = intent.getDataString();
            Log.d(getClass().getName(), "onDeeplink " + deeplink);
            if (deeplink != null)
                com.unity3d.player.UnityPlayer.UnitySendMessage(gameObject, deeplinkMethod, deeplink);
        }
    }

    private Class<?> getMainActivityClass() {
        String packageName = this.getPackageName();
        Intent launchIntent = this.getPackageManager().getLaunchIntentForPackage(packageName);
        try {
            return Class.forName(launchIntent.getComponent().getClassName());
        } catch (Exception e) {
            Log.e(getClass().getName(), "getMainActivityClass: Unable to find Main Activity Class");
            return null;
        }
    }
    
    protected static final String gameObject = "UnityDeeplinks";
    protected static final String deeplinkMethod = "onDeeplink";
}
