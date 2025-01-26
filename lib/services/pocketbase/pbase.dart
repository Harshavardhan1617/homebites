import 'package:pocketbase/pocketbase.dart';
import 'rt_to_stream.dart';

class PocketBaseClient {
  final PocketBase pb;
  RequestsStreamController? requestsStreamController;

  PocketBaseClient({String baseUrl = 'http://127.0.0.1:8090'})
      : pb = PocketBase(baseUrl);

  // Initialize the RequestsStreamController
  void initializeRequestsStreamController() {
    requestsStreamController = RequestsStreamController(pb: pb);
  }

  // Authenticate user using mobile number and password
  Future<void> authenticate(String mobileNumber, String password) async {
    // add +91 prefix to mobile number if not present
    mobileNumber =
        mobileNumber.startsWith('+91') ? mobileNumber : '+91 $mobileNumber';
    try {
      final authData =
          await pb.collection('users').authWithPassword(mobileNumber, password);
      print('Authenticated: ${authData}');
    } catch (e) {
      print('Error authenticating: $e');
    }
  }

  // Register user
  Future<void> register(
      String mobileNumber, String password, String name) async {
    try {
      final body = {
        //modify mobile number such that it is in the format +91 xxxxxxxxxx when the recieved string dont have the +91 prefix
        'mobile_number': mobileNumber.startsWith('+91')
            ? mobileNumber
            : '+91 ${mobileNumber}',
        // 'mobile_number': mobileNumber,
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

  // Check auth status and return boolean
  bool checkAuth() {
    try {
      final bool isAuthenticated = pb.authStore.isValid;
      return isAuthenticated;
    } catch (e) {
      print('Error checking auth status: $e');
      return false;
    }
  }

  // Create a new request
  Future<void> createRequest(Map<String, dynamic> data) async {
    try {
      final record = await pb.collection('requests').create(body: data);
      print('Request created: ${record.id}');
    } catch (e) {
      print('Error creating request: $e');
    }
  }

  // Get live requests stream
  Stream<List<RecordModel>> getLiveRequests() {
    if (requestsStreamController == null) {
      throw Exception('RequestsStreamController is not initialized.');
    }
    return requestsStreamController!.requestsStream;
  }

  // Dispose the stream controller
  void dispose() {
    requestsStreamController?.dispose();
  }
}
