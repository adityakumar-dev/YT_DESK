import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yt_desk/Models/download_model.dart';

class DownloadItemProvider extends ChangeNotifier {
  DownloadItemModel _model =
      DownloadItemModel(url: '', arguments: [], outputPath: '', title: '');
  DownloadItemModel get model => _model;

  Future<void> startDownload(DownloadItemModel item) async {
    _model = item;
    _model.isRunning = true;
    notifyListeners();

    _model.process = await Process.start(
      'yt-dlp',
      _model.arguments,
      workingDirectory: _model.outputPath,
    );
    _model.process!.stdout.transform(utf8.decoder).listen(
      (data) {
        _model.stdout = data;
        if (kDebugMode) {
          print("Stdout : $data");
        }
        final progressMatch = RegExp(r'(\d+)%').firstMatch(_model.stdout);
        if (progressMatch != null) {
          _model.progressPercentage =
              double.tryParse(progressMatch.group(1) ?? '') ?? 0.0 / 100;
          notifyListeners();
        }
      },
    );
    _model.process!.stderr.transform(utf8.decoder).listen((data) {
      _model.stderr = data;
      notifyListeners();
    });
    final exitCode = await _model.process!.exitCode;
    if (exitCode != 0) {
      _model.isFailed = true;
      _model.isCompleted = true;
      _model.isRunning = false;
    } else {
      _model.isFailed = false;
      _model.isCompleted = true;
      _model.isRunning = false;
    }
  }

  void closeDownload() async {
    if (_model.isRunning) {
      _model.process?.kill(ProcessSignal.sigterm);
      _model.isCompleted = true;
      _model.isRunning = false;
      _model.isFailed = true;
      notifyListeners();
    }
  }
}
