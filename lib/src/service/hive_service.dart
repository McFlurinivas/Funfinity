import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'crashlytics_service.dart';

class HiveService {
  Future<void> put(Box box, String key, dynamic value) async {
    await box.put(key, value);
  }

  Future<dynamic> get(Box box, String key) async {
    return box.get(key);
  }

  Future<void> delete(Box box, String key) async {
    await box.delete(key);
  }
}

Future<String> downloadFile(
    String url, String fileName, String fileType) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}/$fileName.$fileType';

  try {
    final response = await Dio().download(url, filePath);
    if (response.statusCode == 200) {
      return filePath;
    } else {
      throw Exception('Failed to download file');
    }
  } catch (e, stackTrace) {
    await CrashlyticsService.logError(e,
        stackTrace: stackTrace, reason: 'Error downloading file');
    throw Exception('Error downloading file: $e');
  }
}

Future<String> downloadImage(String url, String filename) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    }
  } catch (e, stackTrace) {
    await CrashlyticsService.logError(e,
        stackTrace: stackTrace, reason: 'Error downloading image');
    throw Exception('Error downloading image: $e');
  }
  throw Exception('Failed to download image');
}
