import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yt_desk/Providers/dependency_manager_provider.dart';
import 'package:yt_desk/UiHelper/ui_helper.dart';
import 'package:yt_desk/pages/Home/home_option_screen.dart';

class SplashScreen extends StatefulWidget {
  static const rootName = "Splash Screen";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DependencyManagerProvider? provider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        provider =
            Provider.of<DependencyManagerProvider>(context, listen: false);
      });
      provider!.initDependency().then((value) async {
        if (!provider!.isDependencyDone) {
          bool isSudo = await provider!.hasSudoPrivileges();
          if (!isSudo) {
            await passwordHandlerLinux(context);
          }
          if (!provider!.isDependencyDone) {
            await provider!.installDependency();
            if (provider!.isDependencyDone) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                HomeOptionScreen.rootName,
                (route) => false,
              );
            }
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            HomeOptionScreen.rootName,
            (route) => false,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: whiteColor,
      body: provider != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  getBanner(),
                  heightBox(kSize24),
                  Text(
                    "Dependency Manager",
                    style: kTextStyle(kSize48, blackColor, false),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.2),
                    child: const Divider(
                      color: lightRed,
                    ),
                  ),
                  heightBox(kSize24),
                  CircularProgressIndicator(
                    color: mutedBlueColor,
                    strokeWidth: 1,
                  ),
                  heightBox(kSize22),
                  Text(
                    provider!.currentStatus,
                    style: kTextStyle(kSize16, blackColor, false),
                  ),
                ],
              ),
            )
          : const CircularProgressIndicator(),
    );
  }

  Future<void> passwordHandlerLinux(BuildContext context) async {
    final provider =
        Provider.of<DependencyManagerProvider>(context, listen: false);
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: whiteColor,
        title: Text(
          "Password Required",
          style: kTextStyle(kSize24, blackColor, false),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              style: const TextStyle(
                color: darkRed,
              ),
              decoration: getInputDecoration("Enter Password"),
            )
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              await provider.passwordHandle(controller.text).then((res) {
                Navigator.pop(context);
              });
            },
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: kSize16, vertical: kSize16),
              decoration: BoxDecoration(
                  color: deepRed,
                  borderRadius: BorderRadius.circular(kSize13 + 0.0)),
              child: Text(
                "Ok",
                style: kTextStyle(kSize13, whiteColor, true),
              ),
            ),
          )
        ],
      ),
    );
    // Provider.of<DependencyManagerProvider>(context).currentStatus;
  }
}

// class SplashScreen extends HookWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var commandOutput = useState("");
//     var password = useState("");

//     Future<void> showPasswordPrompt() async {
//       final passwordController = TextEditingController();

//       await showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text("Password required"),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter password',
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     password.value = passwordController.text;
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text("OK"),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }

//     Future<void> showErrorDialog(String message) async {
//       await showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Error installing :  pyton and yt-dlp'),
//             content:
//                 Text("$message : please install manually python and yt-dlp"),
//             actions: [
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   SystemNavigator.pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }

//     useEffect(() {
//       Future<void> initialize() async {
//         bool dependenciesReady = await checkAndInstallDependencies();
//         if (dependenciesReady) {
//           Navigator.pushReplacementNamed(context, '/home');
//         } else {
//           if (kDebugMode) {
//             print("Unable to install all required dependencies.");
//           }

