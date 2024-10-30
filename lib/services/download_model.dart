import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class DownloadModel extends ChangeNotifier {
  Process? process;
  String title = '';
  bool isRunning = false;
  bool isCompleted = false;
  bool? isFailed;
  String stdout = '';
  String stderr = '';
  final List<String> arguments;
  final String url;
  final String outputPath;
  final StreamController<double> _progressController =
      StreamController<double>();

  DownloadModel({
    required this.url,
    required this.arguments,
    required this.outputPath,
    required this.title,
  });

  Stream<double> get progressStream => _progressController.stream;

  Future<void> startDownload() async {
    isRunning = true;
    notifyListeners();

    process = await Process.start(
      'yt-dlp',
      arguments,
      // workingDirectory: outputPath,
    );

    process!.stdout.transform(utf8.decoder).listen((data) {
      stdout = data;
      print(data);
      final progressMatch = RegExp(r'(\d+)%').firstMatch(stdout);
      if (progressMatch != null) {
        final progress = double.tryParse(progressMatch.group(1) ?? '') ?? 0.0;
        _progressController.add(progress / 100);
        notifyListeners(); // Notify listeners on progress update
      }
    });

    process!.stderr.transform(utf8.decoder).listen((data) {
      stderr = data;
      notifyListeners(); // Notify listeners on error
    });

    await process!.exitCode.then((value) {
      isRunning = false;
      isCompleted = true;
      if (value == 0) {
        isFailed = false;
      } else {
        isFailed = true;
      }
      _progressController.close();
      notifyListeners(); // Notify listeners when the download is completed
    });
  }

  void dispose() {
    _progressController.close();
    super.dispose();
  }

  void closeDownload() async {
    if (isRunning) {
      process?.kill(ProcessSignal.sigterm);
      isCompleted = true;
      isRunning = false;
      isFailed = true;
      _progressController.close();
      notifyListeners();
    }
  }

  void deleteFile() async {
    try {
      var file = Directory(outputPath).listSync().whereType<File>();
      for (var f in file) {
        final filename = f.uri.pathSegments.last;
        if (filename.startsWith(title)) {
          try {
            await f.delete();
          } catch (e) {
            print(e);
          }
        }
      }
      for (var f in file) {
        await f.delete();
      }
    } catch (e) {
      print("Error Deleting file");
    }
  }
}
