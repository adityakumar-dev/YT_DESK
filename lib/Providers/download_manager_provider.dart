import 'package:flutter/material.dart';
import 'package:yt_desk/Models/download_model.dart';
import 'package:yt_desk/Providers/download_item_provider.dart';

class DownloadManagerProvider extends ChangeNotifier {
  List<DownloadItemProvider> _downloadList = [];
  List<DownloadItemProvider> get downloadList => _downloadList;

  //function for add download
  void addDownload(
      String title, String url, List<String> arguments, String path) {
    // new object of downloadItemModel
    DownloadItemModel download = DownloadItemModel(
        title: title, url: url, arguments: arguments, outputPath: path);

    DownloadItemProvider downloadItemProvider = DownloadItemProvider();
    downloadItemProvider.startDownload(download);
    // adding listener for track the downloadItemModel
    downloadItemProvider.addListener(
      () => notifyListeners(),
    );

    _downloadList.add(downloadItemProvider);

    notifyListeners();
  }

  void cancelDownload(int index) {
    if (index >= 0 && index < _downloadList.length) {
      _downloadList[index].closeDownload();
      notifyListeners();
    }
  }

  void removeDownload(int index) {
    if (index >= 0 && index < _downloadList.length) {
      _downloadList[index].closeDownload();
      _downloadList.removeAt(index);
      notifyListeners();
    }
  }
}