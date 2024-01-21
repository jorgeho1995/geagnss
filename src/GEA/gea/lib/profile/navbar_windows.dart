///////////////////////////////////////////////////////////
/// This file contains the app side navigator classes
//////////////////////////////////////////////////////////
/// Includes
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gea/includes/includes.dart';
import 'package:gea/profile/about.dart';
import 'package:gea/profile/profile.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gea/profile/settings.dart';

///////////////////////////////////////////////////////////
/// PROFILE
/// Displays the profile of the user
//////////////////////////////////////////////////////////
class Profile extends StatelessWidget {
  Profile({Key key, this.uid}) : super(key: key);
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        backgroundColor: GEA_COLOR,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? GEA_DARK
              : GEA_LIGHT,
        ),
      ),
      body: MyProfile(uid: uid),
    );
  }
}

///////////////////////////////////////////////////////////
/// SETTINGS
/// Displays the settings of the app
//////////////////////////////////////////////////////////
class SettingsMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: GoogleFonts.pacifico(
              textStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? GEA_DARK
                    : GEA_LIGHT,
                //fontSize: 30.0,
              ),
            )),
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        backgroundColor: GEA_COLOR,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? GEA_DARK
              : GEA_LIGHT,
        ),
      ),
      //body: Settings(),
    );
  }
}

///////////////////////////////////////////////////////////
/// WEBSITE
/// Displays the website
//////////////////////////////////////////////////////////
class Website extends StatelessWidget {
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
        ),
        body: WebView(
          initialUrl: GEA_URL,
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}

///////////////////////////////////////////////////////////
/// ABOUT
/// Displays a summary of the app
//////////////////////////////////////////////////////////
class About extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        backgroundColor: GEA_COLOR,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? GEA_DARK
              : GEA_LIGHT,
        ),
      ),
      body: AboutPage(),
    );
  }
}
