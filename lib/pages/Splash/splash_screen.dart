import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';

class SplashScreen extends HookWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var commandOutput = useState("");
    var password = useState("");

    Future<void> showPasswordPrompt() async {
      final passwordController = TextEditingController();

      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Password required"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    password.value = passwordController.text;
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            ),
          );
        },
      );
    }

    Future<void> _runCommand(String command, List<String> args) async {
      try {
        Process process = await Process.start(command, args, runInShell: true);

        if (kDebugMode) {
          print("Starting process...");
        }

        StringBuffer outputBuffer = StringBuffer();
        Completer<void> passwordEntered = Completer<void>();

        process.stdout.transform(utf8.decoder).listen((data) {
          if (kDebugMode) {
            print("stdout: $data");
          }
          outputBuffer.write(data);
        });

        process.stderr.transform(utf8.decoder).listen((data) async {
          if (kDebugMode) {
            print("stderr: $data");
          }
          outputBuffer.write(data);

          if (data.contains('[sudo] password')) {
            if (!passwordEntered.isCompleted) {
              await showPasswordPrompt();
              process.stdin.writeln(password.value);
              passwordEntered.complete();
            }
          }
        });

        int exitCode = await process.exitCode;

        if (exitCode == 0) {
          commandOutput.value =
              '\n$command executed successfully!\nOutput:\n${outputBuffer.toString()}';
        } else {
          commandOutput.value =
              '\n$command failed with exit code $exitCode.\nOutput:\n${outputBuffer.toString()}';
        }
      } catch (e) {
        commandOutput.value = '\nError executing command: $e\n';
      }
    }

    Future<void> showErrorDialog(String message) async {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error installing :  pyton and yt-dlp'),
            content:
                Text("$message : please install manually python and yt-dlp"),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  SystemNavigator.pop();
                },
              ),
            ],
          );
        },
      );
    }

    Future<String> _getLinuxDistro() async {
      try {
        final process = await Process.run('cat', ['/etc/os-release']);
        final output = process.stdout as String;
        if (output.contains('Ubuntu')) {
          return 'ubuntu';
        } else if (output.contains('Debian')) {
          return 'debian';
        } else if (output.contains('Fedora')) {
          return 'fedora';
        } else if (output.contains('Arch')) {
          return 'arch';
        } else {
          return 'unknown';
        }
      } catch (e) {
        throw Exception("Failed to determine Linux distribution: $e");
      }
    }

    Future<void> installPython() async {
      try {
        if (Platform.isLinux) {
          final distro = await _getLinuxDistro();
          String installCommand;
          List<String> installArgs;
          if (distro == "ubuntu" || distro == "debian") {
            installCommand = 'sudo';
            installArgs = ['apt-get', 'install', '-y', 'python3'];
          } else if (distro == "fedora") {
            installCommand = 'sudo';
            installArgs = ['dnf', 'install', '-y', 'python3'];
          } else if (distro == "arch") {
            installCommand = 'sudo';
            installArgs = ['pacman', '-S', '--noconfirm', 'python'];
          } else {
            throw Exception("Unsupported Linux distribution: $distro");
          }
          await _runCommand(installCommand, installArgs);
        } else if (Platform.isWindows) {
          await _runCommand('winget',
              ['install', '--id', 'Python.Python', '-e', "--source", "winget"]);
        }
      } catch (e) {
        await showErrorDialog('Error installing Python: $e');
      }
    }

    Future<void> installYtDlp() async {
      try {
        final distro = await _getLinuxDistro();
        if (kDebugMode) {
          print("this is distro : $distro");
        }
        String installCommand;
        List<String> installArgs;
        if (distro == "arch") {
          installCommand = 'sudo';
          installArgs = ['-S', 'pacman', '-S', '--noconfirm', 'yt-dlp'];
        } else {
          installCommand = 'pip';
          installArgs = ['install', 'yt-dlp'];
        }
        if (kDebugMode) {
          print("attempting to install");
        }
        await _runCommand(installCommand, installArgs);
      } catch (e) {
        // await showErrorDialog('Error installing yt-dlp: $e');
      }
    }

    Future<void> checkYtDlp() async {
      try {
        // First, check if the yt-dlp executable exists
        ProcessResult whichResult = await Process.run('which', ['yt-dlp']);

        if (whichResult.exitCode != 0) {
          // yt-dlp is not found, so we need to install it
          if (kDebugMode) {
            print("yt-dlp is not installed, installing...");
          }
          await installYtDlp();
        } else {
          // yt-dlp exists, now check its version
          ProcessResult versionResult =
              await Process.run('yt-dlp', ['--version']);
          if (versionResult.exitCode != 0) {
            if (kDebugMode) {
              print(
                  "Failed to check yt-dlp version, attempting installation...");
            }
            await installYtDlp();
          } else {
            if (kDebugMode) {
              print("yt-dlp is installed: ${versionResult.stdout}");
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error checking yt-dlp: $e");
        }
        await installYtDlp();
      }
    }

    Future<void> checkPython() async {
      try {
        ProcessResult result = await Process.run('python3', ['--version']);
        if (result.exitCode != 0) {
          await installPython();
          if (kDebugMode) {
            print("python is now installed");
          }
          await checkYtDlp();
        } else {
          if (kDebugMode) {
            print("Python is already installed.");
          }
          await checkYtDlp();
        }
      } catch (e) {
        await showErrorDialog('Error checking Python: $e');
      }
    }

    Future<bool> checkAndInstallDependencies() async {
      try {
        await checkPython();
        await checkYtDlp();
        if (kDebugMode) {
          print("All dependencies are installed and ready.");
        }
        return true;
      } catch (e) {
        if (kDebugMode) {
          print("Error during dependency check: $e");
        }
        await showErrorDialog('Error checking or installing dependencies: $e');
        return false;
      }
    }

    useEffect(() {
      Future<void> initialize() async {
        bool dependenciesReady = await checkAndInstallDependencies();
        if (dependenciesReady) {
          Navigator.pushNamed(context, '/home');
        } else {
          if (kDebugMode) {
            print("Unable to install all required dependencies.");
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text(
                    "Unknown error please install python and yt-dlp manually")));
        }
      }

      initialize();
      return null;
    }, []);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [CircularProgressIndicator(), Text(commandOutput.value)],
        ),
      ),
    );
  }
}
