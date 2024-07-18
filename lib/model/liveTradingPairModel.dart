class TradingPair {
  String? trading;
  dynamic baseDecimals;
  String? urlSymbol;
  String? name;
  String? instantAndMarketOrders;
  String? minimumOrder;
  dynamic counterDecimals;
  String? description;

  TradingPair(
      {this.trading,
      this.baseDecimals,
      this.urlSymbol,
      this.name,
      this.instantAndMarketOrders,
      this.minimumOrder,
      this.counterDecimals,
      this.description});

  TradingPair.fromJson(Map<String, dynamic> json) {
    trading = json['trading'] ?? "";
    baseDecimals = json['base_decimals'] ?? 0;
    urlSymbol = json['url_symbol'] ?? "";
    name = json['name'] ?? "";
    instantAndMarketOrders = json['instant_and_market_orders'] ?? "";
    minimumOrder = json['minimum_order'] ?? "";
    counterDecimals = json['counter_decimals'] ?? 0;
    description = json['description'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trading'] = this.trading;
    data['base_decimals'] = this.baseDecimals;
    data['url_symbol'] = this.urlSymbol;
    data['name'] = this.name;
    data['instant_and_market_orders'] = this.instantAndMarketOrders;
    data['minimum_order'] = this.minimumOrder;
    data['counter_decimals'] = this.counterDecimals;
    data['description'] = this.description;
    return data;
  }
}
