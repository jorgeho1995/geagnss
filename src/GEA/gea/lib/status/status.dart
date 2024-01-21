///////////////////////////////////////////////////////////
/// This file contains the app navigator
//////////////////////////////////////////////////////////
/// Includes
import 'package:flutter/material.dart';
import 'package:gea/status/sats_status.dart';

///////////////////////////////////////////////////////////
/// Main Satellite Status widget.
/// This widget calls the Skyplot of the satellites.
//////////////////////////////////////////////////////////
class Status extends StatelessWidget {
  Status({Key key, this.rtTrackedSats, this.status}) : super(key: key);
  final List<String> rtTrackedSats;
  final List<Map<String, dynamic>> status;
  static Route<dynamic> route() => MaterialPageRoute(
        builder: (context) => Status(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SatsStatus(gnss: status, rtTrackedSats: rtTrackedSats),
    );
  }
}
