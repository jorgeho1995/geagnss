///////////////////////////////////////////////////////////
/// This file contains main app launcher
//////////////////////////////////////////////////////////
/// Includes
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gea/navigator/navigation.dart';
import 'package:gea/user_control/signin.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gea/includes/includes.dart';
import 'package:wakelock/wakelock.dart';

///////////////////////////////////////////////////////////
/// Main function, launch the app
//////////////////////////////////////////////////////////
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().then((value) => runApp(GeaApp()));
}

///////////////////////////////////////////////////////////
/// Main GEA application widget.
//////////////////////////////////////////////////////////
class GeaApp extends StatelessWidget {
  static const String _title = 'GEA';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Wakelock.enable();
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        accentColor: GEA_COLOR,
        secondaryHeaderColor: GEA_COLOR,
        textTheme: TextTheme(
          button: TextStyle(color: GEA_COLOR),
        ),
        primaryColor: GEA_COLOR,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: GEA_COLOR,
        secondaryHeaderColor: GEA_COLOR,
        textTheme: TextTheme(
          button: TextStyle(color: GEA_COLOR),
        ),
        primaryColor: GEA_COLOR,
      ),
      title: _title,
      home: new Splash(),
    );
  }
}

///////////////////////////////////////////////////////////
/// Class for splash screen window
//////////////////////////////////////////////////////////
class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> with AfterLayoutMixin<Splash> {
  /// Check intro screen with shared preferences
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('introScreen') ?? false);
    int _proc = (prefs.getInt('isProcessing') ?? NO_LAUNCH);
    String _fileName = (prefs.getString('fileName') ?? "none");
    if (_proc != NO_LAUNCH) {
      await prefs.setInt('isProcessing', NO_LAUNCH);
      await prefs.setStringList('rtTrackedSats', ['null']);
      await prefs.setStringList('rtPosition', ['null']);
    }
    if (_fileName != "none") {
      await prefs.setString('fileName', "none");
    }
    if (_seen) {
      User result = FirebaseAuth.instance.currentUser;
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (context) =>
              result != null ? GeaStatefulWidget(uid: result.uid) : SignIn()));
    } else {
      await prefs.setBool('introScreen', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new WelcomePage()));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: GEA_BACK_COLOR,
      body: new Center(
        child: new Text(''),
      ),
    );
  }
}

///////////////////////////////////////////////////////////
/// Class for welcome page in case of first initialization
//////////////////////////////////////////////////////////
class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  _getPermission() async {
    await Permission.location.request();
    await Permission.storage.request();
  }

  void _onIntroEnd(context) {
    User result = FirebaseAuth.instance.currentUser;
    _getPermission();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                result != null ? GeaStatefulWidget(uid: result.uid) : SignIn()),
        (Route<dynamic> route) => false);
  }

  Widget _buildImage(String assetName, [double width = 200]) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: Image.asset('assets/images/$assetName', width: width));
  }

  @override
  Widget build(BuildContext context) {
    var pageDecoration = PageDecoration(
      titleTextStyle: GoogleFonts.pacifico(
          textStyle: TextStyle(fontSize: 32.0, color: GEA_COLOR)),
      bodyTextStyle: TextStyle(
          fontSize: 19.0, fontWeight: FontWeight.w700, color: GEA_COLOR),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.zero,
      footerPadding: EdgeInsets.symmetric(vertical: 0.0),
    );
    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: GEA_BACK_COLOR,
      pages: [
        PageViewModel(
          title: "Welcome to GEA!",
          body:
              "GEA is a Cloud Computing app which allows you to get the most out of the GNSS data from your smartphone.",
          image: _buildImage('gea_icon.jpeg'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "GNSS Status",
          body:
              "Access the GNSS Status of your device. Check the state of the sky for the constellations of GPS, Galileo, GLONASS and Beidou.",
          image: _buildImage('status.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "GNSS Logger",
          body:
              "Capture raw data from your device and store it in your account.",
          image: _buildImage("log_icon.png"),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Real Time",
          body:
              "Launch real-time executions using Single, RTK or PPP. All your executions will be registered in your account.",
          image: _buildImage("rt_icon.png"),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Are you ready?",
          body:
              "Sign in or create your account and start logging your activity. To use the app it is required that you accept the location and storage permissions.",
          image: _buildImage('gea_icon.jpeg'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      skip: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
          elevation: 0.0,
        ),
        child: Ink(
          child: Container(
            constraints: BoxConstraints(maxWidth: 40.0, minHeight: 30.0),
            alignment: Alignment.center,
            child: Text(
              "Skip",
              style: TextStyle(color: GEA_COLOR, fontSize: 16.0),
            ),
          ),
        ),
      ),
      next: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
          elevation: 0.0,
        ),
        child: Ink(
          child: Container(
            constraints: BoxConstraints(maxWidth: 40.0, minHeight: 30.0),
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_forward,
              color: GEA_COLOR,
            ),
          ),
        ),
      ),
      done: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
          elevation: 0.0,
        ),
        child: Ink(
          child: Container(
            constraints: BoxConstraints(maxWidth: 40.0, minHeight: 30.0),
            alignment: Alignment.center,
            child: Text(
              "Done",
              style: TextStyle(color: GEA_COLOR, fontSize: 16.0),
            ),
          ),
        ),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeColor: GEA_COLOR,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
