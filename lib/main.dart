import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/config/injection.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';
import 'core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  await configureDependencies();
  
  final prefs = await SharedPreferences.getInstance();
  final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
  
  runApp(ProviderScope(
    child: OlympiaApp(initialLocation: onboardingSeen ? RouteNames.login : RouteNames.onboarding),
  ));
}

class OlympiaApp extends StatelessWidget {
  final String initialLocation;
  const OlympiaApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    // Remove splash screen after a short delay to ensure brand visibility
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 2));
      FlutterNativeSplash.remove();
    });

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
        routerConfig: AppRouter.router(initialLocation),
      ),
    );
  }
}
