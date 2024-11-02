import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yt_desk/Providers/dependency_manager_provider.dart';
import 'package:yt_desk/Providers/download_item_provider.dart';
import 'package:yt_desk/Providers/download_manager_provider.dart';
import 'package:yt_desk/Providers/path_manager_provider.dart';
import 'package:yt_desk/pages/Splash/splash_screen.dart';
import 'package:yt_desk/services/download_manager.dart';
import 'package:yt_desk/utils/routing/app_route.dart';
import 'package:yt_desk/utils/themes/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
      minimumSize: Size(800, 1050), skipTaskbar: false, title: "YT_DL : Home");
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => DownloadItemProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => DownloadManagerProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => DependencyManagerProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => PathManagerProvider(),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routes: appRoutes,
      initialRoute: SplashScreen.rootName,
    );
  }
}
