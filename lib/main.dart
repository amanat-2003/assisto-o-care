import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './MainPage.dart';
import 'helper/helper_function.dart';
import 'pages/auth/login_register_page.dart';
import 'service/functions.dart';
import 'shared/constants.dart';

// void main() => runApp(new ExampleApplication());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // initialization for web
    await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: Constants.apiKey,
      appId: Constants.appId,
      messagingSenderId: Constants.messagingSenderId,
      projectId: Constants.projectId,
    ));
  } else {
    // initialization for android, iOS
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainPage());
  }
}


class MyApp extends StatefulWidget {

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async {
    // setState(() async {
    // _isSignedIn = (await HelperFunctions.getUserLoggedInStatus()) ?? false;
    // });
    var val = await HelperFunctions.getUserLoggedInStatus();
    if (val != null) {
      setState(() {
        _isSignedIn = val;
      });
    } else {
      setState(() {
        _isSignedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:
            createMaterialColor(const Color.fromARGB(255, 238, 104, 14)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: _isSignedIn ? MainPage() : LoginRegisterPage(),
      // home: const ButtonScreen(),
    );
  }
}
