import 'package:pocketbase/pocketbase.dart';
import 'rt_to_stream.dart';

class PocketBaseClient {
  final PocketBase pb;
  late RequestsStreamController requestsStreamController;

  PocketBaseClient({String baseUrl = 'http://127.0.0.1:8090'})
      : pb = PocketBase(baseUrl) {
    requestsStreamController = RequestsStreamController(pb: pb);
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
