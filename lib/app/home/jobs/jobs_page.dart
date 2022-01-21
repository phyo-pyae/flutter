import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phyopyaewa_logistics/app/home/job_entries/job_entries_page.dart';
import 'package:phyopyaewa_logistics/app/home/jobs/edit_job_page.dart';

import 'package:phyopyaewa_logistics/app/home/jobs/job_list_tile.dart';
import 'package:phyopyaewa_logistics/app/home/jobs/list_items_builder.dart';
import 'package:phyopyaewa_logistics/app/home/models/job.dart';
import 'package:phyopyaewa_logistics/landing_page.dart';
import 'package:phyopyaewa_logistics/app/sign_in/sign_in_page.dart';
import 'package:phyopyaewa_logistics/common_widgets/dismissable_second_background.dart';
import 'package:phyopyaewa_logistics/common_widgets/show_alert_dialog.dart';
import 'package:phyopyaewa_logistics/common_widgets/show_excepotion_alert_dialog.dart';
import 'package:phyopyaewa_logistics/services/auth.dart';
import 'package:phyopyaewa_logistics/services/database.dart';
import 'package:phyopyaewa_logistics/services/firestore_service.dart';
import 'dart:io';
import 'package:phyopyaewa_logistics/admin_pages/admin_page.dart';
import '../home_page.dart';
import 'package:phyopyaewa_logistics/services/api_path.dart';
import 'package:phyopyaewa_logistics/app/home/models/job.dart';

class JobsPage extends StatefulWidget {
  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  Database data;
  Job job;
  // Job.fromMap(data, documentId);

  Future addData() async {}
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _delete(BuildContext context, Job job) async {
    try {
      final database = Provider.of<Database>(context, listen: false);
      await database.deleteJob(job);
    } on FirebaseException catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Operation failed',
        exception: e,
      );
    }
  }

  Future getData(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    //reading no of documents in collections
    if (auth.currentUser.uid == 'dIppvBE6QHM1ouWKBibhTbCf6Lx1') {
      FirebaseFirestore.instance
          .collection('users/gDxt6nKtm0dXLTl2j9ZtHBuWZRI2/jobs')
          .get()
          .then(
        (QuerySnapshot querySnapshot) {
          print('${querySnapshot.size} ');
          querySnapshot.docs.forEach((doc) {
            print(
                //'${DateTime.parse(doc.id).microsecondsSinceEpoch}, ${doc.data()}');
                '${DateTime.parse(doc.id).day}, ${doc.data()} , ${doc.id}');
            Job testingdata = fromMap(doc.data(), doc.id);
            print(testingdata?.name);
            //print(testingdata);
          });
        },
      );
    } else {
      print('not admin');
    }
  }

  fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final int ratePerHour = data['ratePerHour'];
    return Job(
      id: documentId,
      name: name,
      ratePerHour: ratePerHour,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () => EditJobPage.show(
              context,
              database: Provider.of<Database>(context, listen: false),
            ),
            icon: Icon(Icons.add),
            color: Colors.white,
          ),
        ],
      ),
      body: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<Job>>(
      stream: database.jobsStream(),
      builder: (context, snapshot) {
        return ListItemsBuilder<Job>(
          snapshot: snapshot,
          itemBuilder: (context, job) => Dismissible(
            key: Key('job-${job.id}'), //for unique job id
            background: Container(color: Colors.red),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _delete(context, job),
            child: JobListTile(
              job: job,
              onTap: () => JobEntriesPage.show(context, job),
            ),
            secondaryBackground: Dismissable_Second_BackGround(),
          ),
        );
      },
    );
  }
}
