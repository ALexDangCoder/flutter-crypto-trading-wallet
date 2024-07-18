// ignore_for_file: deprecated_member_use, unnecessary_null_comparison

import 'dart:math';
import 'package:animator/animator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:adevindustries/api/apiProvider.dart';
import 'package:adevindustries/constance/constance.dart';
import 'package:adevindustries/constance/global.dart';
import 'package:adevindustries/constance/themes.dart';
import 'package:adevindustries/model/PairDetailInfoModel.dart';
import 'package:adevindustries/model/PairTransactionDetailModel.dart';
import 'package:adevindustries/model/liveTradingPairModel.dart';
import 'package:adevindustries/modules/tradingPair/tradingPairLiveChart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adevindustries/constance/global.dart' as globals;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class PairDescription extends StatefulWidget {
  final TradingPair tradingPair;

  const PairDescription({key, required this.tradingPair}) : super(key: key);
  @override
  _PairDescriptionState createState() => _PairDescriptionState();
}

class _PairDescriptionState extends State<PairDescription> {
  bool _isInProgress = false;

  var appBarheight = 0.0;
  var height = 0.0;
  var subscription;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  late PairDetailInfo pairDetailInfo;
  List<TransactionDetail> transactionDetail = [];
  List<TransactionDetail> buyColumn = [];
  List<TransactionDetail> sellColumn = [];

