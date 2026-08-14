import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Branded animated splash. Shown first (right after the native splash hands
/// off), it plays a short logo reveal then routes to onboarding or login.
///
/// The logo is wrapped in a [Hero] (`olympia_logo`) shared with the login and
/// dashboard, so it glides smoothly into the next screen instead of cutting.
class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  // Minimum time the splash stays visible, so the reveal never feels rushed.
  static const _minDisplay = Duration(milliseconds: 2400);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _goNext();
  }

  Future<void> _goNext() async {
    final started = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

    // Restore a previous session from the stored tokens (no network call — works
    // offline). If an access token is present, the user goes straight to the
    // dashboard; the Dio interceptor silently refreshes it via the refresh token
    // on the first API call, and only falls back to /login if that refresh fails.
    await ref.read(authProvider.notifier).checkAuth();
    final isAuthenticated = ref.read(authProvider).isAuthenticated;

    // Respect the minimum display time even if everything resolves instantly.
    final elapsed = DateTime.now().difference(started);
    final remaining = _minDisplay - elapsed;
    if (remaining > Duration.zero) await Future.delayed(remaining);

    if (!mounted) return;
    if (isAuthenticated) {
      context.go(RouteNames.dashboard);
    } else {
      context.go(onboardingSeen ? RouteNames.login : RouteNames.onboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Derived from the brand blue instead of a hand-picked hex.
            colors: [Colors.white, AppColors.tint(AppColors.primary)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              // ── Logo + wordmark ─────────────────────────────
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(18.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              blurRadius: 40.r,
                              offset: Offset(0, 16.h),
                            ),
                          ],
                        ),
                        // Only the logo flies into the login screen's Hero.
                        child: Hero(
                          tag: 'olympia_logo',
                          child: Image.asset(
                            'assets/images/olyhub-anneau.png',
                            height: 110.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 28.h),
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  // Meme traitement que le back-office web :
                                  // italique, graisse 900, chasse resserree.
                                  style: TextStyle(
                                    fontSize: 30.sp,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: -1.5,   // ~ tracking-tighter
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Oly',
                                      style: TextStyle(
                                          color: AppColors.brand),
                                    ),
                                    TextSpan(
                                      text: 'Hub',
                                      style: TextStyle(
                                          color: AppColors.secondary),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'ESPACE COMMERCIAL',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 4),
              // ── Loader + footer ─────────────────────────────
              FadeTransition(
                opacity: _textFade,
                child: SizedBox(
                  width: 36.w,
                  height: 36.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              FadeTransition(
                opacity: _textFade,
                child: Text(
                  'OLYMPIA PEINTURE',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
