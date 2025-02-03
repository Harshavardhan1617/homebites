import 'package:home_bites/services/pocketbase/requests_stream.dart';
import 'package:pocketbase/pocketbase.dart';

class RequestsStreamControllerFactory {
  static RequestsStreamController? _instance;

  static RequestsStreamController getInstance(PocketBase pb) {
    _instance ??= RequestsStreamController(pb: pb);
    return _instance!;
  }

  static void dispose() {
    _instance?.dispose();
    _instance = null;
  }
}
