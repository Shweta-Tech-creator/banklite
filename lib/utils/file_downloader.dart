import 'file_downloader_stub.dart'
    if (dart.library.html) 'file_downloader_web.dart';

class FileDownloader {
  static void download({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) {
    downloadFileImpl(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
    );
  }
}
