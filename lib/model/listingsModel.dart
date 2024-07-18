class Listings {
  Status? status;
  List<CryptoCoinDetail>? data;

  Listings({this.status, this.data});

  Listings.fromJson(Map<String, dynamic> json) {
    status = json['status'] != null ? new Status.fromJson(json['status']) : null;
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new CryptoCoinDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Status {
  String? timestamp;
  int? errorCode;
  dynamic errorMessage;
  int? elapsed;
  int? creditCount;
  dynamic notice;
  int? totalCount;

  Status({this.timestamp, this.errorCode, this.errorMessage, this.elapsed, this.creditCount, this.notice, this.totalCount});

  Status.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'] ?? "";
    errorCode = json['error_code'] ?? 0;
    errorMessage = json['error_message'] ?? "";
    elapsed = json['elapsed'] ?? 0;
    creditCount = json['credit_count'] ?? 0;
    notice = json['notice'] ?? "";
    totalCount = json['total_count'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    data['error_code'] = this.errorCode;
    data['error_message'] = this.errorMessage;
    data['elapsed'] = this.elapsed;
    data['credit_count'] = this.creditCount;
    data['notice'] = this.notice;
    data['total_count'] = this.totalCount;
    return data;
  }
}

class CryptoCoinDetail {
  int? id;
  String? name;
  String? symbol;
  String? slug;
  int? numMarketPairs;
  String? dateAdded;
  List<String>? tags;
  int? maxSupply;
  dynamic circulatingSupply;
  dynamic totalSupply;
  Platform? platform;
  int? cmcRank;
  String? lastUpdated;
  Quote? quote;

  CryptoCoinDetail(
      {this.id,
      this.name,
      this.symbol,
      this.slug,
      this.numMarketPairs,
      this.dateAdded,
      this.tags,
      this.maxSupply,
      this.circulatingSupply,
      this.totalSupply,
      this.platform,
      this.cmcRank,
      this.lastUpdated,
      this.quote});

  CryptoCoinDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? "";
    symbol = json['symbol'] ?? "";
    slug = json['slug'] ?? "";
    numMarketPairs = json['num_market_pairs'] ?? 0;
    dateAdded = json['date_added'] ?? "";
    tags = json['tags'].cast<String>();
    maxSupply = json['max_supply'] ?? 0;
    circulatingSupply = json['circulating_supply'] ?? 0;
    totalSupply = json['total_supply'] ?? 0;
    platform = json['platform'] != null ? new Platform.fromJson(json['platform']) : null;
    cmcRank = json['cmc_rank'] ?? 0;
    lastUpdated = json['last_updated'] ?? "";
    quote = json['quote'] != null ? new Quote.fromJson(json['quote']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['symbol'] = this.symbol;
    data['slug'] = this.slug;
    data['num_market_pairs'] = this.numMarketPairs;
    data['date_added'] = this.dateAdded;
    data['tags'] = this.tags;
    data['max_supply'] = this.maxSupply;
    data['circulating_supply'] = this.circulatingSupply;
    data['total_supply'] = this.totalSupply;
    if (this.platform != null) {
      data['platform'] = this.platform!.toJson();
    }
    data['cmc_rank'] = this.cmcRank;
    data['last_updated'] = this.lastUpdated;
    if (this.quote != null) {
      data['quote'] = this.quote!.toJson();
    }
    return data;
  }
}

class Platform {
  int? id;
  String? name;
  String? symbol;
  String? slug;
  String? tokenAddress;

  Platform({this.id, this.name, this.symbol, this.slug, this.tokenAddress});

  Platform.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? "";
    symbol = json['symbol'] ?? "";
    slug = json['slug'] ?? "";
    tokenAddress = json['token_address'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['symbol'] = this.symbol;
    data['slug'] = this.slug;
    data['token_address'] = this.tokenAddress;
    return data;
  }
}

class Quote {
  USD? uSD;

  Quote({this.uSD});

  Quote.fromJson(Map<String, dynamic> json) {
    uSD = json['USD'] != null ? new USD.fromJson(json['USD']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.uSD != null) {
      data['USD'] = this.uSD!.toJson();
    }
    return data;
  }
}

class USD {
  dynamic price;
  dynamic volume24h;
  dynamic volumeChange24h;
  dynamic percentChange1h;
  dynamic percentChange24h;
  dynamic percentChange7d;
  dynamic percentChange30d;
  dynamic percentChange60d;
  dynamic percentChange90d;
  dynamic marketCap;
  dynamic marketCapDominance;
  dynamic fullyDilutedMarketCap;
  String? lastUpdated;

  USD(
      {this.price,
      this.volume24h,
      this.volumeChange24h,
      this.percentChange1h,
      this.percentChange24h,
      this.percentChange7d,
      this.percentChange30d,
      this.percentChange60d,
      this.percentChange90d,
      this.marketCap,
      this.marketCapDominance,
      this.fullyDilutedMarketCap,
      this.lastUpdated});

  USD.fromJson(Map<String, dynamic> json) {
    price = json['price'] ?? 0.0;
    volume24h = json['volume_24h'] ?? 0.0;
    volumeChange24h = json['volume_change_24h'] ?? 0.0;
    percentChange1h = json['percent_change_1h'] ?? 0.0;
    percentChange24h = json['percent_change_24h'] ?? 0.0;
    percentChange7d = json['percent_change_7d'] ?? 0.0;
    percentChange30d = json['percent_change_30d'] ?? 0.0;
    percentChange60d = json['percent_change_60d'] ?? 0.0;
    percentChange90d = json['percent_change_90d'] ?? 0.0;
    marketCap = json['market_cap'] ?? 0.0;
    marketCapDominance = json['market_cap_dominance'] ?? 0.0;
    fullyDilutedMarketCap = json['fully_diluted_market_cap'] ?? 0.0;
    lastUpdated = json['last_updated'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['price'] = this.price;
    data['volume_24h'] = this.volume24h;
    data['volume_change_24h'] = this.volumeChange24h;
    data['percent_change_1h'] = this.percentChange1h;
    data['percent_change_24h'] = this.percentChange24h;
    data['percent_change_7d'] = this.percentChange7d;
    data['percent_change_30d'] = this.percentChange30d;
    data['percent_change_60d'] = this.percentChange60d;
    data['percent_change_90d'] = this.percentChange90d;
    data['market_cap'] = this.marketCap;
    data['market_cap_dominance'] = this.marketCapDominance;
    data['fully_diluted_market_cap'] = this.fullyDilutedMarketCap;
    data['last_updated'] = this.lastUpdated;
    return data;
  }
}

