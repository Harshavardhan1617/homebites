class ResponseModel {
  final String responseTo;
  final String responseBy;
  final String? note;
  final String? price;

  ResponseModel({
    required this.responseTo,
    required this.responseBy,
    this.note,
    this.price,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      responseTo: json['response_to'],
      responseBy: json['response_by'],
      note: json['note'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_to': responseTo,
      'response_by': responseBy,
      'note': note,
      'price': price,
    };
  }
}
