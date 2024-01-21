///////////////////////////////////////////////////////////
/// This file contains the app side navigator classes
//////////////////////////////////////////////////////////
/// Includes
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:gea/includes/includes.dart';
import 'package:gea/includes/commonUtils.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_storage/firebase_storage.dart';

///////////////////////////////////////////////////////////
/// Main PROFILE widget.
/// Show some info about the user
//////////////////////////////////////////////////////////
class MyProfile extends StatefulWidget {
  MyProfile({Key key, this.uid}) : super(key: key);
  final String uid;
  @override
  MyProfileState createState() => MyProfileState();
}

class MyProfileState extends State<MyProfile> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference dbRef = FirebaseFirestore.instance.collection('users');
  CollectionReference dbRefEx =
      FirebaseFirestore.instance.collection('executions');
  var email;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};
    try {
      deviceData = readAndroidBuildData(await deviceInfo.androidInfo);
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    if (!mounted) return;
    setState(() {
      _deviceData = deviceData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
              decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [GEA_COLOR, GEA_COLOR],
                      begin: Alignment.topCenter,
                      end: Alignment.center)),
              child: Container(
                width: double.infinity,
                height: 350.0,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
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
                                    fontSize: 36,
                                    color: GEA_COLOR,
                                  ),
                                );
                              } else {
                                return Text("");
                              }
                            }),
                        radius: 50.0,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                "${snapshot.data['name']} ${snapshot.data['surname']}",
                                style: new TextStyle(
                                    fontSize: 18.0,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? GEA_DARK
                                        : GEA_LIGHT,
                                    fontWeight: FontWeight.bold),
                              );
                            } else {
                              return Text(
                                "",
                                style: new TextStyle(
                                    fontSize: 18.0,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? GEA_DARK
                                        : GEA_LIGHT,
                                    fontWeight: FontWeight.bold),
                              );
                            }
                          }),
                      SizedBox(
                        height: 10.0,
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 5.0),
                        clipBehavior: Clip.antiAlias,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GEA_DARK
                            : GEA_LIGHT,
                        elevation: 5.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 22.0),
                          child: Row(
                            children: <Widget>[
                              showDeviceInfo('Device', 'device'),
                              showDeviceInfo('Model', 'model'),
                              showDeviceInfo('Android', 'version.release'),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )),
          Container(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  infoEmail(Icons.email),
                  //infoText(Icons.chat_bubble, '     Feedback'),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Container(
            width: 300.00,
            padding: EdgeInsets.only(left: 50.0, right: 50.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                elevation: 0.0,
              ),
              onPressed: () {
                resetPassword(context);
              },
              child: Ink(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Change Password",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Container(
            width: 300.00,
            padding: EdgeInsets.only(left: 50.0, right: 50.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                elevation: 0.0,
              ),
              onPressed: () {
                deleteAccount(context);
              },
              child: Ink(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Delete Account",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showDeviceInfo(String header, String field) => new Expanded(
          child: new Column(
        children: <Widget>[
          new Text(header),
          new SizedBox(
            height: 8.0,
          ),
          new Text(
            '${_deviceData[field]}',
            style: new TextStyle(
                fontSize: 14.0,
                color: const Color.fromRGBO(0, 191, 165, 1),
                fontWeight: FontWeight.bold),
          )
        ],
      ));

  Widget infoEmail(IconData icon) => new Padding(
        padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 8.0),
        child: new InkWell(
          child: new Row(
            children: <Widget>[
              new Icon(
                icon,
                color: GEA_COLOR,
                size: 36.0,
              ),
              new StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      email = snapshot.data['email'];
                      return Text("     " + snapshot.data['email']);
                    } else {
                      return Text("");
                    }
                  }),
            ],
          ),
          onTap: () {
            print('Info Object selected');
          },
        ),
      );

  Widget infoText(IconData icon, String data) => new Padding(
        padding: const EdgeInsets.only(left: 40.0, right: 40.0, bottom: 8.0),
        child: new InkWell(
          child: new Row(
            children: <Widget>[
              new Icon(
                icon,
                color: GEA_COLOR,
                size: 36.0,
              ),
              new Text(data),
            ],
          ),
          onTap: () {
            print('Info Object selected');
          },
        ),
      );

  void deleteAccount(BuildContext context) {
    var alert = AlertDialog(
      title: Text(
        'Delete Account',
        style: new TextStyle(color: GEA_COLOR, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
                'Are you sure you want to delete your account? All your data will be deleted, including all executions. Once done, they cannot be recovered. App will close.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Delete',
            style: new TextStyle(
                fontSize: 14.0, color: GEA_COLOR, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            // Remove all elements from logs in executions
            Future<QuerySnapshot> logs =
                dbRefEx.doc(widget.uid).collection("logs").get();
            logs.then((value) {
              value.docs.forEach((element) {
                dbRefEx
                    .doc(widget.uid)
                    .collection("logs")
                    .doc(element.id)
                    .delete()
                    .then((value) => print("success"));
              });
            });
            // Remove doc from executions table
            dbRefEx.doc(widget.uid).delete();
            // Remove all files from storage
            ListResult res = await FirebaseStorage.instance
                .ref()
                .child(widget.uid.toString())
                .listAll();
            res.items.forEach((Reference ref) {
              ref.delete();
            });
            // Remove folder from storage
            Reference ref =
                FirebaseStorage.instance.ref().child(widget.uid.toString());
            ref.delete();
            // Remove doc from users table
            dbRef.doc(widget.uid).delete();
            // Delete account
            firebaseAuth.currentUser.delete().then((result) {
              firebaseAuth.signOut().then((res) {
                SystemNavigator.pop(animated: true);
              });
            }).catchError((err) {
              print(err.message);
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

  void resetPassword(context) {
    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((doc) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Reset Password',
                style: new TextStyle(
                    color: GEA_COLOR, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('A password reset link has been sent to $email'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Close App and Logout',
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: GEA_COLOR,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    FirebaseAuth auth = FirebaseAuth.instance;
                    auth.signOut().then((res) {
                      SystemNavigator.pop(animated: true);
                      /*Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignIn()),
                      (Route<dynamic> route) => false);*/
                    });
                  },
                ),
              ],
            );
          });
    }).catchError((err) {
      print(err.message);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }
}
