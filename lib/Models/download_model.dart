import 'dart:async';
import 'dart:io';

class DownloadItemModel {
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
  double progressPercentage = 0.0;

  DownloadItemModel({
    required this.url,
    required this.arguments,
    required this.outputPath,
    required this.title,
  });
}
