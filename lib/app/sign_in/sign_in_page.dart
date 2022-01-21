import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phyopyaewa_logistics/app/sign_in/sign_in_manager.dart';
import 'package:phyopyaewa_logistics/common_widgets/show_excepotion_alert_dialog.dart';
import 'package:phyopyaewa_logistics/services/auth.dart';

import 'sign_in_button.dart';
import 'social_sign_in_button.dart';
import 'package:phyopyaewa_logistics/app/sign_in/email_sign_in_page.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({
    Key key,
    @required this.manager,
    @required this.isLoading,
  }) : super(key: key);
  final SignInManager manager;
  final bool isLoading;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, isLoading, __) => Provider<SignInManager>(
          create: (_) => SignInManager(auth: auth, isLoading: isLoading),
          child: Consumer<SignInManager>(
            builder: (_, manager, __) => SignInPage(
              manager: manager,
              isLoading: isLoading.value,
            ),
          ),
        ),
      ),
    );
  }

  void _showSignInError(BuildContext context, Exception exception) {
    if (exception is FirebaseException &&
        exception.code == 'ERROR_ABORTED_BY_USER') {
      return;
    }
    showExceptionAlertDialog(
      context,
      title: 'Sign in failed',
      exception: exception,
    );
  }

  void _signInWithEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => EmailSignInPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // we use Provider.of<ValueNotifier<bool>>(context)
    // not listen: false because it is intentional
    // so that the SignInPage rebuilds when the value changes

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Phyo Pyae Wa'),
      //   elevation: 2.0,
      // ),
      body: _buildContent(context),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 50,
            child: _buildHeader(),
          ),
          SizedBox(
            height: 40,
          ),
          SignInButton(
            text: 'Log in',
            textColor: Colors.white,
            color: Colors.indigo[500],
            onPressed: isLoading ? null : () => _signInWithEmail(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      'Phyo Pyae Wa',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.indigo[800],
        fontSize: 32.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
