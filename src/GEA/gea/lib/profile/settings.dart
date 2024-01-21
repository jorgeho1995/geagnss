/*import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class Settings extends StatelessWidget {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SettingsList(
        backgroundColor: Theme.of(context).brightness ==
            Brightness.dark
            ? Color.fromRGBO(41, 41, 41, 1)
            : Colors.white,
        sections: [
          SettingsSection(
            titleTextStyle: TextStyle(color: Color.fromRGBO(0, 191, 165, 1),),
            titlePadding: EdgeInsetsDirectional.only(start:16, top: 16),
            title: 'Common',
            // titleTextStyle: TextStyle(fontSize: 30),
            tiles: [
              SettingsTile(
                title: 'Language',
                subtitle: 'English',
                leading: Icon(Icons.language),
              ),
              SettingsTile(
                title: 'Environment',
                subtitle: 'Production',
                leading: Icon(Icons.cloud_queue),
                onTap: () => print('e'),
              ),
            ],
          ),
          SettingsSection(
            titlePadding: EdgeInsetsDirectional.only(start:16, top: 16),
            titleTextStyle: TextStyle(color: Color.fromRGBO(0, 191, 165, 1),),
            title: 'Account',
            tiles: [
              SettingsTile(title: 'Phone number', leading: Icon(Icons.phone)),
              SettingsTile(title: 'Email', leading: Icon(Icons.email)),
              SettingsTile(title: 'Sign out', leading: Icon(Icons.exit_to_app)),
            ],
          ),
          SettingsSection(
            titlePadding: EdgeInsetsDirectional.only(start:16, top: 16),
            titleTextStyle: TextStyle(color: Color.fromRGBO(0, 191, 165, 1),),
            title: 'Security',
            tiles: [
              SettingsTile.switchTile(
                title: 'Lock app in background',
                leading: Icon(Icons.phonelink_lock),
                switchValue: lockInBackground,
                switchActiveColor: Color.fromRGBO(0, 191, 165, 1),
                onToggle: (bool value) {
                },
              ),
              SettingsTile.switchTile(
                  title: 'Use fingerprint',
                  leading: Icon(Icons.fingerprint),
                  switchActiveColor: Color.fromRGBO(0, 191, 165, 1),
                  onToggle: (bool value) {},
                  switchValue: false),
              SettingsTile.switchTile(
                title: 'Change password',
                leading: Icon(Icons.lock),
                switchActiveColor: Color.fromRGBO(0, 191, 165, 1),
                switchValue: true,
                onToggle: (bool value) {},
              ),
              SettingsTile.switchTile(
                title: 'Enable Notifications',
                enabled: notificationsEnabled,
                leading: Icon(Icons.notifications_active),
                switchActiveColor: Color.fromRGBO(0, 191, 165, 1),
                switchValue: true,
                onToggle: (value) {},
              ),
            ],
          ),
          SettingsSection(
            titlePadding: EdgeInsetsDirectional.only(start:16, top: 16),
            titleTextStyle: TextStyle(color: Color.fromRGBO(0, 191, 165, 1),),
            title: 'Misc',
            tiles: [
              SettingsTile(
                  title: 'Terms of Service', leading: Icon(Icons.description)),
              SettingsTile(
                  title: 'Open source licenses',
                  leading: Icon(Icons.collections_bookmark)),
            ],
          ),
        ],
      ),
    );
  }
}*/