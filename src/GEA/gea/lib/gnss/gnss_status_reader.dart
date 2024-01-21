///////////////////////////////////////////////////////////
/// This file contains the classes and functions for
/// GNSS Status
//////////////////////////////////////////////////////////
/// Includes
import 'dart:isolate';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:gnss_status/gnss_status.dart';
import 'package:gnss_status/gnss_status_model.dart';

///////////////////////////////////////////////////////////
/// Class for GNSS Status
/// Creates an isolate for the Status of the GNSS
//////////////////////////////////////////////////////////
class GnssStat {
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
    Stream<GnssStatusModel> stream = GnssStatus().gnssStatusEvents;
    stream.listen((event) {
      List<Map<String, dynamic>> toSend = [];
      event.status.forEach((element) {
        toSend.add(element.toJson());
      });
      sp.send(toSend);
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
