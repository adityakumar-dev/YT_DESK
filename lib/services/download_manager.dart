import 'package:flutter/material.dart';
import 'package:yt_desk/services/download_model.dart';

class DownloadManager extends ChangeNotifier {
  List<DownloadModel> _processes = [];

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
    print("Download starting");
    _processes.add(download);
    print("Download started");
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
      _processes[index].closeDownload(); // Ensure to cancel if still running
      _processes.removeAt(index);
      notifyListeners();
    }
  }
}
