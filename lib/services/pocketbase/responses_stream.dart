import 'dart:async';
import 'package:pocketbase/pocketbase.dart';

class ResponsesStream {
  final PocketBase pb;
  late final StreamController<List<RecordModel>> _controller;
  List<RecordModel> _currentResponses = [];
  UnsubscribeFunc? _unsubscribe;

  ResponsesStream({required this.pb}) {
    _controller = StreamController<List<RecordModel>>(onCancel: dispose);
    _loadInitialData();
    _subscribeToChanges();
  }

  Stream<List<RecordModel>> get responseStream => _controller.stream;

  Future<void> _loadInitialData() async {
    try {
      _currentResponses = await pb.collection('responses').getFullList(
            sort: '-created',
          );
      _controller.add(_currentResponses);
    } catch (e) {
      print('Error loading initial data: $e');
      _controller.addError(e);
    }
  }

  Future<void> _subscribeToChanges() async {
    try {
      _unsubscribe = await pb.collection('responses').subscribe(
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
    await _loadInitialData();
  }

  // Don't forget to dispose
  void dispose() {
    _unsubscribe?.call();
    _controller.close();
  }
}
