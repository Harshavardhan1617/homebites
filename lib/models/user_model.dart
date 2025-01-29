class UserModel {
  String password;
  String passwordConfirm;
  String email;
  bool emailVisibility;
  bool verified;
  String name;
  String mobileNumber;
  Map<String, String> location;
  bool isVegetarian;

  UserModel({
    required this.password,
    required this.passwordConfirm,
    required this.email,
    required this.emailVisibility,
    required this.verified,
    required this.name,
    required this.mobileNumber,
    required this.location,
    required this.isVegetarian,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      password: json['password'],
      passwordConfirm: json['passwordConfirm'],
      email: json['email'],
      emailVisibility: json['emailVisibility'],
      verified: json['verified'],
      name: json['name'],
      mobileNumber: json['mobile_number'],
      location: Map<String, String>.from(json['location']),
      isVegetarian: json['is_vegetarian'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'passwordConfirm': passwordConfirm,
      'email': email,
      'emailVisibility': emailVisibility,
      'verified': verified,
      'name': name,
      'mobile_number': mobileNumber,
      'location': location,
      'is_vegetarian': isVegetarian,
    };
  }
}
