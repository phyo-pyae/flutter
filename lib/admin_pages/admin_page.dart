import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phyopyaewa_logistics/admin_pages/admin_jobs_page.dart';
import 'package:phyopyaewa_logistics/app/home/account/account_page.dart';
import 'package:phyopyaewa_logistics/app/home/entries/entries_page.dart';
import 'package:provider/provider.dart';
import '../landing_page.dart';

import 'package:phyopyaewa_logistics/common_widgets/dismissable_second_background.dart';
import 'package:phyopyaewa_logistics/common_widgets/show_alert_dialog.dart';
import 'package:phyopyaewa_logistics/common_widgets/show_excepotion_alert_dialog.dart';
import 'package:phyopyaewa_logistics/services/auth.dart';
import 'package:phyopyaewa_logistics/services/database.dart';
import 'package:phyopyaewa_logistics/services/firestore_service.dart';

import '../app/home/cupertino_home_scaffold.dart';
import '../app/home/job_entries/job_entries_page.dart';
import '../app/home/jobs/edit_job_page.dart';
import '../app/home/jobs/job_list_tile.dart';
import '../app/home/jobs/jobs_page.dart';
import '../app/home/jobs/list_items_builder.dart';
import '../app/home/models/job.dart';
import '../app/home/tab_item.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
      await FirebaseAuth.instance.currentUser?.reload();
    } catch (e) {
      //print(e);
    }
  }

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    return {
      //giving provider
      // TabItem.jobs: (_) => Provider<Database>(
      //       create: (_) =>
      //           FirestoreDatabase(uid: FirebaseAuth.instance.currentUser.uid),
      //       child: JobsPage(),
      //     ),

      TabItem.jobs: (_) => AdminJobsPage(),
      TabItem.entries: (_) => EntriesPage.create(context),
      TabItem.account: (_) => AccountPage(),
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
