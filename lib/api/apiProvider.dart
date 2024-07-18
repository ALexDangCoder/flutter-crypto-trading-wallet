import 'dart:convert';
import 'package:candlesticks/candlesticks.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../constance/constance.dart';
import '../model/PairDetailInfoModel.dart';
import '../model/PairTransactionDetailModel.dart';
import '../model/liveCryptoNewsModel.dart';
import '../model/liveTradingPairModel.dart';

class ApiProvider {
  Map<String, dynamic> head = {
    "Content-Type": "application/json",
  };

  Future<List<TradingPair>> getTradingPairsDetail() async {
    List<TradingPair> responseData = [];
    try {
      var response = await Dio().get(
        ConstanceData.LiveTradingPairs,
        options: Options(
          headers: head,
        ),
      );
      if (response.statusCode == 200) {
        response.data.forEach((element) {
          TradingPair objTradingPair = TradingPair.fromJson(element);
          responseData.add(objTradingPair);
        });
      }
    } catch (e) {
      print(e);
    }
    return responseData;
  }

  Future<PairDetailInfo> getPairInfoDetail(String pairName) async {
    String urlString = ConstanceData.PairsDetail;
    PairDetailInfo responseData = new PairDetailInfo();
    try {
      var response = await Dio().get(
        urlString + pairName,
        options: Options(
          headers: head,
        ),
      );
      if (response.statusCode == 200) {
        responseData = PairDetailInfo.fromJson(response.data);
      }
    } catch (e) {
      print(e);
    }
    return responseData;
  }

  Future<List<TransactionDetail>> getPairsTransactionDetail(String pairName) async {
    String urlString = ConstanceData.PairsTransaction;
    List<TransactionDetail> responseData = [];
    try {
      var response = await Dio().get(
        urlString + pairName,
        options: Options(
          headers: head,
        ),
      );

      if (response.statusCode == 200) {
        response.data.forEach((element) {
          TransactionDetail objTransactionDetail = TransactionDetail.fromJson(element);
          responseData.add(objTransactionDetail);
        });
      }
    } catch (e) {
      print(e);
    }
    return responseData;
  }

  Future<CryptoNewsLive> cryptoNews(String pairName) async {
    String urlString = 'https://newsapi.org/v2/everything?q=$pairName&apiKey=dc47f2d8143a4a24b6935f7ea7413c63';
    CryptoNewsLive responseData = new CryptoNewsLive();
    try {
      var response = await Dio().get(
        urlString,
        options: Options(
          headers: head,
        ),
      );
      if (response.statusCode == 200) {
        responseData = CryptoNewsLive.fromJson(response.data);
      }
    } catch (e) {
      print(e);
    }
    return responseData;
  }

  Future<List<Candle>> fetchCandles({required String symbol, required String interval}) async {
    final uri = Uri.parse("https://api.binance.com/api/v3/klines?symbol=$symbol&interval=$interval&limit=1000");
    final res = await http.get(uri);
    return (jsonDecode(res.body) as List<dynamic>).map((e) => Candle.fromJson(e)).toList().reversed.toList();
  }
}
