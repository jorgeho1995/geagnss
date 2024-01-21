import 'dart:async';

import 'package:flutter/services.dart';
import 'package:raw_gnss/gnss_measurement_model.dart';
import 'package:raw_gnss/gnss_status_model.dart';

class RawGnss {
  /// This channel hooks onto the stream for GnssMeasurement events
  static const EventChannel _gnssMeasurementEventChannel =
      EventChannel('dev.joshi.raw_gnss/gnss_measurement');

  /// This channel hooks onto the stream for GnssNavigationMessage events
  static const EventChannel _gnssNavigationMessageEventChannel =
      EventChannel('dev.joshi.raw_gnss/gnss_navigation_message');

  /// This channel hooks onto the stream for GnssNavigationMessage events
  static const EventChannel _gnssStatusEventChannel =
      EventChannel('dev.joshi.raw_gnss/gnss_status');

  Stream<GnssMeasurementModel>? _gnssMeasurementEvents;
  Stream? _gnssNavigationMessageEvents;
  Stream<GnssStatusModel>? _gnssStatusEvents;

  /// Getter for GnssMeasurement events
  Stream<GnssMeasurementModel> get gnssMeasurementEvents {
    if (_gnssMeasurementEvents == null) {
      _gnssMeasurementEvents = _gnssMeasurementEventChannel
          .receiveBroadcastStream()
          .map((event) => GnssMeasurementModel.fromJson(
              (event as Map<dynamic, dynamic>).cast()));
    }
    return _gnssMeasurementEvents!;
  }

  /// Getter for GnssNavigationMessage events
  Stream get gnssNavigationMessageEvents {
    if (_gnssNavigationMessageEvents == null) {
      _gnssNavigationMessageEvents =
          _gnssNavigationMessageEventChannel.receiveBroadcastStream();
    }
    return _gnssNavigationMessageEvents!;
  }

  /// Getter for GnssMeasurement events
  Stream<GnssStatusModel> get gnssStatusEvents {
    if (_gnssMeasurementEvents == null) {
      _gnssStatusEvents = _gnssStatusEventChannel.receiveBroadcastStream().map(
          (event) => GnssStatusModel.fromJson(
              (event as Map<dynamic, dynamic>).cast()));
    }
    return _gnssStatusEvents!;
  }
}
