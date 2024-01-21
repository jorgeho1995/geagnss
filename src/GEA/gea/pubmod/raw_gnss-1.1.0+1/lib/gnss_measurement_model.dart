// To parse this JSON data, do
//
//     final gnssMeasurementModel = gnssMeasurementModelFromJson(jsonString);

import 'dart:convert';

GnssMeasurementModel gnssMeasurementModelFromJson(String str) =>
    GnssMeasurementModel.fromJson(json.decode(str));

String gnssMeasurementModelToJson(GnssMeasurementModel data) =>
    json.encode(data.toJson());

/// Model for the GnssMeasurement class in Android
class GnssMeasurementModel {
  GnssMeasurementModel({
    this.contents,
    this.string,
    this.measurements,
    this.clock,
  });

  final int? contents;
  final String? string;
  final List<Measurement>? measurements;
  final Clock? clock;

  factory GnssMeasurementModel.fromJson(Map<String, dynamic> json) =>
      GnssMeasurementModel(
        contents: json["contents"] == null ? null : json["contents"],
        string: json["string"] == null ? null : json["string"],
        measurements: json["measurements"] == null
            ? null
            : List<Measurement>.from(json["measurements"].map(
                (x) => Measurement.fromJson(Map<String, dynamic>.from(x)))),
        clock: json["clock"] == null
            ? null
            : Clock.fromJson(Map<String, dynamic>.from(json["clock"])),
      );

  Map<String, dynamic> toJson() => {
        "contents": contents == null ? null : contents,
        "string": string == null ? null : string,
        "measurements": measurements == null
            ? null
            : List<dynamic>.from(measurements!.map((x) => x.toJson())),
        "clock": clock == null ? null : clock!.toJson(),
      };
}

class Clock {
  Clock({
    this.contents,
    this.utcTimeMillis,
    this.biasNanos,
    this.biasUncertaintyNanos,
    this.driftNanosPerSecond,
    this.driftUncertaintyNanosPerSecond,
    this.fullBiasNanos,
    this.hardwareClockDiscontinuityCount,
    this.leapSecond,
    this.timeNanos,
    this.timeUncertaintyNanos,
    this.elapsedRealtimeNanos,
  });

  final int? contents;
  final int? utcTimeMillis;
  final double? biasNanos;
  final double? biasUncertaintyNanos;
  final double? driftNanosPerSecond;
  final double? driftUncertaintyNanosPerSecond;
  final int? fullBiasNanos;
  final int? hardwareClockDiscontinuityCount;
  final int? leapSecond;
  final int? timeNanos;
  final double? timeUncertaintyNanos;
  final int? elapsedRealtimeNanos;

  factory Clock.fromJson(Map<String, dynamic> json) => Clock(
        contents: json["contents"] == null ? null : json["contents"],
        utcTimeMillis: json["utcTimeMillis"] == null ? null : json["utcTimeMillis"],
        biasNanos:
            json["biasNanos"] == null ? null : json["biasNanos"].toDouble(),
        biasUncertaintyNanos: json["biasUncertaintyNanos"] == null
            ? null
            : json["biasUncertaintyNanos"].toDouble(),
        driftNanosPerSecond: json["driftNanosPerSecond"] == null
            ? null
            : json["driftNanosPerSecond"].toDouble(),
        driftUncertaintyNanosPerSecond:
            json["driftUncertaintyNanosPerSecond"] == null
                ? null
                : json["driftUncertaintyNanosPerSecond"].toDouble(),
        fullBiasNanos:
            json["fullBiasNanos"] == null ? null : json["fullBiasNanos"],
        hardwareClockDiscontinuityCount:
            json["hardwareClockDiscontinuityCount"] == null
                ? null
                : json["hardwareClockDiscontinuityCount"],
        leapSecond: json["leapSecond"] == null ? null : json["leapSecond"],
        timeNanos: json["timeNanos"] == null ? null : json["timeNanos"],
        timeUncertaintyNanos: json["timeUncertaintyNanos"] == null
            ? null
            : json["timeUncertaintyNanos"].toDouble(),
        elapsedRealtimeNanos: json["elapsedRealtimeNanos"] == null
            ? null
            : json["elapsedRealtimeNanos"],
      );

