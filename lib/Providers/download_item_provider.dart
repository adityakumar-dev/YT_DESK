import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:yt_desk/Models/download_model.dart';

class DownloadItemProvider extends ChangeNotifier {
  DownloadItemModel _model = DownloadItemModel(
      url: '', arguments: [], outputPath: '', title: '', description: '');
  DownloadItemModel get model => _model;
  Future<void> startDownload(DownloadItemModel item) async {
    _model = item;
    _model.isRunning = true;
    // print(
    //     "Download Starting: Arguments = ${_model.arguments}, Output Path = ${_model.outputPath}");
    notifyListeners();

    try {
      // print(item.arguments);
      // print("Attempting to start process...");

      _model.process = await Process.start(
        'yt-dlp', // Ensure the path is correct or use '/full/path/to/yt-dlp' if necessary
        _model.arguments,

        // workingDirectory: _model.outputPath,
      );

      // print("Download process started successfully.");

      _model.process!.stdout.transform(utf8.decoder).listen(
        (data) {
          if (kDebugMode) {
//  print("Stdout received: $data");
          }
          _model.stdout = data;

          final progressMatch = RegExp(r'(\d+)%').firstMatch(_model.stdout);
          if (progressMatch != null) {
            _model.progressPercentage =
                double.tryParse(progressMatch.group(1) ?? '') ?? 0.0 / 100;
            if (kDebugMode) {
              // print("Progress updated: ${_model.progressPercentage}");
            }
            notifyListeners();
          }
        },
      );

      _model.process!.stderr.transform(utf8.decoder).listen(
        (data) {
          if (kDebugMode) {
            print("Stderr received: $data");
          }
          _model.stderr = data;
          notifyListeners();
        },
      );

      final exitCode = await _model.process!.exitCode;
      if (kDebugMode) {
        print("Download process exited with code: $exitCode");
      }

      if (exitCode != 0) {
        if (kDebugMode) {
          print("Download failed with exit code: $exitCode");
        }
        _model.isFailed = true;
        _model.isCompleted = true;
        _model.isRunning = false;
      } else {
        if (kDebugMode) {
          print("Download completed successfully.");
        }
        _model.isFailed = false;
        _model.isCompleted = true;
        _model.isRunning = false;
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Exception caught during download: $e");
      }
      _model.isFailed = true;
      _model.isCompleted = true;
      _model.isRunning = false;

      notifyListeners();
    }
  }

  void closeDownload() async {
    if (_model.isRunning) {
      if (Platform.isWindows) {
        if (kDebugMode) {
          print("Trying to cancel download");
        }
        await Process.run(
            'taskkill', ['/PID', '${_model.process?.pid}', '/F', '/T']);
      } else {
        _model.process?.kill(ProcessSignal.sigterm);
      }

      _model.isCompleted = true;
      _model.isRunning = false;
      _model.isFailed = true;
      notifyListeners();
    }
  }
}
