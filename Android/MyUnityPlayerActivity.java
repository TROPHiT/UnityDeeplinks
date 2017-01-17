package com.trophit;

import com.unity3d.player.UnityPlayerActivity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;


public class MyUnityPlayerActivity extends UnityPlayerActivity {
    
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        // Log.d(getClass().getName(), "onCreate " + intent.getAction() + " " + intent.getDataString());
        onDeeplink(getIntent());
    }
    
    
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        // Log.d(getClass().getName(), "onNewIntent " + getIntent().getAction() + " " + getIntent().getDataString());
        onDeeplink(intent);
    }
    
    
    protected void onDeeplink(Intent intent) {
        if (Intent.ACTION_VIEW.equals(intent.getAction())) {
            String deeplink = intent.getDataString();
            // Log.d(getClass().getName(), "onDeeplink " + deeplink);
            if (deeplink != null)
                com.unity3d.player.UnityPlayer.UnitySendMessage(gameObject, deeplinkMethod, deeplink);
        }
    }

    protected static final String gameObject = "UnityDeeplinks";
    protected static final String deeplinkMethod = "onDeeplink";
}
