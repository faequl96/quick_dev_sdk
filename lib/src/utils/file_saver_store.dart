import 'package:flutter/services.dart';

class FileSaverStore {
  static const MethodChannel _channel = MethodChannel('media_store_channel');

  static Future<String?> saveFileToDownloads(Uint8List bytes, String fileName) async {
    try {
      final String? uri = await _channel.invokeMethod('saveFileToDownloads', {
        'fileName': fileName,
        'bytes': bytes,
      });
      return uri;
    } on PlatformException catch (e) {
      print('Error saving file: ${e.message}');
      return null;
    }
  }
}
