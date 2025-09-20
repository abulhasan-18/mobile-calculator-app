import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/calculator_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const CalcProApp());
}

class CalcProApp extends StatelessWidget {
  const CalcProApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6750A4);

    ThemeData themed(Brightness b) {
      final base = ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: b),
        brightness: b,
      );
      // we’ll apply a device-aware factor via MaterialApp.builder below,
      // so keep textTheme at 1.0 here and just switch to Google Fonts.
      final inter = GoogleFonts.interTextTheme(base.textTheme);
      final display = GoogleFonts.spaceGroteskTextTheme(base.textTheme);

      return base.copyWith(
        textTheme: inter.copyWith(
          headlineMedium: display.headlineMedium,
          displayLarge: display.displayLarge,
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculus',
      themeMode: ThemeMode.system,
      theme: themed(Brightness.light),
      darkTheme: themed(Brightness.dark),

      // Builder lets us cap extreme OS textScale and add a gentle device scale
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        // Respect accessibility but keep UI intact.
        final clampedOsScale =
            mq.textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.4);

        return MediaQuery(
          data: mq.copyWith(textScaler: clampedOsScale),
          child: child ?? const SizedBox.shrink(),
        );
      },

      home: const CalculatorPage(),
    );
  }
}