  @override
  void initState() {
    super.initState();
    checkConnection();
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result.index != 2) {
        showInSnackBar(ConstanceData.GotInternet, isGreeen: true);
        getPairDescriptionDetail();
      } else {
        showInSnackBar(ConstanceData.NoInternet, isGreeen: false);
      }
    });
  }

  Future showInSnackBar(String value, {bool isGreeen = false}) async {
    await Future.delayed(const Duration(milliseconds: 700));

    var snackBar = SnackBar(
      duration: Duration(seconds: 2),
      backgroundColor: isGreeen ? Colors.green : Colors.red,
      content: Text(
        value,
        style: TextStyle(
          color: AllCoustomTheme.getReBlackAndWhiteThemeColors(),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  checkConnection() async {
    getPairDescriptionDetail();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showInSnackBar(ConstanceData.NoInternet, isGreeen: false);
    }
  }

  getPairDescriptionDetail() async {
    setState(() {
      _isInProgress = true;
    });
    pairDetailInfo = await ApiProvider().getPairInfoDetail(widget.tradingPair.urlSymbol ?? "");

    transactionDetail.clear();
    buyColumn.clear();
    sellColumn.clear();

    transactionDetail = await ApiProvider().getPairsTransactionDetail(widget.tradingPair.urlSymbol ?? "");
    transactionDetail.sort((f, g) => g.date!.compareTo(f.date ?? ""));
    transactionDetail.forEach((f) {
      // 0=buy && 1=sell
      if (f.type == '0') {
        buyColumn.add(f);
      } else {
        sellColumn.add(f);
      }
    });
    setState(() {
      _isInProgress = false;
    });
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar();
    appBarheight = appBar.preferredSize.height;
    height = MediaQuery.of(context).size.height;
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
        SafeArea(
          bottom: true,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: AllCoustomTheme.getThemeData().primaryColor,
            body: ModalProgressHUD(
              inAsyncCall: _isInProgress,
              opacity: 0,
              progressIndicator: CupertinoActivityIndicator(
                radius: 12,
              ),
              child: !_isInProgress
                  ? Column(
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).padding.top,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 16,
                            left: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Animator<Offset>(
                                  tween: Tween<Offset>(begin: Offset(0, 0), end: Offset(0.2, 0)),
                                  duration: Duration(milliseconds: 500),
                                  cycles: 0,
                                  builder: (_, anim, __) => FractionalTranslation(
                                    translation: anim.value,
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: AllCoustomTheme.getTextThemeColors(),
                                    ),
                                  ),
                                ),
                              ),
                              Animator<double>(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.decelerate,
                                cycles: 1,
                                builder: (_, anim, __) => Transform.scale(
                                  scale: anim.value,
                                  child: Text(
                                    widget.tradingPair.name ?? "",
                                    style: TextStyle(
                                      color: AllCoustomTheme.getTextThemeColors(),
                                      fontSize: ConstanceData.SIZE_TITLE18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Animator<double>(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: Duration(milliseconds: 500),
                                cycles: 1,
                                builder: (_, anim, __) => SizeTransition(
                                  sizeFactor: anim.animation,
                                  axis: Axis.horizontal,
                                  axisAlignment: 1,
                                  child: InkWell(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (BuildContext context) => TradingPairChart(
                                            transactionDetail: transactionDetail,
                                            tradingPair: widget.tradingPair,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      FontAwesomeIcons.chartBar,
                                      size: 20,
                                      color: AllCoustomTheme.getsecoundTextThemeColor(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        pairDetailInfo != null
                            ? Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Animator<double>(
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.decelerate,
                                      cycles: 1,
                                      builder: (_, anim, __) => Transform.scale(
                                        scale: anim.value,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 16),
                                          child: Column(
                                            children: <Widget>[
                                              MagicBoxGradiantLine(
                                                height: 0,
                                              ),
                                              Container(
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.only(
                                                    bottomLeft: Radius.circular(30),
                                                  ),
                                                  color: AllCoustomTheme.boxColor(),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                    right: 10,
                                                    left: 10,
                                                    bottom: 10,
                                                  ),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(
                                                        FontAwesomeIcons.bitcoin,
                                                        color: AllCoustomTheme.getTextThemeColors(),
                                                        size: 50,
                                                      ),
                                                      Animator<double>(
                                                        tween: Tween<double>(begin: 0.5, end: 0.8),
                                                        curve: Curves.fastOutSlowIn,
                                                        cycles: 0,
                                                        builder: (_, anim, __) => Transform.scale(
                                                          scale: anim.value,
                                                          child: Text(
                                                            pairDetailInfo.last.toString(),
                                                            style: TextStyle(
                                                              color: AllCoustomTheme.getTextThemeColors(),
                                                              fontSize: 30,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 8),
                                                        child: Text(
                                                          "USD",
                                                          style: TextStyle(
                                                            color: AllCoustomTheme.getsecoundTextThemeColor(),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: ConstanceData.SIZE_TITLE14,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: SizedBox(),
                                                      ),
                                                      Text(
                                                        widget.tradingPair.urlSymbol!.toUpperCase(),
                                                        style: TextStyle(
                                                          color: AllCoustomTheme.getTextThemeColors(),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Animator<Offset>(
                                      tween: Tween<Offset>(begin: Offset(-50, 0), end: Offset(10, 0)),
                                      duration: Duration(milliseconds: 500),
                                      cycles: 1,
                                      builder: (_, anim, __) => Transform(
                                        transform: Matrix4.translationValues(anim.value.dx, 0, 0),
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 12),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 6),
                                                        child: Text(
                                                          'High',
                                                          style: TextStyle(
                                                            color: AllCoustomTheme.getsecoundTextThemeColor(),
                                                            fontSize: ConstanceData.SIZE_TITLE14,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      Text(
                                                        pairDetailInfo.high ?? "",
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: ConstanceData.SIZE_TITLE14,
                                                        ),
                                                      ),
                                                      Animator<Offset>(
                                                        tween: Tween<Offset>(begin: Offset(0, -0.1), end: Offset(0, 0.2)),
                                                        duration: Duration(milliseconds: 500),
                                                        cycles: 0,
                                                        builder: (_, anim, __) => FractionalTranslation(
                                                          translation: anim.value,
                                                          child: Icon(
                                                            Icons.arrow_upward,
                                                            color: Colors.green,
                                                            size: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        'Low',
                                                        style: TextStyle(
                                                          color: AllCoustomTheme.getsecoundTextThemeColor(),
                                                          fontSize: ConstanceData.SIZE_TITLE14,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      Text(
                                                        pairDetailInfo.low ?? "",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.red,
                                                          fontSize: ConstanceData.SIZE_TITLE14,
                                                        ),
                                                      ),
                                                      Animator<Offset>(
                                                        tween: Tween<Offset>(begin: Offset(0, -0.1), end: Offset(0, 0.2)),
                                                        duration: Duration(milliseconds: 500),
                                                        cycles: 0,
                                                        builder: (_, anim, __) => FractionalTranslation(
                                                          translation: anim.value,
                                                          child: Icon(
                                                            Icons.arrow_downward,
                                                            color: Colors.red,
                                                            size: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        'Vol',
                                                        style: TextStyle(
                                                          color: AllCoustomTheme.getsecoundTextThemeColor(),
                                                          fontSize: ConstanceData.SIZE_TITLE14,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 4,
                                                      ),
                                                      Text(
                                                        pairDetailInfo.volume.toString() + ' B',
                                                        style: TextStyle(
                                                          color: AllCoustomTheme.getTextThemeColors(),
                                                          fontSize: ConstanceData.SIZE_TITLE14,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 25,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16, right: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Price Chart',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AllCoustomTheme.getsecoundTextThemeColor(),
                                            ),
                                          ),
                                          Text(
                                            'Settlement',
                                            style: TextStyle(
                                              color: AllCoustomTheme.getTextThemeColors(),
                                            ),
                                          ),
                                          Text(
                                            'Trade History',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AllCoustomTheme.getsecoundTextThemeColor(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Container(
                                        height: 35,
                                        color: AllCoustomTheme.boxColor(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(left: 4),
                                                child: Text(
                                                  'Buy',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AllCoustomTheme.getTextThemeColors(),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 24),
                                                child: Text(
                                                  'Volume',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AllCoustomTheme.getTextThemeColors(),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 30),
                                                child: Text(
                                                  'Sell',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AllCoustomTheme.getTextThemeColors(),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 10),
                                                child: Text(
                                                  'Volume',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AllCoustomTheme.getTextThemeColors(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 0,
                                    ),
                                    buyColumn != null || sellColumn != null
                                        ? Expanded(
                                            child: Animator<double>(
                                              duration: Duration(milliseconds: 500),
                                              cycles: 1,
                                              builder: (_, anim, __) => Transform.scale(
                                                scale: anim.value,
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ListView.builder(
                                                        padding: EdgeInsets.only(right: 10),
                                                        physics: BouncingScrollPhysics(),
                                                        itemCount: buyColumn.length,
                                                        itemBuilder: (context, index) {
                                                          return Padding(
                                                            padding: const EdgeInsets.only(left: 16),
                                                            child: Container(
                                                              height: 30,
                                                              color: index % 2 == 0
                                                                  ? AllCoustomTheme.getThemeData().primaryColor
                                                                  : AllCoustomTheme.boxColor(),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: <Widget>[
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(left: 10),
                                                                    child: Text(
                                                                      double.parse(buyColumn[index].amount).toStringAsFixed(4),
                                                                      style: TextStyle(
                                                                        color: AllCoustomTheme.getTextThemeColors(),
                                                                        fontSize: ConstanceData.SIZE_TITLE14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Text(
                                                                      double.parse(buyColumn[index].price).toStringAsFixed(2),
                                                                      style: TextStyle(
                                                                        color: AllCoustomTheme.getTextThemeColors(),
                                                                        fontSize: ConstanceData.SIZE_TITLE14,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        padding: EdgeInsets.only(left: 10),
                                                        physics: BouncingScrollPhysics(),
                                                        itemCount: sellColumn.length,
                                                        itemBuilder: (context, index) {
                                                          return Container(
                                                            height: 30,
                                                            color: index % 2 == 0
                                                                ? AllCoustomTheme.getThemeData().primaryColor
                                                                : AllCoustomTheme.boxColor(),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: <Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 10),
                                                                  child: Text(
                                                                    double.parse(sellColumn[index].amount).toStringAsFixed(4),
                                                                    style: TextStyle(
                                                                      color: AllCoustomTheme.getTextThemeColors(),
                                                                      fontSize: ConstanceData.SIZE_TITLE14,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 14),
                                                                  child: Text(
                                                                    double.parse(sellColumn[index].price).toStringAsFixed(2),
                                                                    style: TextStyle(
                                                                      color: AllCoustomTheme.getTextThemeColors(),
                                                                      fontSize: ConstanceData.SIZE_TITLE14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : CupertinoActivityIndicator(
                                            radius: 12,
                                          ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    !_isInProgress
                                        ? Padding(
                                            padding: const EdgeInsets.only(left: 16, right: 16),
                                            child: Animator<double>(
                                              duration: Duration(milliseconds: 500),
                                              cycles: 1,
                                              builder: (_, anim, __) => Transform.scale(
                                                scale: anim.value,
                                                child: SizedBox(
                                                  height: 55,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Animator<double>(
                                                          tween: Tween<double>(begin: 0.5, end: 1),
                                                          curve: Curves.fastOutSlowIn,
                                                          cycles: 0,
                                                          builder: (_, anim, __) => Transform.scale(
                                                            scale: anim.value,
                                                            child: InkWell(
                                                              child: Container(
                                                                height: 45.0,
                                                                alignment: FractionalOffset.center,
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(color: Colors.white, width: 1.3),
                                                                  borderRadius: BorderRadius.circular(30),
                                                                  gradient: LinearGradient(
                                                                    begin: Alignment.topLeft,
                                                                    end: Alignment.bottomRight,
                                                                    colors: [
                                                                      globals.buttoncolor1,
                                                                      globals.buttoncolor2,
                                                                    ],
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  "BUY",
                                                                  style: TextStyle(
                                                                    color: AllCoustomTheme.getReBlackAndWhiteThemeColors(),
                                                                    letterSpacing: 0.3,
                                                                  ),
                                                                ),
                                                              ),
                                                              onTap: () {},
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: InkWell(
                                                          child: new Container(
                                                            height: 45.0,
                                                            alignment: FractionalOffset.center,
                                                            decoration: BoxDecoration(
                                                              borderRadius: new BorderRadius.circular(30),
                                                              color: AllCoustomTheme.getTextThemeColors(),
                                                            ),
                                                            child: GradientText(
                                                              "SELL",
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
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.star_border,
                                                            color: AllCoustomTheme.getsecoundTextThemeColor(),
                                                          ),
                                                          Text(
                                                            'Add To\nFavorites',
                                                            style: TextStyle(
                                                              fontSize: ConstanceData.SIZE_TITLE12,
                                                              color: AllCoustomTheme.getsecoundTextThemeColor(),
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox()
                                  ],
                                ),
                              )
                            : Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Animator<double>(
                                      tween: Tween<double>(begin: 0, end: 2 * pi),
                                      duration: Duration(milliseconds: 500),
                                      repeats: 0,
                                      builder: (_, anim, __) => Transform(
                                        transform: Matrix4.rotationZ(anim.value),
                                        child: SizedBox(
                                          height: 80,
                                          width: 80,
                                          child: Image.asset(
                                            ConstanceData.planetImage,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Animator<double>(
                                      duration: Duration(seconds: 1),
                                      cycles: 1,
                                      builder: (_, anim, __) => Transform.scale(
                                        scale: anim.value,
                                        child: Text(
                                          'Something Wents To Wrong\nPlease try Again',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AllCoustomTheme.getTextThemeColors(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    )
                  : SizedBox(),
            ),
          ),
        )
      ],
    );
  }
}
