import 'dart:async';
import 'dart:convert';
import 'dart:io';

class DownloadModel {
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
    process = await Process.start(
      'yt-dlp',
      arguments,
      // workingDirectory: outputPath,
    );

    process!.stdout.transform(utf8.decoder).listen((data) {
      stdout += data;
      print(data);
      // Example of extracting progress from stdout. Adjust based on yt-dlp output.
      final progressMatch = RegExp(r'(\d+)%').firstMatch(stdout);
      if (progressMatch != null) {
        final progress = double.tryParse(progressMatch.group(1) ?? '') ?? 0.0;
        _progressController.add(progress / 100);
      }
    });

    process!.stderr.transform(utf8.decoder).listen((data) {
      stderr += data;
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
    });
  }

  void dispose() {
    _progressController.close();
  }

  void closeDownload() async {
    if (isRunning) {
      process?.kill(ProcessSignal.sigterm);
      isCompleted = true;
      isRunning = false;
      isFailed = true;
      _progressController.close();
    }
  }
}
