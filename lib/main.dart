import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phyopyaewa_logistics/services/auth.dart';
import 'package:provider/provider.dart';

import 'landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        // options: FirebaseOptions(
        //   apiKey: "AIzaSyBRSfCxPndLArYLK8tscBgbV1U8YzvPf1k",
        //   appId: "1:1026424689971:web:49d07b2d90b69f92e11a46",
        //   messagingSenderId: "1026424689971",
        //   projectId: "time-tracker-a0700",
        // ),
        );
  }
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthBase>(
      // return Provider<FirebaseAuth>(
      //   builder: (_) => FirebaseAuth.instance,
      create: (context) => Auth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Phyo Pyae Wa',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: LandingPage(),
      ),
    );
  }
}
