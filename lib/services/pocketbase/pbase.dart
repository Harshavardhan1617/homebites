import 'package:pocketbase/pocketbase.dart';

class PocketBaseClient {
  final PocketBase pb;

  PocketBaseClient({String baseUrl = 'http://127.0.0.1:8090'})
      : pb = PocketBase(baseUrl);

  // get paginated records
  Future<List<RecordModel>> getPaginatedRecords(
      {String collection = 'requests',
      String expand = "requested_user"}) async {
    try {
      final records = await pb.collection(collection).getFullList(
            expand: expand,
          );
      return records;
    } catch (e) {
      print('Error fetching records: $e');
      return [];
    }
  }
}
