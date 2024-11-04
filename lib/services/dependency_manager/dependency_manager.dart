import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class DependencyManager {
  //window dependency manager
  static Future<bool> isWingetAvailable() async {
  try {
    ProcessResult result = await Process.run('winget', ['--version'], runInShell: true);
    return result.exitCode == 0;
  } catch (e) {
    if (kDebugMode) {
      print('Winget not available: $e');
    }
    return false;
  }
}

static Future<bool> acceptPolicyWindow() async {
  try {
    // Start the PowerShell process
    Process result = await Process.start(
      'powershell',
      ['-Command', 'Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe'],
      mode: ProcessStartMode.normal,
    );

    // Listen for standard output
    result.stdout.transform(utf8.decoder).listen((data) {
      print('Output: $data');
    });

    // Listen for standard error
    result.stderr.transform(utf8.decoder).listen((error) {
      print('Error: $error');
    });

    // Wait for the process to complete and get the exit code
    int exitCode = await result.exitCode;
    
    if (exitCode == 0) {
      print('Execution policy set successfully.');
      return true;
    } else {
      print('Failed to set execution policy with exit code: $exitCode');
      return false;
    }
  } catch (e) {
    print('Exception occurred: $e');
    return false;
  }
}



// static Future<bool> installPythonWindow() async {
//   try {
//     // Start the Scoop process to install Python
//    Process result = await Process.start(
//       'winget',
//       ['install', 'python', '--accept-source-agreements', '--accept-package-agreements'],
//       runInShell: true,
//     );
//   if(kDebugMode){
//     result.stdout.transform(utf8.decoder).listen((res){
//       print(res);
//     });
//     result.stderr.transform(utf8.decoder).listen((res){
//       print(res);
//     });

//   }
//     return await result.exitCode == 0;
//       } catch (e) {
//     if (kDebugMode) {
//       print('Exception occurred: $e');
//     }
//     return false;
//   }
// }

//   static Future<bool> installYtDlpWindow() async {
//    try {
//     // Start the Scoop process to install Python
//    Process result = await Process.start(
//       'winget',
//       ['install', 'yt-dlp', '--accept-source-agreements', '--accept-package-agreements'],
//       runInShell: true,
//     );
//   if(kDebugMode){
//     result.stdout.transform(utf8.decoder).listen((res){
//       print(res);
//     });
//     result.stderr.transform(utf8.decoder).listen((res){
//       print(res);
//     });

//   }
//     return await result.exitCode == 0;
//       } catch (e) {
//     if (kDebugMode) {
//       print('Exception occurred: $e');
//     }
//     return false;
//   }
//   }

//   static Future<bool> installFFMPEGWindow() async {
//     try {
//     // Start the Scoop process to install Python
//    Process result = await Process.start(
//       'winget',
//       ['install', 'ffmpeg', '--accept-source-agreements', '--accept-package-agreements'],
//       runInShell: true,
//     );
//   if(kDebugMode){
//     result.stdout.transform(utf8.decoder).listen((res){
//       print(res);
//     });
//     result.stderr.transform(utf8.decoder).listen((res){
//       print(res);
//     });

//   }
//     return await result.exitCode == 0;
//       } catch (e) {
//     if (kDebugMode) {
//       print('Exception occurred: $e');
//     }
//     return false;
//   }
//   }

  //linux function for setup dependency
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
      final result = await Process.run('python', ['--version'], runInShell: true);
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
      final result = await Process.run('yt-dlp', ['--version'], runInShell: true);
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

  static Future<bool> handlePassword(String distro) async {
    try {
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(' $e');
      }
      return false; // An error occurred
    }
  }
}
