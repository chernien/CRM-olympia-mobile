import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/config/injection.dart';
import 'services/push_service.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';
import 'core/theme/app_theme.dart';
import 'views/shared/widgets/bandeau_hors_ligne.dart';

void main() async {
  WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Un widget qui lève une exception affiche, en release, un rectangle GRIS vide —
  // sans texte, sans issue. Le commercial croit l'application morte et la ferme.
  // On lui substitue un message lisible : l'écran concerné est perdu, pas la session.
  // Purement visuel : l'erreur reste remontée aux outils de développement.
  ErrorWidget.builder = (details) => Material(
        color: const Color(0xFFFAFBFD),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 40, color: Color(0xFFEF4444)),
                const SizedBox(height: 14),
                const Text(
                  "Cet écran n'a pas pu s'afficher",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Revenez en arrière puis réessayez. Si le problème persiste, signalez-le.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      );

  await configureDependencies();

  // Push FCM. Tout est protégé : si le client n'a pas encore déposé son
  // google-services.json, l'initialisation échoue proprement, PushService passe
  // en mode dégradé et l'application démarre exactement comme avant.
  try {
    FirebaseMessaging.onBackgroundMessage(olympiaFirebaseBackgroundHandler);
  } catch (_) {
    // Plugin indisponible sur cette plateforme : sans conséquence.
  }
  await getIt<PushService>().init();

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
        title: 'OlyHub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _router,
        // Monté via le builder de MaterialApp : il coiffe TOUTES les routes d'un
        // coup, plutôt que d'être ajouté écran par écran — un nouvel écran en
        // hériterait sans qu'on y pense.
        builder: (context, enfant) =>
            BandeauHorsLigne(child: enfant ?? const SizedBox.shrink()),
      ),
    );
  }
}
