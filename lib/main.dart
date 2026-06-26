import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'core/config/injection.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await configureDependencies();

  // The app always boots into the animated splash, which then routes to
  // onboarding or login (it reads the onboarding flag itself).
  runApp(const ProviderScope(
    child: OlympiaApp(initialLocation: RouteNames.splash),
  ));
}

class OlympiaApp extends ConsumerStatefulWidget {
  final String initialLocation;
  const OlympiaApp({super.key, required this.initialLocation});

  @override
  ConsumerState<OlympiaApp> createState() => _OlympiaAppState();
}

class _OlympiaAppState extends ConsumerState<OlympiaApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Hand off from the OS native splash to our animated SplashView as soon as
    // the first frame is ready — the SplashView owns the branded reveal.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    // Router is created once. RouterNotifier drives refreshListenable
    // so GoRouter re-evaluates redirect on every auth state change.
    final notifier = ref.read(routerNotifierProvider.notifier);
    _router = AppRouter.router(widget.initialLocation, notifier);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        title: 'Olympia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
