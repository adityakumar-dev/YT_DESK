import 'package:flutter/material.dart';
import 'package:yt_desk/Models/download_model.dart';
import 'package:yt_desk/Providers/download_item_provider.dart';

class DownloadManagerProvider extends ChangeNotifier {
  // List of active downloads, max 2 at a time.
  final List<DownloadItemProvider> _activeDownloads = [];
  List<DownloadItemProvider> get activeDownloads => _activeDownloads;

  // Queue for pending downloads
  final List<DownloadItemModel> _pendingDownloadsQueue = [];
  List<DownloadItemModel> get pendingDownloadsQueue => _pendingDownloadsQueue;

  // List of completed downloads
  final List<DownloadItemProvider> _completedDownloads = [];
  List<DownloadItemProvider> get completedDownloads => _completedDownloads;

  // Function to add a download to the manager
  void addDownload(String title, String url, List<String> arguments,
      String path, String description) {
    // Create a new download item
    final download = DownloadItemModel(
      title: title,
      url: url,
      arguments: arguments,
      outputPath: path,
      description: description,
    );

    if (_activeDownloads.length < 2) {
      // Start download immediately if below limit
      _startDownload(download);
    } else {
      // Add to pending queue if limit reached
      _pendingDownloadsQueue.add(download);
    }
    notifyListeners();
  }

  // Internal function to start a download
  void _startDownload(DownloadItemModel download) {
    final downloadItemProvider = DownloadItemProvider();
    downloadItemProvider.startDownload(download);

    // Listen for download completion and cleanup after completion
    void _listener() {
      if (downloadItemProvider.model.isCompleted) {
        _onDownloadComplete(downloadItemProvider);
        downloadItemProvider
            .removeListener(_listener); // Remove listener after completion
      }
      notifyListeners();
    }

    downloadItemProvider.addListener(_listener);

    // Add to active downloads
    _activeDownloads.add(downloadItemProvider);
    notifyListeners();
  }

  void cancelPendingDownload(int index) {
    if (index >= 0 && index < _pendingDownloadsQueue.length) {
      _pendingDownloadsQueue.removeAt(index);
      notifyListeners();
    }
  }

  void cancelCompletedDownload(int index) {
    if (index >= 0 && index < _completedDownloads.length) {
      _completedDownloads.removeAt(index);
      notifyListeners();
    }
  }

  // Handler for when a download completes
  void _onDownloadComplete(DownloadItemProvider downloadItemProvider) {
    // Remove from active downloads and add to completed
    _activeDownloads.remove(downloadItemProvider);
    _completedDownloads.add(downloadItemProvider);

    // Start the next pending download, if any
    if (_pendingDownloadsQueue.isNotEmpty) {
      final nextDownload = _pendingDownloadsQueue.removeAt(0);
      _startDownload(nextDownload);
    }

    notifyListeners();
  }

  // Cancel an active download
  void cancelDownload(int index) {
    if (index >= 0 && index < _activeDownloads.length) {
      try {
        _activeDownloads[index].closeDownload();

        notifyListeners();
      } catch (e) {
        print("Error canceling download: $e");
      }
    }
  }
}
