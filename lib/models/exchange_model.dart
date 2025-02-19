class ExchangeModel {
  Map<String, dynamic> data = {};

  ExchangeModel({bool? isAccepted, bool? isConfirmed}) {
    data['isAccepted'] = isAccepted;
    data['isConfirmed'] = isConfirmed;
  }

  ExchangeModel.fromMap(Map<String, dynamic> map) {
    data = Map.from(map);
  }

  Map<String, dynamic> toMap() {
    return Map.from(data);
  }
}