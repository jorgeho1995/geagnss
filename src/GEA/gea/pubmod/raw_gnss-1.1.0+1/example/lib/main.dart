import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raw_gnss/gnss_status_model.dart';
import 'package:raw_gnss/raw_gnss.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Demo"),
        ),
        body: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _hasPermissions = false;
  late RawGnss _gnss;

  @override
  void initState() {
    super.initState();

    _gnss = RawGnss();

    Permission.location
        .request()
        .then((value) => setState(() => _hasPermissions = value.isGranted));
  }

  @override
  Widget build(BuildContext context) => _hasPermissions
      ? StreamBuilder<GnssStatusModel>(
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return _loadingSpinner();
            } else {
              return ListView.builder(
                itemBuilder: (context, position) {
                  return ListTile(
                    title: Text(
                        "Satellite: ${snapshot.data!.status![position].azimuthDegrees}"),
                  );
                },
                itemCount: snapshot.data!.satelliteCount ?? 0,
              );
            }
          },
          stream: _gnss.gnssStatusEvents,
        )
      : _loadingSpinner();

  Widget _loadingSpinner() => const Center(child: CircularProgressIndicator());
}
