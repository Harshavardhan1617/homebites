import 'package:pocketbase/pocketbase.dart';
import 'rt_to_stream.dart';

class PocketBaseClient {
  final PocketBase pb;
  late RequestsStreamController requestsStreamController;

  PocketBaseClient({String baseUrl = 'http://127.0.0.1:8090'})
      : pb = PocketBase(baseUrl) {
    requestsStreamController = RequestsStreamController(pb: pb);
  }

  // Authenticate user using mobile number and password
  Future<void> authenticate(String mobileNumber, String password) async {
    try {
      final authData =
          await pb.collection('users').authWithPassword(mobileNumber, password);
      print('Authenticated: ${authData.token}');
      print(pb.authStore.isValid);
      print(pb.authStore.token);
      print(pb.authStore.record?.id);
    } catch (e) {
      print('Error authenticating: $e');
    }
  }

  // Register user
  Future<void> register(
      String mobileNumber, String password, String name) async {
    try {
      final body = {
        'mobile_number': mobileNumber,
        'password': password,
        'passwordConfirm': password,
        'name': name,
      };
      final record = await pb.collection('users').create(body: body);
      print('Registered: ${record.id}');
    } catch (e) {
      print('Error registering: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      pb.authStore.clear();
      print('Logged out');
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  // get live requests stream
  Stream<List<RecordModel>> getLiveRequests() {
    return requestsStreamController.requestsStream;
  }

  // Dispose the stream controller
  void dispose() {
    requestsStreamController.dispose();
  }
}
