import 'package:flutter/material.dart';
import 'package:yt_desk/services/download_model.dart';

class DownloadManager extends ChangeNotifier {
  final List<DownloadModel> _processes = [];

  List<DownloadModel> get processes => _processes;

  void addDownload(
      String title, String url, List<String> arguments, String path) {
    DownloadModel download = DownloadModel(
        title: title, url: url, arguments: arguments, outputPath: path);
    download.startDownload();

    download.addListener(
      () {
        notifyListeners();
      },
    );
    _processes.add(download);
    notifyListeners();
  }

  void cancelDownload(int index) {
    if (index >= 0 && index < _processes.length) {
      _processes[index].closeDownload();
      notifyListeners();
    }
  }

  void removeDownload(int index) {
    if (index >= 0 && index < _processes.length) {
      _processes[index].closeDownload();
      _processes.removeAt(index);
      notifyListeners();
    }
  }
}
