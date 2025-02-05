import 'dart:async';
import 'package:pocketbase/pocketbase.dart';

class ResponseDashboardStream {
  final PocketBase pb;
  final String collectionName;
  final String recordId;

  final StreamController<RecordModel> _controller =
      StreamController<RecordModel>.broadcast();

  ResponseDashboardStream(
      {required this.pb,
      required this.collectionName,
      required this.recordId}) {
    _fetchInitialData();
    _startListening();
  }

  Stream<RecordModel> get stream => _controller.stream;

  Future<void> _fetchInitialData() async {
    try {
      final initialRecord =
          await pb.collection(collectionName).getOne(recordId);
      _controller.sink.add(RecordModel.fromJson(initialRecord.toJson()));
    } catch (e) {
      _controller.addError("Error fetching initial data: $e");
    }
  }

  void _startListening() {
    pb.collection(collectionName).subscribe(recordId, (event) {
      if (event.action == "update" || event.action == "create") {
        final updatedRecord = RecordModel.fromJson(event.record!.data);
        _controller.sink.add(updatedRecord);
      }
    });
  }

  void dispose() {
    pb.collection(collectionName).unsubscribe(recordId);
    _controller.close();
  }
}
