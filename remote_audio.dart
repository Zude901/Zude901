import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class RemoteAudioService {
  // Map audio files to their Firebase Storage URLs
  static final Map<String, String> audioUrls = {
    'story1s.wav': 'https://firebasestorage.googleapis.com/v0/b/tale-875f2.firebasestorage.app/o/audio%2Fstory1s.wav?alt=media&token=8dbe73e8-4b3f-42e0-8c1a-a2826468267c',
    // Add other audio files with their URLs when you upload them
    'story1.wav': '', // Add URL after uploading
    'story1h.wav': '', // Add URL after uploading
    'story2.wav': '', // Add URL after uploading
    'story2h.wav': '', // Add URL after uploading
    'story2s.wav': '', // Add URL after uploading
    'story3.wav': '', // Add URL after uploading
    'story3h.wav': '', // Add URL after uploading
    'story3s.wav': '', // Add URL after uploading
  };

  /// Downloads an audio file and returns the local path
  static Future<String> getAudioFilePath(String fileName) async {
    // Check if URL exists for the requested file
    final url = audioUrls[fileName];
    if (url == null || url.isEmpty) {
      debugPrint('No URL defined for $fileName - using local asset');
      // Return special URI to indicate using asset instead
      return 'asset:///assets/audio/$fileName';
    }
    
    // Get app's document directory for caching files
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    
    // If file already exists in cache, return its path
    if (await file.exists()) {
      debugPrint('Loading $fileName from cache');
      return filePath;
    }
    
    // Otherwise download and save the file
    debugPrint('Downloading $fileName');
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Failed to download $fileName: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading $fileName: $e');
      // Fallback - if download fails, try to use local asset
      return 'asset:///assets/audio/$fileName';
    }
  }
  
  /// Clear all cached audio files
  static Future<void> clearCache() async {
    final directory = await getApplicationDocumentsDirectory();
    
    for (final fileName in audioUrls.keys) {
      final file = File('${directory.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  // Add this method and call it before downloading large files
  static Future<bool> checkStorageSpace() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final stat = await directory.stat();
      final freeSpace = stat.size;
      debugPrint('Free storage space: $freeSpace bytes');
      return freeSpace > 10 * 1024 * 1024; // 10 MB minimum
    } catch (e) {
      debugPrint('Error checking storage: $e');
      return true; // Assume there's enough space if we can't check
    }
  }
}
