import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  var status = await Permission.camera.request();
  if (status.isGranted) {
    status = await Permission.storage.request();
    if (!status.isGranted) {
      // Handle storage permission denied
    }
  } else {
    // Handle camera permission denied
  }
}
