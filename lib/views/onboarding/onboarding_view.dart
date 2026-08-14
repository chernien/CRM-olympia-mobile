import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Tints are derived from the brand palette instead of hand-picked hex values,
  // so the onboarding illustrations stay in step with AppColors.
  static final _pages = [
    _OnboardingPage(
      icon: Icons.route_rounded,
      iconColor: AppColors.primary,
      bgColor: AppColors.tint(AppColors.primary),
      accentColor: AppColors.deepen(AppColors.primary),
      title: 'Gérez vos visites\nterrain',
      subtitle:
          'Planifiez et suivez toutes vos tâches sur le terrain. '
          'Priorisez vos interventions et mettez à jour leur statut en temps réel.',
    ),
    _OnboardingPage(
      icon: Icons.assignment_rounded,
      iconColor: AppColors.secondary,
      bgColor: AppColors.tint(AppColors.secondary),
      accentColor: AppColors.deepen(AppColors.secondary),
      title: 'Traitez vos\ndemandes clients',
      // The backend defines 8 demande types, not 9 (see DemandeType enum).
      subtitle:
          'Créez et suivez vos demandes commerciales : échantillons, '
          'réclamations, nouveaux clients et bien plus encore.',
    ),
    _OnboardingPage(
      icon: Icons.bar_chart_rounded,
      iconColor: AppColors.warning,
      bgColor: AppColors.tint(AppColors.warning),
      accentColor: AppColors.deepen(AppColors.warning),
      title: 'Analysez vos\nperformances',
      subtitle:
          'Consultez votre chiffre d\'affaires mensuel et trimestriel. '
          // Matches the labels the dashboard actually shows.
          'Visualisez vos catégories Intérieur, Extérieur et Olybat d\'un seul coup d\'œil.',
    ),
  ];

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _complete();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: AnimatedOpacity(
                  opacity: isLast ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: isLast ? null : _complete,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(64, 44),
                    ),
                    child: const Text(
                      'Passer',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _PageContent(page: _pages[i]),
              ),
            ),

            // Bottom section: dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 36),
              child: Column(
                children: [
                  _DotIndicator(
                    count: _pages.length,
                    current: _currentPage,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].iconColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          isLast ? 'Commencer' : 'Suivant',
                          key: ValueKey(isLast),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page data ────────────────────────────────────────────────────────────────

class _OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color accentColor;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.accentColor,
    required this.title,
    required this.subtitle,
  });
}

// ─── Page content widget ──────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;

  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    // Fixed 260 dp illustration + fixed gaps overflowed on short screens and at
    // large system font sizes. The column now scrolls instead of clipping, and
    // still centres whenever there is room.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration area
          _IllustrationBox(page: page),
          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

// ─── Illustration ─────────────────────────────────────────────────────────────

class _IllustrationBox extends StatelessWidget {
  final _OnboardingPage page;

  const _IllustrationBox({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: page.bgColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.iconColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.iconColor.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Main icon circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: page.iconColor.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 56,
              color: page.iconColor,
            ),
          ),
          // Small accent badges
          Positioned(
            top: 40,
            left: 28,
            child: _AccentBadge(color: page.iconColor),
          ),
          Positioned(
            bottom: 40,
            right: 28,
            child: _AccentBadge(color: page.accentColor, size: 10),
          ),
        ],
      ),
    );
  }
}

class _AccentBadge extends StatelessWidget {
  final Color color;
  final double size;

  const _AccentBadge({required this.color, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.5),
      ),
    );
  }
}

// ─── Dot indicator ────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
