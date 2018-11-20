import 'package:flutter/material.dart';
import 'package:stock_tracker/auth/authentication.dart';

//------------------------------------------------------
// To use this class:
//  AuthProvider.of(context).auth
//------------------------------------------------------
class AuthProvider extends InheritedWidget {
  
  //------------------------------------------------------
  // Inherited widget will need to have a child, specify 
  // that in the constructor.
  //------------------------------------------------------
  AuthProvider({Key key, Widget child, this.baseAuth}) : super(key: key, child: child);

  final BaseAuthentication baseAuth;

  //------------------------------------------------------
  // When widget is rebuilt, should widgets that inherit
  // from it be rebuilt.
  //------------------------------------------------------
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
   return true;
  }

  //------------------------------------------------------
  // A class method that obtains the nearest widget of 
  // AuthProvider type.
  //------------------------------------------------------
  static AuthProvider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(AuthProvider) as AuthProvider);
  }

}
