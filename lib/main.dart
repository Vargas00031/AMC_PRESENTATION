import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:quadtalk/providers/theme_provider.dart';
import 'package:quadtalk/providers/chat_provider.dart';
import 'package:quadtalk/screens/splash_screen.dart';
import 'package:quadtalk/screens/dashboard_screen.dart';
import 'package:quadtalk/screens/chat_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Initialize Hive
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
  }

  // Open Hive boxes
  await Hive.openBox('settings');
  await Hive.openBox('conversations');
  await Hive.openBox('messages');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

const Color primarySeedColor = Colors.deepPurple;

final TextTheme appTextTheme = TextTheme(
  displayLarge:
  GoogleFonts.montserrat(fontSize: 57, fontWeight: FontWeight.bold),
  displayMedium:
  GoogleFonts.montserrat(fontSize: 45, fontWeight: FontWeight.bold),
  displaySmall:
  GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.bold),
  headlineLarge:
  GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold),
  headlineMedium:
  GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold),
  headlineSmall:
  GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w600),
  titleLarge: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.w500),
  titleMedium: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500),
  titleSmall: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w500),
  bodyLarge: GoogleFonts.lato(fontSize: 16),
  bodyMedium: GoogleFonts.lato(fontSize: 14),
  bodySmall: GoogleFonts.lato(fontSize: 12),
  labelLarge: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
  labelMedium: GoogleFonts.lato(fontSize: 12),
  labelSmall: GoogleFonts.lato(fontSize: 10),
);

ThemeData buildTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: primarySeedColor,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: appTextTheme.copyWith(
      bodyMedium: appTextTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      displayLarge: appTextTheme.displayLarge?.copyWith(color: colorScheme.onSurface),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle:
      appTextTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: appTextTheme.labelLarge,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const DashboardScreen();
      },
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (BuildContext context, GoRouterState state) {
        final String id = state.pathParameters['id']!;
        final String? persona = state.uri.queryParameters['persona'];
        final String? decodedPersona = persona != null ? Uri.decodeComponent(persona) : null;
        return ChatScreen(conversationId: id, initialPersona: decodedPersona);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = buildTheme(Brightness.light);
    final ThemeData darkTheme = buildTheme(Brightness.dark);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'HiveChat',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
