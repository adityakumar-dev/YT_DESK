import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:yt_desk/services/dependency_manager/dependency_manager.dart';

class DependencyManagerProvider extends ChangeNotifier {
  bool _isDependencyDone = false;
  bool _isPythonDone = false;
  bool _isYtDlpDone = false;
  bool _isError = false;
  bool _isInstalling = false;
  String _currentStatus = "Checking All Dependencies";

  String get currentStatus => _currentStatus;
  bool get isDependencyDone => _isDependencyDone;
  bool get isError => _isError;
  bool get isInstalling => _isInstalling;

  Future<void> initDependency() async {
    _currentStatus = "Checking Python dependency...";
    _isPythonDone = await DependencyManager.checkPython();
    notifyListeners();

    if (_isPythonDone) {
      _currentStatus = "Checking yt-dlp dependency...";
      _isYtDlpDone = await DependencyManager.checkYtDlp();
      notifyListeners();
    }
    _isDependencyDone = _isPythonDone && _isYtDlpDone;
    print(_isDependencyDone);
    if (_isDependencyDone) {
      _currentStatus = "All Dependencies Installed!";
      print(_currentStatus);
    } else {
      _currentStatus = "Waiting to Start installation of Dependencies";
    }
    notifyListeners();
  }

  Future installDependency() async {
    // Start installation process if dependencies are missing
    _isInstalling = true;
    _currentStatus = "Installing Dependencies...";
    notifyListeners();

    String distro = await DependencyManager.getLinuxDist();

    // Install Python if it's not done
    if (!_isPythonDone) {
      _currentStatus = "Installing Python...";
      notifyListeners();
      _isPythonDone = await DependencyManager.installPython(distro);
    }

    // Install yt-dlp only if Python installation was successful
    if (_isPythonDone && !_isYtDlpDone) {
      _currentStatus = "Installing yt-dlp...";
      notifyListeners();
      _isYtDlpDone = await DependencyManager.installYtDlp(distro);
    }

    // Update the dependency status
    _isDependencyDone = _isPythonDone && _isYtDlpDone;
    _isError = !_isDependencyDone;

    if (_isError) {
      _currentStatus =
          "Failed to install dependencies. Please install manually.";
    } else {
      _currentStatus = "All Dependencies Installed!";
    }

    _isInstalling = false;
    notifyListeners();
  }

  Future<bool> passwordHandle(String text) async {
    try {
      // Create a process that runs 'sudo -v' with password from stdin
      final process = await Process.start(
        'sudo',
        [
          '-S',
          '-v'
        ], // -S reads password from stdin, -v validates sudo credentials
        mode: ProcessStartMode.normal,
      );

      // Write the password to stdin immediately
      process.stdin.write('$text\n');
      await process.stdin.close();

      // Capture any error output
      final stderr = await process.stderr.transform(utf8.decoder).join();
      if (stderr.isNotEmpty && kDebugMode) {
        print('Sudo authentication stderr: $stderr');
      }

      // Wait for the process to complete
      final exitCode = await process.exitCode;

      // If exitCode is 0, authentication was successful
      if (exitCode == 0) {
        return true;
      } else {
        if (kDebugMode) {
          print('Sudo authentication failed with exit code: $exitCode');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during sudo authentication: $e');
      }
      return false;
    }
  }

  Future<bool> hasSudoPrivileges() async {
    try {
      final result = await Process.run('sudo', ['-n', 'true']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}
