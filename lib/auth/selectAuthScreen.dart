import 'package:adevindustries/auth/signInScreen.dart';
import 'package:adevindustries/constance/constance.dart';
import 'package:adevindustries/constance/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adevindustries/constance/global.dart' as globals;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'signUpScreen.dart';

class SelectAuthScreen extends StatefulWidget {
  @override
  _SelectAuthScreenState createState() => _SelectAuthScreenState();
}

class _SelectAuthScreenState extends State<SelectAuthScreen> {
  bool _visible = false;
  bool _visibleButtons = false;
  bool _isInProgress = false;

  @override
  void initState() {
    super.initState();
    animationText();
  }

  animationText() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _visible = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _visibleButtons = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Container(
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                HexColor(globals.primaryColorString).withOpacity(0.4),
                HexColor(globals.primaryColorString).withOpacity(0.4),
                HexColor(globals.primaryColorString).withOpacity(0.5),
                HexColor(globals.primaryColorString).withOpacity(0.6),
              ],
            ),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              ConstanceData.authImage,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: ModalProgressHUD(
            inAsyncCall: _isInProgress,
            opacity: 0,
            progressIndicator: SizedBox(),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
                child: Padding(
                  padding: EdgeInsets.only(top: height / 1.6, right: 16, left: 16, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: _visible ? 1.0 : 0.0,
                        child: Text(
                          'Professional\ncryptocurrency\nexchange',
                          style: TextStyle(
                            color: AllCoustomTheme.getTextThemeColors(),
                            fontSize: 38,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height / 40,
                      ),
                      _visible
                          ? AnimatedOpacity(
                              duration: Duration(milliseconds: 500),
                              opacity: _visibleButtons ? 1.0 : 0.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    // ignore: deprecated_member_use
                                    child: InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _isInProgress = true;
                                        });
                                        await Future.delayed(const Duration(seconds: 1));

                                        Navigator.of(context, rootNavigator: true)
                                            .push(
                                          CupertinoPageRoute<void>(
                                            builder: (BuildContext context) => SignInScreen(),
                                          ),
                                        )
                                            .then((onValue) {
                                          setState(() {
                                            _isInProgress = false;
                                          });
                                        });
                                      },
                                      child: new Container(
                                        height: 45.0,
                                        alignment: FractionalOffset.center,
                                        decoration: BoxDecoration(
                                          border: new Border.all(color: Colors.white, width: 1.5),
                                          borderRadius: new BorderRadius.circular(30),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              globals.buttoncolor1,
                                              globals.buttoncolor2,
                                            ],
                                          ),
                                        ),
                                        child: new Text(
                                          "Sign in",
                                          style: new TextStyle(
                                            color: AllCoustomTheme.getReBlackAndWhiteThemeColors(),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    // ignore: deprecated_member_use
                                    child: InkWell(
                                      child: new Container(
                                        height: 45.0,
                                        alignment: FractionalOffset.center,
                                        decoration: BoxDecoration(
                                          borderRadius: new BorderRadius.circular(30),
                                          color: AllCoustomTheme.getTextThemeColors(),
                                        ),
                                        child: GradientText(
                                          "Register",
                                          colors: [
                                            globals.buttoncolor1,
                                            globals.buttoncolor2,
                                          ],
                                          gradientType: GradientType.linear,
                                          style: new TextStyle(
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        setState(() {
                                          _isInProgress = true;
                                        });
                                        await Future.delayed(const Duration(seconds: 1));
                                        Navigator.of(context, rootNavigator: true)
                                            .push(
                                          CupertinoPageRoute<void>(
                                            builder: (BuildContext context) => SignUpScreen(),
                                          ),
                                        )
                                            .then((onValue) {
                                          setState(() {
                                            _isInProgress = false;
                                          });
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 10,
                      ),
                      _isInProgress
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CupertinoActivityIndicator(
                                  radius: 12,
                                ),
                              ],
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
