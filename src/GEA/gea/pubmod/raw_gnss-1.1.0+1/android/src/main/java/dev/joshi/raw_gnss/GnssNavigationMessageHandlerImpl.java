package dev.joshi.raw_gnss;

import android.location.GnssNavigationMessage;
import android.location.LocationManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.RequiresApi;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;

public class GnssNavigationMessageHandlerImpl implements EventChannel.StreamHandler {
    private static final String TAG = "GNSS_MESSAGE";

    LocationManager locationManager;
    GnssNavigationMessage.Callback listener;
    private final Handler uiThreadHandler = new Handler(Looper.getMainLooper());

    GnssNavigationMessageHandlerImpl(LocationManager manager) {
        locationManager = manager;
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        Log.d(TAG, "onListen");
        listener = createSensorEventListener(events);
        locationManager.registerGnssNavigationMessageCallback(listener);
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onCancel(Object arguments) {
        Log.d(TAG, "onCancel");
        locationManager.unregisterGnssNavigationMessageCallback(listener);
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    GnssNavigationMessage.Callback createSensorEventListener(final EventChannel.EventSink events) {
        return new GnssNavigationMessage.Callback() {
            @Override
            public void onGnssNavigationMessageReceived(GnssNavigationMessage event) {
                Log.d(TAG, "onGnssNavigationMessageReceived: " + event.toString());

                super.onGnssNavigationMessageReceived(event);
                HashMap<String, Object> resultMap = new HashMap<>();
                resultMap.put("data", event.getData());
                resultMap.put("contents", event.describeContents());
                resultMap.put("messageId", event.getMessageId());
                resultMap.put("status", event.getStatus());
                resultMap.put("subMessageId", event.getSubmessageId());
                resultMap.put("svid", event.getSvid());
                resultMap.put("type", event.getType());

                uiThreadHandler.post(() -> events.success(resultMap));
            }

            @Override
            public void onStatusChanged(int status) {
                Log.d(TAG, "onStatusChanged: " + status);
                super.onStatusChanged(status);
            }
        };
    }
}
