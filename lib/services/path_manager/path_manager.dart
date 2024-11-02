import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class PathManager {
  static Future setOutputPath() async {
    String? directory = await FilePicker.platform.getDirectoryPath();
    print("Diectory : $directory");
    return directory;
  }

  static Future initPaths() async {
    Directory? directory = await getDownloadsDirectory();
    if (Platform.isLinux) {
      return Directory('${Platform.environment['HOME']}/Downloads').path;
    } else if (Platform.isWindows) {
      Directory('${Platform.environment['USERPROFILE']}\\Downloads').path;
    }
    return directory?.path;
  }
}
