import 'dart:io';

import 'package:flutter/foundation.dart';
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

  final List<DownloadItemProvider> _pausedDownloads = [];
  List<DownloadItemProvider> get pausedDownloads => _pausedDownloads;
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
  void cancelDownload(int index, bool isPaused) {
    {
      try {
        print("isPaused : $isPaused");
        if (isPaused) {
          _pausedDownloads.removeAt(index);
        } else {
          _activeDownloads[index].closeDownload();
        }

        notifyListeners();
      } catch (e) {
        print("Error canceling download: $e");
      }
    }
  }

  void pauseDownload(int index) async {
    if (_activeDownloads[index].model.isRunning) {
      if (Platform.isWindows) {
        if (kDebugMode) {
          print("Trying to cancel download");
        }
        await Process.run('taskkill', [
          '/PID',
          '${_activeDownloads[index].model.process?.pid}',
          '/F',
          '/T'
        ]);
      } else {
        _activeDownloads[index].model.process?.kill(ProcessSignal.sigterm);
      }
      _activeDownloads[index].model.isCompleted = false;
      _activeDownloads[index].model.isRunning = false;
      _activeDownloads[index].model.isFailed = false;
      _pausedDownloads.add(_activeDownloads[index]);
      _activeDownloads.removeAt(index);
      // if (_pendingDownloadsQueue.isNotEmpty) {
      //   final nextDownload = _pendingDownloadsQueue.removeAt(0);
      //   _startDownload(nextDownload);
      // } else {
      //   notifyListeners();
      // }
      notifyListeners();
    }
  }

  void resumeDownload(int index) async {
    try {
      // Check if we can start a new download (respecting active download limits)
      if (_activeDownloads.length < 2 &&
          index >= 0 &&
          index < _pausedDownloads.length) {
        // Retrieve paused download data
        final data = _pausedDownloads[index];

        // Ensure resume argument is set if needed
        if (!data.model.arguments.contains('--continue')) {
          data.model.arguments.add('--continue');
        }

        // Re-add the download to the active list using the existing data
        addDownload(
          data.model.title,
          data.model.url,
          data.model.arguments,
          data.model.outputPath,
          data.model.description,
        );

        // Remove from paused list
        _pausedDownloads.removeAt(index);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error resuming download: $e");
      }
    }

    notifyListeners();
  }
}
