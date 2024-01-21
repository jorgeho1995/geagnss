///////////////////////////////////////////////////////////
/// This file contains map window
//////////////////////////////////////////////////////////
/// Includes
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gea/includes/includes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

///////////////////////////////////////////////////////////
/// Main MAP widget.
//////////////////////////////////////////////////////////
class CreateMap extends StatefulWidget {
  CreateMap({Key key, this.rtPosition}) : super(key: key);
  static Route<dynamic> route() => MaterialPageRoute(
        builder: (context) => CreateMap(),
      );
  final List<String> rtPosition;

  @override
  _CreateMapState createState() => _CreateMapState();
}

class _CreateMapState extends State<CreateMap> with WidgetsBindingObserver {
  MapType _defaultMapType = MapType.normal;
  Completer<GoogleMapController> _controller = Completer();
  String _darkMapStyle;
  String _lightMapStyle;
  Location location;
  LocationData currentLocation;
  bool located = false;
  Map<MarkerId, Marker> rtPoints = <MarkerId, Marker>{};
  BitmapDescriptor singleIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor rtkIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor pppIcon = BitmapDescriptor.defaultMarker;
  SharedPreferences prefs;
  var msgLegend = "No RT Running";
  var iconLegend = Icons.map_rounded;
  var colorLegend = Colors.black54;
  var lastLat = 0.0;
  var lastLon = 0.0;
  bool _updateCam = true;

