import 'dart:convert';

GnssStatusModel gnssStatusModelFromJson(String str) =>
    GnssStatusModel.fromJson(json.decode(str));

String gnssStatusModelToJson(GnssStatusModel data) =>
    json.encode(data.toJson());

/// Model for the GnssStatus class in Android
class GnssStatusModel {
  GnssStatusModel({
    this.satelliteCount,
    this.hashCodec,
    this.status,
  });

  int? satelliteCount;
  int? hashCodec;
  List<Status>? status;

  factory GnssStatusModel.fromJson(Map<String, dynamic> json) =>
      GnssStatusModel(
        satelliteCount:
            json["satelliteCount"] == null ? null : json["satelliteCount"],
        hashCodec: json["hashCode"] == null ? null : json["hashCode"],
        status: json["status"] == null
            ? null
            : List<Status>.from(json["status"]
                .map((x) => Status.fromJson(Map<String, dynamic>.from(x)))),
      );

  Map<String, dynamic> toJson() => {
        "satelliteCount": satelliteCount == null ? null : satelliteCount,
        "hashCode": hashCodec == null ? null : hashCodec,
        "status": status == null
            ? null
            : List<dynamic>.from(status!.map((x) => x.toJson())),
      };
}

class Status {
  Status({
    this.azimuthDegrees,
    this.carrierFrequencyHz,
    this.cn0DbHz,
    this.constellationType,
    this.elevationDegrees,
    this.svid,
    this.hasAlmanacData,
    this.hasCarrierFrequencyHz,
    this.hasEphemerisData,
    this.usedInFix,
  });

  double? azimuthDegrees;
  double? carrierFrequencyHz;
  double? cn0DbHz;
  int? constellationType;
  double? elevationDegrees;
  int? svid;
  bool? hasAlmanacData;
  bool? hasCarrierFrequencyHz;
  bool? hasEphemerisData;
  bool? usedInFix;

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        azimuthDegrees: json["azimuthDegrees"] == null
            ? null
            : json["azimuthDegrees"].toDouble(),
        carrierFrequencyHz: json["carrierFrequencyHz"] == null
            ? null
            : json["carrierFrequencyHz"].toDouble(),
        cn0DbHz: json["cn0DbHz"] == null ? null : json["cn0DbHz"].toDouble(),
        constellationType: json["constellationType"] == null
            ? null
            : json["constellationType"],
        elevationDegrees: json["elevationDegrees"] == null
            ? null
            : json["elevationDegrees"].toDouble(),
        svid: json["svid"] == null ? null : json["svid"],
        hasAlmanacData:
            json["hasAlmanacData"] == null ? null : json["hasAlmanacData"],
        hasCarrierFrequencyHz: json["hasCarrierFrequencyHz"] == null
            ? null
            : json["hasCarrierFrequencyHz"],
        hasEphemerisData:
            json["hasEphemerisData"] == null ? null : json["hasEphemerisData"],
        usedInFix: json["usedInFix"] == null ? null : json["usedInFix"],
      );

  Map<String, dynamic> toJson() => {
        "azimuthDegrees": azimuthDegrees == null ? null : azimuthDegrees,
        "carrierFrequencyHz":
            carrierFrequencyHz == null ? null : carrierFrequencyHz,
        "cn0DbHz": cn0DbHz == null ? null : cn0DbHz,
        "constellationType":
            constellationType == null ? null : constellationType,
        "elevationDegrees": elevationDegrees == null ? null : elevationDegrees,
        "svid": svid == null ? null : svid,
        "hasAlmanacData": hasAlmanacData == null ? null : hasAlmanacData,
        "hasCarrierFrequencyHz":
            hasCarrierFrequencyHz == null ? null : hasCarrierFrequencyHz,
        "hasEphemerisData": hasEphemerisData == null ? null : hasEphemerisData,
        "usedInFix": usedInFix == null ? null : usedInFix,
      };
}
