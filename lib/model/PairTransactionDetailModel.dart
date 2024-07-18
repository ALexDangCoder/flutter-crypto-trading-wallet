class TransactionDetail {
  String? date;
  String? tid;
  dynamic price;
  String? type;
  late String amount;

  TransactionDetail({
    this.date,
    this.tid,
    this.price,
    this.type,
    required this.amount,
  });

  TransactionDetail.fromJson(Map<String, dynamic> json) {
    date = json['date'] ?? "";
    tid = json['tid'] ?? "";
    amount = json['amount'] ?? "";
    type = json['type'] ?? "";
    price = json['price'] ?? 0;
  }

  Map<String, dynamic> toMap() => {
        "date": date,
        "tid": tid,
        "price": price,
        "type": type,
        "amount": amount,
      };
}
