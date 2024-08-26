import 'package:yt_desk/pages/Download/download_screen.dart';
import 'package:yt_desk/pages/Home/home_screen.dart';
import 'package:yt_desk/pages/Splash/splash_screen.dart';

var appRoutes = {
  '/': (context) => const SplashScreen(),
  '/home': (context) => const HomeScreen(),
  '/download': (context) => const DownloadScreen()
};
