import 'dart:async';
import 'package:pocketbase/pocketbase.dart';

class RequestsStreamController {
  final PocketBase pb;
  late final StreamController<List<RecordModel>> _controller;
  final String myId;
  List<RecordModel> _currentRequests = [];
  UnsubscribeFunc? _unsubscribe;

  RequestsStreamController({required this.pb, required this.myId}) {
    _controller = StreamController<List<RecordModel>>(onCancel: dispose);
    _loadInitialData(myId);
    _subscribeToChanges(myId);
  }

  Stream<List<RecordModel>> get requestsStream => _controller.stream;

  Future<void> _loadInitialData(String myId) async {
    try {
      _currentRequests = await pb.collection('requests').getFullList(
            sort: '-created',
            expand: 'requested_user',
            filter: "requested_user!='$myId'",
          );
      if (!_controller.isClosed) {
        _controller.add(_currentRequests);
      }
    } catch (e) {
      print('Error loading initial data: $e');
      if (!_controller.isClosed) {
        _controller.addError(e);
      }
    }
  }

  Future<void> _subscribeToChanges(String myId) async {
    try {
      _unsubscribe = await pb.collection('requests').subscribe(
        expand: 'requested_user',
        filter: "requested_user!='$myId'",
        '*',
        (e) {
          if (!_controller.isClosed) {
            switch (e.action) {
              case 'create':
                final newRecord = RecordModel.fromJson(e.record!.data);
                _currentRequests.add(newRecord);
                _controller.sink.add(_currentRequests.reversed.toList());
                break;
              case 'delete':
                final deletedRecordId = e.record!.id;
                _currentRequests
                    .removeWhere((record) => record.id == deletedRecordId);
                _controller.sink.add(_currentRequests.reversed.toList());
                break;
            }
          }
        },
      );
    } catch (e) {
      print('Error subscribing to changes: $e');
      if (!_controller.isClosed) {
        _controller.addError(e);
      }
    }
  }

  Future<void> refreshData() async {
    await _loadInitialData(myId);
  }

  void dispose() {
    _unsubscribe?.call();
    _controller.close();
  }
}
