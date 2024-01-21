///////////////////////////////////////////////////////////
/// This file contains the SignUp window
//////////////////////////////////////////////////////////
/// Includes
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gea/includes/includes.dart';

///////////////////////////////////////////////////////////
/// Main Sign Up+ widget.
/// This window allows to create an account
//////////////////////////////////////////////////////////
class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

/// This is the private State class that goes with SignUp.
class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference dbRef = FirebaseFirestore.instance.collection('users');
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  bool isLoading = false;

  Widget _name() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Name',
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
            controller: nameController,
            keyboardType: TextInputType.name,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? GEA_LIGHT
                  : GEA_DARK,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.perm_identity,
                color: Colors.green,
              ),
              hintText: 'Enter your Name',
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Enter Name';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _lastName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Last Name',
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
            controller: surnameController,
            keyboardType: TextInputType.name,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? GEA_LIGHT
                  : GEA_DARK,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.perm_identity,
                color: Colors.orange,
              ),
              hintText: 'Enter your Last Name',
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Enter Last Name';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

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

  Widget _password() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
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
            controller: passwordController,
            obscureText: true,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? GEA_LIGHT
                  : GEA_DARK,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.redAccent,
              ),
              hintText: 'Enter your Password',
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Enter Password';
              } else if (value.length < 6) {
                return 'Password must be at least 6 characters!';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _confirmPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
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
            controller: confirmPasswordController,
            obscureText: true,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? GEA_LIGHT
                  : GEA_DARK,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.redAccent,
              ),
              hintText: 'Confirm your Password',
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Enter Password';
              } else if (value.length < 6) {
                return 'Password must be at least 6 characters!';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _signUpBtn() {
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
                  padding: EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? GEA_DARK
                          : GEA_LIGHT,
                  elevation: 5.0,
                ),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    registerToFb();
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
              text: 'Have an account? ',
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
                        Text('Sign Up',
                            style: GoogleFonts.pacifico(
                              textStyle: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? GEA_DARK
                                    : GEA_LIGHT,
                                fontSize: 30.0,
                              ),
                            )),
                        _name(),
                        _lastName(),
                        _email(),
                        _password(),
                        _confirmPassword(),
                        SizedBox(
                          height: 10.0,
                        ),
                        _signUpBtn(),
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

  void registerToFb() {
    if (passwordController.text == confirmPasswordController.text) {
      firebaseAuth
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then((result) {
        dbRef.doc(result.user.uid).set({
          "email": emailController.text,
          "name": nameController.text,
          "surname": surnameController.text,
          "rt_enabled": false,
          "clientRTKLIBPort": -1,
          "clientRTKLIBRecPort": -1
        }).then((res) {
          User user = FirebaseAuth.instance.currentUser;
          if (!user.emailVerified) {
            user.sendEmailVerification();
          }
          setState(() {
            isLoading = false;
          });
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Email Verification',
                    style: new TextStyle(
                        color: GEA_COLOR, fontWeight: FontWeight.bold),
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(
                            'A verification email has been sent to ${emailController.text}. Login to your email account and follow the validation steps, then come back to login.'),
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
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      },
                    ),
                  ],
                );
              });
        });
      }).catchError((err) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Error",
                  style: new TextStyle(
                      fontSize: 14.0,
                      color: GEA_COLOR,
                      fontWeight: FontWeight.bold),
                ),
                content: Text(err.message),
                actions: [
                  TextButton(
                    child: Text(
                      "Ok",
                      style: new TextStyle(
                          fontSize: 14.0,
                          color: GEA_COLOR,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      });
    } else {
      isLoading = false;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "Error",
                style: new TextStyle(
                    fontSize: 14.0,
                    color: GEA_COLOR,
                    fontWeight: FontWeight.bold),
              ),
              content: Text("The Password Confirmation does not match"),
              actions: [
                TextButton(
                  child: Text(
                    "Ok",
                    style: new TextStyle(
                        fontSize: 14.0,
                        color: GEA_COLOR,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
