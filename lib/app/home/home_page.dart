import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phyopyaewa_logistics/app/home/account/account_page.dart';
import 'package:phyopyaewa_logistics/app/home/entries/entries_page.dart';
import 'package:phyopyaewa_logistics/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:phyopyaewa_logistics/app/home/cupertino_home_scaffold.dart';
import 'package:phyopyaewa_logistics/app/home/tab_item.dart';
import 'package:phyopyaewa_logistics/services/auth.dart';
import 'package:phyopyaewa_logistics/services/database.dart';

import 'jobs/jobs_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab = TabItem.jobs;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.jobs: GlobalKey<NavigatorState>(),
    TabItem.entries: GlobalKey<NavigatorState>(),
    TabItem.account: GlobalKey<NavigatorState>(),
  };

  Timer timer;

  void initState() {
    super.initState();
    var timer = Timer.periodic(Duration(seconds: 2), (Timer t) => checkAuth());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkAuth() async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.currentUser?.reload();
    } catch (e) {
      //print(e);
    }
  }

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return {
      //giving provider
      // TabItem.jobs: (_) => Provider<Database>(
      //       create: (_) =>
      //           FirestoreDatabase(uid: FirebaseAuth.instance.currentUser.uid),
      //       child: JobsPage(),
      //     ),

      TabItem.jobs: (_) => JobsPage(),
      TabItem.entries: (_) => EntriesPage.create(context),
      TabItem.account: (_) => Provider<FirestoreServiceImage>(
            create: (_) => FirestoreServiceImage(uid: auth.currentUser.uid),
            child: AccountPage(),
          ),
      //TabItem.account: (_) => AccountPage(),
    };
  }

  void _select(TabItem tabItem) {
    if (tabItem == _currentTab) {
      //pop to first route
      navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !await navigatorKeys[_currentTab]
          .currentState
          .maybePop(), //more than one route //pop and return true
      //only one route // no pop and return false
      child: CupertinoHomeScaffold(
        currentTab: _currentTab,
        onSelectTab: _select,
        widgetBuilders: widgetBuilders,
        navigatorKeys: navigatorKeys,
      ),
    );
  }
}