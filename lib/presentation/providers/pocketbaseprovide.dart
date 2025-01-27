import 'package:flutter/material.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketBaseProvider extends ChangeNotifier {
  final PocketBaseClient _pocketBaseClient =
      PocketBaseClient(baseUrl: 'http://127.0.0.1:8090');

  PocketBaseClient get pocketBaseClient => _pocketBaseClient;

  void initializeRequestsStreamController() {
    _pocketBaseClient.initializeRequestsStreamController();
    notifyListeners();
  }

  Future<void> authenticate(String mobileNumber, String password) async {
    await _pocketBaseClient.authenticate(mobileNumber, password);
    notifyListeners();
  }

  Future<void> register(
      String mobileNumber, String password, String name) async {
    await _pocketBaseClient.register(mobileNumber, password, name);
    notifyListeners();
  }

  Future<void> logout() async {
    await _pocketBaseClient.logout();
    notifyListeners();
  }

  bool checkAuth() {
    return _pocketBaseClient.checkAuth();
  }

  Future<void> createRequest(Map<String, dynamic> data) async {
    await _pocketBaseClient.createRequest(data);
    notifyListeners();
  }

  Stream<List<RecordModel>> getLiveRequests() {
    return _pocketBaseClient.getLiveRequests();
  }

  void dispose() {
    _pocketBaseClient.dispose();
    super.dispose();
  }
}
