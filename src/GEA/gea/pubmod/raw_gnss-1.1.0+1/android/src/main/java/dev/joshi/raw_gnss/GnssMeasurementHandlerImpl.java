package dev.joshi.raw_gnss;

import android.location.GnssClock;
import android.location.GnssMeasurement;
import android.location.GnssMeasurementsEvent;
import android.location.LocationManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.RequiresApi;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;

public class GnssMeasurementHandlerImpl implements EventChannel.StreamHandler {
    private static final String TAG = "GNSS_MEASURE";

    LocationManager locationManager;
    GnssMeasurementsEvent.Callback listener;
    private final Handler uiThreadHandler = new Handler(Looper.getMainLooper());

    GnssMeasurementHandlerImpl(LocationManager manager) {
        locationManager = manager;
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        Log.d(TAG, "onListen");
        listener = createSensorEventListener(events);
        locationManager.registerGnssMeasurementsCallback(listener);
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onCancel(Object arguments) {
        Log.d(TAG, "onCancel");
        locationManager.unregisterGnssMeasurementsCallback(listener);
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    GnssMeasurementsEvent.Callback createSensorEventListener(final EventChannel.EventSink events) {
        return new GnssMeasurementsEvent.Callback() {
            @Override
            public void onGnssMeasurementsReceived(GnssMeasurementsEvent eventArgs) {
                Log.d(TAG, "onGnssMeasurementsReceived: " + eventArgs.getMeasurements().size());

                super.onGnssMeasurementsReceived(eventArgs);
                HashMap<String, Object> resultMap = new HashMap<>();
                resultMap.put("contents", eventArgs.describeContents());
                resultMap.put("string", eventArgs.toString());

                GnssClock clock = eventArgs.getClock();
                HashMap<String, Object> clockMap = new HashMap<>();

                clockMap.put("contents", clock.describeContents());
                clockMap.put("utcTimeMillis", System.currentTimeMillis());
                clockMap.put("biasNanos", clock.getBiasNanos());
                clockMap.put("biasUncertaintyNanos", clock.getBiasUncertaintyNanos());
                clockMap.put("driftNanosPerSecond", clock.getDriftNanosPerSecond());
                clockMap.put("driftUncertaintyNanosPerSecond", clock.getDriftUncertaintyNanosPerSecond());
                clockMap.put("fullBiasNanos", clock.getFullBiasNanos());
                clockMap.put("hardwareClockDiscontinuityCount", clock.getHardwareClockDiscontinuityCount());
                clockMap.put("leapSecond", clock.getLeapSecond());
                clockMap.put("timeNanos", clock.getTimeNanos());
                clockMap.put("timeUncertaintyNanos", clock.getTimeUncertaintyNanos());
                clockMap.put("elapsedRealtimeNanos", clock.getElapsedRealtimeNanos());

                resultMap.put("clock", clockMap);

                Collection<GnssMeasurement> measurements = eventArgs.getMeasurements();

                ArrayList<HashMap<String, Object>> measurementsMapList  = new ArrayList<>();

                for (int i = 0; i < measurements.size(); ++i) {
                    HashMap<String, Object> map = new HashMap<>();
                    GnssMeasurement measurement = (GnssMeasurement) measurements.toArray()[i];

                    map.put("contents", measurement.describeContents());
                    map.put("accumulatedDeltaRangeMeters", measurement.getAccumulatedDeltaRangeMeters());
                    map.put("accumulatedDeltaRangeState", measurement.getAccumulatedDeltaRangeState());
                    map.put("accumulatedDeltaRangeUncertaintyMeters", measurement.getAccumulatedDeltaRangeUncertaintyMeters());
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        map.put("automaticGainControlLevelDb", measurement.getAutomaticGainControlLevelDb());
                    }
                    map.put("carrierFrequencyHz", measurement.getCarrierFrequencyHz());
                    map.put("cn0DbHz", measurement.getCn0DbHz());
                    map.put("constellationType", measurement.getConstellationType());
                    map.put("multipathIndicator", measurement.getMultipathIndicator());
                    map.put("pseudorangeRateMetersPerSecond", measurement.getPseudorangeRateMetersPerSecond());
                    map.put("pseudorangeRateUncertaintyMetersPerSecond", measurement.getPseudorangeRateUncertaintyMetersPerSecond());
                    map.put("receivedSvTimeNanos", measurement.getReceivedSvTimeNanos());
                    map.put("receivedSvTimeUncertaintyNanos", measurement.getReceivedSvTimeUncertaintyNanos());
                    map.put("snrInDb", measurement.getSnrInDb());
                    map.put("state", measurement.getState());
                    map.put("svid", measurement.getSvid());
                    map.put("timeOffsetNanos", measurement.getTimeOffsetNanos());
                    map.put("basebandCn0DbHz", measurement.getBasebandCn0DbHz());
                    map.put("fullInterSignalBiasNanos", measurement.getFullInterSignalBiasNanos());
                    map.put("fullInterSignalBiasUncertaintyNanos", measurement.getFullInterSignalBiasUncertaintyNanos());
                    map.put("satelliteInterSignalBiasNanos", measurement.getSatelliteInterSignalBiasNanos());
                    map.put("satelliteInterSignalBiasUncertaintyNanos", measurement.getSatelliteInterSignalBiasUncertaintyNanos());
                    map.put("codeType", measurement.getCodeType());
                    map.put("string", measurement.toString());

                    measurementsMapList.add(map);
                }

                resultMap.put("measurements", measurementsMapList);

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
