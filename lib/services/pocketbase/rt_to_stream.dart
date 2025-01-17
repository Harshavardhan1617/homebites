import 'dart:async';
import 'package:pocketbase/pocketbase.dart';

class RequestsStreamController {
  final PocketBase pb;
  final _requestsController = StreamController<List<RecordModel>>.broadcast();
  List<RecordModel> _currentRequests = [];
  UnsubscribeFunc? _unsubscribe;

  RequestsStreamController({required this.pb}) {
    // Initial load of data
    _loadInitialData();
    // Subscribe to realtime updates
    _subscribeToChanges();
  }

  Stream<List<RecordModel>> get requestsStream => _requestsController.stream;

  Future<void> _loadInitialData() async {
    try {
      _currentRequests = await pb.collection('requests').getFullList(
            expand: 'requested_user',
          );
      _requestsController.add(_currentRequests);
    } catch (e) {
      print('Error loading initial data: $e');
      _requestsController.addError(e);
    }
  }

  Future<void> _subscribeToChanges() async {
    try {
      _unsubscribe = await pb.collection('requests').subscribe(
        '*',
        (e) {
          switch (e.action) {
            case 'create':
              final newRecord = RecordModel.fromJson(e.record!.data);
              _currentRequests.add(newRecord);
              _requestsController.add(_currentRequests);
              break;
            case 'delete':
              final deletedRecordId = e.record!.id;
              _currentRequests
                  .removeWhere((record) => record.id == deletedRecordId);
              _requestsController.add(_currentRequests);
              break;
          }
        },
      );
    } catch (e) {
      print('Error subscribing to changes: $e');
      _requestsController.addError(e);
    }
  }

  // Method to manually refresh the data
  Future<void> refreshData() async {
    await _loadInitialData();
  }

  // Don't forget to dispose
  void dispose() {
    _unsubscribe?.call();
    _requestsController.close();
  }
}