//           await showDialog(
//             context: context,
//             builder: (context) {
//               return AlertDialog(
//                 title: const Text("Error!"),
//                 content: const Text(
//                     "Python or yt-dlp not installed. Please install manually!"),
//                 actions: [
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                       if (Platform.isAndroid || Platform.isIOS) {
//                         SystemNavigator.pop(animated: true);
//                       } else {
//                         exit(0); // For desktop
//                       }
//                     },
//                     child: const Text("Exit"),
//                   ),
//                 ],
//               );
//             },
//           );
//         }
//       }

//       initialize();
//       return null;
//     }, []);

//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(),
//             Text(commandOutput.value)
//           ],
//         ),
//       ),
//     );
//   }
// }

//  Future<void> _runCommand(String command, List<String> args) async {
//     try {
//       Process process = await Process.start(command, args, runInShell: true);

//       if (kDebugMode) {
//         print("Starting process...");
//       }

//       StringBuffer outputBuffer = StringBuffer();
//       Completer<void> passwordEntered = Completer<void>();

//       process.stdout.transform(utf8.decoder).listen((data) {
//         if (kDebugMode) {
//           print("stdout: $data");
//         }
//         commandOutput.value = data;
//         outputBuffer.write(data);
//       });

//       process.stderr.transform(utf8.decoder).listen((data) async {
//         if (kDebugMode) {
//           print("stderr: $data");
//         }
//         outputBuffer.write(data);
//         commandOutput.value = data;

//         if (data.contains('[sudo] password')) {
//           if (!passwordEntered.isCompleted) {
//             await showPasswordPrompt();
//             process.stdin.writeln(password.value);
//             passwordEntered.complete();
//           }
//         }
//       });

//       int exitCode = await process.exitCode;

//       if (exitCode == 0) {
//         commandOutput.value =
//             '\n$command executed successfully!\nOutput:\n${outputBuffer.toString()}';
//       } else {
//         commandOutput.value =
//             '\n$command failed with exit code $exitCode.\nOutput:\n${outputBuffer.toString()}';
//       }
//     } catch (e) {
//       commandOutput.value = '\nError executing command: $e\n';
//     }
//   }

// Future<String> _getLinuxDistro() async {
// try {
// final process = await Process.run('cat', ['/etc/os-release']);
// final output = process.stdout as String;
// if (output.contains('Ubuntu') || output.contains('ubuntu')) {
// return 'ubuntu';
// } else if (output.contains('Debian') || output.contains('debian')) {
// return 'debian';
// } else if (output.contains('Fedora') || output.contains('fedora')) {
// return 'fedora';
// } else if (output.contains('Arch') || output.contains('arch')) {
// return 'arch';
// } else {
// return 'unknown';
// }
// } catch (e) {
// throw Exception("Failed to determine Linux distribution: $e");
// }
// }
//
// Future<void> installPython() async {
// try {
// if (Platform.isLinux) {
// final distro = await _getLinuxDistro();
// String installCommand;
// List<String> installArgs;
// if (distro == "ubuntu" || distro == "debian") {
// installCommand = 'sudo';
// installArgs = ['apt-get', 'install', '-y', 'python3'];
// } else if (distro == "fedora") {
// installCommand = 'sudo';
// installArgs = ['dnf', 'install', '-y', 'python3'];
// } else if (distro == "arch") {
// installCommand = 'sudo';
// installArgs = ['pacman', '-S', '--noconfirm', 'python'];
// } else {
// throw Exception("Unsupported Linux distribution: $distro");
// }
// await _runCommand(installCommand, installArgs);
// } else if (Platform.isWindows) {
// await _runCommand('winget',
// ['install', '--id', 'Python.Python', '-e', "--source", "winget"]);
// }
// } catch (e) {
// await showErrorDialog('Error installing Python: $e');
// }
// }
//
// Future<void> installYtDlp() async {
// try {
// final distro = await _getLinuxDistro();
// if (kDebugMode) {
// print("this is distro : $distro");
// }
// String installCommand;
// List<String> installArgs;
// if (distro == "arch") {
// installCommand = 'sudo';
// installArgs = ['-S', 'pacman', '-S', '--noconfirm', 'yt-dlp'];
// } else if (distro == "ubuntu") {
// installCommand = "sudo";
// installArgs = ['-S', 'apt-get', 'install', '-y', 'yt-dlp'];
// } else if (distro == "fedora") {
// installCommand = "sudo";
// installArgs = ['-S', 'dnf', 'install', '-y', 'yt-dlp'];
// } else {
// installCommand = 'pip';
// installArgs = ['install', 'yt-dlp'];
// }
// if (kDebugMode) {
// print("attempting to install");
// }
// await _runCommand(installCommand, installArgs);
// } catch (e) {
// await showErrorDialog('Error installing yt-dlp: $e');
// }
// }
//
// Future<void> checkYtDlp() async {
// try {
// Using 'command -v' instead of 'which' to check for yt-dlp binary
// ProcessResult whichResult = await Process.run('command', ['-v', 'yt-dlp']);
//
// if (whichResult.exitCode != 0) {
// if (kDebugMode) {
// print("yt-dlp is not installed, installing...");
// }
// await installYtDlp();
// } else {
// ProcessResult versionResult = await Process.run('yt-dlp', ['--version']);
// if (versionResult.exitCode != 0) {
// if (kDebugMode) {
// print("Failed to check yt-dlp version, attempting installation...");
// }
// await installYtDlp();
// } else {
// if (kDebugMode) {
// print("yt-dlp is installed: ${versionResult.stdout}");
// }
// }
// }
// } catch (e) {
// if (kDebugMode) {
// print("Error checking yt-dlp: $e");
// }
// await installYtDlp();
// }
// }
//
// Future<void> checkPython() async {
// try {
// ProcessResult result = await Process.run('python3', ['--version']);
// if (result.exitCode != 0) {
// Try checking for just 'python' if 'python3' is not found
// result = await Process.run('python', ['--version']);
// if (result.exitCode != 0) {
// await installPython();
// if (kDebugMode) {
// print("Python is now installed.");
// }
// await checkYtDlp();
// }
// } else {
// if (kDebugMode) {
// print("Python is already installed.");
// }
// await checkYtDlp();
// }
// } catch (e) {
// await showErrorDialog('Error checking Python: $e');
// }
// }
//
// Future<bool> checkAndInstallDependencies() async {
// try {
// await checkPython();
// await checkYtDlp();
// if (kDebugMode) {
// print("All dependencies are installed and ready.");
// }
// return true;
// } catch (e) {
// if (kDebugMode) {
// print("Error during dependency check: $e");
// }
// await showErrorDialog('Error checking or installing dependencies: $e');
// return false;
// }
// }
//
