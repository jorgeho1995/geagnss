///////////////////////////////////////////////////////////
/// This file contains the SignIn window
//////////////////////////////////////////////////////////
/// Includes
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gea/profile/navbar_windows.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gea/navigator/navigation.dart';
import 'package:gea/user_control/reset_password.dart';
import 'package:gea/user_control/signup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gea/includes/includes.dart';

///////////////////////////////////////////////////////////
/// Google SignIn
//////////////////////////////////////////////////////////
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
    'profile'
  ],
);

///////////////////////////////////////////////////////////
/// Main Sign In widget.
/// This window allows to log in into the app
//////////////////////////////////////////////////////////
class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

/// This is the private State class that goes with SignIn.
class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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

  Widget _forgotPassword() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResetPass()),
          );
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.only(right: 0.0),
        ),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? GEA_DARK
                : GEA_LIGHT,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _loginBtn() {
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
                    logInToFb();
                  }
                },
                child: Text(
                  'Log In',
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
    return Column(
      children: <Widget>[
        SizedBox(height: 20.0),
        Text(
          'Sign in with',
          style: GoogleFonts.pacifico(
            textStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? GEA_DARK
                  : GEA_LIGHT,
              fontSize: 24.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _socialSignIn() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          GestureDetector(
            onTap: _handleSignInWithGoogle,
            child: Container(
              height: 60.0,
              width: 60.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).brightness == Brightness.dark
                    ? GEA_DARK
                    : GEA_LIGHT,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(
                    'assets/logos/google.png',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          /*GestureDetector(
            onTap: _handleSignInWithGithub,
            child: Container(
              height: 60.0,
              width: 60.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(41, 41, 41, 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(
                    'assets/logos/github.png',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _signUp() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignUp())),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Do not have an Account? ',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? GEA_DARK
                    : GEA_LIGHT,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
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
                      vertical: 65.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ListTile(
                          trailing: Icon(
                            Icons.info_outlined,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? GEA_DARK
                                    : GEA_LIGHT,
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => About()));
                          },
                        ),
                        Text('Sign In',
                            textAlign: TextAlign.center,
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
                        _password(),
                        _forgotPassword(),
                        _loginBtn(),
                        _signIn(),
                        _socialSignIn(),
                        _signUp(),
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

  void logInToFb() {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((result) {
      setState(() {
        isLoading = false;
      });
      User user = FirebaseAuth.instance.currentUser;
      if (!user.emailVerified) {
        FirebaseAuth auth = FirebaseAuth.instance;
        auth.signOut();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Email Verification Error',
                  style: new TextStyle(
                      color: GEA_COLOR, fontWeight: FontWeight.bold),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text(
                          'Your email ${emailController.text} has not been already verified. Please, login to your email account and follow the validation steps, then come back to login.'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'Close',
                      style: new TextStyle(
                          fontSize: 14.0,
                          color: GEA_COLOR,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  ),
                ],
              );
            });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => GeaStatefulWidget(uid: result.user.uid)),
        );
      }
    }).catchError((err) {
      print(err.message);
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

  Future<UserCredential> _handleSignInWithGoogle() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User user = authResult.user;

      if (authResult.additionalUserInfo.isNewUser) {
        if (user != null) {
          registerToFb(googleUser, user);
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => GeaStatefulWidget(uid: user.uid)),
        );
      }

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      print(error);
    }
  }

  void registerToFb(googleUser, user) {
    // User table
    var entireName = googleUser.displayName.toString();
    var arrName = entireName.split(" ");
    CollectionReference dbRef = FirebaseFirestore.instance.collection('users');
    dbRef.doc(user.uid).set({
      "email": googleUser.email.toString(),
      "name": arrName[0],
      "surname": arrName[1],
      "rt_enabled": false,
      "clientRTKLIBPort": -1,
      "clientRTKLIBRecPort": -1
    }).then((res) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => GeaStatefulWidget(uid: user.uid)),
      );
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
  }
}