  Map<String, dynamic> toJson() => {
        "contents": contents == null ? null : contents,
        "utcTimeMillis": utcTimeMillis,
        "biasNanos": biasNanos == null ? null : biasNanos,
        "biasUncertaintyNanos":
            biasUncertaintyNanos == null ? null : biasUncertaintyNanos,
        "driftNanosPerSecond":
            driftNanosPerSecond == null ? null : driftNanosPerSecond,
        "driftUncertaintyNanosPerSecond": driftUncertaintyNanosPerSecond == null
            ? null
            : driftUncertaintyNanosPerSecond,
        "fullBiasNanos": fullBiasNanos == null ? null : fullBiasNanos,
        "hardwareClockDiscontinuityCount":
            hardwareClockDiscontinuityCount == null
                ? null
                : hardwareClockDiscontinuityCount,
        "leapSecond": leapSecond == null ? null : leapSecond,
        "timeNanos": timeNanos == null ? null : timeNanos,
        "timeUncertaintyNanos":
            timeUncertaintyNanos == null ? null : timeUncertaintyNanos,
        "elapsedRealtimeNanos":
            elapsedRealtimeNanos == null ? null : elapsedRealtimeNanos,
      };
}

class Measurement {
  Measurement({
    this.contents,
    this.accumulatedDeltaRangeMeters,
    this.accumulatedDeltaRangeState,
    this.accumulatedDeltaRangeUncertaintyMeters,
    this.automaticGainControlLevelDb,
    this.carrierFrequencyHz,
    this.cn0DbHz,
    this.constellationType,
    this.multipathIndicator,
    this.pseudorangeRateMetersPerSecond,
    this.pseudorangeRateUncertaintyMetersPerSecond,
    this.receivedSvTimeNanos,
    this.receivedSvTimeUncertaintyNanos,
    this.snrInDb,
    this.state,
    this.svid,
    this.timeOffsetNanos,
    this.basebandCn0DbHz,
    this.fullInterSignalBiasNanos,
    this.fullInterSignalBiasUncertaintyNanos,
    this.satelliteInterSignalBiasNanos,
    this.satelliteInterSignalBiasUncertaintyNanos,
    this.codeType,
    this.string,
  });

  final int? contents;
  final double? accumulatedDeltaRangeMeters;
  final int? accumulatedDeltaRangeState;
  final double? accumulatedDeltaRangeUncertaintyMeters;
  final double? automaticGainControlLevelDb;
  final double? carrierFrequencyHz;
  final double? cn0DbHz;
  final int? constellationType;
  final int? multipathIndicator;
  final double? pseudorangeRateMetersPerSecond;
  final double? pseudorangeRateUncertaintyMetersPerSecond;
  final int? receivedSvTimeNanos;
  final int? receivedSvTimeUncertaintyNanos;
  final double? snrInDb;
  final int? state;
  final int? svid;
  final double? timeOffsetNanos;
  final double? basebandCn0DbHz;
  final double? fullInterSignalBiasNanos;
  final double? fullInterSignalBiasUncertaintyNanos;
  final double? satelliteInterSignalBiasNanos;
  final double? satelliteInterSignalBiasUncertaintyNanos;
  final String? codeType;
  final String? string;

