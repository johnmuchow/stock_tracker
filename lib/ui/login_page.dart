import 'package:flutter/material.dart';
import 'package:stock_tracker/auth/auth_provider.dart';
import 'package:flutter/services.dart';

// Enum that drives fields on the login form.
enum FormAction { loginUser, createUser }

class LoginPage extends StatefulWidget {
  LoginPage({this.onSuccessfulLogin});

  // Callback to root_page upon successful login.
  final VoidCallback onSuccessfulLogin;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Identifier for the form to faciliate field validation.
  final formKey = GlobalKey<FormState>();

  // To facilitate showing snackbar messages.
  BuildContext _scaffoldContext;

  String _email;
  String _password;
  FormAction _formAction = FormAction.loginUser;

  //------------------------------------------------------
  // Show layout for creating a new user account.
  //------------------------------------------------------
  void changeToCreateAccountLayout() {
    // Clear the fields.
    formKey.currentState.reset();

    // Force a reload of UI.
    setState(() {
      _formAction = FormAction.createUser;
    });
  }

  //------------------------------------------------------
  // Show layout for user to login.
  //------------------------------------------------------
  void changeToLoginLayout() {
    // Clear the fields.
    formKey.currentState.reset();

    // Force a reload of UI.
    setState(() {
      _formAction = FormAction.loginUser;
    });
  }

  //------------------------------------------------------
  // Validate user email and password
  //------------------------------------------------------
  bool validateFields() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else
      return false;
  }

  //------------------------------------------------------
  // Button pressed, validate and take necessary action.
  //------------------------------------------------------
  void buttonPressed() async {
    if (validateFields()) {
      try {
        var auth = AuthProvider.of(context).baseAuth;

        if (_formAction == FormAction.loginUser) {
          String userId = await auth.signInWithEmailAndPassword(_email, _password);
          print('Userid: $userId');
        } else {
          String userId = await auth.createUserWithEmailAndPassword(_email, _password);
          print('Userid: $userId');
        }

        // Callback to root to inform root login is complete.
        widget.onSuccessfulLogin();
      } on PlatformException catch (e) {
        // Use the scaffold context saved previously.
        Scaffold.of(_scaffoldContext).showSnackBar(
          new SnackBar(
            backgroundColor: Colors.blueGrey[50],
            content: Text(e.details, style: TextStyle(color: Colors.blueGrey[700])),
          ),
        );
      }
    }
  }

  //------------------------------------------------------
  // Build widget.
  //------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: Text('Stock Tracker Login'),
      ),

      //------------------------------------------------------
      // Create a new Builder and save the context so
      // we can show snackbar messages elsewhere.
      //------------------------------------------------------
      body: Builder(builder: (BuildContext context) {
        // To facilitate showing snackbar messages.
        _scaffoldContext = context;
        return Container(
          padding: EdgeInsets.fromLTRB(20, 15, 30, 0),
          child: Form(
            key: formKey,
            child: Column(
              children: createUserInputFields() + createButtons(),
            ),
          ),
        );
      }),
    );
  }

  //------------------------------------------------------
  // Form fields for email and password.
  //------------------------------------------------------
  List<Widget> createUserInputFields() {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 7.0),
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          validator: (value) => value.isEmpty ? 'Please enter an email.' : null,
          onSaved: (value) => _email = value,
        ),
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        obscureText: true,
        validator: (value) => value.isEmpty ? 'Please enter a password.' : null,
        onSaved: (value) => _password = value,
      ),
    ];
  }

  //------------------------------------------------------
  // Create buttons depending on whether form will be
  // for login or create new user.
  //------------------------------------------------------
  List<Widget> createButtons() {
    if (_formAction == FormAction.loginUser) {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          child: RaisedButton(
            color: Colors.blue[800],
            child: Text(
              'Login',
              style: TextStyle(fontSize: 18.0),
            ),
            onPressed: buttonPressed,
          ),
        ),
        FlatButton(
          child: Text('Create an account.'),
          onPressed: changeToCreateAccountLayout,
        )
      ];
    } else {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          child: RaisedButton(
            child: Text(
              'Create an account',
              style: TextStyle(fontSize: 20.0),
            ),
            onPressed: buttonPressed,
          ),
        ),
        FlatButton(
          child: Text('I already have an account.'),
          onPressed: changeToLoginLayout,
        )
      ];
    }
  }
}
