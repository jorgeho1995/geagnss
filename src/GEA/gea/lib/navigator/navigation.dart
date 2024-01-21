///////////////////////////////////////////////////////////
/// This file contains the app navigator
//////////////////////////////////////////////////////////
/// Includes
import 'dart:isolate';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:gea/gnss/raw_gnss_reader.dart';
import 'package:gea/gnss/gnss_status_reader.dart';
/*import 'package:gea/status/ar_sats.dart';*/
import 'package:gea/status/table_sat_status.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gea/profile/navbar_windows.dart';
import 'package:gea/home/home.dart';
import 'package:gea/records/records.dart';
import 'package:gea/map/map.dart';
import 'package:gea/status/status.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gea/includes/includes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gea/includes/commonUtils.dart';

///////////////////////////////////////////////////////////
/// Main NAVIGATOR widget.
/// This is the stateful widget that the main application instantiates.
//////////////////////////////////////////////////////////
class GeaStatefulWidget extends StatefulWidget {
  GeaStatefulWidget({Key key, this.uid}) : super(key: key);
  final String uid;

  @override
  _GeaStatefulWidgetState createState() => _GeaStatefulWidgetState();
}

/// This is the private State class that goes with GeaStatefulWidget.
class _GeaStatefulWidgetState extends State<GeaStatefulWidget>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  List<Map<String, dynamic>> _gnssRawData;
  Map<String, dynamic> _gnssClockData;
  List<Map<String, dynamic>> _gnssStatusData;
  List<String> _rtTrackedSats = ["null"];
  List<String> _rtPosition = ["null"];
  ReceivePort _recPortRawGnss;
  ReceivePort _recPortGnssStatus;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<int> _isProcessing;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _animationController.repeat(reverse: true);
    super.initState();
    _isProcessing = _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('isProcessing') ?? NO_LAUNCH);
    });
    _startGnss();
  }

  Future<void> _checkPrefs() async {
    final SharedPreferences prefs = await _prefs;
    final int isProc = (prefs.getInt('isProcessing') ?? NO_LAUNCH);
    final List<String> rtTrack =
        (prefs.getStringList('rtTrackedSats') ?? ["null"]);
    final List<String> rtPos = (prefs.getStringList('rtPosition') ?? ["null"]);
    setState(() {
      _isProcessing = prefs.setInt("isProcessing", isProc).then((bool success) {
        return isProc;
      });
      _rtTrackedSats = rtTrack;
      _rtPosition = rtPos;
    });
  }

  /// GNSS Start Raw Data catch
  void _startGnss() async {
    if (await Permission.location.isGranted ||
        await Permission.location.request().isGranted) {
      _recPortRawGnss = await GnssMeas.spawnIsolate();
      _recPortGnssStatus = await GnssStat.spawnIsolate();
      try {
        _recPortRawGnss.listen(_handleMessageRawGnss);
        _recPortGnssStatus.listen(_handleMessageGnssStatus);
      } catch (_) {
        //print('Already listening');
      }
      //_betaMessage(context);
    } else {
      _alertLocation(context);
      //_betaMessage(context);
    }
    //final response = await fetchNtripMountPoints('http://www.euref-ip.net/');
    //print(response.body);
  }

  void disposeGnss() {
    print('Disposal of isolate GNSS');
    GnssMeas.killIsolate();
    _recPortRawGnss = null;
    GnssStat.killIsolate();
    _recPortGnssStatus = null;
    super.dispose();
  }

  void _handleMessageRawGnss(dynamic data) {
    if (data is List<Map<String, dynamic>>) {
      //print('RECEIVED: ${data.first["svid"]}');
      setState(() {
        _gnssRawData = data;
      });
    }
    if (data is Map<String, dynamic>) {
      setState(() {
        _gnssClockData = data;
      });
    }
    _checkPrefs();
  }

  void _handleMessageGnssStatus(dynamic data) {
    if (data is List<Map<String, dynamic>>) {
      setState(() {
        _gnssStatusData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        title: Text('GEA',
            style: GoogleFonts.pacifico(
              textStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? GEA_DARK
                    : GEA_LIGHT,
                //fontSize: 30.0,
              ),
            )),
        backgroundColor: GEA_COLOR,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? GEA_DARK
              : GEA_LIGHT,
        ),
        actions: <Widget>[
          /*IconButton(
            icon: Icon(
              Icons.wallpaper_rounded,
              color: Theme.of(context).brightness == Brightness.dark
                  ? GEA_DARK
                  : GEA_LIGHT,
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ARCore(title: "Super",)));
            },
          ),*/
          FutureBuilder<int>(
              future: _isProcessing,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  //return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      return IconButton(
                        icon: Icon(
                          Icons.circle,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () {},
                      );
                    } else {
                      Color color = Colors.blueGrey;
                      String msg = "No execution in progress.";
                      if (snapshot.data == LOG_LAUNCH) {
                        color = LOG_COLOR;
                        msg = "LOG execution in progress.";
                      } else if (snapshot.data == SINGLE_LAUNCH) {
                        color = SINGLE_COLOR;
                        msg = "SINGLE execution in progress.";
                      } else if (snapshot.data == RTK_LAUNCH) {
                        color = RTK_COLOR;
                        msg = "RTK execution in progress.";
                      } else if (snapshot.data == PPP_LAUNCH) {
                        color = PPP_COLOR;
                        msg = "PPP execution in progress.";
                      }
                      return IconButton(
                        icon: snapshot.data != NO_LAUNCH
                            ? FadeTransition(
                                opacity: _animationController,
                                child: Icon(
                                  Icons.circle,
                                  color: color,
                                ),
                              )
                            : Icon(
                                Icons.circle,
                                color: color,
                              ),
                        onPressed: () {
                          Fluttertoast.showToast(
                              msg: msg,
                              toastLength: Toast.LENGTH_SHORT,
                              textColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? GEA_LIGHT
                                  : GEA_DARK,
                              fontSize: 16.0);
                        },
                      );
                    }
                }
              }),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          TableSatStatus(
              rtTrackedSats: _rtTrackedSats ?? null,
              status: _gnssStatusData ?? null,
              gnss: _gnssRawData ?? null,
              clock: _gnssClockData ?? null),
          Status(
              rtTrackedSats: _rtTrackedSats ?? null,
              status: _gnssStatusData ?? null),
          Home(
              uid: widget.uid,
              gnss: _gnssRawData ?? null,
              clock: _gnssClockData ?? null),
          CreateMap(rtPosition: _rtPosition ?? null),
          Records(
              uid: widget.uid,
              gnss: _gnssRawData ?? null,
              clock: _gnssClockData ?? null),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: GEA_COLOR,
        unselectedItemColor: Colors.grey,
        onTap: (int index) => setState(() => _selectedIndex = index),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.table_chart_outlined), label: "Info"),
          BottomNavigationBarItem(
              icon: Icon(Icons.satellite_outlined), label: "Skyplot"),
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Map"),
          BottomNavigationBarItem(
              icon: Icon(Icons.archive_outlined), label: "Records"),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                                "${snapshot.data['name']} ${snapshot.data['surname']}");
                          } else {
                            return Text("Welcome to GEA!");
                          }
                        }),
                    accountEmail: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(snapshot.data['email']);
                          } else {
                            return Text("");
                          }
                        }),
                    decoration: BoxDecoration(
                      color: GEA_COLOR,
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? GEA_DARK
                              : GEA_LIGHT,
                      child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data['name'][0],
                                style: TextStyle(
                                  fontSize: 36.0,
                                  color: GEA_COLOR,
                                ),
                              );
                            } else {
                              return Text(
                                "G",
                                style: TextStyle(
                                  fontSize: 36.0,
                                  color: GEA_COLOR,
                                ),
                              );
                            }
                          }),
                    ),
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.account_circle, color: Colors.blueAccent),
                    title: Text('Profile'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profile(uid: widget.uid)));
                    },
                  ),
                  /*ListTile(
                    leading: Icon(Icons.settings, color: Colors.green),
                    title: Text('Settings'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsMenu()));
                    },
                  ),*/
                  ListTile(
                    leading: Icon(Icons.web, color: Colors.redAccent),
                    title: Text('Website'),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Website()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.orange),
                    title: Text('About'),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => About()));
                    },
                  ),
                ],
              ),
            ),
            // This container holds the align
            Container(
                // This align moves the children to the bottom
                child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    // This container holds all the children that will be aligned
                    // on the bottom and should not scroll with the above ListView
                    child: Container(
                        child: Column(
                      children: <Widget>[
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.exit_to_app, color: Colors.red),
                          title: Text('Log Out'),
                          onTap: () => _logout(context),
                        ),
                      ],
                    ))))
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    var alert = AlertDialog(
      title: Text(
        'Log Out',
        style: new TextStyle(color: GEA_COLOR, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Are you sure you want to log out? App will close'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Log Out',
            style: new TextStyle(
                fontSize: 14.0, color: GEA_COLOR, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            FirebaseAuth auth = FirebaseAuth.instance;
            auth.signOut().then((res) {
              try {
                final GoogleSignIn googleSignIn = GoogleSignIn();
                googleSignIn.signOut();
              } catch (e) {
                print("No Google account");
              }
              SystemNavigator.pop(animated: true);
              /*Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                  (Route<dynamic> route) => false);*/
            });
          },
        ),
        TextButton(
          child: Text(
            'Cancel',
            style: new TextStyle(
                fontSize: 14.0, color: GEA_COLOR, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void _alertLocation(BuildContext context) {
    var alert = AlertDialog(
      title: Text(
        'Location Disabled',
        style: new TextStyle(color: GEA_COLOR, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
                'In order to use the app it is necessary to accept the location permissions and activate it.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: new Text('Open App Settings',
              style: TextStyle(
                color: GEA_COLOR,
              )),
          onPressed: () => openAppSettings(),
        ),
        TextButton(
          child: Text(
            'Cancel',
            style: new TextStyle(
                fontSize: 14.0, color: GEA_COLOR, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void _betaMessage(BuildContext context) {
    var alert = AlertDialog(
      title: Text(
        'News $GEA_VERSION',
        style: new TextStyle(color: GEA_COLOR, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
                'You are in a Beta testing version at the user level, for testing and bug fixes. The features of the app are limited to:'),
            ListTile(
              leading: new Icon(RT_ICON, color: REAL_TIME_COLOR),
              title: new Text('Real Time: Only Single Processing is enabled.'),
            ),
            ListTile(
              leading: new Icon(RT_ICON, color: REAL_TIME_COLOR),
              title: new Text('Real Time: Only GPS and Galileo satellites are used in RT processing.'),
            ),
            ListTile(
              leading: new Icon(RT_ICON, color: REAL_TIME_COLOR),
              title: new Text('Real Time: Modification of RTKLib settings is disabled. Using default values.'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Got it!',
            style: new TextStyle(
                fontSize: 14.0, color: GEA_COLOR, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          },
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => alert);
  }
}
