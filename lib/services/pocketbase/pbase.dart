import 'dart:io';

import 'package:home_bites/models/response_model.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:home_bites/models/request_model.dart';

class PocketBaseService {
  final PocketBase pb;

  PocketBaseService(
      {String baseUrl = 'http://127.0.0.1:8090', required AuthStore store})
      : pb = PocketBase(baseUrl, authStore: store);

  // Auth Methods
  Future<RecordAuth> signIn(String mobile, String password) async {
    final formattedMobile = mobile.startsWith('+91') ? mobile : '+91 $mobile';
    return await pb.collection('users').authWithPassword(
          formattedMobile,
          password,
        );
  }

  Future<RecordModel> signUp({
    required String mobile,
    required String password,
    required String name,
  }) async {
    final formattedMobile = mobile.startsWith('+91') ? mobile : '+91 $mobile';
    return await pb.collection('users').create(body: {
      'mobile_number': formattedMobile,
      'password': password,
      'passwordConfirm': password,
      'name': name,
    });
  }

  void signOut() => pb.authStore.clear();

  bool get isAuthenticated => pb.authStore.isValid;

  Future<bool> checkAuthStatus() async {
    try {
      await pb
          .collection('users')
          .authRefresh(); // Refreshes and verifies token
      return true;
    } catch (e) {
      print('Auth Check Failed: $e');
      return false;
    }
  }

  // Request Methods
  Future<RecordModel> createRequest({
    required RequestModel request,
    File? file,
  }) async {
    if (file != null) {
      final bytes = await file.readAsBytes();
      return await pb.collection('requests').create(
        body: request.toJson(),
        files: [
          MultipartFile.fromBytes(
            'voice_note',
            bytes,
            filename: 'voice_note.m4a',
          )
        ],
      );
    }

    return await pb.collection('requests').create(
          body: request.toJson(),
        );
  }

  Future<RecordModel> createResponse({required ResponseModel response}) async {
    print(response.toJson());
    return await pb.collection('responses').create(body: response.toJson());
  }

  Future<List<RecordModel>> getRequests() async {
    return await pb.collection('requests').getFullList();
  }

  Future<ResultList<RecordModel>> getResponses(requestID) async {
    return await pb
        .collection('responses')
        .getList(filter: "response_to = '$requestID'", sort: '-created');
  }

  Future<RecordModel> getRequest(String id) async {
    return await pb.collection('requests').getOne(id);
  }

  Future<RecordModel> updateRequest(
      String id, Map<String, dynamic> data) async {
    return await pb.collection('requests').update(id, body: data);
  }

  Future<void> deleteRequest(String id) async {
    await pb.collection('requests').delete(id);
  }
}
