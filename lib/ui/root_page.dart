import 'package:flutter/material.dart';
import 'package:stock_tracker/auth/auth_provider.dart';
import 'package:stock_tracker/ui/login_page.dart';
import 'package:stock_tracker/ui/stock_list/stock_page.dart';
import 'package:stock_tracker/ui/home_page.dart';

// Enum that drives flow of which page to show
enum AuthState { signedIn, notSignedIn }

class RootPage extends StatefulWidget {

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {

  // Set user state (based on enum).
  AuthState _authState = AuthState.notSignedIn;

  //------------------------------------------------------
  // Access to the AuthProvider InhertitedWidget cannot
  // be done from within initState().
  //------------------------------------------------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //------------------------------------------------------
    // Because didChangeDependencies() is not declared as 
    // async method, we can't use await as part of the 
    // call to currentUser(). The alternative is to use
    // 'then' which registers a callback to be called when 
    // the currentUser() Future returns.
    //------------------------------------------------------
    AuthProvider.of(context).baseAuth.currentUser().then((uid) {
      setState(() {
        _authState = (uid == null) ? AuthState.notSignedIn : AuthState.signedIn;
      });
    });
  }

  //------------------------------------------------------
  // Callback function after successful login.
  // Called from LoginPage().
  //------------------------------------------------------
  void _successfulLogin() {
    setState(() {
      _authState = AuthState.signedIn;
    });
  }

  //------------------------------------------------------
  // Callback function after successful logout.
  // Called from HomePage()
  //------------------------------------------------------
  void _successfulSignOut() {
    setState(() {
      _authState = AuthState.notSignedIn;
    });
  }

  //------------------------------------------------------
  // Build widget.
  //------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Notice callback functions passed into pages.
    switch (_authState) {
      case AuthState.notSignedIn:
        return LoginPage(
          onSuccessfulLogin: _successfulLogin,
        );
      case AuthState.signedIn:
        return StockPage(onSuccessfulLogout: _successfulSignOut);
    }
  }
}
