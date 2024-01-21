///////////////////////////////////////////////////////////
/// This file contains global variables
//////////////////////////////////////////////////////////
/// Includes
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// GEA VERSION AND RELEASE DATE
const GEA_VERSION = '2.1.0';
const GEA_RELEASE_DATE = '23-12-2023';

/// App Color
const GEA_COLOR = Color.fromRGBO(0, 191, 165, 1.0);
const GEA_BACK_COLOR = Color.fromRGBO(0, 28, 49, 1);
const LOG_COLOR = Colors.deepOrangeAccent;
const REAL_TIME_COLOR = Colors.indigoAccent;
const SINGLE_COLOR = Colors.deepPurpleAccent;
const RTK_COLOR = Colors.redAccent;
const PPP_COLOR = Colors.blueAccent;
const GEA_LIGHT = Colors.white;
const GEA_DARK = Color.fromRGBO(41, 41, 41, 1);
const GPS_COLOR = Colors.blueAccent;
const GALILEO_COLOR = Colors.green;
const GLONASS_COLOR = Colors.redAccent;
const BEIDOU_COLOR = Colors.orange;

/// App icons
const LOG_ICON = Icons.article_rounded;
const RT_ICON = Icons.route_outlined;
const SINGLE_ICON = Icons.gps_fixed_rounded;
const RTK_ICON = Icons.settings_input_antenna_rounded;
const PPP_ICON = Icons.location_on_rounded;

/// Global variables for execution status
const NO_LAUNCH = 0;
const LOG_LAUNCH = 1;
const RT_LAUNCH = 2;
const SINGLE_LAUNCH = 3;
const RTK_LAUNCH = 4;
const PPP_LAUNCH = 5;

/// Execution Message Types
const LAUNCH = 0;
const MSG = 1;
const STOP = 2;

/// App Texts
const String HEADER_FILE = "#\n"
    "# Header Description:\n"
    "#\n"
    "# GEA Version: " + GEA_VERSION + "\n"
    "#\n"
    "# Raw,utcTimeMillis,TimeNanos,LeapSecond,TimeUncertaintyNanos,FullBiasNanos,BiasNanos,BiasUncertaintyNanos,DriftNanosPerSecond,DriftUncertaintyNanosPerSecond,HardwareClockDiscontinuityCount,Svid,TimeOffsetNanos,State,ReceivedSvTimeNanos,ReceivedSvTimeUncertaintyNanos,Cn0DbHz,PseudorangeRateMetersPerSecond,PseudorangeRateUncertaintyMetersPerSecond,AccumulatedDeltaRangeState,AccumulatedDeltaRangeMeters,AccumulatedDeltaRangeUncertaintyMeters,CarrierFrequencyHz,CarrierCycles,CarrierPhase,CarrierPhaseUncertainty,MultipathIndicator,SnrInDb,ConstellationType,AgcDb,BasebandCn0DbHz,FullInterSignalBiasNanos,FullInterSignalBiasUncertaintyNanos,SatelliteInterSignalBiasNanos,SatelliteInterSignalBiasUncertaintyNanos,CodeType,ChipsetElapsedRealtimeNanos\n"
    "#\n";

const String HEADER_FILE_RT = "#\n"
    "# Header Description:\n"
    "#\n"
    "# GEA Version: " + GEA_VERSION + "\n"
    "#\n"
    "# Raw,utcTimeMillis,TimeNanos,LeapSecond,TimeUncertaintyNanos,FullBiasNanos,BiasNanos,BiasUncertaintyNanos,DriftNanosPerSecond,DriftUncertaintyNanosPerSecond,HardwareClockDiscontinuityCount,Svid,TimeOffsetNanos,State,ReceivedSvTimeNanos,ReceivedSvTimeUncertaintyNanos,Cn0DbHz,PseudorangeRateMetersPerSecond,PseudorangeRateUncertaintyMetersPerSecond,AccumulatedDeltaRangeState,AccumulatedDeltaRangeMeters,AccumulatedDeltaRangeUncertaintyMeters,CarrierFrequencyHz,CarrierCycles,CarrierPhase,CarrierPhaseUncertainty,MultipathIndicator,SnrInDb,ConstellationType,AgcDb,BasebandCn0DbHz,FullInterSignalBiasNanos,FullInterSignalBiasUncertaintyNanos,SatelliteInterSignalBiasNanos,SatelliteInterSignalBiasUncertaintyNanos,CodeType,ChipsetElapsedRealtimeNanos\n"
    "#\n"
    "# NMEA0183 : NMEA GPRMC, GPGGA, GPGSA, GLGSA, GAGSA, GPGSV, GLGSV and GAGSV\n"
    "#\n"
    "# NMEA GEA : TIMEST\n"
    "#\n";

/// App URLs
const GEA_EMAIL = 'geagnss@gmail.com';
const GEA_URL = "https://www.geagnss.com";
const GEA_WSS = "ws://www.geagnss.com/wss";

/// Map Constants
const double CAMERA_ZOOM = 16;
const LatLng SOURCE_LOCATION = LatLng(0.0, 0.0);

/// Global constellation variables
const int GPS = 1;
const int SBAS = 2;
const int GLONASS = 3;
const int QZSS = 4;
const int BEIDOU = 5;
const int GALILEO = 6;
const int UNKNOWN = 0;

/// Global output path
const PATH_TO_STORAGE = "/storage/emulated/0/Android/data/xyz.gea/files/";

/// Global RTKLib values
const int L1 = 1;
const int L1L2 = 2;
const int L1L2L5 = 3;
const int PMODE_SINGLE = 0;
const int SYS_GPS = 1;
const int SYS_GLO = 4;
const int SYS_GAL = 8;
const int SYS_CMP = 32;

