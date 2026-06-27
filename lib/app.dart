import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'screens/settings/widget_config_screen.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();

  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F1214),
    cardColor: const Color(0xFF1C1F22),
    primaryColor: const Color(0xFF2196F3),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF4CAF50),
      surface: Color(0xFF1C1F22),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    useMaterial3: true,
  );

  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7F9),
    primaryColor: const Color(0xFF2196F3),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF4CAF50),
    ),
    useMaterial3: true,
  );
}

class _AppState extends State<App> {
  static const _channel = MethodChannel('com.loop.habit_tracker/widget_config');
  Future<dynamic>? _pendingWidgetFuture;

  @override
  void initState() {
    super.initState();
    _pendingWidgetFuture = _channel.invokeMethod('checkPendingWidgetConfig');
    
    // Keep listener for warm-starts
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openWidgetConfig') {
        final args = call.arguments as Map?;
        final int? appWidgetId = args?['appWidgetId'] as int?;
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => WidgetConfigScreen(appWidgetId: appWidgetId, isStandalone: true)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _pendingWidgetFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(backgroundColor: Colors.transparent, body: SizedBox.shrink()),
          );
        }

        final pendingResult = snapshot.data;
        final bool isStandalone = pendingResult != null;
        final int? appWidgetId = isStandalone ? ((pendingResult as Map?)?['appWidgetId'] as int?) : null;

        return Selector<SettingsProvider, ({ThemeMode themeMode, bool hasProfile, bool onboardingComplete})>(
          selector: (context, settings) => (
            themeMode: settings.themeMode,
            hasProfile: settings.profile != null,
            onboardingComplete: settings.profile?.onboardingComplete ?? false,
          ),
          builder: (context, config, _) {
            if (!config.hasProfile) {
              return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(backgroundColor: Colors.transparent, body: Center(child: CircularProgressIndicator())),
              );
            }

            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Habit Loop',
              debugShowCheckedModeBanner: false,
              theme: App._lightTheme.copyWith(scaffoldBackgroundColor: isStandalone ? Colors.transparent : null),
              darkTheme: App._darkTheme.copyWith(scaffoldBackgroundColor: isStandalone ? Colors.transparent : null),
              themeMode: config.themeMode,
              home: isStandalone
                  ? WidgetConfigScreen(appWidgetId: appWidgetId, isStandalone: true)
                  : SplashScreen(
                      nextScreen: config.onboardingComplete
                          ? const MainShell()
                          : const WelcomeScreen(),
                    ),
            );
          },
        );
      },
    );
  }
}
