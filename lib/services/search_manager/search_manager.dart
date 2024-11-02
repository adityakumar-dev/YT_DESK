import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class SearchManager {
  static Map? outputStr;
  static String errorOutput = "";
  static List _mediaDetails = [];
  static String _thumbnailUrl = "";
  static String _title = "";
  static String _publicUrl = "";
  static String _description = "";
  static String get publicUrl => _publicUrl;
  static String get thumbnailUrl => _thumbnailUrl;
  static String get title => _title;
  static String get description => _description;
  static List get mediaDetails => _mediaDetails;

  static Future<void> searchThumbnail(String url) async {
    try {
      _thumbnailUrl = "";
      Process result = await Process.start(
        "yt-dlp",
        ['--get-thumbnail', url],
      );
      final outputBytes = await result!.stdout
          .fold<List<int>>([], (acc, data) => acc..addAll(data));
      _thumbnailUrl = utf8.decode(outputBytes).trim();

      print("thumnail Url : ${_thumbnailUrl}");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static Future<int> search(String url) async {
    _publicUrl = url;
    print(_publicUrl);
    try {
      Process process = await Process.start(
        "yt-dlp",
        ['--dump-json', url],
      );

      final outputBytes = await process.stdout
          .fold<List<int>>([], (acc, data) => acc..addAll(data));
      final errorBytes = await process.stderr
          .fold<List<int>>([], (acc, data) => acc..addAll(data));
      final outputString = utf8.decode(outputBytes);
      errorOutput = utf8.decode(errorBytes);

      final exitCode = await process.exitCode;

      if (exitCode == 0) {
        outputStr = jsonDecode(outputString);
        _title = outputStr!['title'] ?? 'No Title';
        _description = outputStr!['description'] ?? 'No Description';
        // if(_description.isEmpty){
        _description = _description.trim();
        // }
        print(_description);
        await searchThumbnail(url);
        extractData();
      } else {
        if (kDebugMode) {
          print("Error: $errorOutput");
        }
      }

      return exitCode;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return -1;
    }
  }

  static void extractData() {
    try {
      Map jsonOutput = outputStr!;
      List<dynamic> formats = jsonOutput['formats'];
      Map<String, Map<String, dynamic>> bestFormats = {};

      for (var format in formats) {
        String resolution = format['resolution'] ?? 'audio only';
        dynamic vbr = format['vbr'];
        dynamic abr = format['abr'];

        if (!bestFormats.containsKey(resolution)) {
          bestFormats[resolution] = format;
        } else {
          var currentBest = bestFormats[resolution];
          bool isBetter = (vbr != null && (currentBest?['vbr'] ?? 0) < vbr) ||
              (abr != null && (currentBest?['abr'] ?? 0) < abr);
          if (isBetter) {
            bestFormats[resolution] = format;
          }
        }
      }

      _mediaDetails.clear();

      bestFormats.forEach((resolution, format) {
        _mediaDetails.add({
          'resolution': resolution,
          'quality': resolution != 'audio only'
              ? '${resolution.split('x')[1]}p'
              : resolution,
          'formatId': format['format_id'],
          'extension': format['ext'],
          'size':
              '${format['filesize'] != null ? (format['filesize'] / (1024 * 1024)).toStringAsFixed(2) + " MB" : 'Unknown'}', // Detailed description for easy access
        });
      });

      _mediaDetails = _mediaDetails
          .where((element) => element['extension'] != 'mhtml')
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
