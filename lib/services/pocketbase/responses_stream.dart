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
            expand: 'response_by, response_to',
          );
      sortController(_currentResponses);
      _controller.add(_currentResponses);
    } catch (e) {
      print('Error loading initial data: $e');
      _controller.addError(e);
    }
  }

  void sortController(List<RecordModel> controller) {
    _currentResponses.sort((a, b) {
      if (a.get('response_by') == pb.authStore.record!.id) return -1;
      if (b.get('response_by') == pb.authStore.record!.id) return 1;
      return b.get('created').compareTo(a.get('created'));
    });
  }

  Future<void> _subscribeToChanges(String responseTo) async {
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

              sortController(_currentResponses);

              _controller.add(_currentResponses);
              break;
            case 'update':
              final updatedRecord = RecordModel.fromJson(e.record!.data);
              final index = _currentResponses
                  .indexWhere((record) => record.id == updatedRecord.id);
              if (index != -1) {
                _currentResponses[index] = updatedRecord; // Update in place
                sortController(_currentResponses);
                _controller.add(_currentResponses);
              }
              break;
            case 'delete':
              final deletedRecordId = e.record!.id;
              _currentResponses
                  .removeWhere((record) => record.id == deletedRecordId);
              sortController(_currentResponses);
              _controller.add(_currentResponses);
              break;
          }
        },
      );
    } catch (e) {
      print('Error subscribing to changes: $e');
      _controller.addError(e);
    }
  }

  Future<void> refreshData() async {
    await _loadInitialData(responseTo);
  }

  void dispose() {
    _unsubscribe?.call();
    _controller.close();
  }
}
