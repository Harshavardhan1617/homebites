import 'dart:async';
import 'package:pocketbase/pocketbase.dart';

class ResponsesStream {
  final PocketBase pb;
  final String responseTo;
  late final StreamController<List<RecordModel>> _controller;
  List<RecordModel> _currentResponses = [];
  UnsubscribeFunc? _unsubscribe;

  ResponsesStream({required this.pb, required this.responseTo}) {
    _controller =
        StreamController<List<RecordModel>>.broadcast(onCancel: dispose);
    _loadInitialData(responseTo);
    _subscribeToChanges(responseTo);
  }

  Stream<List<RecordModel>> get responseStream => _controller.stream;

  Future<void> _loadInitialData(String responseTo) async {
    try {
      _currentResponses = await pb.collection('responses').getFullList(
            filter: "response_to='$responseTo'",
            sort: '-created',
            expand: 'response_by',
          );
      _controller.add(_currentResponses);
    } catch (e) {
      print('Error loading initial data: $e');
      _controller.addError(e);
    }
  }

  Future<void> _subscribeToChanges(String responseTo) async {
    print(responseTo);
    try {
      _unsubscribe = await pb.collection('responses').subscribe(
        filter: "response_to='$responseTo'",
        expand: 'response_by',
        '*',
        (e) {
          switch (e.action) {
            case 'create':
              final newRecord = RecordModel.fromJson(e.record!.data);
              _currentResponses.add(newRecord);
              _controller.add(_currentResponses.reversed.toList());
              break;
            case 'delete':
              final deletedRecordId = e.record!.id;
              _currentResponses
                  .removeWhere((record) => record.id == deletedRecordId);
              _controller.add(_currentResponses.reversed.toList());
              break;
          }
        },
      );
    } catch (e) {
      print('Error subscribing to changes: $e');
      _controller.addError(e);
    }
  }

  // Method to manually refresh the data
  Future<void> refreshData() async {
    await _loadInitialData(responseTo);
  }

  // Don't forget to dispose
  void dispose() {
    _unsubscribe?.call();
    _controller.close();
  }
}