  factory Measurement.fromJson(Map<String, dynamic> json) => Measurement(
        contents: json["contents"] == null ? null : json["contents"],
        accumulatedDeltaRangeMeters: json["accumulatedDeltaRangeMeters"] == null
            ? null
            : json["accumulatedDeltaRangeMeters"].toDouble(),
        accumulatedDeltaRangeState: json["accumulatedDeltaRangeState"] == null
            ? null
            : json["accumulatedDeltaRangeState"],
        accumulatedDeltaRangeUncertaintyMeters:
            json["accumulatedDeltaRangeUncertaintyMeters"] == null
                ? null
                : json["accumulatedDeltaRangeUncertaintyMeters"].toDouble(),
        automaticGainControlLevelDb: json["automaticGainControlLevelDb"] == null
            ? null
            : json["automaticGainControlLevelDb"].toDouble(),
        carrierFrequencyHz: json["carrierFrequencyHz"] == null
            ? null
            : json["carrierFrequencyHz"].toDouble(),
        cn0DbHz: json["cn0DbHz"] == null ? null : json["cn0DbHz"].toDouble(),
        constellationType: json["constellationType"] == null
            ? null
            : json["constellationType"],
        multipathIndicator: json["multipathIndicator"] == null
            ? null
            : json["multipathIndicator"],
        pseudorangeRateMetersPerSecond:
            json["pseudorangeRateMetersPerSecond"] == null
                ? null
                : json["pseudorangeRateMetersPerSecond"].toDouble(),
        pseudorangeRateUncertaintyMetersPerSecond:
            json["pseudorangeRateUncertaintyMetersPerSecond"] == null
                ? null
                : json["pseudorangeRateUncertaintyMetersPerSecond"].toDouble(),
        receivedSvTimeNanos: json["receivedSvTimeNanos"] == null
            ? null
            : json["receivedSvTimeNanos"],
        receivedSvTimeUncertaintyNanos:
            json["receivedSvTimeUncertaintyNanos"] == null
                ? null
                : json["receivedSvTimeUncertaintyNanos"],
        snrInDb: json["snrInDb"] == null ? null : json["snrInDb"].toDouble(),
        state: json["state"] == null ? null : json["state"],
        svid: json["svid"] == null ? null : json["svid"],
        timeOffsetNanos: json["timeOffsetNanos"] == null
            ? null
            : json["timeOffsetNanos"].toDouble(),
        basebandCn0DbHz: json["basebandCn0DbHz"] == null
            ? null
            : json["basebandCn0DbHz"].toDouble(),
        fullInterSignalBiasNanos: json["fullInterSignalBiasNanos"] == null
            ? null
            : json["fullInterSignalBiasNanos"].toDouble(),
        fullInterSignalBiasUncertaintyNanos:
            json["fullInterSignalBiasUncertaintyNanos"] == null
                ? null
                : json["fullInterSignalBiasUncertaintyNanos"].toDouble(),
        satelliteInterSignalBiasNanos:
            json["satelliteInterSignalBiasNanos"] == null
                ? null
                : json["satelliteInterSignalBiasNanos"].toDouble(),
        satelliteInterSignalBiasUncertaintyNanos:
            json["satelliteInterSignalBiasUncertaintyNanos"] == null
                ? null
                : json["satelliteInterSignalBiasUncertaintyNanos"].toDouble(),
        codeType: json["codeType"] == null ? null : json["codeType"],
        string: json["string"] == null ? null : json["string"],
      );

  Map<String, dynamic> toJson() => {
        "contents": contents == null ? null : contents,
        "accumulatedDeltaRangeMeters": accumulatedDeltaRangeMeters == null
            ? null
            : accumulatedDeltaRangeMeters,
        "accumulatedDeltaRangeState": accumulatedDeltaRangeState == null
            ? null
            : accumulatedDeltaRangeState,
        "accumulatedDeltaRangeUncertaintyMeters":
            accumulatedDeltaRangeUncertaintyMeters == null
                ? null
                : accumulatedDeltaRangeUncertaintyMeters,
        "automaticGainControlLevelDb": automaticGainControlLevelDb == null
            ? null
            : automaticGainControlLevelDb,
        "carrierFrequencyHz":
            carrierFrequencyHz == null ? null : carrierFrequencyHz,
        "cn0DbHz": cn0DbHz == null ? null : cn0DbHz,
        "constellationType":
            constellationType == null ? null : constellationType,
        "multipathIndicator":
            multipathIndicator == null ? null : multipathIndicator,
        "pseudorangeRateMetersPerSecond": pseudorangeRateMetersPerSecond == null
            ? null
            : pseudorangeRateMetersPerSecond,
        "pseudorangeRateUncertaintyMetersPerSecond":
            pseudorangeRateUncertaintyMetersPerSecond == null
                ? null
                : pseudorangeRateUncertaintyMetersPerSecond,
        "receivedSvTimeNanos":
            receivedSvTimeNanos == null ? null : receivedSvTimeNanos,
        "receivedSvTimeUncertaintyNanos": receivedSvTimeUncertaintyNanos == null
            ? null
            : receivedSvTimeUncertaintyNanos,
        "snrInDb": snrInDb == null ? null : snrInDb,
        "state": state == null ? null : state,
        "svid": svid == null ? null : svid,
        "timeOffsetNanos": timeOffsetNanos == null ? null : timeOffsetNanos,
        "basebandCn0DbHz": basebandCn0DbHz == null ? null : basebandCn0DbHz,
        "fullInterSignalBiasNanos":
            fullInterSignalBiasNanos == null ? null : fullInterSignalBiasNanos,
        "fullInterSignalBiasUncertaintyNanos":
            fullInterSignalBiasUncertaintyNanos == null
                ? null
                : fullInterSignalBiasUncertaintyNanos,
        "satelliteInterSignalBiasNanos": satelliteInterSignalBiasNanos == null
            ? null
            : satelliteInterSignalBiasNanos,
        "satelliteInterSignalBiasUncertaintyNanos":
            satelliteInterSignalBiasUncertaintyNanos == null
                ? null
                : satelliteInterSignalBiasUncertaintyNanos,
        "codeType": codeType == null ? null : codeType,
        "string": string == null ? null : string,
      };
}
