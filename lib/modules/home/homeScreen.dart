// ignore_for_file: unnecessary_null_comparison, unused_field, import_of_legacy_library_into_null_safe
import 'dart:convert';
import 'dart:math';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:adevindustries/api/apiProvider.dart';
import 'package:adevindustries/constance/constance.dart';
import 'package:adevindustries/constance/global.dart';
import 'package:adevindustries/constance/themes.dart';
import 'package:adevindustries/graphDetail/QuickPercentChangeBar.dart';
import 'package:adevindustries/main.dart';
import 'package:adevindustries/model/listingsModel.dart';
import 'package:adevindustries/modules/chagePIN/changepin.dart';
import 'package:adevindustries/modules/drawer/drawer.dart';
import 'package:adevindustries/modules/news/latestCryptoNews.dart';
import 'package:adevindustries/modules/underGroundSlider/cryptoCoinDetailSlider.dart';
import 'package:adevindustries/modules/underGroundSlider/notificationSlider.dart';
import 'package:adevindustries/modules/userProfile/userProfile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adevindustries/constance/global.dart' as globals;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:candlesticks/candlesticks.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

const String testDevice = 'YOUR_DEVICE_ID';

class _HomeScreenState extends State<HomeScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isInProgress = false;
  bool isSelect1 = false;
  bool isSelect2 = false;
  bool isSelect3 = false;
  bool _isSearch = false;
  bool allCoin = false;
  bool isLoading = false;

  var width = 0.0;
  var height = 0.0;
  var appBarheight = 0.0;
  var statusBarHeight = 0.0;
  var graphHeight = 0.0;
  List<CryptoCoinDetail> _serchCoinList = [];
  var marketCapUpDown;

  String historyAmt = "720";
  String historyType = "minute";
  String historyTotal = "24h";
  String historyAgg = "2";
  String _high = "0";
  String _low = "0";
  String _change = "0";
  String symbol = 'BTC';

  USD generalStats = new USD();
  int currentOHLCVWidthSetting = 0;
  List historyOHLCV = [];

  var subscription;

  List<CryptoCoinDetail> lstCryptoCoinDetail = [];

  @override
  void initState() {
    super.initState();
    binanceFetch("1m");
    setFirstTab();
    callItself();
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      print(result.index); // 0=wifi, 1=mobile, 2=none
      if (result.index != 2) {
        setFirstTab();
        callItself();
        marketCapUpDown = Icons.arrow_upward;
      } else {
        connectionError();
      }
    });
  }

  connectionError() {
    showInSnackBar(ConstanceData.NoInternet);
  }

  Future showInSnackBar(String value, {bool isGreeen = false}) async {
    await Future.delayed(const Duration(milliseconds: 700));

    var snackBar = SnackBar(
      duration: Duration(seconds: 2),
      backgroundColor: isGreeen ? AllCoustomTheme.getThemeData().primaryColor : Colors.red,
      content: Text(
        value,
        style: TextStyle(
          color: AllCoustomTheme.getReBlackAndWhiteThemeColors(),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  isLoadingList() async {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  Future<Null> getApiAllData(int index) async {
    List<CryptoCoinDetail> allCoinList = [];
    allCoinList.clear();
    List<CryptoCoinDetail> coindata = await getData1(index);
    coindata = await getData1(index);
    if (coindata != null) {
      if (coindata.length != 0) {
        index += coindata.length;
        if (index == 1) {
          setState(() {
            allCoinList.addAll(coindata);
          });
        } else {
          allCoinList.addAll(coindata);
          setState(() {
            allCoinList.removeWhere((length) => length.quote!.uSD!.marketCap == null);
            if (allCoin == true) {
              getApiAllData(index);
            }
            lstCryptoCoinDetail.clear();
            lstCryptoCoinDetail.addAll(allCoinList);
            lstCryptoCoinDetail.sort((a, b) => b.quote!.uSD!.marketCap!.compareTo(a.quote!.uSD!.marketCap ?? 0));
            print(lstCryptoCoinDetail[0].quote!.uSD);

            marketListData.clear();
            marketListData.addAll(allCoinList);
            marketListData.sort((a, b) => b.quote.uSD.marketCap.compareTo(a.quote.uSD.marketCap));
          });
        }
      }
    }
  }

  callItself() async {
    await getApiAllData(1);
    await changeHistory(historyType, historyAmt, historyTotal, historyAgg);
    await Future.delayed(Duration(hours: 1));
    callItself();
  }

  Future<Null> changeHistory(String type, String amt, String total, String agg) async {
    setState(() {
      _high = "0";
      _low = "0";
      _change = "0";

      historyAmt = amt;
      historyType = type;
      historyTotal = total;
      historyAgg = agg;

      historyOHLCV = [];
    });
    _makeGeneralStats();
    await getHistoryOHLCV();
    _getHL();
  }

  _makeGeneralStats() {
    for (CryptoCoinDetail coin in marketListData) {
      if (coin.symbol == symbol) {
        generalStats = coin.quote!.uSD!;
        setState(() {});
        break;
      }
    }
  }

  _getHL() {
    num highReturn = -double.infinity;
    num lowReturn = double.infinity;

    for (var i in historyOHLCV) {
      if (i["high"] > highReturn) {
        highReturn = i["high"].toDouble();
      }
      if (i["low"] < lowReturn) {
        lowReturn = i["low"].toDouble();
      }
    }

    _high = normalizeNumNoCommas(highReturn);
    _low = normalizeNumNoCommas(lowReturn);

    var start = historyOHLCV[0]["open"] == 0 ? 1 : historyOHLCV[0]["open"];
    var end = historyOHLCV.last["close"];
    var changePercent = (end - start) / start * 100;
    _change = changePercent.toStringAsFixed(2);
  }

  Future<Null> getHistoryOHLCV() async {
    Map<String, dynamic> head = {
      "Accept": "application/json",
    };

    try {
      var response = await Dio().get(
        "https://min-api.cryptocompare.com/data/histo" +
            ohlcvWidthOptions[historyTotal][currentOHLCVWidthSetting][3] +
            "?fsym=" +
            symbol +
            "&tsym=USD&limit=" +
            (ohlcvWidthOptions[historyTotal][currentOHLCVWidthSetting][1] - 1).toString() +
            "&aggregate=" +
            ohlcvWidthOptions[historyTotal][currentOHLCVWidthSetting][2].toString(),
        options: Options(
          headers: head,
        ),
      );

      setState(() {
        historyOHLCV = response.data["Data"];
        if (historyOHLCV == null) {
          historyOHLCV = [];
        }
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {});
    }
  }

  setFirstTab() {
    setState(() {
      isSelect1 = true;
      isSelect2 = false;
      isSelect3 = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar();
    appBarheight = appBar.preferredSize.height;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    statusBarHeight = MediaQuery.of(context).padding.top;
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
            bottomNavigationBar: Container(
              height: 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        isSelect1
                            ? Animator<double>(
                                duration: Duration(milliseconds: 500),
                                cycles: 1,
                                builder: (_, anim, __) => Transform.scale(
                                  scale: anim.value,
                                  child: Container(
                                    height: 2,
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
                              )
                            : SizedBox(
                                height: 2,
                              ),
                        GestureDetector(
                          onTap: () {
                            selectFirst();
                          },
                          child: isSelect1
                              ? Animator<double>(
                                  tween: Tween<double>(begin: 0.8, end: 1.1),
                                  curve: Curves.decelerate,
                                  cycles: 1,
                                  builder: (_, anim, __) => Transform.scale(
                                    scale: anim.value,
                                    child: Container(
                                      height: 40,
                                      width: width / 3,
                                      color: Colors.transparent,
                                      child: Icon(
                                        Icons.card_travel,
                                        color: isSelect1 ? AllCoustomTheme.getTextThemeColors() : AllCoustomTheme.getsecoundTextThemeColor(),
                                      ),
                                    ),
                                  ),
                                )
                              : firstAnimation(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        isSelect2
                            ? Animator<double>(
                                duration: Duration(milliseconds: 500),
                                cycles: 1,
                                builder: (_, anim, __) => Transform.scale(
                                  scale: anim.value,
                                  child: Container(
                                    height: 2,
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
                              )
                            : SizedBox(
                                height: 2,
                              ),
                        GestureDetector(
                          onTap: () {
                            selectSecond();
                          },
                          child: isSelect2
                              ? Animator<double>(
                                  tween: Tween<double>(begin: 0.8, end: 1.1),
                                  curve: Curves.decelerate,
                                  cycles: 1,
                                  builder: (_, anim, __) => Transform.scale(
                                    scale: anim.value,
                                    child: secondAnimation(),
                                  ),
                                )
                              : secondAnimation(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        isSelect3
                            ? Animator<double>(
                                duration: Duration(milliseconds: 500),
                                cycles: 1,
                                builder: (_, anim, __) => Transform.scale(
                                  scale: anim.value,
                                  child: Container(
                                    height: 2,
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
                              )
                            : SizedBox(
                                height: 2,
                              ),
                        GestureDetector(
                          onTap: () {
                            selectThird();
                          },
                          child: isSelect3
                              ? Animator<double>(
                                  tween: Tween<double>(begin: 0.8, end: 1.1),
                                  curve: Curves.decelerate,
                                  cycles: 1,
                                  builder: (_, anim, __) => Transform.scale(
                                    scale: anim.value,
                                    child: thirdAnimation(),
                                  ),
                                )
                              : thirdAnimation(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            drawer: SizedBox(
              width: MediaQuery.of(context).size.width * 0.75 < 400 ? MediaQuery.of(context).size.width * 0.75 : 350,
              child: Drawer(
                elevation: 0,
                child: AppDrawer(
                  selectItemName: 'home',
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            body: ModalProgressHUD(
              inAsyncCall: _isInProgress,
              opacity: 0,
              progressIndicator: SizedBox(),
              child: Container(
                height: height,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).padding.top,
                    ),
                    Expanded(
                      child: isSelect1
                          ? firstScreen()
                          : isSelect2
                              ? secoundScreen()
                              : thirdScreen(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget firstAnimation() {
    return Container(
      height: 40,
      width: width / 3,
      color: Colors.transparent,
      child: Icon(
        Icons.card_travel,
        color: isSelect1 ? AllCoustomTheme.getTextThemeColors() : AllCoustomTheme.getsecoundTextThemeColor(),
      ),
    );
  }

  Widget secondAnimation() {
    return Container(
      height: 40,
      width: width / 3,
      color: Colors.transparent,
      child: Icon(
        Icons.pie_chart,
        color: isSelect2 ? AllCoustomTheme.getTextThemeColors() : AllCoustomTheme.getsecoundTextThemeColor(),
      ),
    );
  }

  Widget thirdAnimation() {
    return Container(
      height: 40,
      width: width / 3,
      color: Colors.transparent,
      child: Icon(
        Icons.settings,
        color: isSelect3 ? AllCoustomTheme.getTextThemeColors() : AllCoustomTheme.getsecoundTextThemeColor(),
      ),
    );
  }

  List<Candle> candles = [];
  WebSocketChannel? _channel;

  String interval = "1m";
  @override
  void dispose() {
    _channel!.sink.close();
    super.dispose();
  }

  Future<void> binanceFetch(String interval) async {
    await ApiProvider().fetchCandles(symbol: "BTCUSDT", interval: interval).then(
          (value) => setState(
            () {
              this.interval = interval;
              candles = value;
            },
          ),
        );
    if (_channel != null) _channel!.sink.close();
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://stream.binance.com:9443/ws'),
    );
    _channel!.sink.add(
      jsonEncode(
        {
          "method": "SUBSCRIBE",
          "params": ["btcusdt@kline_" + interval],
          "id": 1
        },
      ),
    );
  }

  void updateCandlesFromSnapshot(AsyncSnapshot<Object?> snapshot) {
    if (snapshot.data != null) {
      final data = jsonDecode(snapshot.data as String) as Map<String, dynamic>;
      if (data.containsKey("k") == true && candles[0].date.millisecondsSinceEpoch == data["k"]["t"]) {
        candles[0] = Candle(
            date: candles[0].date,
            high: double.parse(data["k"]["h"]),
            low: double.parse(data["k"]["l"]),
            open: double.parse(data["k"]["o"]),
            close: double.parse(data["k"]["c"]),
            volume: double.parse(data["k"]["v"]));
      } else if (data.containsKey("k") == true &&
          data["k"]["t"] - candles[0].date.millisecondsSinceEpoch ==
              candles[0].date.millisecondsSinceEpoch - candles[1].date.millisecondsSinceEpoch) {
        candles.insert(
            0,
            Candle(
                date: DateTime.fromMillisecondsSinceEpoch(data["k"]["t"]),
                high: double.parse(data["k"]["h"]),
                low: double.parse(data["k"]["l"]),
                open: double.parse(data["k"]["o"]),
                close: double.parse(data["k"]["c"]),
                volume: double.parse(data["k"]["v"])));
      }
    }
  }

  Widget firstScreen() {
    graphHeight = height - appBarheight - 42;
    return Container(
      height: graphHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState!.openDrawer();
                  },
                  child: Icon(
                    Icons.sort,
                    color: AllCoustomTheme.getsecoundTextThemeColor(),
                  ),
                ),
                historyOHLCV != null
                    ? Animator<double>(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.decelerate,
                        cycles: 1,
                        builder: (_, anim, __) => Transform.scale(
                          scale: anim.value,
                          child: Text(
                            'Bitcoin, BTC Live',
                            style: TextStyle(color: AllCoustomTheme.getTextThemeColors(), fontSize: ConstanceData.SIZE_TITLE18),
                          ),
                        ),
                      )
                    : SizedBox(),
                Animator<double>(
                  duration: Duration(milliseconds: 500),
                  tween: Tween<double>(begin: -0.1, end: 0.1),
                  curve: Curves.decelerate,
                  cycles: 0,
                  builder: (_, anim, __) => Transform(
                    transform: Matrix4.skewX(anim.value),
                    child: InkWell(
                      onTap: () {},
                      child: Icon(
                        Icons.notifications,
                        color: AllCoustomTheme.getsecoundTextThemeColor(),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16),
            child: historyOHLCV != null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Animator<double>(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.decelerate,
                        cycles: 1,
                        builder: (_, anim, __) => Transform.scale(
                          scale: anim.value,
                          child: Text(
                            '\$',
                            style: TextStyle(
                              color: AllCoustomTheme.getTextThemeColors(),
                              fontWeight: FontWeight.bold,
                              fontSize: ConstanceData.SIZE_TITLE18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Animator<double>(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.decelerate,
                        cycles: 1,
                        builder: (_, anim, __) => Transform.scale(
                          scale: anim.value,
                          child: Text(
                            generalStats != null
                                ? normalizeNumNoCommas(
                                    generalStats.price ?? 0,
                                  )
                                : "0",
                            style: TextStyle(
                              color: AllCoustomTheme.getTextThemeColors(),
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Row(
                        children: <Widget>[
                          Animator<double>(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.decelerate,
                            cycles: 1,
                            builder: (_, anim, __) => Transform.scale(
                              scale: anim.value,
                              child: Text(
                                '1h:',
                                style: TextStyle(
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
                              child: generalStats.percentChange1h != null
                                  ? Icon(
                                      generalStats.percentChange1h.toString().contains('-') ? Icons.arrow_downward : Icons.arrow_upward,
                                      color: generalStats.percentChange1h.toString().contains('-') ? Colors.red : Colors.green,
                                      size: 16,
                                    )
                                  : SizedBox(),
                            ),
                          ),
                          Animator<double>(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.decelerate,
                            cycles: 1,
                            builder: (_, anim, __) => Transform.scale(
                              scale: anim.value,
                              child: generalStats.percentChange1h != null
                                  ? Text(
                                      generalStats.percentChange1h.toString() + '%',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        color: generalStats.percentChange1h.toString().contains('-') ? Colors.red : Colors.green,
                                        fontSize: ConstanceData.SIZE_TITLE14,
                                      ),
                                    )
                                  : SizedBox(),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                : SizedBox(),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Candlesticks(
              onIntervalChange: (String value) async {
                binanceFetch(value);
              },
              candles: candles,
              interval: interval,
            ),
          ),
          generalStats != null && generalStats.percentChange1h != null
              ? historyOHLCV != null
                  ? Animator<double>(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.decelerate,
                      cycles: 1,
                      builder: (_, anim, __) => Transform.scale(
                        scale: anim.value,
                        child: QuickPercentChangeBar(
                          snapshot: generalStats,
                        ),
                      ),
                    )
                  : SizedBox()
              : Container(
                  height: 0.0,
                ),
        ],
      ),
    );
  }

  Widget secoundScreen() {
    // print(lstCryptoCoinDetail[0]);
    graphHeight = height - appBarheight - 42;
    return Container(
      height: graphHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (BuildContext context) => CryptoNews(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.info_outline,
                    color: AllCoustomTheme.getsecoundTextThemeColor(),
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  color: AllCoustomTheme.getsecoundTextThemeColor(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            children: <Widget>[
              Animator<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 500),
                cycles: 1,
                builder: (_, anim, __) => SizeTransition(
                  sizeFactor: anim.animation,
                  axis: Axis.horizontal,
                  axisAlignment: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Live Stock',
                      style: TextStyle(
                        color: AllCoustomTheme.getTextThemeColors(),
                        fontWeight: FontWeight.bold,
                        fontSize: ConstanceData.SIZE_TITLE25,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: AllCoustomTheme.boxColor(),
                    ),
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: ConstanceData.SIZE_TITLE16,
                        color: AllCoustomTheme.getTextThemeColors(),
                      ),
                      cursorColor: AllCoustomTheme.getTextThemeColors(),
                      onChanged: (value) {
                        filterSearchResults(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(
                          Icons.search,
                          size: 20,
                          color: AllCoustomTheme.getsecoundTextThemeColor(),
                        ),
                        hintStyle: TextStyle(
                          fontSize: ConstanceData.SIZE_TITLE16,
                          color: AllCoustomTheme.getsecoundTextThemeColor(),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _upDownMarketCap();
                    },
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: AllCoustomTheme.boxColor(),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 8, left: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Market cap',
                              style: TextStyle(
                                color: AllCoustomTheme.getTextThemeColors(),
                              ),
                            ),
                            Animator<double>(
                              tween: Tween<double>(begin: 0, end: 2 * pi),
                              duration: Duration(milliseconds: 500),
                              repeats: 1,
                              builder: (_, anim, __) => Transform(
                                transform: Matrix4.skewX(anim.value),
                                child: InkWell(
                                  onTap: () {},
                                  child: Icon(
                                    marketCapUpDown == Icons.arrow_upward ? Icons.arrow_upward : Icons.arrow_downward,
                                    size: 18,
                                    color: AllCoustomTheme.getTextThemeColors(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 4,
          ),
          isLoading
              ? Expanded(
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Shimmer.fromColors(
                      baseColor: globals.buttoncolor1,
                      highlightColor: globals.buttoncolor2,
                      enabled: true,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 26),
                        child: Column(
                          children: [1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1]
                              .map(
                                (_) => Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 16),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  height: 8.0,
                                                  color: Colors.white,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                ),
                                                Container(
                                                  width: 40.0,
                                                  height: 8.0,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: _isSearch ? _serchCoinList.length : lstCryptoCoinDetail.length,
                      itemBuilder: (BuildContext context, int index) {
                        var coinData = _isSearch ? _serchCoinList[index] : lstCryptoCoinDetail[index];
                        // ignore: unused_local_variable
                        var coinId = coinData.id.toString();
                        var coinSymbol = coinData.symbol.toString();
                        var coinName = coinData.name.toString();
                        var price = coinData.quote!.uSD!.price.toString();
                        var percentchange1h = coinData.quote!.uSD!.percentChange1h.toString();
                        var marketCap = coinData.quote!.uSD!.marketCap.toString();
                        var volume = coinData.quote!.uSD!.volume24h.toString();
                        var availableSupply = coinData.totalSupply.toString();
                        var changein24HR = coinData.quote!.uSD!.percentChange24h.toString();
                        return InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            showCupertinoModalPopup<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        globals.buttoncolor1,
                                        globals.buttoncolor2,
                                      ],
                                    ),
                                  ),
                                  height: height - appBarheight - 42,
                                  child: Scaffold(
                                    backgroundColor: Colors.transparent,
                                    body: SliderOpen(
                                      coinSymbol: coinSymbol,
                                      coinName: coinName,
                                      price: price,
                                      percentchange1h: percentchange1h,
                                      marketCap: marketCap,
                                      volume: volume,
                                      availableSupply: availableSupply,
                                      changein24HR: changein24HR,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    height: 30,
                                    width: 30,
                                    child: CachedNetworkImage(
                                      errorWidget: (context, url, error) => CircleAvatar(
                                        backgroundColor: AllCoustomTheme.getsecoundTextThemeColor(),
                                        child: Text(
                                          coinSymbol.substring(0, 1),
                                        ),
                                      ),
                                      imageUrl: coinImageURL + coinSymbol.toLowerCase() + "@2x.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        coinName,
                                        style: TextStyle(
                                          color: AllCoustomTheme.getTextThemeColors(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        coinSymbol,
                                        style: TextStyle(
                                          color: AllCoustomTheme.getsecoundTextThemeColor(),
                                          fontSize: ConstanceData.SIZE_TITLE12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        ' \$ ' + double.parse(price).toStringAsFixed(2),
                                        style: TextStyle(
                                          color: AllCoustomTheme.getTextThemeColors(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        percentchange1h.contains('-') ? '' + percentchange1h + '%' : '+' + percentchange1h + '%',
                                        style: TextStyle(
                                          color: percentchange1h.contains('-') ? Colors.red : Colors.green,
                                          fontSize: ConstanceData.SIZE_TITLE12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(
                                color: AllCoustomTheme.getsecoundTextThemeColor(),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget thirdScreen() {
    return Column(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(top: 8),
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Animator<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 500),
                    cycles: 1,
                    builder: (_, anim, __) => SizeTransition(
                      sizeFactor: anim.animation,
                      axis: Axis.horizontal,
                      axisAlignment: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            'Settings',
                            style: TextStyle(
                              color: AllCoustomTheme.getTextThemeColors(),
                              fontWeight: FontWeight.bold,
                              fontSize: ConstanceData.SIZE_TITLE25,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'General',
                            style: TextStyle(
                              color: AllCoustomTheme.getsecoundTextThemeColor(),
                              fontSize: ConstanceData.SIZE_TITLE16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          showCupertinoModalPopup<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      globals.buttoncolor1,
                                      globals.buttoncolor2,
                                    ],
                                  ),
                                ),
                                height: height / 1.8,
                                child: Scaffold(
                                  backgroundColor: Colors.transparent,
                                  body: NotificationSlider(),
                                ),
                              );
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Notifications',
                              style: TextStyle(
                                color: AllCoustomTheme.getTextThemeColors(),
                              ),
                            ),
                            AnimatedForwardArrow(
                              isShowingarroeForward: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      AnimatedDivider(),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Currency Preference',
                              style: TextStyle(
                                color: AllCoustomTheme.getTextThemeColors(),
                              ),
                            ),
                            AnimatedForwardArrow(
                              isShowingarroeForward: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: AnimatedDivider(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Alerts',
                              style: TextStyle(
                                color: AllCoustomTheme.getTextThemeColors(),
                              ),
                            ),
                            AnimatedForwardArrow(
                              isShowingarroeForward: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: AnimatedDivider(),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Account',
                            style: TextStyle(
                              color: AllCoustomTheme.getsecoundTextThemeColor(),
                              fontSize: ConstanceData.SIZE_TITLE16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (BuildContext context) => UserProfile(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'User Profile',
                              style: TextStyle(
                                color: AllCoustomTheme.getTextThemeColors(),
                              ),
                            ),
                            AnimatedForwardArrow(
                              isShowingarroeForward: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: AnimatedDivider(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (BuildContext context) => ChangePINCode(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Change PIN-code',
                              style: TextStyle(
                                color: AllCoustomTheme.getTextThemeColors(),
                              ),
                            ),
                            AnimatedForwardArrow(
                              isShowingarroeForward: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: AnimatedDivider(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: AllCoustomTheme.getTextThemeColors(),
                            ),
                          ),
                          AnimatedForwardArrow(
                            isShowingarroeForward: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _upDownMarketCap() {
    isLoadingList();
    if (marketCapUpDown == Icons.arrow_upward) {
      setState(() {
        marketCapUpDown = Icons.arrow_downward;
        marketListData.sort((a, b) => a.quote.uSD.marketCap.compareTo(b.quote.uSD.marketCap));
      });
    } else {
      setState(() {
        marketCapUpDown = Icons.arrow_upward;
        marketListData.sort((a, b) => b.quote.uSD.marketCap.compareTo(a.quote.uSD.marketCap));
      });
    }
  }

  void filterSearchResults(String query) {
    isLoadingList();
    _serchCoinList.clear();
    if (query != "") {
      marketListData.forEach((coin) {
        if (coin.symbol.toString().contains(query) ||
            coin.symbol.toString().toLowerCase().contains(query) ||
            coin.symbol.toString().toUpperCase().contains(query) ||
            coin.name.toString().contains(query) ||
            coin.name.toString().toLowerCase().contains(query) ||
            coin.name.toString().toUpperCase().contains(query)) {
          _serchCoinList.add(coin);
        }
      });
      setState(() {
        _isSearch = true;
      });
    } else {
      setState(() {
        _isSearch = false;
      });
    }
  }

  selectFirst() async {
    if (!isSelect1) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        setFirstTab();
        callItself();
      }
      setState(() {
        isSelect1 = true;
        isSelect2 = false;
        isSelect3 = false;
      });
    }
  }

  selectSecond() async {
    if (!isSelect2) {
      setState(() {
        isSelect1 = false;
        isSelect2 = true;
        isSelect3 = false;
      });
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        isLoadingList();
      }
    }
  }

  selectThird() {
    if (!isSelect3) {
      setState(() {
        isSelect1 = false;
        isSelect2 = false;
        isSelect3 = true;
      });
    }
  }

  List sampleData = [
    {"open": 50.0, "high": 100.0, "low": 40.0, "close": 80, "volumeto": 5000.0},
    {"open": 80.0, "high": 90.0, "low": 55.0, "close": 65, "volumeto": 4000.0},
    {"open": 65.0, "high": 120.0, "low": 60.0, "close": 90, "volumeto": 7000.0},
    {"open": 90.0, "high": 95.0, "low": 85.0, "close": 80, "volumeto": 2000.0},
    {"open": 80.0, "high": 85.0, "low": 40.0, "close": 50, "volumeto": 3000.0},
  ];
}
