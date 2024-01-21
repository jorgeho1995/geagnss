///////////////////////////////////////////////////////////
/// This file contains the classes and functions for
/// GNSS Raw measurements
//////////////////////////////////////////////////////////
/// Includes
import 'dart:isolate';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:raw_gnss/gnss_measurement_model.dart';
import 'package:raw_gnss/raw_gnss.dart';

///////////////////////////////////////////////////////////
/// Class for GNSS Raw measurements
/// Creates an isolate for the Measurements of the GNSS
//////////////////////////////////////////////////////////
class GnssMeas {
  static ReceivePort receivePort;
  static FlutterIsolate _isolate;

  static Future<ReceivePort> spawnIsolate() async {
    if (_isolate == null) {
      receivePort = ReceivePort();
      _isolate = await FlutterIsolate.spawn(createStream, receivePort.sendPort);
    }
    return receivePort;
  }

  @pragma('vm:entry-point')
  static void createStream(SendPort sp) async {
    Stream<GnssMeasurementModel> stream = RawGnss().gnssMeasurementEvents;
    stream.listen((event) {
      List<Map<String, dynamic>> toSend = [];
      Map<String, dynamic> clock = event.clock.toJson();
      event.measurements.forEach((element) {
        toSend.add(element.toJson());
      });
      sp.send(toSend);
      sp.send(clock);
      toSend.clear();
    });
  }

  static void killIsolate() {
    if (_isolate != null) {
      receivePort.close();
      receivePort = null;
      _isolate.kill();
      _isolate = null;
    }
  }
}
