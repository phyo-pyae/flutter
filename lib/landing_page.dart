import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phyopyaewa_logistics/admin_pages/admin_database/admin_database.dart';
import 'package:provider/provider.dart';
import 'admin_pages/admin_page.dart';
import 'package:phyopyaewa_logistics/app/home/home_page.dart';

import 'package:phyopyaewa_logistics/app/sign_in/sign_in_page.dart';
import 'package:phyopyaewa_logistics/services/auth.dart';
import 'package:phyopyaewa_logistics/services/database.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return StreamBuilder<User>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User user = snapshot.data;
          // user.reload();
          // user = auth.currentUser;
          //isLoggedIn
          if (user == null) {
            return SignInPage.create(context);
          }

          if (snapshot.data?.uid == 'dIppvBE6QHM1ouWKBibhTbCf6Lx1') {
            //this is for admin screen
            final List<String> uidList = [
              'Vnz17OOJTrVJBhG7QJ9zFjsR3bS2',
              'gDxt6nKtm0dXLTl2j9ZtHBuWZRI2',
            ];
            return Provider<Database>(
                create: (_) => FirestoreDatabase(uid: user.uid),
                child: AdminPage());
            //replace AdminPage() with HomePage configured for buttom navigator tab
          }
          // auth.currentUser.reload());

          return Provider<Database>(
            create: (_) => FirestoreDatabase(uid: user.uid),
            child: HomePage(),
          );
        }
        if (Platform.isIOS) {
          return Scaffold(
            body: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
