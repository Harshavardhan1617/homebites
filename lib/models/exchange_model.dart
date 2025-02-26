class ExchangeModel {
  Map<String, dynamic> data = {};

  ExchangeModel(
      {bool? isAccepted,
      bool? isConfirmed,
      bool? isCooking,
      bool? isReady,
      bool? isRecieved}) {
    data['isAccepted'] = isAccepted;
    data['isConfirmed'] = isConfirmed;
    data['isCooking'] = isCooking;
    data['isRecieved'] = isRecieved;
    data['isReady'] = isReady;
  }

  ExchangeModel.fromMap(Map<String, dynamic> map) {
    data = Map.from(map);
  }

  Map<String, dynamic> toMap() {
    return Map.from(data);
  }
}
