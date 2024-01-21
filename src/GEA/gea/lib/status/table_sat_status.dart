///////////////////////////////////////////////////////////
/// This file contains the app navigator
//////////////////////////////////////////////////////////
/// Includes
import 'package:flutter/material.dart';
import 'package:gea/includes/includes.dart';
import 'package:gea/logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

///////////////////////////////////////////////////////////
/// Main INFO widget.
//////////////////////////////////////////////////////////
class TableSatStatus extends StatefulWidget {
  TableSatStatus(
      {Key key, this.rtTrackedSats, this.status, this.gnss, this.clock})
      : super(key: key);
  static Route<dynamic> route() => MaterialPageRoute(
        builder: (context) => TableSatStatus(),
      );
  final List<String> rtTrackedSats;
  final List<Map<String, dynamic>> status;
  final List<Map<String, dynamic>> gnss;
  final Map<String, dynamic> clock;

  @override
  _TableSatStatusStatefulWidgetState createState() =>
      _TableSatStatusStatefulWidgetState();
}

///////////////////////////////////////////////////////////
/// Main Table Satellite Status widget.
/// This widget calls the Table of the satellites.
//////////////////////////////////////////////////////////
class _TableSatStatusStatefulWidgetState extends State<TableSatStatus>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<int> _isProcessing;
  bool _isProc = false;
  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double screenWidth(BuildContext context,
      {double dividedBy = 1, double reducedBy = 0.0}) {
    return (screenSize(context).width - reducedBy) / dividedBy;
  }

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 2);
    super.initState();
    _isProcessing = _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('isProcessing') ?? NO_LAUNCH);
    });
    setState(() {
      _isProc = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isProcessing = _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('isProcessing') ?? NO_LAUNCH);
    });
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: TabBar(
            tabs: [
              Tab(text: "Satellites"),
              Tab(text: "Raw Data"),
            ],
            labelColor: GEA_COLOR,
            unselectedLabelColor: Colors.grey,
            indicatorColor: GEA_COLOR,
            controller: _tabController,
          ),
          body: TabBarView(controller: _tabController, children: [
            ListView(
              children: [
                Container(
                  margin:
                      const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                  child: Row(
                    children: [
                      FutureBuilder<int>(
                          future: _isProcessing,
                          builder: (BuildContext context,
                              AsyncSnapshot<int> snapshot) {
                            Color color = Colors.blueGrey;
                            String msg = "GNSS Status";
                            IconData icon = Icons.table_chart_outlined;
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                              //return const CircularProgressIndicator();
                              default:
                                if (snapshot.hasError) {
                                  color = Colors.blueGrey;
                                  msg = "GNSS Status";
                                  icon = Icons.table_chart_outlined;
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
                                                  'This indicator shows the current run type and the data source for the Info Table: GNSS Status, Log or Real Time.\n'),
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
                Center(
                    child: Column(children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Table(
                      defaultColumnWidth:
                          FixedColumnWidth(screenWidth(context) / 5.5),
                      border: TableBorder.lerp(
                          TableBorder(
                              top: BorderSide(
                                width: 4,
                                color: GEA_COLOR,
                              ),
                              bottom: BorderSide(
                                width: 4,
                                color: GEA_COLOR,
                              )),
                          TableBorder(
                              horizontalInside: BorderSide(
                            width: 1,
                            color: Colors.grey,
                          )),
                          0.5),
                      children: _setData(widget.status, widget.rtTrackedSats),
                    ),
                  ),
                ]))
              ],
            ),
            Logger(gnss: widget.gnss ?? null, clock: widget.clock ?? null),
          ]),
        ));
  }

  _setData(data, rtTrackedSats) {
    List<TableRow> tableRows = [];
    // In case of RT Launching, show tracked satellites
    if (rtTrackedSats != null &&
        rtTrackedSats.length > 0 &&
        rtTrackedSats[0] != 'null') {
      List<Map<String, dynamic>> rtTrack = [];
      for (int i = 0; i < rtTrackedSats.length; i++) {
        var values = rtTrackedSats[i].split('{')[1].split('}')[0].split(',');
        var constellation, satId, el, az, snr = 0.0;
        for (int j = 0; j < values.length; j++) {
          var val = values[j];
          if (val.contains('satelliteId')) {
            satId = int.parse(val.split(':')[1]);
          }
          if (val.contains('elevationDegrees')) {
            el = double.parse(val.split(':')[1]);
          }
          if (val.contains('azimuthDegrees')) {
            az = double.parse(val.split(':')[1]);
          }
          if (val.contains('constellation')) {
            constellation = val.split(':')[1];
          }
          if (val.contains('signalNoiseRatio')) {
            snr = double.parse(val.split(':')[1]);
          }
        }
        var consId = 0;
        if (constellation.contains('GP')) {
          consId = GPS;
        } else if (constellation.contains('GA')) {
          consId = GALILEO;
        } else if (constellation.contains('GL')) {
          consId = GLONASS;
        } else if (constellation.contains('BD') ||
            constellation.contains('GB')) {
          consId = BEIDOU;
        }
        rtTrack.add({
          "svid": satId,
          "constellationType": consId,
          "elevationDegrees": el,
          "azimuthDegrees": az,
          "cn0DbHz": snr,
          "carrierFrequencyHz": 1575420032.0
        });
      }
      data = rtTrack;
    } else if (_isProc) {
      data = [];
    }
    var header = TableRow(
      children: [
        Column(children: [Text('SVID', style: TextStyle(fontSize: 18.0))]),
        Column(children: [
          _isProc
              ? Text('Status', style: TextStyle(fontSize: 18.0))
              : Text('CF', style: TextStyle(fontSize: 18.0))
        ]),
        Column(children: [Text('C/N0', style: TextStyle(fontSize: 18.0))]),
        Column(children: [Text('Elev', style: TextStyle(fontSize: 18.0))]),
        Column(children: [Text('Azim', style: TextStyle(fontSize: 18.0))]),
      ],
      decoration: BoxDecoration(
        color: GEA_COLOR,
      ),
    );
    tableRows.add(header);
    try {
      for (var i = 0; i < data.length; i++) {
        var color = _setColor(data[i]["constellationType"]);
        var row = TableRow(
          children: [
            Column(children: [Text(data[i]["svid"].toString())]),
            Column(children: [_isProc ? Text("Used") : _setCF(data[i])]),
            Column(
                children: [Text(data[i]["cn0DbHz"].round().toString() + ".0")]),
            Column(children: [Text(data[i]["elevationDegrees"].toString())]),
            Column(children: [Text(data[i]["azimuthDegrees"].toString())]),
          ],
          decoration: BoxDecoration(color: color),
        );
        tableRows.add(row);
      }
    } catch (e) {
      print("No data received");
    }
    return tableRows;
  }

  _setCF(data) {
    var constellation = data["constellationType"];
    var cF = data["carrierFrequencyHz"];
    var iFreq = (cF / 10.23e6).round();
    var type = 0;
    var freq = "";
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
    switch (constellation) {
      case GPS:
        {
          if (type == 1) {
            freq = "L1";
          } else if (type == 5) {
            freq = "L5";
          } else {
            freq = "L1";
          }
        }
        break;
      case GLONASS:
        {
          freq = "G1";
        }
        break;
      case BEIDOU:
        {
          if (type == 1) {
            freq = "B1";
          } else if (type == 2) {
            freq = "B2";
          } else {
            freq = "B1";
          }
        }
        break;
      case GALILEO:
        {
          if (type == 1) {
            freq = "E1";
          } else if (type == 5) {
            freq = "E5";
          } else {
            freq = "E1";
          }
        }
        break;
      default:
        {
          freq = "L1";
        }
        break;
    }
    return Text(freq);
  }

  _setColor(constType) {
    var color;
    switch (constType) {
      case GPS:
        {
          color = GPS_COLOR;
        }
        break;
      case GLONASS:
        {
          color = GLONASS_COLOR;
        }
        break;
      case BEIDOU:
        {
          color = BEIDOU_COLOR;
        }
        break;
      case GALILEO:
        {
          color = GALILEO_COLOR;
        }
        break;
      default:
        {
          color = Colors.grey;
        }
        break;
    }
    return color;
  }
}
