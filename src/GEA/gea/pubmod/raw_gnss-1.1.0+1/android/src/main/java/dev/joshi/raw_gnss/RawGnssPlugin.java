package dev.joshi.raw_gnss;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.location.GnssMeasurement;
import android.location.GnssMeasurementsEvent;
import android.location.GnssNavigationMessage;
import android.location.LocationManager;
import android.location.OnNmeaMessageListener;
import android.location.GnssStatus;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** RawGnssPlugin */
public class RawGnssPlugin implements FlutterPlugin {

  private static final String GNSS_MEASUREMENT_CHANNEL_NAME =
          "dev.joshi.raw_gnss/gnss_measurement";
  private static final String GNSS_NAVIGATION_MESSAGE_CHANNEL_NAME = "dev.joshi.raw_gnss/gnss_navigation_message";
  private static final String GNSS_STATUS_CHANNEL_NAME = "dev.joshi.raw_gnss/gnss_status";

  private EventChannel gnssMeasurementChannel;
  private EventChannel gnssNavigationMessageChannel;
  private EventChannel gnssStatusChannel;
  private LocationManager locationManager;
  private Context context;

  @RequiresApi(api = Build.VERSION_CODES.N)
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    setupEventChannels(context, flutterPluginBinding.getBinaryMessenger());
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  @RequiresApi(api = Build.VERSION_CODES.N)
  public static void registerWith(Registrar registrar) {
    RawGnssPlugin plugin = new RawGnssPlugin();
    plugin.setupEventChannels(registrar.context(), registrar.messenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    teardownEventChannels();
  }

  @RequiresApi(api = Build.VERSION_CODES.N)
  private void setupEventChannels(Context context, BinaryMessenger messenger) {
    locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
    gnssMeasurementChannel = new EventChannel(messenger, GNSS_MEASUREMENT_CHANNEL_NAME);
    gnssNavigationMessageChannel = new EventChannel(messenger, GNSS_NAVIGATION_MESSAGE_CHANNEL_NAME);
    gnssStatusChannel = new EventChannel(messenger, GNSS_STATUS_CHANNEL_NAME);

    final GnssMeasurementHandlerImpl gnssMeasurementStreamHandler =
            new GnssMeasurementHandlerImpl(locationManager);
    gnssMeasurementChannel.setStreamHandler(gnssMeasurementStreamHandler);

    final GnssNavigationMessageHandlerImpl gnssNavigationMessageHandler =
            new GnssNavigationMessageHandlerImpl(locationManager);
    gnssNavigationMessageChannel.setStreamHandler(gnssNavigationMessageHandler);

    final GnssStatusHandlerImpl gnssStatusStreamHandler =
            new GnssStatusHandlerImpl(locationManager);
    gnssStatusChannel.setStreamHandler(gnssStatusStreamHandler);
  }

  private void teardownEventChannels() {
    gnssMeasurementChannel.setStreamHandler(null);
    gnssNavigationMessageChannel.setStreamHandler(null);
    gnssStatusChannel.setStreamHandler(null);
  }
}
