import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yt_desk/data/format_id_list.dart';
import 'package:yt_desk/services/download_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController url = TextEditingController();
  TextEditingController path = TextEditingController();
  String data = '';

  int isVideo = 0;
  String quality = 'Best';
  String? radioButtonValue;
  bool isSubtitle = false;
  bool isSponserBlock = false;

  void onisSubtitleChange(bool value) {
    setState(() {
      isSubtitle = value;
    });
  }

  void onisSponserBlockChange(bool value) {
    setState(() {
      isSponserBlock = value;
    });
  }

  List<DropdownMenuItem<String>> getType() {
    return isVideo == 0 ? videoDropDownMenu : audioDropDownMenu;
  }

  List<DropdownMenuItem<String>> audioDropDownMenu = const [
    DropdownMenuItem(value: "Best", child: Text("Best")),
    DropdownMenuItem(value: "m4a", child: Text("m4a")),
    DropdownMenuItem(value: 'webm', child: Text("webm"))
  ];

  List<DropdownMenuItem<String>> videoDropDownMenu = const [
    DropdownMenuItem(value: 'Best', child: Text("Best")),
    DropdownMenuItem(value: 'mp4', child: Text("mp4")),
    DropdownMenuItem(value: 'webm', child: Text("webm"))
  ];

  List<dynamic> getFormat() {
    if (isVideo == 0) {
      return quality == 'mp4'
          ? FormatIdList.videoFormatsMp4
          : quality == 'webm'
              ? FormatIdList.videoFormatsWebm
              : [];
    } else {
      return quality == 'Best'
          ? []
          : quality == 'm4a'
              ? FormatIdList.audioFormatsM4a
              : FormatIdList.audioFormatsWebm;
    }
  }

  Future<String?> getTitle() async {
    String title = '';
    String error = '';
    try {
      // Start the process
      Process process =
          await Process.start('yt-dlp', ['--get-title', url.text]);

      // Listen to stdout
      process.stdout.transform(utf8.decoder).listen((data) {
        title += data;
      });

      // Listen to stderr
      process.stderr.transform(utf8.decoder).listen((err) {
        error += err;
      });

      // Wait for process to exit and check the exit code
      int exitCode = await process.exitCode;
      if (exitCode != 0) {
        // print('Error: $error');
        return null; // or handle error more appropriately
      }

      // Check if there was any error
      if (error.isNotEmpty) {
        // print('Error: $error');
        return null; // or handle error more appropriately
      }

      // Return the title after process completion
      return title.trim(); // Remove any trailing newlines
    } catch (e) {
      // print('Exception: ${e.toString()}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    WindowManager.instance.setTitle("YT_DESK : Home");
    final downloadProvider =
        Provider.of<DownloadManager>(context, listen: false);
    Future<void> handleDownload() async {
      List<String> arguments = ['-f'];
      if (isVideo == 0) {
        if (radioButtonValue == 'Best' || radioButtonValue == null) {
          arguments.add("bestvideo+bestaudio");
        } else {
          arguments.add("${radioButtonValue ?? ''}+bestaudio");
        }
      } else {
        arguments.add(radioButtonValue ?? 'bestaudio');
      }

      if (isSponserBlock) {
        arguments.add("--no-sponsorblock"); // Fixed typo in the flag
      }

      if (isSubtitle) {
        arguments
            .addAll(["--write-sub", "--sub-lang", "en"]); // Removed extra space
      }
      arguments.addAll([
        '-o',
        '${path.text}/%(title)s.%(ext)s',
        url.text,
      ]);
      if (path.text.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text("Please choose a correct directory")),
          );
      } else if (url.text.isEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text("Please paste the URL")),
          );
      } else if (radioButtonValue == null && quality != 'Best') {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text("Please choose a quality")),
          );
      } else {
        download_confirmed(context);

        getTitle().then(
          (value) {
            if (value != null) {
              downloadProvider.addDownload(
                  value, url.text, arguments, path.text);
            }
            if (kDebugMode) {
              print(value);
            }
          },
        );
      }

      if (kDebugMode) {
        print(
            "Url is : ${url.text}, path : ${path.text}, isvideo : $isVideo, Quality : $radioButtonValue, attributes : $isSponserBlock, $isSubtitle");
        print(arguments);
      }
    }

    return _getwidget(context, handleDownload);
  }

  Future<dynamic> download_confirmed(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/started.svg',
                height: 70,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Download Strting...",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Okay"))
            ],
          ),
        ),
      ),
    );
  }

  Scaffold _getwidget(
      BuildContext context, Future<void> Function() handleDownload) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => Navigator.pushNamed(context, '/download'),
              icon: const Icon(
                Icons.download,
                size: 30,
              ))
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const Heading_Yt_Desk(),
            File_Path(path: path),
            const SizedBox(height: 20),
            UrlTextEditor(url: url),
            const SizedBox(height: 30),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    "Choose Download Options",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      "Format",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(width: 40),
                    DropdownButton<int>(
                      value: isVideo,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text("Video")),
                        DropdownMenuItem(value: 1, child: Text("Audio")),
                      ],
                      onChanged: (int? value) {
                        setState(() {
                          isVideo = value!;
                          quality = "Best";
                          isSubtitle = true;

                          radioButtonValue =
                              null; // Reset the selected radio button
                        });
                      },
                    ),
                    const Spacer(),
                    const Text(
                      "Type",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(width: 40),
                    DropdownButton<String>(
                      value: quality,
                      items: getType(),
                      onChanged: (String? value) {
                        setState(() {
                          quality = value!;
                          radioButtonValue =
                              null; // Reset the selected radio button
                        });
                      },
                    ),
                    const Spacer()
                  ],
                ),
                webm_warning(quality: quality, isVideo: isVideo),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centers the entire row
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Aligns the columns at the top
                  children: [
                    const Spacer(),
                    select_format_quality(),
                    attributes(),
                    const Spacer()
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: handleDownload,
                  child: const Text("Get Info"),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Expanded attributes() {
    return Expanded(
        child: Column(
      children: [
        Row(
          children: [
            Switch(
              value: isSubtitle,
              onChanged: (value) {
                onisSubtitleChange(!isSubtitle);
              },
            ),
            const SizedBox(
              width: 10,
            ),
            const Text("Subtitles")
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Switch(
              value: isSponserBlock,
              onChanged: (value) {
                onisSubtitleChange(!isSponserBlock);
              },
            ),
            const SizedBox(
              width: 10,
            ),
            const Text("Sponser Block")
          ],
        ),
      ],
    ));
  }

  Visibility select_format_quality() {
    return Visibility(
      visible: quality != 'Best',
      child: Expanded(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns text to the left
          children: [
            const Text(
              "Quality",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              getFormat().length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(
                    vertical:
                        8.0), // Adds vertical spacing between radio buttons
                child: RadioListTile<String>(
                  title: Text(
                    "${getFormat()[index]['quality']} ${getFormat()[index]['fps'] != null ? '(${getFormat()[index]['fps']} fps)' : ''}", // Displays fps if available
                    style: const TextStyle(fontSize: 18), // Custom font size
                  ),
                  value: getFormat()[index]['format_id'],
                  groupValue: radioButtonValue,
                  onChanged: (String? value) {
                    setState(() {
                      radioButtonValue = value;
                    });
                  },
                  activeColor: Colors.blueAccent, // Custom active color
                ),
              ),
            ),
            const SizedBox(height: 16), // Spacing after the last radio button
          ],
        ),
      ),
    );
  }
}

