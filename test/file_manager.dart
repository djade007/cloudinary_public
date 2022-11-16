import 'dart:io';
import 'dart:typed_data';

const videoSize = 1024 * 1024 * 50; // 50MB

File getFile() {
  File file = File('../test/icon.png');
  try {
    file.lengthSync();
  } catch (exception) {
    file = File('test/icon.png');
  }
  return file;
}

Future<ByteData> getFutureByteData() async {
  final tempFile = getFile();
  Uint8List uIntBytes = tempFile.readAsBytesSync();
  ByteData bytes = (ByteData.view(uIntBytes.buffer));
  return Future.value(bytes);
}

// To test video add sample video to test folder
File getVideoFile() {
  final file = File('test/video.mp4');
  if (file.existsSync()) {
    return file;
  }

  file.writeAsBytesSync(List.filled(videoSize, 0));
  return file;
}

Future<ByteData> getFutureVideoByteData() {
  final tempFile = getVideoFile();
  Uint8List uIntBytes = tempFile.readAsBytesSync();
  ByteData bytes = (ByteData.view(uIntBytes.buffer));
  return Future.value(bytes);
}

Future<void> deleteGeneratedVideoFile() async {
  final file = getVideoFile();
  if (file.existsSync()) {
    await file.delete();
  }
}
