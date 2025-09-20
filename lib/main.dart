import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/calculator_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const CalcProApp());
}

class CalcProApp extends StatefulWidget {
  const CalcProApp({super.key});

  @override
  State<CalcProApp> createState() => _CalcProAppState();
}

class _CalcProAppState extends State<CalcProApp> {
  ThemeMode _mode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _mode = (_mode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _setSystemTheme() {
    setState(() => _mode = ThemeMode.system);
  }

  ThemeData _themed(Brightness b) {
    const seed = Color(0xFF6750A4);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: b),
      brightness: b,
    );
    final inter = GoogleFonts.interTextTheme(base.textTheme);
    final display = GoogleFonts.spaceGroteskTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: inter.copyWith(
        headlineMedium: display.headlineMedium,
        displayLarge: display.displayLarge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calc Pro',
      // Uncomment if you want to always show Latin digits:
      // locale: const Locale('en'),
      themeMode: _mode,
      theme: _themed(Brightness.light),
      darkTheme: _themed(Brightness.dark),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final clamped =
            mq.textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.4);
        return MediaQuery(
            data: mq.copyWith(textScaler: clamped),
            child: child ?? const SizedBox.shrink());
      },
      home: CalculatorPage(
        themeMode: _mode,
        onToggleTheme: _toggleTheme,
        onSystemTheme: _setSystemTheme,
      ),
    );
  }
}
