import 'package:flutter/material.dart';
import 'package:glove_app/widgets/yanamn_drawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  String fullName = '';
  String email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
      ),
      drawer: YanamnDrawer(fullName: fullName, email: email, selected: IsSelected.Properties),
      body: Center(child: Text('Settings Page')),
    );
  }
}