///////////////////////////////////////////////////////////
/// This file contains logger window
//////////////////////////////////////////////////////////
/// Includes
import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////
/// Main LOGGER widget.
//////////////////////////////////////////////////////////
class Logger extends StatelessWidget {
  Logger({Key key, this.gnss, this.clock}) : super(key: key);
  final List<Map<String, dynamic>> gnss;
  final Map<String, dynamic> clock;
  static Route<dynamic> route() => MaterialPageRoute(
        builder: (context) => Logger(),
      );

  @override
  Widget build(BuildContext context) {
    var gnssData = "Receiving Data...";
    var clockData = "Receiving Data...";
    if (clock != null) {
      clockData = clock.toString();
    }
    if (gnss != null) {
      gnssData = gnss.toString();
    }
    return new Scaffold(
      body: ListView(children: <Widget>[
        ListTile(
          title: Text('Clock'),
          subtitle: Text(clockData),
        ),
        ListTile(
          title: Text('Raw Data'),
          subtitle: Text(gnssData),
        ),
      ]),
    );
  }
}
