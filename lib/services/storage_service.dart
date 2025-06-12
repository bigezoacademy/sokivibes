import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadSong(String filePath, String fileName) async {
    // TODO: Implement upload logic
    return '';
  }

  Future<String> getDownloadUrl(String filePath) async {
    return await _storage.ref(filePath).getDownloadURL();
  }

  Future<String> downloadSong(String url, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${dir.path}/SokiVibes/downloads');
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync(recursive: true);
    }
    final filePath = '${downloadsDir.path}/$fileName.mp3';
    final file = File(filePath);
    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
