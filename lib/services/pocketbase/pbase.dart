import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  final PocketBase pb;

  PocketBaseService({String baseUrl = 'http://127.0.0.1:8090'})
      : pb = PocketBase(baseUrl);

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

  // Request Methods
  Future<RecordModel> createRequest(Map<String, dynamic> data) async {
    return await pb.collection('requests').create(body: data);
  }

  Future<List<RecordModel>> getRequests() async {
    return await pb.collection('requests').getFullList();
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
