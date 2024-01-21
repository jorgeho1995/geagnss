///////////////////////////////////////////////////////////
/// This file contains the app navigator
//////////////////////////////////////////////////////////
/// Includes
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gea/includes/includes.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:shared_preferences/shared_preferences.dart';

///////////////////////////////////////////////////////////
/// Main INFO widget.
//////////////////////////////////////////////////////////
class SatsStatus extends StatefulWidget {
  SatsStatus({Key key, this.gnss, this.rtTrackedSats}) : super(key: key);
  static Route<dynamic> route() => MaterialPageRoute(
        builder: (context) => SatsStatus(),
      );
  final List<Map<String, dynamic>> gnss;
  final List<String> rtTrackedSats;

  @override
  _SatStatusStatefulWidgetState createState() =>
      _SatStatusStatefulWidgetState();
}

///////////////////////////////////////////////////////////
/// Main Satellite Status widget.
/// This widget shows the Skyplot of the satellites.
//////////////////////////////////////////////////////////
class _SatStatusStatefulWidgetState extends State<SatsStatus> {
  bool _lockNorthUp;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<int> _isProcessing;
  bool _isProc = false;

  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double screenHeight(BuildContext context,
      {double percentage = 1, double reducedBy = 0.0}) {
    double hAppBar = AppBar().preferredSize.height;
    return (screenSize(context).height - (3 * hAppBar)) * percentage;
  }

  double screenWidth(BuildContext context,
      {double dividedBy = 1, double reducedBy = 0.0}) {
    return (screenSize(context).width - reducedBy) / dividedBy;
  }

  double screenHeightExcludingToolbar(BuildContext context,
      {double percentage = 1}) {
    return screenHeight(context,
        percentage: percentage, reducedBy: kToolbarHeight);
  }

