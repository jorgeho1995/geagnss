///////////////////////////////////////////////////////////
/// This file contains the app about
//////////////////////////////////////////////////////////
/// Includes
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gea/includes/includes.dart';

///////////////////////////////////////////////////////////
/// Main ABOUT widget.
/// Show some info about the app
//////////////////////////////////////////////////////////
class AboutPage extends StatelessWidget {
  launchMailto() async {
    final mailtoLink = Mailto(
      to: [GEA_EMAIL],
      subject: 'Add amazing subject',
      body: 'Add amazing body',
    );
    await launch('$mailtoLink');
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
                height: 300.0,
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
                        backgroundImage:
                            AssetImage("assets/images/gea_icon.jpeg"),
                        radius: 50.0,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "GEA",
                        style: new TextStyle(
                            fontSize: 18.0,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? GEA_DARK
                                    : GEA_LIGHT,
                            fontWeight: FontWeight.bold),
                      ),
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
                              showCard('App Version', GEA_VERSION),
                              showCard('Last Update', GEA_RELEASE_DATE),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )),
          Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  DefaultTabController(
                      length: 2, // length of tabs
                      initialIndex: 0,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              child: TabBar(
                                labelColor: GEA_COLOR,
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: GEA_COLOR,
                                tabs: [
                                  Tab(text: 'Information'),
                                  Tab(text: 'Privacy Policy'),
                                ],
                              ),
                            ),
                            Container(
                                height: 400, //height of TabBarView
                                child: TabBarView(children: <Widget>[
                                  Container(
                                    child: ListView(children: <Widget>[
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      ListTile(
                                        title: Text('What is GEA?'),
                                        subtitle: Text(
                                            'GEA is a Cloud Computing app which allows '
                                            'you to get the most out of the GNSS data from your smartphone.\n'
                                            'Allows access to the GNSS Status of your device, and '
                                            'Check the state of the sky for the constellations of GPS, Galileo, GLONASS and Beidou.\n'
                                            'For the execution of scenarios using the RTK or PPP methodology, the RTKLib software is used.',
                                            textAlign: TextAlign.justify),
                                      ),
                                      ListTile(
                                        title: Text('Software'),
                                        subtitle: Text(
                                            'This application is free software and '
                                            'can be used free of charge. We intend to keep it free, '
                                            'maintain it, and improve it. '
                                            'If you find bugs or want to request a feature, '
                                            'feel free to E-Mail us this information.',
                                            textAlign: TextAlign.justify),
                                      ),
                                      ListTile(
                                        title: Center(
                                          child: InkWell(
                                            child: new Text(GEA_EMAIL,
                                                style: TextStyle(
                                                  color: GEA_COLOR,
                                                )),
                                            onTap: () => launchMailto(),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                  Container(
                                    child: ListView(children: <Widget>[
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      ListTile(
                                        title: Text('User Account'),
                                        subtitle: Text(
                                            'A user account is required to provide functions that access our server.\n'
                                            'To create an account you only need a username, a password and a valid email address.\n'
                                            "The database is hosted on Firebase, therefore all personal data is protected under Google's security.\n"
                                            "The E-Mail address used will not be disclosed to third parties.",
                                            textAlign: TextAlign.justify),
                                      ),
                                    ]),
                                  ),
                                ]))
                          ])),
                ]),
          ),
          SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  Widget showCard(String header, String field) => new Expanded(
          child: new Column(
        children: <Widget>[
          new Text(header),
          new SizedBox(
            height: 8.0,
          ),
          new Text(
            field,
            style: new TextStyle(
                fontSize: 14.0, color: GEA_COLOR, fontWeight: FontWeight.bold),
          ),
        ],
      ));
}