class webm_warning extends StatelessWidget {
  const webm_warning({
    super.key,
    required this.quality,
    required this.isVideo,
  });

  final String quality;
  final int isVideo;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: quality == 'webm' && isVideo == 0,
        child: const Text(
          "Warning:WEBM quality may not be available, and high-quality options might be limited. Please consider choosing a different format if issues arise.",
          style: TextStyle(color: Colors.yellow),
        ));
  }
}

class File_Path extends StatelessWidget {
  const File_Path({
    super.key,
    required this.path,
  });

  final TextEditingController path;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onTap: () async {
                  path.text =
                      await FilePicker.platform.getDirectoryPath() ?? '';
                },
                readOnly: true,
                controller: path,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select a directory',
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.folder),
              onPressed: () async {
                path.text = await FilePicker.platform.getDirectoryPath() ?? '';
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UrlTextEditor extends StatelessWidget {
  const UrlTextEditor({
    super.key,
    required this.url,
  });

  final TextEditingController url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Your Social Media Link",
          fillColor: Theme.of(context).colorScheme.surface,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.white, // Color when focused
              width: 2, // Slightly thicker border
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.white60, // Color when not focused
              width: 1,
            ),
          ),
        ),
        controller: url,
      ),
    );
  }
}

class Heading_Yt_Desk extends StatelessWidget {
  const Heading_Yt_Desk({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        "YT_DESK",
        style: GoogleFonts.roboto(
          fontSize: 60,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
