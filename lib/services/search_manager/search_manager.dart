import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class SearchManager {
  static Map? outputStr;
  static String errorOutput = "";
  static List _mediaDetails = [];
  static String _thumbnailUrl = "";
  static String _title = "";
  static bool _isPlaylistFound = false;
  static String _publicUrl = "";
  static String _description = "";
  static List<Map<String, dynamic>> _playlistEntries = [];
  static bool get isPlaylistFound => _isPlaylistFound;
  static String get publicUrl => _publicUrl;
  static String get thumbnailUrl => _thumbnailUrl;
  static String get title => _title;
  static String get description => _description;
  static List get mediaDetails => _mediaDetails;
  static List<Map<String, dynamic>> get playlistEntries => _playlistEntries;
  static List<String> playListThumnail = [];

  static Future searchPlaylistThumnailUrl(String url) async {
    try {
      Process result = await Process.start(
        "yt-dlp",
        [
          '--user-agent',
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
          '--skip-download',
          '--get-thumbnail',
          url
        ],
      );

      final outputBytes = await result.stdout
          .fold<List<int>>([], (acc, data) => acc..addAll(data));
      playListThumnail.add(utf8.decode(outputBytes).trim());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static Future<void> searchThumbnail(String url) async {
    try {
      _thumbnailUrl = "";
      Process result = await Process.start(
        "yt-dlp",
        [
          '--user-agent',
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36',
          '--skip-download',
          '--get-thumbnail',
          url
        ],
      );

      final outputBytes = await result.stdout
          .fold<List<int>>([], (acc, data) => acc..addAll(data));
      _thumbnailUrl = utf8.decode(outputBytes).trim();

      print("Thumbnail URL: $_thumbnailUrl");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static Future<int> search(String url) async {
    _isPlaylistFound = false;
    _publicUrl = url;
    final playList = [];
    print(_publicUrl);
    try {
      List<String> args;
      if (url.contains("playlist")) {
        _isPlaylistFound = true;
        args = ['--flat-playlist', '--print-json', '--skip-download', url];
      } else {
        args = ['--print-json', '--skip-download', url];
      }
      Process process = await Process.start("yt-dlp", args);

      final outputBytes = await process.stdout
          .fold<List<int>>([], (acc, data) => acc..addAll(data));
      final errorBytes = await process.stderr
          .fold<List<int>>([], (acc, data) => acc..addAll(data));
      final outputString = utf8.decode(outputBytes);
      errorOutput = utf8.decode(errorBytes);
      List convertedOutput = outputString.split('}}');
      // print(convertedOutput);
      for (int i = 0; i < convertedOutput.length; i++) {
        convertedOutput[i] = convertedOutput[i] + "}}";
      }

      if (url.contains("playlist")) {
        // Handle playlist output
        List<String> convertedOutput = outputString.split('}}');
        for (int i = 0; i < convertedOutput.length; i++) {
          convertedOutput[i] = convertedOutput[i] + "}}";
        }

        for (String str in convertedOutput) {
          try {
            playList.add(jsonDecode(str));
          } catch (e) {
            print("JSON decoding error for playlist item: $e");
          }
        }
        print("Playlist data: ${playList[0]}");
      } else {
        // Handle single video output
        try {
          outputStr = jsonDecode(outputString);
        } catch (e) {
          print("JSON decoding error for video: $e");
        }
      }
      final exitCode = await process.exitCode;
      print(exitCode);
      if (exitCode == 0) {
        if (url.contains("playlist")) {
          extractPlaylistData(playList);
        } else {
          _title = outputStr!['title'] ?? 'No Title';
          _description = outputStr!['description']?.trim() ?? 'No Description';
          await searchThumbnail(url);

          extractData();
        }
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

  static Future<void> extractPlaylistData(List playList) async {
    try {
      _playlistEntries.clear();

      for (var entry in playList) {
        Map<String, dynamic> videoData = {
          'title': entry['title'] ?? 'No Title',
          'description': entry['description']?.trim() ?? 'No Description',
          'url': entry['url'] ?? 'No URL',
          'thumbnail': entry['thumbnail'] ?? '',
          'duration': entry['duration'] != null
              ? '${(entry['duration'] / 60).toStringAsFixed(2)} mins'
              : 'Unknown',
        };
        _playlistEntries.add(videoData);
      }

      // print("Playlist Entries:");
      // for (var entry in _playlistEntries) {
      //   print(entry);
      // }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
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
              '${format['filesize'] != null ? (format['filesize'] / (1024 * 1024)).toStringAsFixed(2) + " MB" : 'Unknown'}',
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
