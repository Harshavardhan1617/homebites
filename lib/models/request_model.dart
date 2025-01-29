class RequestModel {
  final String mealType;
  final String requestedUser;
  final bool vegetarian;
  final bool? active;
  final String? textNote;

  RequestModel({
    required String mealType,
    required this.requestedUser,
    required this.vegetarian,
    this.active,
    this.textNote,
  }) : mealType = mealType.toLowerCase();

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      mealType: json['meal_type'],
      requestedUser: json['requested_user'],
      vegetarian: json['vegetarian'],
      active: json['active'],
      textNote: json['text_note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_type': mealType,
      'requested_user': requestedUser,
      'vegetarian': vegetarian,
      'active': active,
      'text_note': textNote,
    };
  }
}
