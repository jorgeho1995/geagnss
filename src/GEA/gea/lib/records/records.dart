///////////////////////////////////////////////////////////
/// This file contains the Records window
//////////////////////////////////////////////////////////
/// Includes
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gea/includes/includes.dart';
import 'package:gea/includes/commonUtils.dart';
import 'package:open_file/open_file.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

///////////////////////////////////////////////////////////
/// Main RECORDS widget.
//////////////////////////////////////////////////////////
class Records extends StatefulWidget {
  Records({Key key, this.uid, this.gnss, this.clock}) : super(key: key);
  static Route<dynamic> route() => MaterialPageRoute(
        builder: (context) => Records(),
      );
  final List<Map<String, dynamic>> gnss;
  final Map<String, dynamic> clock;
  final String uid;

  @override
  _RecordsStatefulWidgetState createState() => _RecordsStatefulWidgetState();
}

class _RecordsStatefulWidgetState extends State<Records>
    with SingleTickerProviderStateMixin {
  var logs = [];
  var rtk = [];
  var ppp = [];
  String fileName = "none";
  AnimationController _animationController;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _animationController.repeat(reverse: true);
    super.initState();
    setState(() {
      fileName = "none";
    });
  }

  Future<void> _checkPrefs() async {
    final SharedPreferences prefs = await _prefs;
    final String filename = (prefs.getString('fileName') ?? "none");
    setState(() {
      fileName = filename;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          tabs: [
            Tab(text: "Log Data"),
            Tab(text: "RT Navi"),
          ],
          labelColor: GEA_COLOR,
          unselectedLabelColor: Colors.grey,
          indicatorColor: GEA_COLOR,
        ),
        body: TabBarView(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('executions')
                    .doc(widget.uid)
                    .collection('logs')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, orderSnapshot) {
                  return orderSnapshot.hasData
                      ? ListView.builder(
                          itemCount: orderSnapshot.data.docs.length + 1,
                          itemBuilder: (context, index) {
                            if (orderSnapshot.data.docs.length + 1 == 1) {
                              return _logIntro();
                            }
                            if (index < orderSnapshot.data.docs.length) {
                              DocumentSnapshot orderData =
                                  orderSnapshot.data.docs[index];
                              return logsCard(orderData);
                            } else {
                              return SizedBox(
                                height: 0.0,
                              );
                            }
                          },
                        )
                      : _loading(LOG_COLOR);
                }),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('executions')
                    .doc(widget.uid)
                    .collection('rt')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, orderSnapshot) {
                  return orderSnapshot.hasData
                      ? ListView.builder(
                          itemCount: orderSnapshot.data.docs.length + 1,
                          itemBuilder: (context, index) {
                            if (orderSnapshot.data.docs.length + 1 == 1) {
                              return _rtIntro();
                            }
                            if (index < orderSnapshot.data.docs.length) {
                              DocumentSnapshot orderData =
                                  orderSnapshot.data.docs[index];
                              return rtCard(orderData);
                            } else {
                              return SizedBox(
                                height: 0.0,
                              );
                            }
                          },
                        )
                      : _loading(RTK_COLOR);
                }),
          ],
        ),
      ),
    );
  }

  _loading(color) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(9.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }

  _logIntro() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 80.0,
        ),
        Center(
          child: Image(image: AssetImage("assets/images/log_icon.png"), width: 150,),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
                "You do not have any log file yet. Start recording your data and save it in a text file.",
                style: TextStyle(color: Colors.grey, fontSize: 24.0),
                textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }

  _rtIntro() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 80.0,
        ),
        Center(
          child: Image(image: AssetImage("assets/images/rt_icon.png"), width: 150,),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
                "You do not have any Real Time execution yet. Start processing your data using Single, RTK or PPP.",
                style: TextStyle(color: Colors.grey, fontSize: 24.0),
                textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }

  logsCard(orderData) {
    var name = orderData["name"];
    var desc = orderData["description"];
    var filename = orderData["route"][0]["filename"];
    var date = orderData["date"].split(" ")[0] +
        " " +
        orderData["date"].split(" ")[1].split(".")[0];
    var existsFile = File('$PATH_TO_STORAGE$filename').existsSync();
    _checkPrefs();
    if (fileName == filename) {
      return FadeTransition(
        opacity: _animationController,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(15),
          elevation: 10,
          color: LOG_COLOR,
          child: Column(
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.fromLTRB(15, 10, 25, 0),
                title: Text('$name'),
                subtitle: Text('$date UTC\n$desc'),
                leading: Icon(LOG_ICON),
              ),
              Divider(color: Colors.black54, indent: 15, endIndent: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        'Recording data...',
                        style: new TextStyle(
                            fontSize: 14.0,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? GEA_LIGHT
                                    : GEA_DARK,
                            fontWeight: FontWeight.bold),
                      )),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(15),
        elevation: 10,
        color: LOG_COLOR,
        child: Column(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(15, 10, 25, 0),
              title: Text('$name'),
              subtitle: Text('$date UTC\n$desc'),
              leading: Icon(LOG_ICON),
            ),
            Divider(color: Colors.black54, indent: 15, endIndent: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    shareFile(name, desc, filename);
                  },
                  child: Icon(
                    Icons.share_outlined,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? GEA_LIGHT
                        : GEA_DARK,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (existsFile) {
                      OpenFile.open("$PATH_TO_STORAGE$filename");
                    } else {
                      downloadLogOrRT(filename);
                    }
                  },
                  child: existsFile
                      ? Icon(
                          Icons.open_in_new,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? GEA_LIGHT
                              : GEA_DARK,
                        )
                      : Icon(
                          Icons.download_outlined,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? GEA_LIGHT
                              : GEA_DARK,
                        ),
                ),
                TextButton(
                  onPressed: () {
                    var alert = AlertDialog(
                      title: Text(
                        'Delete',
                        style: new TextStyle(
                            color: GEA_COLOR, fontWeight: FontWeight.bold),
                      ),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text(
                                'Are you sure you want to delete this entry? Once done, they cannot be recovered'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'Delete',
                            style: new TextStyle(
                                fontSize: 14.0,
                                color: GEA_COLOR,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                            deleteLog(filename, orderData.id, name);
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
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          },
                        ),
                      ],
                    );
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => alert);
                  },
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? GEA_LIGHT
                        : GEA_DARK,
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
  }

  rtCard(orderData) {
    var name = orderData["name"];
    var desc = orderData["description"];
    var filename = orderData["route"][0]["filename"];
    var date = orderData["date"].split(" ")[0] +
        " " +
        orderData["date"].split(" ")[1].split(".")[0];
    var type = orderData["type"];
    var existsFile = File('$PATH_TO_STORAGE$filename').existsSync();
    _checkPrefs();
    var color;
    var icon;
    if (type == SINGLE_LAUNCH) {
      color = SINGLE_COLOR;
      icon = SINGLE_ICON;
    } else if (type == RTK_LAUNCH) {
      color = RTK_COLOR;
      icon = RTK_ICON;
    } else if (type == PPP_LAUNCH) {
      color = PPP_COLOR;
      icon = PPP_ICON;
    } else {
      color = REAL_TIME_COLOR;
      icon = PPP_ICON;
    }
    if (fileName == filename) {
      return FadeTransition(
        opacity: _animationController,
        child: Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(15),
          elevation: 10,
          color: color,
          child: Column(
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.fromLTRB(15, 10, 25, 0),
                title: Text('$name'),
                subtitle: Text('$date UTC\n$desc'),
                leading: Icon(icon),
              ),
              Divider(color: Colors.black54, indent: 15, endIndent: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        'Launching execution...',
                        style: new TextStyle(
                            fontSize: 14.0,
                            color:
                            Theme.of(context).brightness == Brightness.dark
                                ? GEA_LIGHT
                                : GEA_DARK,
                            fontWeight: FontWeight.bold),
                      )),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(15),
        elevation: 10,
        color: color,
        child: Column(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(15, 10, 25, 0),
              title: Text('$name'),
              subtitle: Text('$date UTC\n$desc'),
              leading: Icon(icon),
            ),
            Divider(color: Colors.black54, indent: 15, endIndent: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    shareFile(name, desc, filename);
                  },
                  child: Icon(
                    Icons.share_outlined,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? GEA_LIGHT
                        : GEA_DARK,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (existsFile) {
                      OpenFile.open("$PATH_TO_STORAGE$filename");
                    } else {
                      downloadLogOrRT(filename);
                    }
                  },
                  child: existsFile
                      ? Icon(
                    Icons.open_in_new,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? GEA_LIGHT
                        : GEA_DARK,
                  )
                      : Icon(
                    Icons.download_outlined,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? GEA_LIGHT
                        : GEA_DARK,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    var alert = AlertDialog(
                      title: Text(
                        'Delete',
                        style: new TextStyle(
                            color: GEA_COLOR, fontWeight: FontWeight.bold),
                      ),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text(
                                'Are you sure you want to delete this entry? Once done, they cannot be recovered'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'Delete',
                            style: new TextStyle(
                                fontSize: 14.0,
                                color: GEA_COLOR,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                            deleteRT(filename, orderData.id, name);
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
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          },
                        ),
                      ],
                    );
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => alert);
                  },
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? GEA_LIGHT
                        : GEA_DARK,
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
  }

  Future<void> deleteLog(String filename, index, name) async {
    var alert = SimpleDialog(
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {},
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(9.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(GEA_COLOR),
              ),
            ),
            title: Text('Deleting entry...'),
          ),
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => alert);

    /// Delete file from local storage and remote storage
    try {
      // Delete form local storage
      if (await File('$PATH_TO_STORAGE$filename').exists()) {
        await File('$PATH_TO_STORAGE$filename').delete();
      }
      // Delete from remote storage
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(widget.uid.toString())
          .child('$filename');
      await ref.delete();
    } catch (e) {
      print("Error deleting files");
    }
    // Delete record from database
    CollectionReference dbRef =
        FirebaseFirestore.instance.collection('executions');
    dbRef.doc(widget.uid).collection('logs').doc(index).delete();
    Navigator.of(context, rootNavigator: true).pop('dialog');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Success!\n Deleted $name ',
        ),
      ),
    );
  }

  Future<void> deleteRT(String filename, index, name) async {
    var alert = SimpleDialog(
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {},
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(9.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(GEA_COLOR),
              ),
            ),
            title: Text('Deleting entry...'),
          ),
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => alert);

    /// Delete file from local storage and remote storage
    try {
      // Delete form local storage
      if (await File('$PATH_TO_STORAGE$filename').exists()) {
        await File('$PATH_TO_STORAGE$filename').delete();
      }
      // Delete from remote storage
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(widget.uid.toString())
          .child('$filename');
      await ref.delete();
    } catch (e) {
      print("Error deleting files");
    }
    // Delete record from database
    CollectionReference dbRef =
    FirebaseFirestore.instance.collection('executions');
    dbRef.doc(widget.uid).collection('rt').doc(index).delete();
    Navigator.of(context, rootNavigator: true).pop('dialog');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Success!\n Deleted $name ',
        ),
      ),
    );
  }

  Future<void> downloadLogOrRT(String filename) async {
    var alert = SimpleDialog(
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {},
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(9.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(GEA_COLOR),
              ),
            ),
            title: Text('Downloading...'),
          ),
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => alert);
    // Download file from remote storage to local storage
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child(widget.uid.toString())
        .child('$filename');
    if (File('$PATH_TO_STORAGE$filename').existsSync()) {
      await File('$PATH_TO_STORAGE$filename').delete();
    }
    final File file = File('$PATH_TO_STORAGE$filename');
    await ref.writeToFile(file);
    Navigator.of(context, rootNavigator: true).pop('dialog');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Success!\n Downloaded ${ref.name} \n from Database\n ',
        ),
      ),
    );
  }
}
