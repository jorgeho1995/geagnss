///////////////////////////////////////////////////////////
/// This file contains the home window
//////////////////////////////////////////////////////////
/// Includes
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gea/includes/commonUtils.dart';
import 'package:gea/includes/includes.dart';
import 'package:gea/map/map.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mailto/mailto.dart';
import 'package:card_settings/card_settings.dart';
import 'package:http/http.dart' as http;

///////////////////////////////////////////////////////////
/// Main HOME widget.
//////////////////////////////////////////////////////////
class Home extends StatefulWidget {
  Home({Key key, this.uid, this.gnss, this.clock}) : super(key: key);
  static Route<dynamic> route() => MaterialPageRoute(
        builder: (context) => Home(),
      );
  final List<Map<String, dynamic>> gnss;
  final Map<String, dynamic> clock;
  final String uid;

  @override
  _HomeStatefulWidgetState createState() => _HomeStatefulWidgetState();
}

class _HomeStatefulWidgetState extends State<Home>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<bool> _isEnabled = [true, true, true];
  SharedPreferences prefs;
  int execLaunch = NO_LAUNCH;
  File globalFileName;
  bool isWriting = false;
  Timer timer;
  String fileName = "none";
  String rtConsole = "";
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController nameRT = TextEditingController();
  TextEditingController descriptionRT = TextEditingController();
  WebSocketChannel _channel;
  bool semaphore = false;
  List<String> GSVSats = [];
  List<String> GGAPost = [];
  var isRTEnabled = 'false';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map configRT = {
    "solType": PMODE_SINGLE,
    "freqType": L1,
    "elevMask": 15,
    "constType": SYS_GPS + SYS_GAL
  };
  List solType = ["Single"]; // TODO: Add Options
  String solTypeDefault = "Single";
  List freqType = [
    "L1"
  ]; // TODO: Add Options: number of frequencies (1:L1,2:L1+L2,3:L1+L2+L5)
  String freqTypeDefault = "L1";
  List elevMask = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70];
  int elevMaskDefault = 15;
  List constType = ["GPS", "Galileo", "Glonass", "Beidou"];
  List constTypeDefault = ["GPS", "Galileo"];
  Duration diffTimeServer = Duration(hours: 0, minutes: 0, seconds: 0);
  var bufferLOG = StringBuffer();
  var bufferRT = StringBuffer();

  // Check if tabs are enabled or disabled
  onTap() {
    if (!_isEnabled[_tabController.index]) {
      int index = _tabController.previousIndex;
      int indexC = _tabController.index;
      setState(() {
        _tabController.index = index;
      });
      if (indexC == 2 && isRTEnabled.contains('false')) {
        _alertRT(context);
      }
    }
  }

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 3);
    _tabController.addListener(onTap);
    super.initState();
    setState(() {
      execLaunch = NO_LAUNCH;
    });
    timer = Timer.periodic(
        Duration(seconds: 1), (Timer t) => _checkExecution(widget.gnss));
    //synchronizeTimeWithServer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: TabBar(
            tabs: [
              Tab(text: "Start"),
              Tab(text: "Log Data"),
              Tab(text: "RT Navi"),
            ],
            labelColor: GEA_COLOR,
            unselectedLabelColor: Colors.grey,
            indicatorColor: GEA_COLOR,
            controller: _tabController,
          ),
          body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        isRTEnabled = snapshot.data['rt_enabled'].toString();
                        if (isRTEnabled.contains('true') &&
                            execLaunch == NO_LAUNCH) {
                          _isEnabled = [true, true, true];
                        } else if (execLaunch == NO_LAUNCH) {
                          _isEnabled = [true, true, false];
                        }
                      }
                      return Scaffold(
                          body: ListView(
                        children: <Widget>[
                          welcome(),
                          logRawData(),
                          launchRealTime(isRTEnabled)
                        ],
                      ));
                    }),
                createLogView(),
                createRTView(),
              ]),
        ));
  }

  Card welcome() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(15),
      elevation: 10,
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(15, 10, 25, 0),
            title: Text('Welcome to GEA!'),
            subtitle: Text(
              'In this window you can start an execution. In the tabs "Skyplot" and "Info" you can take a look at how the sky is above you. Finally, in "Records" tab, you will have available a history of all executions.',
              textAlign: TextAlign.justify,
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Color.fromRGBO(41, 41, 41, 1)
                  : Colors.white,
              backgroundImage: AssetImage("assets/images/gea_icon.jpeg"),
              radius: 30.0,
            ),
          ),
          Divider(color: Colors.transparent, indent: 15, endIndent: 15),
        ],
      ),
    );
  }

  Card logRawData() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(15),
      elevation: 10,
      color: LOG_COLOR,
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(15, 10, 25, 0),
            title: Text('Log raw GNSS data'),
            subtitle: Text(
              'Captures raw GNSS data from the Smartphone for later post-processing.',
              textAlign: TextAlign.justify,
            ),
            trailing: Image(image: AssetImage("assets/images/log_icon.png")),
          ),
          Divider(color: Colors.black54, indent: 15, endIndent: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  child: Text(
                    'Start',
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                        fontWeight: FontWeight.bold),
                  )),
              /*TextButton(
                  onPressed: () {},
                  child: Text(
                    'More info',
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                        fontWeight: FontWeight.bold),
                  )),*/ // TODO: Add web link to manual
            ],
          )
        ],
      ),
    );
  }

  Card launchRealTime(isRTEnabled) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(15),
      elevation: 10,
      color: REAL_TIME_COLOR,
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(15, 10, 25, 0),
            title: Text('Real Time Navigation'),
            subtitle: Text(
              'Launch a Real Time run using raw GNSS data from the Smartphone.',
              textAlign: TextAlign.justify,
            ),
            trailing: Image(image: AssetImage("assets/images/rt_icon.png")),
          ),
          Divider(color: Colors.black54, indent: 15, endIndent: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    if (isRTEnabled.contains('true')) {
                      _tabController.animateTo(2);
                    } else {
                      _alertRT(context);
                    }
                  },
                  child: Text(
                    'Start',
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                        fontWeight: FontWeight.bold),
                  )),
              /*TextButton(
                  onPressed: () {},
                  child: Text(
                    'More info',
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                        fontWeight: FontWeight.bold),
                  )),*/ // TODO: Add web link to manual
            ],
          )
        ],
      ),
    );
  }

  launchMailto() async {
    final mailtoLink = Mailto(
      to: [GEA_EMAIL],
      subject: 'Enable RT Feature',
      body: 'Add user email',
    );
    await launch('$mailtoLink');
  }

  void _alertRT(BuildContext context) {
    var alert = AlertDialog(
      title: Text(
        'Real Time Disabled',
        style: new TextStyle(color: GEA_COLOR, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
                'To avoid server overload problems, the Real Time feature is disabled. To activate it, send an email to $GEA_EMAIL.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: new Text('Send Email',
              style: TextStyle(
                color: GEA_COLOR,
              )),
          onPressed: () => launchMailto(),
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

  createLogView() {
    return DefaultTabController(
        length: 1, // length of tabs
        initialIndex: 0,
        child: Scaffold(
            appBar: TabBar(
              labelColor: GEA_COLOR,
              unselectedLabelColor: Colors.grey,
              indicatorColor: GEA_COLOR,
              tabs: [
                Tab(icon: Icon(LOG_ICON)),
              ],
            ),
            body: TabBarView(children: <Widget>[
              ListView(
                children: <Widget>[
                  SizedBox(
                    height: 40.0,
                  ),
                  Center(
                    child: Image(
                      image: AssetImage("assets/images/log_icon.png"),
                      width: 150,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: ListTile(
                        contentPadding: EdgeInsets.fromLTRB(15, 10, 25, 0),
                        title: execLaunch != NO_LAUNCH &&
                                execLaunch == LOG_LAUNCH
                            ? Text('Recording...',
                                style:
                                    TextStyle(color: LOG_COLOR, fontSize: 28.0),
                                textAlign: TextAlign.justify)
                            : Text('Log raw GNSS data',
                                style: TextStyle(fontSize: 28.0),
                                textAlign: TextAlign.justify),
                        subtitle: execLaunch != NO_LAUNCH &&
                                execLaunch == LOG_LAUNCH
                            ? Text('Recording data on $fileName',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 18.0),
                                textAlign: TextAlign.left)
                            : Text(
                                'Currently no data recording is running. Click on the play button to start recording data.',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 18.0),
                                textAlign: TextAlign.justify),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: execLaunch != NO_LAUNCH &&
                    execLaunch == LOG_LAUNCH
                ? FloatingActionButton.extended(
                    heroTag: "createExec",
                    onPressed: () {
                      _stop(context);
                    },
                    icon: Icon(
                      Icons.stop_circle_outlined,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? GEA_LIGHT
                          : GEA_DARK,
                    ),
                    label: Text(
                      'Stop Recording',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                      ),
                    ),
                    backgroundColor: Colors.red,
                  )
                : FloatingActionButton.extended(
                    heroTag: "createExec",
                    onPressed: () {
                      _createLog(context);
                    },
                    icon: Icon(
                      Icons.play_circle_outline_rounded,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? GEA_LIGHT
                          : GEA_DARK,
                    ),
                    label: Text(
                      'Start Recording',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                      ),
                    ),
                    backgroundColor: LOG_COLOR,
                  )));
  }

  createRTView() {
    var colorExe = REAL_TIME_COLOR;
    if (execLaunch == SINGLE_LAUNCH) {
      colorExe = SINGLE_COLOR;
    } else if (execLaunch == RTK_LAUNCH) {
      colorExe = RTK_COLOR;
    } else if (execLaunch == PPP_LAUNCH) {
      colorExe = PPP_COLOR;
    }
    return DefaultTabController(
        length: 2, // length of tabs
        initialIndex: 0,
        child: Scaffold(
            appBar: TabBar(
              labelColor: GEA_COLOR,
              unselectedLabelColor: Colors.grey,
              indicatorColor: GEA_COLOR,
              tabs: [
                Tab(icon: Icon(RT_ICON)),
                Tab(icon: Icon(Icons.settings)),
              ],
            ),
            body: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  ListView(
                    children: <Widget>[
                      SizedBox(
                        height: 40.0,
                      ),
                      Center(
                        child: Image(
                          image: AssetImage("assets/images/rt_icon.png"),
                          width: 150,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: ListTile(
                            contentPadding: EdgeInsets.fromLTRB(15, 10, 25, 0),
                            title: execLaunch != NO_LAUNCH &&
                                    execLaunch > LOG_LAUNCH
                                ? Text('Running...',
                                    style: TextStyle(
                                        color: colorExe, fontSize: 28.0),
                                    textAlign: TextAlign.justify)
                                : Text('Real Time Navigation',
                                    style: TextStyle(fontSize: 28.0),
                                    textAlign: TextAlign.justify),
                            subtitle: execLaunch != NO_LAUNCH &&
                                    execLaunch > LOG_LAUNCH
                                ? Text(
                                    'Recording data on $fileName\n\nServer Response:\n$rtConsole',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 18.0),
                                    textAlign: TextAlign.left)
                                : Text(
                                    'There is currently no Real Time execution in progress. Click on the play button to start a run.',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 18.0),
                                    textAlign: TextAlign.justify),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Form(
                    key: _formKey,
                    child: CardSettings(children: <CardSettingsSection>[
                      CardSettingsSection(
                        header: CardSettingsHeader(
                          label: 'GEA Real Time Configuration',
                        ),
                        children: <CardSettingsWidget>[
                          CardSettingsRadioPicker(
                            label: "Position Mode",
                            contentAlign: TextAlign.right,
                            initialItem: solTypeDefault,
                            items: solType,
                            onChanged: (value) {
                              int solVal = PMODE_SINGLE;
                              if (value.contains("Single")) {
                                solVal = PMODE_SINGLE;
                              }
                              solTypeDefault = value;
                              configRT["solType"] = solVal;
                            },
                            enabled: false,
                          ),
                          CardSettingsRadioPicker(
                            label: "Frequencies",
                            contentAlign: TextAlign.right,
                            initialItem: freqTypeDefault,
                            items: freqType,
                            onChanged: (value) {
                              int freqVal = L1;
                              if (value.contains("L1")) {
                                freqVal = L1;
                              }
                              freqTypeDefault = value;
                              configRT["freqType"] = freqVal;
                            },
                            enabled: false,
                          ),
                          CardSettingsRadioPicker(
                            label: "Elevation Mask",
                            contentAlign: TextAlign.right,
                            initialItem: elevMaskDefault,
                            items: elevMask,
                            onChanged: (value) {
                              elevMaskDefault = value;
                              configRT["elevMask"] = value;
                            },
                          ),
                          CardSettingsCheckboxPicker(
                            label: "Satellite Systems",
                            contentAlign: TextAlign.right,
                            initialItems: constTypeDefault,
                            items: constType,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                constTypeDefault = ["GPS", "Galileo"];
                                configRT["constType"] = SYS_GPS + SYS_GAL;
                                return 'Satellite System is required. GPS + Galileo selected by default.';
                              }
                              return "";
                            },
                            onChanged: (value) {
                              int constVal = 0;
                              List constList = [];
                              if (value.contains("GPS")) {
                                constVal += SYS_GPS;
                                constList.add("GPS");
                              }
                              if (value.contains("Galileo")) {
                                constVal += SYS_GAL;
                                constList.add("Galileo");
                              }
                              if (value.contains("Glonass")) {
                                constVal += SYS_GLO;
                                constList.add("Glonass");
                              }
                              if (value.contains("Beidou")) {
                                constVal += SYS_CMP;
                                constList.add("Beidou");
                              }
                              if (constVal == 0) {
                                constVal = SYS_GPS + SYS_GAL;
                                constList = ["GPS", "Galileo"];
                              }
                              constTypeDefault = constList;
                              configRT["constType"] = constVal;
                            },
                          )
                        ],
                      ),
                    ]),
                  ),
                ]),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: execLaunch != NO_LAUNCH &&
                    execLaunch > LOG_LAUNCH
                ? FloatingActionButton.extended(
                    heroTag: "createExec",
                    onPressed: () {
                      _stop(context);
                    },
                    icon: Icon(
                      Icons.stop_circle_outlined,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? GEA_LIGHT
                          : GEA_DARK,
                    ),
                    label: Text(
                      'Stop RT',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                      ),
                    ),
                    backgroundColor: Colors.red,
                  )
                : FloatingActionButton.extended(
                    heroTag: "createExec",
                    onPressed: () {
                      int type = SINGLE_LAUNCH;
                      if (configRT["solType"] == PMODE_SINGLE) {
                        type = SINGLE_LAUNCH;
                      }
                      _createRT(context, type);
                    },
                    icon: Icon(
                      Icons.play_circle_outline_rounded,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? GEA_LIGHT
                          : GEA_DARK,
                    ),
                    label: Text(
                      'Start RT',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                      ),
                    ),
                    backgroundColor: REAL_TIME_COLOR,
                  )));
  }

  void _serverConnection() async {
    _channel = WebSocketChannel.connect(
      Uri.parse(GEA_WSS),
      protocols: {'test'},
    );
    _channel.stream.listen((message) async {
      if (message.contains('EVENT:') ||
          message.contains('WARNING:') ||
          message.contains('ERROR:')) {
        rtConsole += message + '\n';
      }
      if (message.contains('Status (-1)')) {
        _stopExecution();
      }
      if (message.contains('Status (2)')) {
        semaphore = true;
      }
      if (message.contains('nmeaType')) {
        _readNMEAMessage(message);
      }
      if (message.contains("\$")) {
        bufferRT.write('$message\n');
      }
      if (message.contains("TIMEST,2,2")) {
        var msgNMEATime = generateTimeStampNMEA("2");
        bufferRT.write('$msgNMEATime\n');
        await writeRT(globalFileName, bufferRT.toString());
        bufferRT = StringBuffer();
      }
    });
  }

  _readNMEAMessage(message) async {
    // Encode JSON data
    prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> nmea = jsonDecode(message);

    // Read NMEA type
    if (nmea['nmeaType'] == 'GSV') {
      // GSV = Number of SVs in view, PRN, elevation, azimuth, and SNR
      // Check if all sentence is received
      var satList = nmea['satellites'].toList();
      for (int i = 0; i < satList.length; i++) {
        var item = satList[i];
        item["constellation"] = nmea['talker'];
        GSVSats.add(item.toString());
      }
      if (nmea['sentenceNumber'] == nmea['sentenceCount']) {
        // Case all sentence received
        await prefs.setStringList('rtTrackedSats', GSVSats);
        GSVSats = [];
      }
    }

    if (nmea['nmeaType'] == 'GGA') {
      // GGA = 	Time, position, and fix related data
      var lat = nmea['latitude'];
      var lon = nmea['longitude'];
      GGAPost.add([lat, lon].toString());
      await prefs.setStringList('rtPosition', GGAPost);
    }
  }

  void _sendMessage(msg) {
    _channel.sink.add(msg);
  }

  void _createRT(context, type) async {
    final File file = await _localFile(RT_LAUNCH);
    setState(() {
      globalFileName = file;
      bufferLOG = StringBuffer();
      bufferRT = StringBuffer();
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'RT Navigation',
              style:
                  new TextStyle(color: GEA_COLOR, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SimpleDialogOption(
                    child: TextFormField(
                      cursorColor: GEA_COLOR,
                      controller: nameRT,
                      keyboardType: TextInputType.name,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 14.0),
                        prefixIcon: Icon(
                          Icons.input,
                          color: GEA_COLOR,
                        ),
                        hintText: 'RT name...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter RT Name';
                        } else if (value.length > 10) {
                          return 'Name shall be less than 10 characters.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SimpleDialogOption(
                    child: TextFormField(
                      cursorColor: GEA_COLOR,
                      controller: descriptionRT,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 14.0),
                        prefixIcon: Icon(
                          Icons.input,
                          color: GEA_COLOR,
                        ),
                        hintText: 'Description...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Description';
                        } else if (value.length > 30) {
                          return 'Description shall be less than 30 characters.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SimpleDialogOption(
                    child: TextFormField(
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 14.0),
                        prefixIcon: Icon(
                          LOG_ICON,
                          color: GEA_COLOR,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      initialValue: fileName,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Start RT Nav',
                  style: new TextStyle(
                      fontSize: 14.0,
                      color: GEA_COLOR,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _createAndLaunchRT(
                      file, nameRT.text, descriptionRT.text, type);
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
              ),
              TextButton(
                child: Text(
                  'Cancel',
                  style: new TextStyle(
                      fontSize: 14.0,
                      color: GEA_COLOR,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
              ),
            ],
          );
        });
  }

  void _createLog(context) async {
    final File file = await _localFile(LOG_LAUNCH);
    setState(() {
      globalFileName = file;
      bufferLOG = StringBuffer();
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Log GNSS Data',
              style:
                  new TextStyle(color: GEA_COLOR, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SimpleDialogOption(
                    child: TextFormField(
                      cursorColor: GEA_COLOR,
                      controller: name,
                      keyboardType: TextInputType.name,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 14.0),
                        prefixIcon: Icon(
                          Icons.input,
                          color: GEA_COLOR,
                        ),
                        hintText: 'Log name...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Log Name';
                        } else if (value.length > 10) {
                          return 'Name shall be less than 10 characters.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SimpleDialogOption(
                    child: TextFormField(
                      cursorColor: GEA_COLOR,
                      controller: description,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 14.0),
                        prefixIcon: Icon(
                          Icons.input,
                          color: GEA_COLOR,
                        ),
                        hintText: 'Description...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Description';
                        } else if (value.length > 30) {
                          return 'Description shall be less than 30 characters.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SimpleDialogOption(
                    child: TextFormField(
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_LIGHT
                            : GEA_DARK,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 14.0),
                        prefixIcon: Icon(
                          LOG_ICON,
                          color: GEA_COLOR,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      initialValue: fileName,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Start Logging',
                  style: new TextStyle(
                      fontSize: 14.0,
                      color: GEA_COLOR,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _createAndWriteLog(file, name.text, description.text);
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
              ),
              TextButton(
                child: Text(
                  'Cancel',
                  style: new TextStyle(
                      fontSize: 14.0,
                      color: GEA_COLOR,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
              ),
            ],
          );
        });
  }

  Future<void> synchronizeTimeWithServer() async {
    try {
      // Make an HTTP request to the server
      var response = await http.get(Uri.parse('$GEA_URL/getServerTime'));
      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> data = json.decode(response.body);
        String serverTimeString = data['serverTime'];

        // Get the current time in the Dart application
        DateTime localTime = DateTime.now();

        // Convert the server time to DateTime
        DateTime serverTime = DateTime.parse(serverTimeString);

        // Calculate the time difference
        Duration difference = serverTime.difference(localTime);
        setState(() {
          diffTimeServer = difference;
        });

        // Adjust the local time in the application
        DateTime adjustedTime = localTime.add(difference);

        print('Adjusted local time: $adjustedTime');
      } else {
        print('Error fetching server time: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String generateTimeStampNMEA(String msgPos) {
    // Date now
    DateTime now = new DateTime.now().toUtc();

    // Format Time and Date
    String time =
        "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}";
    String date =
        "${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year % 100}";

    // Create NMEA msg
    String message = "TIMEST,2,$msgPos,$date,$time,A";

    // Generate checksum
    int checksum = 0;
    for (int i = 0; i < message.length; i++) {
      checksum ^= message.codeUnitAt(i);
    }

    // Format checksum in hex
    String checksumHex =
        checksum.toRadixString(16).toUpperCase().padLeft(2, '0');

    // Final msg
    String nmeaMsg = "\$$message\*$checksumHex";

    return nmeaMsg;
  }

  /// Main function of the executions
  /// Checks if there is any active execution and process data
  _checkExecution(gnss) async {
    /// CASE LOG = 1:
    if (execLaunch == LOG_LAUNCH) {
      /// Write received data in file (append)
      /// RAW messages
      for (int i = 0; i < widget.gnss.length; i++) {
        String nmea = nmeaRawMsgFormatter(gnss[i], widget.clock);
        bufferLOG.write('$nmea\n');
      }
      if (bufferLOG.isNotEmpty) {
        await writeLog(globalFileName, bufferLOG.toString());
        bufferLOG = StringBuffer();
      }
      setState(() {
        _isEnabled = [false, true, false];
      });
    }

    /// CASE SINGLE = 3:
    if (execLaunch == SINGLE_LAUNCH) {
      /// RAW messages
      Map send = {};
      Map satMsg = {};
      send["MessageType"] = MSG;
      for (int i = 0; i < widget.gnss.length; i++) {
        String nmea = nmeaRawMsgFormatter(gnss[i], widget.clock);
        satMsg[i.toString()] = nmea;
        bufferLOG.write('$nmea\n');
      }
      if (bufferLOG.isNotEmpty) {
        var msgNMEATime = generateTimeStampNMEA("1");
        bufferLOG.write('$msgNMEATime\n');
        await writeRT(globalFileName, bufferLOG.toString());
        bufferLOG = StringBuffer();
      }
      send["Content"] = satMsg;
      CollectionReference dbRefUser =
          FirebaseFirestore.instance.collection('users');
      DocumentSnapshot document = await dbRefUser.doc(widget.uid).get();
      var email = document.get('email');
      var clientRTKLIBPort = document.get('clientRTKLIBPort');
      var clientRTKLIBRecPort = document.get('clientRTKLIBRecPort');
      send['clientRTKLIBPort'] = clientRTKLIBPort;
      send['clientRTKLIBRecPort'] = clientRTKLIBRecPort;
      send['User'] = email;
      if (semaphore) {
        _sendMessage(json.encode(send));
      }
      setState(() {
        _isEnabled = [false, false, true];
      });
    }

    /// CASE RTK = 4:
    if (execLaunch == RTK_LAUNCH) {
      /// RAW messages
      Map send = {};
      Map satMsg = {};
      send["MessageType"] = MSG;
      for (int i = 0; i < widget.gnss.length; i++) {
        String nmea = nmeaRawMsgFormatter(gnss[i], widget.clock);
        satMsg[i.toString()] = nmea;
      }
      send["Content"] = satMsg;
      CollectionReference dbRefUser =
          FirebaseFirestore.instance.collection('users');
      DocumentSnapshot document = await dbRefUser.doc(widget.uid).get();
      var email = document.get('email');
      var clientRTKLIBPort = document.get('clientRTKLIBPort');
      var clientRTKLIBRecPort = document.get('clientRTKLIBRecPort');
      send['clientRTKLIBPort'] = clientRTKLIBPort;
      send['clientRTKLIBRecPort'] = clientRTKLIBRecPort;
      send['User'] = email;
      if (semaphore) {
        _sendMessage(json.encode(send));
      }
      setState(() {
        _isEnabled = [false, false, true];
      });
    }

    /// CASE PPP = 5:
    if (execLaunch == PPP_LAUNCH) {
      /// RAW messages
      Map send = {};
      Map satMsg = {};
      send["MessageType"] = MSG;
      for (int i = 0; i < widget.gnss.length; i++) {
        String nmea = nmeaRawMsgFormatter(gnss[i], widget.clock);
        satMsg[i.toString()] = nmea;
      }
      send["Content"] = satMsg;
      CollectionReference dbRefUser =
          FirebaseFirestore.instance.collection('users');
      DocumentSnapshot document = await dbRefUser.doc(widget.uid).get();
      var email = document.get('email');
      var clientRTKLIBPort = document.get('clientRTKLIBPort');
      var clientRTKLIBRecPort = document.get('clientRTKLIBRecPort');
      send['clientRTKLIBPort'] = clientRTKLIBPort;
      send['clientRTKLIBRecPort'] = clientRTKLIBRecPort;
      send['User'] = email;
      if (semaphore) {
        _sendMessage(json.encode(send));
      }
      setState(() {
        _isEnabled = [false, false, true];
      });
    }
  }

  /// Set all variables to NOT EXECUTION LAUNCHED = 0
  _stopExecution() async {
    /// Upload file to storage
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child(widget.uid.toString())
        .child('$fileName');
    final metadata = firebase_storage.SettableMetadata(
        contentType: 'text/plain',
        customMetadata: {'picked-file-path': PATH_TO_STORAGE});
    firebase_storage.UploadTask uploadTask =
        ref.putFile(File('$PATH_TO_STORAGE$fileName'), metadata);

    /// Disconnection from server
    if (execLaunch != LOG_LAUNCH) {
      /// Send STOP message
      Map send = {};
      send["MessageType"] = STOP;
      send["Content"] = "None";
      CollectionReference dbRefUser =
          FirebaseFirestore.instance.collection('users');
      DocumentSnapshot document = await dbRefUser.doc(widget.uid).get();
      var email = document.get('email');
      var clientRTKLIBPort = document.get('clientRTKLIBPort');
      var clientRTKLIBRecPort = document.get('clientRTKLIBRecPort');
      send['clientRTKLIBPort'] = clientRTKLIBPort;
      send['clientRTKLIBRecPort'] = clientRTKLIBRecPort;
      send['User'] = email;
      _sendMessage(json.encode(send));
      _channel.sink.close();
    }

    /// Change processing data status to STOP type = 0
    prefs = await SharedPreferences.getInstance();
    await prefs.setInt('isProcessing', NO_LAUNCH);
    await prefs.setString('fileName', "none");
    await prefs.setStringList('rtTrackedSats', ['null']);
    await prefs.setStringList('rtPosition', ['null']);
    setState(() {
      execLaunch = NO_LAUNCH;
      fileName = "none";
      rtConsole = "";
      semaphore = false;
      _isEnabled = [true, true, true];
      name.clear();
      nameRT.clear();
      description.clear();
      descriptionRT.clear();
      GSVSats = [];
      GGAPost = [];
    });
  }

  void _stop(BuildContext context) {
    var alert = AlertDialog(
      title: Text(
        'Stop Execution',
        style: new TextStyle(color: GEA_COLOR, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Are you sure you want to stop the execution?'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Stop',
            style: new TextStyle(
                fontSize: 14.0, color: GEA_COLOR, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            _stopExecution();
            Navigator.of(context, rootNavigator: true).pop('dialog');
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

  /// This function creates the file, writes the header
  /// and creates the card and also the DB entrance
  _createAndWriteLog(File file, String name, String desc) async {
    /// Change processing data status to LOG type = 1
    prefs = await SharedPreferences.getInstance();
    await prefs.setInt('isProcessing', LOG_LAUNCH);
    await prefs.setString('fileName', fileName);
    setState(() {
      execLaunch = LOG_LAUNCH;
    });

    /// Create the file in local
    await createFileLog(file);
    Future.delayed(Duration(seconds: 1));
    DateTime now = new DateTime.now();
    if (name == "") {
      name = "Log Execution";
    }
    if (desc == "") {
      desc = "Raw GNSS data";
    }

    /// Create the entrance to the DB
    CollectionReference dbRef =
        FirebaseFirestore.instance.collection('executions');
    dbRef.doc(widget.uid).collection('logs').add({
      "date": now.toUtc().toString(),
      "description": desc,
      "name": name,
      "route": [
        {"filename": fileName}
      ],
    }).then((res) {
      print("created");
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Error",
                style: new TextStyle(
                    fontSize: 14.0,
                    color: GEA_COLOR,
                    fontWeight: FontWeight.bold),
              ),
              content: Text(err.message),
              actions: [
                TextButton(
                  child: Text(
                    "Ok",
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: GEA_COLOR,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }

  /// This function creates the file, writes the header
  /// and creates the card and also the DB entrance
  /// for RT executions
  _createAndLaunchRT(File file, String name, String desc, type) async {
    /// Connect with Server
    _serverConnection();

    /// Change processing data status to RT type
    prefs = await SharedPreferences.getInstance();
    await prefs.setInt('isProcessing', type);
    await prefs.setString('fileName', fileName);
    await prefs.setStringList('rtTrackedSats', ['null']);
    await prefs.setStringList('rtPosition', ['null']);
    setState(() {
      execLaunch = type;
    });

    /// Create the file in local
    await createFileRT(file);
    print("it works");
    Future.delayed(Duration(seconds: 1));
    DateTime now = new DateTime.now();
    if (name == "") {
      name = "RT Execution";
    }
    if (desc == "") {
      desc = "RT data processed";
    }

    /// Create the entrance to the DB
    CollectionReference dbRef =
        FirebaseFirestore.instance.collection('executions');
    dbRef.doc(widget.uid).collection('rt').add({
      "date": now.toUtc().toString(),
      "description": desc,
      "name": name,
      "type": type,
      "route": [
        {"filename": fileName}
      ],
    }).then((res) {
      print("created");
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Error",
                style: new TextStyle(
                    fontSize: 14.0,
                    color: GEA_COLOR,
                    fontWeight: FontWeight.bold),
              ),
              content: Text(err.message),
              actions: [
                TextButton(
                  child: Text(
                    "Ok",
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: GEA_COLOR,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });

    /// Send LAUNCH message to start processing
    Map send = {};
    Map content = configRT;
    send["MessageType"] = LAUNCH;
    CollectionReference dbRefUser =
        FirebaseFirestore.instance.collection('users');
    DocumentSnapshot document = await dbRefUser.doc(widget.uid).get();
    var email = document.get('email');
    var clientRTKLIBPort = document.get('clientRTKLIBPort');
    var clientRTKLIBRecPort = document.get('clientRTKLIBRecPort');
    send['clientRTKLIBPort'] = clientRTKLIBPort;
    send['clientRTKLIBRecPort'] = clientRTKLIBRecPort;
    send['User'] = email;
    send["Content"] = content;
    _sendMessage(json.encode(send));
  }

  /// Get Directory File
  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  /// Get Log File Name
  /// TODO: Create final folder (now in /storage/emulated/0/Android/data/xyz.gea/files)
  Future<File> _localFile(type) async {
    final path = await _localPath;
    print(path.toString());
    DateTime now = new DateTime.now();
    var month;
    var day;
    var hour;
    var minute;
    var second;
    if (now.month < 10) {
      month = "0" + now.month.toString();
    } else {
      month = now.month.toString();
    }
    if (now.day < 10) {
      day = "0" + now.day.toString();
    } else {
      day = now.day.toString();
    }
    if (now.hour < 10) {
      hour = "0" + now.hour.toString();
    } else {
      hour = now.hour.toString();
    }
    if (now.minute < 10) {
      minute = "0" + now.minute.toString();
    } else {
      minute = now.minute.toString();
    }
    if (now.second < 10) {
      second = "0" + now.second.toString();
    } else {
      second = now.second.toString();
    }

    var dateStr = now.year.toString() + month + day + hour + minute + second;
    setState(() {
      if (type == LOG_LAUNCH) {
        fileName = "log_" + dateStr + ".txt";
      } else if (type == RT_LAUNCH) {
        fileName = "rt_" + dateStr + ".txt";
      }
    });
    return File('$path/$fileName');
  }

  /// Read File
  /// TODO: Add reader for file input
  /*Future<int> readLog() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }*/

  /// Create log file and print header
  Future<File> createFileLog(File file) async {
    return file.writeAsString('$HEADER_FILE');
  }

  /// Write (append) data in file
  Future<File> writeLog(File file, String msgNMEA) async {
    final sink = file.openWrite(mode: FileMode.append);
    sink.write('$msgNMEA');
    await sink.flush();
    await sink.close();
    return file;
  }

  /// Create RT file and print header
  Future<File> createFileRT(File file) async {
    return file.writeAsString('$HEADER_FILE_RT');
  }

  /// Write (append) data in file
  Future<File> writeRT(File file, String msgNMEA) async {
    final sink = file.openWrite(mode: FileMode.append);
    sink.write('$msgNMEA');
    await sink.flush();
    await sink.close();
    return file;
  }
}
