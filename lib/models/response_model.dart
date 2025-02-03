class ResponseModel {
  final String responseTo;
  final String? note;
  final String? price;

  ResponseModel({
    required this.responseTo,
    this.note,
    this.price,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      responseTo: json['response_to'],
      note: json['note'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_to': responseTo,
      'note': note,
      'price': price,
    };
  }
}