  @override
  void initState() {
    _lockNorthUp = false;
    _isProcessing = _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('isProcessing') ?? NO_LAUNCH);
    });
    super.initState();
    setState(() {
      _isProc = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isProcessing = _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('isProcessing') ?? NO_LAUNCH);
    });
    return _setData(widget.gnss, widget.rtTrackedSats, context);
  }

  _setData(data, rtTrackedSats, context) {
    int _nbrSatsGPSL1 = 0;
    int _nbrSatsGPSL5 = 0;
    int _nbrSatsSBAS = 0;
    int _nbrSatsGLO = 0;
    int _nbrSatsQZSS = 0;
    int _nbrSatsBeiB1 = 0;
    int _nbrSatsBeiB2 = 0;
    int _nbrSatsGalE1 = 0;
    int _nbrSatsGalE5 = 0;
    int _nbrSatsUnk = 0;
    List<Offset> gps = [];
    List<Offset> gal = [];
    List<Offset> glo = [];
    List<Offset> bei = [];
    List svidG = [];
    List svidE = [];
    List svidR = [];
    List svidC = [];
    double centerX = screenWidth(context) / 2.0;
    double centerY = screenWidth(context) / 2.0;
    // In case of RT Launching, show tracked satellites
    if (rtTrackedSats != null &&
        rtTrackedSats.length > 0 &&
        rtTrackedSats[0] != 'null') {
      List<Map<String, dynamic>> rtTrack = [];
      for (int i = 0; i < rtTrackedSats.length; i++) {
        var values = rtTrackedSats[i].split('{')[1].split('}')[0].split(',');
        var constellation, satId, el, az = 0;
        for (int j = 0; j < values.length; j++) {
          var val = values[j];
          if (val.contains('satelliteId')) {
            satId = int.parse(val.split(':')[1]);
          }
          if (val.contains('elevationDegrees')) {
            el = int.parse(val.split(':')[1]);
          }
          if (val.contains('azimuthDegrees')) {
            az = int.parse(val.split(':')[1]);
          }
          if (val.contains('constellation')) {
            constellation = val.split(':')[1];
          }
        }
        var consId = 0;
        double freqHz = 0;
        if (constellation.contains('GP')) {
          consId = GPS;
          freqHz = 1575420032.0;
        } else if (constellation.contains('GA')) {
          consId = GALILEO;
          freqHz = 1575420032.0;
        } else if (constellation.contains('GL')) {
          consId = GLONASS;
          freqHz = 1575420032.0;
        } else if (constellation.contains('BD') ||
            constellation.contains('GB')) {
          consId = BEIDOU;
          freqHz = 1561098000.0;
        }
        rtTrack.add({
          "svid": satId,
          "constellationType": consId,
          "elevationDegrees": el,
          "azimuthDegrees": az,
          "carrierFrequencyHz": freqHz
        });
      }
      data = rtTrack;
    } else if (_isProc) {
      data = [];
    }
    if (data != null) {
      for (var i = 0; i < data.length; i++) {
        double azimuth = (data[i]["azimuthDegrees"] * pi) / 180.0;
        double dist = ((90 - data[i]["elevationDegrees"]) * centerX) / 90.0;
        double XSat;
        double YSat;
        //print('${data[i]["constellationType"]} ${data[i]["svid"]} ${data[i]["carrierFrequencyHz"]} ${data[i]["azimuthDegrees"]} ${data[i]["elevationDegrees"]}');
        if (data[i]["azimuthDegrees"] > 90.0) {
          XSat = centerX + dist * sin(azimuth);
          YSat = centerY - dist * cos(azimuth);
        } else if (data[i]["azimuthDegrees"] > 180.0) {
          XSat = centerX - dist * sin(azimuth);
          YSat = centerY - dist * cos(azimuth);
        } else if (data[i]["azimuthDegrees"] > 270.0) {
          XSat = centerX - dist * sin(azimuth);
          YSat = centerY + dist * cos(azimuth);
        } else {
          XSat = centerX + dist * sin(azimuth);
          YSat = centerY - dist * cos(azimuth);
        }
        switch (data[i]["constellationType"]) {
          case GPS:
            {
              if (_setCF(data[i]["carrierFrequencyHz"]) == 1) {
                _nbrSatsGPSL1++;
              } else if (_setCF(data[i]["carrierFrequencyHz"]) == 5) {
                _nbrSatsGPSL5++;
              }
              gps.add(Offset(XSat, YSat));
              svidG.add(data[i]["svid"]);
            }
            break;
          case SBAS:
            {
              _nbrSatsSBAS++;
            }
            break;
          case GLONASS:
            {
              _nbrSatsGLO++;
              glo.add(Offset(XSat, YSat));
              svidR.add(data[i]["svid"]);
            }
            break;
          case QZSS:
            {
              _nbrSatsQZSS++;
            }
            break;
          case BEIDOU:
            {
              if (_setCF(data[i]["carrierFrequencyHz"]) == 2) {
                _nbrSatsBeiB1++;
              } else if (_setCF(data[i]["carrierFrequencyHz"]) == 5) {
                _nbrSatsBeiB2++;
              }
              bei.add(Offset(XSat, YSat));
              svidC.add(data[i]["svid"]);
            }
            break;
          case GALILEO:
            {
              if (_setCF(data[i]["carrierFrequencyHz"]) == 1) {
                _nbrSatsGalE1++;
              } else if (_setCF(data[i]["carrierFrequencyHz"]) == 5) {
                _nbrSatsGalE5++;
              }
              gal.add(Offset(XSat, YSat));
              svidE.add(data[i]["svid"]);
            }
            break;
          case UNKNOWN:
            {
              _nbrSatsUnk++;
            }
            break;
          default:
            {
              _nbrSatsUnk++;
            }
            break;
        }
      }
    }
    var sats = [gps, gal, glo, bei, svidG, svidE, svidR, svidC];

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        double direction = 0.0;
        if (snapshot.data != null) {
          direction = snapshot.data.heading;
        } else {
          direction = 0.0;
        }
        if (_lockNorthUp) {
          direction = 0.0;
        }
        return OrientationBuilder(
          builder: (context, orientation) {
            return ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Transform.rotate(
                    angle: (direction * (pi / 180) * -1),
                    child: Container(
                      decoration: BoxDecoration(
                        image: new DecorationImage(
                          image: _isProc
                              ? new AssetImage('assets/images/polar_chart.png')
                              : new AssetImage(
                                  'assets/images/polar_chart_grey.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: screenWidth(context),
                      height: screenWidth(context),
                      child: CustomPaint(
                        painter: DrawSatellites(sats: sats),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _lockNorthUp ? GEA_COLOR : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0)),
                            elevation: 0.0,
                            side: BorderSide(
                              color: GEA_COLOR,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _lockNorthUp = _lockNorthUp ? false : true;
                            });
                          },
                          icon: Icon(
                            Icons.navigation_outlined,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? GEA_LIGHT
                                    : GEA_DARK,
                          ),
                          label: Text(
                            'Lock North Up',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? GEA_LIGHT
                                  : GEA_DARK,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                        height: 0.0,
                      ),
                      FutureBuilder<int>(
                          future: _isProcessing,
                          builder: (BuildContext context,
                              AsyncSnapshot<int> snapshot) {
                            Color color = Colors.blueGrey;
                            String msg = "GNSS Status";
                            IconData icon = Icons.satellite_outlined;
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                              //return const CircularProgressIndicator();
                              default:
                                if (snapshot.hasError) {
                                  color = Colors.blueGrey;
                                  msg = "GNSS Status";
                                  icon = Icons.satellite_outlined;
                                  _isProc = false;
                                } else {
                                  if (snapshot.data == LOG_LAUNCH) {
                                    color = LOG_COLOR;
                                    msg = "LOG";
                                    icon = LOG_ICON;
                                    _isProc = false;
                                  } else if (snapshot.data == SINGLE_LAUNCH) {
                                    color = SINGLE_COLOR;
                                    msg = "SINGLE";
                                    icon = SINGLE_ICON;
                                    _isProc = true;
                                  } else if (snapshot.data == RTK_LAUNCH) {
                                    color = RTK_COLOR;
                                    msg = "RTK";
                                    icon = RTK_ICON;
                                    _isProc = true;
                                  } else if (snapshot.data == PPP_LAUNCH) {
                                    color = PPP_COLOR;
                                    msg = "PPP";
                                    icon = PPP_ICON;
                                    _isProc = true;
                                  } else {
                                    _isProc = false;
                                  }
                                }
                                return Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: color,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(80.0)),
                                      elevation: 0.0,
                                      side: BorderSide(
                                        color: color,
                                      ),
                                    ),
                                    onPressed: () {
                                      var alert = AlertDialog(
                                        title: Text(
                                          'Legend',
                                          style: new TextStyle(
                                              color: GEA_COLOR,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              Text(
                                                  'This indicator shows the current run type and the data source for the Skyplot: GNSS Status, Log or Real Time.\n'),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blueGrey,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              80.0)),
                                                  elevation: 0.0,
                                                  side: BorderSide(
                                                    color: Colors.blueGrey,
                                                  ),
                                                ),
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.satellite_outlined,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? GEA_LIGHT
                                                      : GEA_DARK,
                                                ),
                                                label: Text(
                                                  "GNSS Status",
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? GEA_LIGHT
                                                        : GEA_DARK,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: LOG_COLOR,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              80.0)),
                                                  elevation: 0.0,
                                                  side: BorderSide(
                                                    color: LOG_COLOR,
                                                  ),
                                                ),
                                                onPressed: () {},
                                                icon: Icon(
                                                  LOG_ICON,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? GEA_LIGHT
                                                      : GEA_DARK,
                                                ),
                                                label: Text(
                                                  "LOG",
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? GEA_LIGHT
                                                        : GEA_DARK,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: SINGLE_COLOR,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              80.0)),
                                                  elevation: 0.0,
                                                  side: BorderSide(
                                                    color: SINGLE_COLOR,
                                                  ),
                                                ),
                                                onPressed: () {},
                                                icon: Icon(
                                                  SINGLE_ICON,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? GEA_LIGHT
                                                      : GEA_DARK,
                                                ),
                                                label: Text(
                                                  "SINGLE",
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? GEA_LIGHT
                                                        : GEA_DARK,
                                                  ),
                                                ),
                                              ), // TODO: Finish legend
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(
                                              'Got it!',
                                              style: new TextStyle(
                                                  fontSize: 14.0,
                                                  color: GEA_COLOR,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop('dialog');
                                            },
                                          ),
                                        ],
                                      );
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              alert);
                                    },
                                    icon: Icon(
                                      icon,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? GEA_LIGHT
                                          : GEA_DARK,
                                    ),
                                    label: Text(
                                      msg,
                                      style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? GEA_LIGHT
                                            : GEA_DARK,
                                      ),
                                    ),
                                  ),
                                );
                            }
                          }),
                    ],
                  ),
                ),
                Container(
                  width: screenWidth(context),
                  height:
                      screenHeightExcludingToolbar(context, percentage: 0.5),
                  child: GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio:
                        orientation == Orientation.portrait ? (10 / 7) : 3,
                    children: <Widget>[
                      satsListTwoFZ("GPS", "gps", _nbrSatsGPSL1, _nbrSatsGPSL5,
                          GPS_COLOR),
                      satsListTwoFZ("Galileo", "galileo", _nbrSatsGalE1,
                          _nbrSatsGalE5, GALILEO_COLOR),
                      satsListOneFZ(
                          "GLONASS", "glonass", _nbrSatsGLO, GLONASS_COLOR),
                      satsListTwoFZ("Beidou", "beidou", _nbrSatsBeiB1,
                          _nbrSatsBeiB2, BEIDOU_COLOR),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Card satsListTwoFZ(_constellation, _file, _nbrSatsL1, _nbrSatsL5, _color) {
    return Card(
      color: _isProc && _nbrSatsL1 == 0 ? Colors.blueGrey : _color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(15),
      elevation: 10,
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(15, 10, 25, 10),
            title: Text(
              "$_constellation",
              style: TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              _isProc
                  ? "Sats: $_nbrSatsL1"
                  : _file == "gps"
                      ? "L1: $_nbrSatsL1 L5: $_nbrSatsL5"
                      : _file == "galileo"
                          ? "E1: $_nbrSatsL1 E5: $_nbrSatsL5"
                          : "B1: $_nbrSatsL1 B2: $_nbrSatsL5",
              style: TextStyle(fontSize: 12),
            ),
            leading: Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/$_file.png',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Card satsListOneFZ(_constellation, _file, _nbrSatsL1, _color) {
    return Card(
      color: _isProc && _nbrSatsL1 == 0 ? Colors.blueGrey : _color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(15),
      elevation: 10,
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(15, 10, 25, 10),
            title: Text(
              "$_constellation",
              style: TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              _isProc
                  ? "Sats: $_nbrSatsL1"
                  : _file == "glonass"
                      ? "G1: $_nbrSatsL1"
                      : "B1: $_nbrSatsL1",
              style: TextStyle(fontSize: 12),
            ),
            leading: Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/$_file.png',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _setCF(cF) {
    var iFreq = (cF / 10.23e6).round();
    var type = 0;
    if (iFreq >= 154) {
      //QZSS L1 (154), GPS L1 (154), GAL E1 (154), and GLO L1 (156)
      type = 1;
    } else if (iFreq == 115) {
      //QZSS L5 (115), GPS L5 (115), GAL E5 (115)
      type = 5;
    } else if (iFreq == 153) {
      //BDS B1I (153)
      type = 2;
    } else {
      print("CF not valid");
    }
    return type;
  }
}

class DrawSatellites extends CustomPainter {
  DrawSatellites({Key key, this.sats});
  final List sats;

  @override
  void paint(Canvas canvas, Size size) {
    var paintG = Paint()
      ..color = GPS_COLOR
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20;
    var paintE = Paint()
      ..color = GALILEO_COLOR
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20;
    var paintR = Paint()
      ..color = GLONASS_COLOR
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20;
    var paintC = Paint()
      ..color = BEIDOU_COLOR
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20;
    var pointsG = sats[0];
    var pointsE = sats[1];
    var pointsR = sats[2];
    var pointsC = sats[3];
    //draw points on canvas
    canvas.drawPoints(PointMode.points, pointsG, paintG);
    for (var i = 0; i < sats[4].length; i++) {
      var paragraphStyle = ParagraphStyle(
        textDirection: TextDirection.ltr,
      );
      var paragraphBuilder = ParagraphBuilder(paragraphStyle)
        ..addText(sats[4][i] < 10
            ? "0" + sats[4][i].toString()
            : sats[4][i].toString());
      var constraints = ParagraphConstraints(width: 300);
      var paragraph = paragraphBuilder.build();
      paragraph.layout(constraints);
      canvas.drawParagraph(paragraph, (sats[0][i] - Offset(8, 10)));
    }
    canvas.drawPoints(PointMode.points, pointsE, paintE);
    for (var i = 0; i < sats[5].length; i++) {
      var paragraphStyle = ParagraphStyle(
        textDirection: TextDirection.ltr,
      );
      var paragraphBuilder = ParagraphBuilder(paragraphStyle)
        ..addText(sats[5][i] < 10
            ? "0" + sats[5][i].toString()
            : sats[5][i].toString());
      var constraints = ParagraphConstraints(width: 300);
      var paragraph = paragraphBuilder.build();
      paragraph.layout(constraints);
      canvas.drawParagraph(paragraph, (sats[1][i] - Offset(8, 10)));
    }
    canvas.drawPoints(PointMode.points, pointsR, paintR);
    for (var i = 0; i < sats[6].length; i++) {
      var paragraphStyle = ParagraphStyle(
        textDirection: TextDirection.ltr,
      );
      var paragraphBuilder = ParagraphBuilder(paragraphStyle)
        ..addText(sats[6][i] < 10
            ? "0" + sats[6][i].toString()
            : sats[6][i].toString());
      var constraints = ParagraphConstraints(width: 300);
      var paragraph = paragraphBuilder.build();
      paragraph.layout(constraints);
      canvas.drawParagraph(paragraph, (sats[2][i] - Offset(8, 10)));
    }
    canvas.drawPoints(PointMode.points, pointsC, paintC);
    for (var i = 0; i < sats[7].length; i++) {
      var paragraphStyle = ParagraphStyle(
        textDirection: TextDirection.ltr,
      );
      var paragraphBuilder = ParagraphBuilder(paragraphStyle)
        ..addText(sats[7][i] < 10
            ? "0" + sats[7][i].toString()
            : sats[7][i].toString());
      var constraints = ParagraphConstraints(width: 300);
      var paragraph = paragraphBuilder.build();
      paragraph.layout(constraints);
      canvas.drawParagraph(paragraph, (sats[3][i] - Offset(8, 10)));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