  @override
  void initState() {
    super.initState();
    addSingleIcon();
    addRTKIcon();
    addPPPIcon();
    WidgetsBinding.instance.addObserver(this);
    _loadMapStyles();
    location = new Location();
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updateMapCamera();
    });
    setInitialLocation();
  }

  void setInitialLocation() async {
    currentLocation = await location.getLocation();
  }

  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/json/night.json');
    _lightMapStyle = await rootBundle.loadString('assets/json/light.json');
  }

  Future _setMapStyle() async {
    final controller = await _controller.future;
    final theme = Theme.of(context).brightness;
    if (theme == Brightness.dark)
      controller.setMapStyle(_darkMapStyle);
    else
      controller.setMapStyle(_lightMapStyle);
  }

  void addSingleIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/images/single_marker.png")
        .then(
      (icon) {
        setState(() {
          singleIcon = icon;
        });
      },
    );
  }

  void addRTKIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/images/rtk_marker.png")
        .then(
      (icon) {
        setState(() {
          rtkIcon = icon;
        });
      },
    );
  }

  void addPPPIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/images/ppp_marker.png")
        .then(
      (icon) {
        setState(() {
          pppIcon = icon;
        });
      },
    );
  }

  void _checkRTPosition() async {
    prefs = await SharedPreferences.getInstance();
    int _proc = (prefs.getInt('isProcessing') ?? NO_LAUNCH);
    BitmapDescriptor icon = singleIcon;
    var iconD = Icons.map_rounded;
    var colorD = Colors.black54;
    var msg = 'No RT Running';
    switch (_proc) {
      case SINGLE_LAUNCH:
        icon = singleIcon;
        msg = 'Single';
        iconD = SINGLE_ICON;
        colorD = SINGLE_COLOR;
        break;
      case RTK_LAUNCH:
        icon = rtkIcon;
        msg = 'RTK';
        iconD = RTK_ICON;
        colorD = RTK_COLOR;
        break;
      case PPP_LAUNCH:
        icon = pppIcon;
        msg = 'PPP';
        iconD = PPP_ICON;
        colorD = PPP_COLOR;
        break;
      case NO_LAUNCH:
      default:
        icon = singleIcon;
        msg = 'No RT Running';
        iconD = Icons.map_rounded;
        colorD = Colors.black54;
        setState(() {
          _updateCam = true;
        });
        break;
    }
    setState(() {
      msgLegend = msg;
      iconLegend = iconD;
      colorLegend = colorD;
    });
    // Check if there is any RT running and plot the position
    if (widget.rtPosition.length != null && widget.rtPosition[0] != 'null') {
      var lat = 0.0;
      var lon = 0.0;
      for (int i = 0; i < widget.rtPosition.length; i++) {
        var values =
            widget.rtPosition[i].split('[')[1].split(']')[0].split(',');
        lat = double.parse(values[0]);
        lon = double.parse(values[1]);
        final String markerIdVal = 'rt_id_$i';
        final MarkerId markerId = MarkerId(markerIdVal);
        final Marker marker = Marker(
            markerId: markerId,
            position: LatLng(
              lat,
              lon,
            ),
            infoWindow: InfoWindow(
                title: msg,
                snippet:
                    'Lat: ${lat.toStringAsFixed(3)}º, Lon: ${lon.toStringAsFixed(3)}º'),
            icon: icon);
        setState(() {
          rtPoints[markerId] = marker;
        });
      }
      if ((lastLat != lat || lastLon != lon) && _updateCam) {
        updateMapCameraRT(lat, lon);
        lastLat = lat;
        lastLon = lon;
      }
    } else {
      setState(() {
        rtPoints = <MarkerId, Marker>{};
        lastLat = 0.0;
        lastLon = 0.0;
      });
    }
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _setMapStyle();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _changeMapType() {
    setState(() {
      _defaultMapType = _defaultMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition =
        CameraPosition(zoom: 0, target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM);
    }
    didChangePlatformBrightness();
    _checkRTPosition();
    return Stack(
      children: <Widget>[
        GoogleMap(
            mapType: _defaultMapType,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _setMapStyle();
            },
            onCameraMove: (CameraPosition cam) {
              setState(() {
                if (!msgLegend.contains('No RT Running')) {
                  _updateCam = false;
                }
              });
            },
            initialCameraPosition: initialCameraPosition,
            markers: Set<Marker>.of(rtPoints.values)),
        Container(
          margin: EdgeInsets.only(top: 60, right: 12),
          alignment: Alignment.topRight,
          child: Column(
            children: <Widget>[
              Container(
                width: 38.0,
                height: 38.0,
                child: FloatingActionButton(
                    child: _defaultMapType == MapType.normal
                        ? Icon(
                            Icons.map_rounded,
                            color: Colors.black54,
                          )
                        : Icon(
                            Icons.image_outlined,
                            color: Colors.black54,
                          ),
                    elevation: 5,
                    backgroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2.0))),
                    onPressed: () {
                      _changeMapType();
                      print('Changing the Map Type');
                    }),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 12, right: 62),
          alignment: Alignment.topRight,
          child: Column(
            children: <Widget>[
              Container(
                height: 38.0,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white70),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(80.0)))),
                    elevation: MaterialStateProperty.all(5),
                  ),
                  icon: Icon(
                    iconLegend,
                    color: colorLegend,
                  ),
                  label: Text(
                    msgLegend,
                    style: TextStyle(
                      color: colorLegend,
                    ),
                  ),
                  onPressed: () {
                    var alert = AlertDialog(
                      title: Text(
                        'Legend',
                        style: new TextStyle(
                            color: GEA_COLOR, fontWeight: FontWeight.bold),
                      ),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text(
                                'This indicator shows if Real Time is running and the current run type:\n'),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white70,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(80.0)),
                                elevation: 0.0,
                                side: BorderSide(
                                  color: Colors.white70,
                                ),
                              ),
                              onPressed: () {},
                              icon: Icon(
                                Icons.map_rounded,
                                color: Colors.black54,
                              ),
                              label: Text(
                                "No RT Running",
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white70,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(80.0)),
                                elevation: 0.0,
                                side: BorderSide(
                                  color: Colors.white70,
                                ),
                              ),
                              onPressed: () {},
                              icon: Icon(
                                SINGLE_ICON,
                                color: SINGLE_COLOR,
                              ),
                              label: Text(
                                "Single",
                                style: TextStyle(
                                  color: SINGLE_COLOR,
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
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 12, left: 54),
          alignment: Alignment.topLeft,
          child: Column(
            children: <Widget>[
              Container(
                height: 38.0,
                child: !_updateCam
                    ? ElevatedButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(GEA_COLOR),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)))),
                          elevation: MaterialStateProperty.all(5),
                        ),
                        icon: Icon(
                          Icons.navigation_outlined,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? GEA_LIGHT
                              : GEA_DARK,
                        ),
                        label: Text(
                          "Center",
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? GEA_LIGHT
                                    : GEA_DARK,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _updateCam = true;
                          });
                        },
                      )
                    : SizedBox(
                        height: 0.0,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void updateMapCameraRT(lat, lon) async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      target: LatLng(lat, lon),
    );
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(cPosition));
    located = true;
  }

  void updateMapCamera() async {
    if (!located) {
      CameraPosition cPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
      );
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
      located = true;
    }
  }
}
