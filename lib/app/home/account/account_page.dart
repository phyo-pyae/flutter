import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phyopyaewa_logistics/app/home/account/report_page.dart';
import 'package:phyopyaewa_logistics/app/home/models/avatar_reference.dart';
import 'package:phyopyaewa_logistics/app/home/models/image.dart';
import 'package:phyopyaewa_logistics/app/home/models/job.dart';
import 'package:phyopyaewa_logistics/common_widgets/avatar.dart';
import 'package:phyopyaewa_logistics/services/database.dart';
import 'package:phyopyaewa_logistics/services/firebase_storage_service.dart';
import 'package:phyopyaewa_logistics/services/firestore_service.dart';
import 'package:phyopyaewa_logistics/services/image_picker_service.dart';
import 'package:provider/provider.dart';
import 'package:phyopyaewa_logistics/common_widgets/show_alert_dialog.dart';
import 'package:phyopyaewa_logistics/services/auth.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:async/async.dart';

// class  extends StatelessWidget {
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

class AccountPage extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(
      context,
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Logout',
    );
    if (didRequestSignOut == true) {
      _signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        actions: <Widget>[
          TextButton(
            onPressed: () => _confirmSignOut(context),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: _buildUserInfo(auth.currentUser, context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ReportPage(context: context)));
                  },
                  label: Text(
                    ' Issues',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  icon: Icon(
                    Icons.warning,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUserInfo(User user, BuildContext context) {
    return Column(
      children: <Widget>[
        // Avatar(
        //   onPressed: () => _chooseAvatar('gallery', context),
        //   photoUrl: user.photoURL,
        //   radius: 50,
        // ),
        SizedBox(height: 8),

        if (user.email != null)
          Text(
            user.email,
            style: TextStyle(color: Colors.white),
          ),
        SizedBox(height: 8),
      ],
    );
  }
}
