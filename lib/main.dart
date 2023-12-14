import 'dart:io' show Platform, exit;
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import './common/settings.dart';
import './db/app.dart';
import './db/settings.dart';
import './models/settings.dart';
import './screens/calendar.dart';

const double windowWidth = 400;
const double windowHeight = 800;

Future main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    platformInit();
    await AppDatabase.initialize();
    SettingsMap settings = await SettingsDatabase.getSettings();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kReleaseMode) exit(1);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      print(error.toString());
      if (kReleaseMode) exit(1);
      return true;
    };
    runApp(MyApp(initialSettings: settings));
  } catch (error, stack) {
    print(error.toString());
    if (kDebugMode) print(stack.toString());
    exit(1);
  }
}

void platformInit() {
  if (kIsWeb) throw UnimplementedError('web is not support');
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Gamesheet');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: windowWidth,
        height: windowHeight,
      ));
    });
  }
}

class MyApp extends StatelessWidget {
  final SettingsMap initialSettings;

  const MyApp({
    super.key,
    required this.initialSettings,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsModel(initialSettings)),
      ],
      builder: (context, _) {
        final settingsModel = Provider.of<SettingsModel>(context);
        return MaterialApp(
          title: 'Hanage',
          theme: settingsModel.themeData,
          home: const CalendarScreen(),
        );
      },
    );
  }
}
