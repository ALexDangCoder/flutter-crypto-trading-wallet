import 'dart:math';
import 'package:animator/animator.dart';
import 'package:adevindustries/constance/constance.dart';
import 'package:adevindustries/constance/routes.dart';
import 'package:adevindustries/constance/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adevindustries/constance/global.dart' as globals;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SwipeIntroductionScreen extends StatefulWidget {
  @override
  _SwipeIntroductionScreenState createState() => _SwipeIntroductionScreenState();
}

class _SwipeIntroductionScreenState extends State<SwipeIntroductionScreen> with SingleTickerProviderStateMixin {
  bool _visible = false;
  bool loop = false;
  bool _isInProgress = false;

  // PageIndicatorLayout layout = PageIndicatorLayout.SLIDE;

  late AnimationController controller;
  late Animation<Offset> offset;

  late PageController pageController;

  @override
  void initState() {
    super.initState();
    animation();
    controller = AnimationController(vsync: this, duration: Duration(seconds: 1));

    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 0.4)).animate(controller);

    controller.forward();

    pageController = new PageController();
  }

  double size = 10.0;
  double activeSize = 10.0;

  animation() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _visible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var children = <Widget>[
      Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: height / 1.7,
                    width: width / 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          globals.buttoncolor1,
                          globals.buttoncolor2,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Animator<double>(
                tween: Tween<double>(begin: 0, end: 2 * pi),
                duration: Duration(milliseconds: 500),
                repeats: 1,
                builder: (_, anim, __) => Transform(
                  transform: Matrix4.rotationZ(anim.value),
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {},
                    child: Center(
                      child: SizedBox(
                        height: 150,
                        width: 150,
                        child: Image.asset(
                          ConstanceData.planetImage,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            height: 2,
            width: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  globals.buttoncolor1,
                  globals.buttoncolor2,
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: _visible ? 1.0 : 0.0,
            child: Text(
              'Exchange engine',
              style: TextStyle(
                color: AllCoustomTheme.getTextThemeColors(),
                fontSize: ConstanceData.SIZE_TITLE25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SlideTransition(
            position: offset,
            child: Text(
              'Our engine matches you up with an\n ever growing list of traders to buy and\nsell your cryptocurrency',
              style: TextStyle(
                color: AllCoustomTheme.getsecoundTextThemeColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      Container(
        height: height,
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Container(
                        height: height / 1.7,
                        width: width / 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              globals.buttoncolor1,
                              globals.buttoncolor2,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'Select currencies',
                      style: TextStyle(
                        color: AllCoustomTheme.getTextThemeColors(),
                        fontSize: ConstanceData.SIZE_TITLE25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 2,
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            globals.buttoncolor1,
                            globals.buttoncolor2,
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Lear to love growth and change\nand you will be succsess',
                      style: TextStyle(
                        color: AllCoustomTheme.getTextThemeColors(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: !_isInProgress
                        ? Animator<double>(
                            tween: Tween<double>(begin: 0.8, end: 1),
                            curve: Curves.easeInToLinear,
                            cycles: 0,
                            builder: (_, anim, __) => Transform.scale(
                              scale: anim.value,
                              // ignore: deprecated_member_use
                              child: InkWell(
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
                                    "Strat Trading",
                                    style: new TextStyle(
                                      color: AllCoustomTheme.getReBlackAndWhiteThemeColors(),
                                      fontSize: ConstanceData.SIZE_TITLE16,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  setState(() {
                                    _isInProgress = true;
                                  });
                                  await Future.delayed(const Duration(milliseconds: 500));
                                  Navigator.pushReplacementNamed(
                                    context,
                                    Routes.Auth,
                                  );
                                },
                              ),
                            ),
                          )
                        : CupertinoActivityIndicator(
                            radius: 12,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];

    return Stack(
      children: <Widget>[
        Container(
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                HexColor(globals.primaryColorString).withOpacity(0.6),
                HexColor(globals.primaryColorString).withOpacity(0.6),
                HexColor(globals.primaryColorString).withOpacity(0.6),
                HexColor(globals.primaryColorString).withOpacity(0.6),
              ],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: AllCoustomTheme.getThemeData().primaryColor,
          body: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    PageView(
                      controller: pageController,
                      children: children,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: SmoothPageIndicator(
                          controller: pageController,
                          count: 2,
                          effect: SlideEffect(
                            strokeWidth: 1.5,
                            dotColor: (Colors.grey[350]!),
                            activeDotColor: Color(0xFF7635ff),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
