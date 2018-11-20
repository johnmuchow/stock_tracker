import 'package:flutter/material.dart';
import 'package:stock_tracker/auth/auth_provider.dart';

class HomePage extends StatelessWidget {
  HomePage({this.onSuccessfulLogout});

  // Callback to root_page upon successful logout.
  final VoidCallback onSuccessfulLogout;

  //------------------------------------------------------
  // Firebase logout and callback to root_page.
  //------------------------------------------------------
  void _signout(BuildContext context) async {
    try {
      await AuthProvider.of(context).baseAuth.signOut();
      onSuccessfulLogout();
    } catch (e) {
      print(e);
    }
  }

  //------------------------------------------------------
  // Build widget.
  //------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () => _signout(context),
          ),
        ],
      ),
      body: new Container(
        child: Center(
          child: Text(
            'Welcome',
            style: TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }
}
