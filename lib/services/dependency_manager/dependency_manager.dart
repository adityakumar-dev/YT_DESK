import 'dart:io';

import 'package:flutter/foundation.dart';

class DependencyManager {
  static bool? checkIsLinux() {
    if (Platform.isWindows) {
      return false;
    } else if (Platform.isLinux) {
      return true;
    } else {
      return null;
    }
  }

  static Future<String> getLinuxDist() async {
    if (!checkIsLinux()!) {
      return 'Not running on Linux';
    }

    try {
      final result = await Process.run(
        'bash',
        [
          '-c',
          'hostnamectl | grep "Operating System" | awk -F ":" \'{print \$2}\''
        ],
      );

      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      } else {
        return 'Error retrieving Linux distribution: ${result.stderr}';
      }
    } catch (e) {
      return 'Error occurred: $e';
    }
  }

  static Future<bool> checkPython() async {
    try {
      final result = await Process.run('python', ['--version']);
      if (result.exitCode == 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return false;
    }
  }

  static Future<bool> checkYtDlp() async {
    try {
      final result = await Process.run('yt-dlp', ['--version']);
      if (result.exitCode == 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return false;
    }
  }

  /// Installs Python based on the detected Linux distribution.
  static Future<bool> installPython(String distro) async {
    try {
      String commandParams = _getCommandParams(distro, 'python') ?? '';
      if (commandParams.isEmpty) {
        return false; // Unsupported distribution
      }
      final result = await Process.run('bash', ['-c', commandParams]);
      return result.exitCode == 0; // Check if installation was successful
    } catch (e) {
      if (kDebugMode) {
        print('Error installing Python: $e');
      }
      return false; // An error occurred
    }
  }

  /// Retrieves the installation command parameters based on the distribution and dependency name.
  static String? _getCommandParams(String distro, String dependency) {
    if (distro.contains("Arch") || distro.contains("Manjaro")) {
      return "sudo pacman -S $dependency --noconfirm";
    } else if (distro.contains("Ubuntu") ||
        distro.contains("Kali") ||
        distro.contains("Mint") ||
        distro.contains("Debian") ||
        distro.contains("Raspbian")) {
      return "sudo apt install $dependency -y";
    } else if (distro.contains("Fedora") ||
        distro.contains("Red Hat") ||
        distro.contains("CentOS")) {
      return "sudo dnf install $dependency -y";
    } else if (distro.contains("OpenSUSE")) {
      return "sudo zypper install $dependency";
    } else if (distro.contains("Alpine")) {
      return "sudo apk add $dependency";
    } else if (distro.contains("Gentoo")) {
      return "sudo emerge $dependency";
    } else if (distro.contains("Slackware")) {
      return "sudo slackpkg install $dependency";
    } else {
      if (kDebugMode) {
        print('Unsupported distribution: $distro');
      }
      return null; // Return null for unsupported distributions
    }
  }

  /// Installs yt-dlp based on the detected Linux distribution.
  static Future<bool> installYtDlp(String distro) async {
    try {
      String commandParams = _getCommandParams(distro, 'yt-dlp') ?? '';
      if (commandParams.isEmpty) {
        return false; // Unsupported distribution
      }
      final result = await Process.run('bash', ['-c', commandParams]);
      if (result.exitCode == 0) {
        return true; // Installation successful
      } else {
        if (kDebugMode) {
          print('Installation failed with exit code: ${result.exitCode}');
          print('Error output: ${result.stderr}');
          print('Standard output: ${result.stdout}');
        }
        return false; // Installation failed
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error installing yt-dlp: $e');
      }
      return false; // An error occurred
    }
  }
}
