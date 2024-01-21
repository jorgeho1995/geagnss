///////////////////////////////////////////////////////////
/// This file contains the Reset password window
//////////////////////////////////////////////////////////
/// Includes
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gea/includes/includes.dart';

///////////////////////////////////////////////////////////
/// Main RESET PASSWORD widget.
/// This window allows the user to get an email for pass reset
//////////////////////////////////////////////////////////
class ResetPass extends StatefulWidget {
  @override
  _ResetPassState createState() => _ResetPassState();
}

/// This is the private State class that goes with ResetPass.
class _ResetPassState extends State<ResetPass> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Widget _email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? GEA_DARK
                : GEA_LIGHT,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? GEA_DARK
                : GEA_LIGHT,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60.0,
          child: TextFormField(
            cursorColor: GEA_COLOR,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? GEA_LIGHT
                  : GEA_DARK,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.blueAccent,
              ),
              hintText: 'Enter your Email',
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Enter Email Address';
              } else if (!value.contains('@')) {
                return 'Please enter a valid email address!';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _resetBtn() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      child: isLoading
          ? Container(
              padding: EdgeInsets.all(9.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
              ),
            )
          : Container(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 5.0,
                  padding: EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? GEA_DARK
                          : GEA_LIGHT,
                ),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    resetPassword();
                  }
                },
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: GEA_COLOR,
                    letterSpacing: 1.5,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _signIn() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Return to ',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? GEA_DARK
                    : GEA_LIGHT,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign In',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? GEA_DARK
                    : GEA_LIGHT,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                color: GEA_COLOR,
              ),
              Container(
                height: double.infinity,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 120.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Reset Password',
                            style: GoogleFonts.pacifico(
                              textStyle: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? GEA_DARK
                                    : GEA_LIGHT,
                                fontSize: 30.0,
                              ),
                            )),
                        _email(),
                        SizedBox(
                          height: 10.0,
                        ),
                        _resetBtn(),
                        _signIn(),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void resetPassword() {
    FirebaseAuth.instance
        .sendPasswordResetEmail(email: emailController.text)
        .then((doc) {
      setState(() {
        isLoading = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Reset Password',
                style: new TextStyle(
                    color: GEA_COLOR, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                        'A password reset link has been sent to ${emailController.text}'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Go to Log In',
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: GEA_COLOR,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                ),
              ],
            );
          });
    }).catchError((err) {
      print(err.message);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      isLoading = false;
                    });
                  },
                )
              ],
            );
          });
    });
  }
}
