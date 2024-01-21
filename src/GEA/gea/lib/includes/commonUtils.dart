///////////////////////////////////////////////////////////
/// This file contains common functions
//////////////////////////////////////////////////////////
import 'dart:io';
import 'package:flutter_android/android.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;

///////////////////////////////////////////////////////////
/// Function to format GNSS Raw data to NMEA format
/// Inputs:
///   Map<String, dynamic> gnss      Raw GNSS measurements
///   Map<String, dynamic> clock     GNSS clock data
/// Outputs:
///   String               nmeaMsg   NMEA message
//////////////////////////////////////////////////////////
String nmeaRawMsgFormatter(
    Map<String, dynamic> gnss, Map<String, dynamic> clock) {
  /// Define variables
  String nmeaMsg = "Raw,";

  /// Clock parameters
  String utcTimeMillis = clock["utcTimeMillis"].toString() + ",";
  String timeNanos = clock["timeNanos"].toString() + ",";
  String leapSecond = clock["leapSecond"].toString() + ",";
  String timeUncertaintyNanos = clock["timeUncertaintyNanos"].toString() + ",";
  String fullBiasNanos = clock["fullBiasNanos"].toString() + ",";
  String biasNanos = clock["biasNanos"].toString() + ",";
  String biasUncertaintyNanos = clock["biasUncertaintyNanos"].toString() + ",";
  String driftNanosPerSecond = clock["driftNanosPerSecond"].toString() + ",";
  String driftUncertaintyNanosPerSecond =
      clock["driftUncertaintyNanosPerSecond"].toString() + ",";
  String hardwareClockDiscontinuityCount =
      clock["hardwareClockDiscontinuityCount"].toString() + ",";
  String chipsetElapsedRealtimeNanos =
      clock["elapsedRealtimeNanos"].toString();

  /// Raw GNSS parameters
  String svid = gnss["svid"].toString() + ",";
  String timeOffsetNanos = gnss["timeOffsetNanos"].toString() + ",";
  String state = gnss["state"].toString() + ",";
  String receivedSvTimeNanos = gnss["receivedSvTimeNanos"].toString() + ",";
  String receivedSvTimeUncertaintyNanos =
      gnss["receivedSvTimeUncertaintyNanos"].toString() + ",";
  String cn0DbHz = gnss["cn0DbHz"].toString() + ",";
  String pseudorangeRateMetersPerSecond =
      gnss["pseudorangeRateMetersPerSecond"].toString() + ",";
  String pseudorangeRateUncertaintyMetersPerSecond =
      gnss["pseudorangeRateUncertaintyMetersPerSecond"].toString() + ",";
  String accumulatedDeltaRangeState =
      gnss["accumulatedDeltaRangeState"].toString() + ",";
  String accumulatedDeltaRangeMeters =
      gnss["accumulatedDeltaRangeMeters"].toString() + ",";
  String accumulatedDeltaRangeUncertaintyMeters =
      gnss["accumulatedDeltaRangeUncertaintyMeters"].toString() + ",";
  String carrierFrequencyHz = gnss["carrierFrequencyHz"].toString() + ",";
  String carrierCycles = ",";
  String carrierPhase = ",";
  String carrierPhaseUncertainty = ",";
  String multipathIndicator = gnss["multipathIndicator"].toString() + ",";
  String snrInDb = gnss["snrInDb"].toString() + ",";
  String constellationType = gnss["constellationType"].toString() + ",";
  String automaticGainControlLevelDb =
      gnss["automaticGainControlLevelDb"].toString() + ",";
  String basebandCn0DbHz = gnss["basebandCn0DbHz"].toString() + ",";
  String fullInterSignalBiasNanos =
      gnss["fullInterSignalBiasNanos"].toString() + ",";
  String fullInterSignalBiasUncertaintyNanos =
      gnss["fullInterSignalBiasUncertaintyNanos"].toString() + ",";
  String satelliteInterSignalBiasNanos =
      gnss["satelliteInterSignalBiasNanos"].toString() + ",";
  String satelliteInterSignalBiasUncertaintyNanos =
      gnss["satelliteInterSignalBiasUncertaintyNanos"].toString() + ",";
  String codeType = gnss["codeType"].toString() + ",";

  /// Create msg
  nmeaMsg += utcTimeMillis +
      timeNanos +
      leapSecond +
      timeUncertaintyNanos +
      fullBiasNanos +
      biasNanos +
      biasUncertaintyNanos +
      driftNanosPerSecond +
      driftUncertaintyNanosPerSecond +
      hardwareClockDiscontinuityCount +
      svid +
      timeOffsetNanos +
      state +
      receivedSvTimeNanos +
      receivedSvTimeUncertaintyNanos +
      cn0DbHz +
      pseudorangeRateMetersPerSecond +
      pseudorangeRateUncertaintyMetersPerSecond +
      accumulatedDeltaRangeState +
      accumulatedDeltaRangeMeters +
      accumulatedDeltaRangeUncertaintyMeters +
      carrierFrequencyHz +
      carrierCycles +
      carrierPhase +
      carrierPhaseUncertainty +
      multipathIndicator +
      snrInDb +
      constellationType +
      automaticGainControlLevelDb +
      basebandCn0DbHz +
      fullInterSignalBiasNanos +
      fullInterSignalBiasUncertaintyNanos +
      satelliteInterSignalBiasNanos +
      satelliteInterSignalBiasUncertaintyNanos +
      codeType +
      chipsetElapsedRealtimeNanos;

  /// Return msg in nmea formatter
  return nmeaMsg;
}

///////////////////////////////////////////////////////////
/// Get Directory File
/// Outputs:
///   String               directory External Storage Dir
//////////////////////////////////////////////////////////
Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();
  return directory.path;
}

///////////////////////////////////////////////////////////
/// Function to share files
/// Inputs:
///   String               name   Title
///   String               desc   Description of file
///   String               file   Filename
//////////////////////////////////////////////////////////
Future<void> shareFile(String name, String desc, String file) async {
  final path = "/storage/emulated/0/Android/data/xyz.gea/files/" + file;
  await FlutterShare.shareFile(
    title: name,
    text: desc,
    filePath: path,
  );
}

///////////////////////////////////////////////////////////
/// Function to get Android Device info
/// Inputs:
///   AndroidDeviceInfo    build   Device info init
//////////////////////////////////////////////////////////
Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
  return <String, dynamic>{
    'version.securityPatch': build.version.securityPatch,
    'version.sdkInt': build.version.sdkInt,
    'version.release': build.version.release,
    'version.previewSdkInt': build.version.previewSdkInt,
    'version.incremental': build.version.incremental,
    'version.codename': build.version.codename,
    'version.baseOS': build.version.baseOS,
    'board': build.board,
    'bootloader': build.bootloader,
    'brand': build.brand,
    'device': build.device,
    'display': build.display,
    'fingerprint': build.fingerprint,
    'hardware': build.hardware,
    'host': build.host,
    'id': build.id,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    'supported32BitAbis': build.supported32BitAbis,
    'supported64BitAbis': build.supported64BitAbis,
    'supportedAbis': build.supportedAbis,
    'tags': build.tags,
    'type': build.type,
    'isPhysicalDevice': build.isPhysicalDevice,
    'androidId': build.androidId,
    'systemFeatures': build.systemFeatures,
  };
}

///////////////////////////////////////////////////////////
/// Function to get Mount Points from Ntrip Casters
/// Inputs:
///   String               url   URL
//////////////////////////////////////////////////////////
Future<http.Response> fetchNtripMountPoints(String url) {
  return http.get(Uri.parse(url));
}
