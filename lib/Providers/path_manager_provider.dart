import 'package:flutter/material.dart';
import 'package:yt_desk/services/path_manager/path_manager.dart';

class PathManagerProvider extends ChangeNotifier {
  String? _outputPath;
  String? get outputPath => _outputPath;
  bool _isInitDone = false;
  void init() async {
    !_isInitDone ? _outputPath = await PathManager.initPaths() : null;
    _isInitDone = true;

    notifyListeners();
  }

  Future changePath() async {
    _outputPath = await PathManager.setOutputPath();

    notifyListeners();
  }
}
