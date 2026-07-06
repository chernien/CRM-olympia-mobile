import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/objectif_progress.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import 'widgets/ca_chart_widget.dart';
import 'widgets/stats_card_widget.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    Future.microtask(
      () => ref.read(dashboardProvider.notifier).loadDashboard(),
    );
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  /// Fires a confetti burst + a congratulations dialog the FIRST time an
  /// objective (CA or task) reaches 100 %. The "already shown" state lives on
  /// the SERVER (ObjectifCelebrations table) — once per objective per user,
  /// shared across devices, logins and reinstalls.
  void _maybeCelebrate(List<ObjectifProgress> objectifs) {
    final freshlyDone =
        objectifs.where((o) => o.pct >= 100 && !o.celebrated).toList();
    if (freshlyDone.isEmpty) return;
    // Mark server-side immediately (also updates local state → no re-fire).
    final notifier = ref.read(dashboardProvider.notifier);
    for (final o in freshlyDone) {
      notifier.markCelebrated(o.id);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _confetti.play();
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => _CelebrationDialog(objectif: freshlyDone.first),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(dashboardProvider);

    // Detect newly-completed objectives and celebrate.
    ref.listen<DashboardState>(dashboardProvider, (_, next) {
      _maybeCelebrate(next.objectifs);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leadingWidth: 60.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: InkWell(
            onTap: state.isLoading
                ? null
                : () => ref
                    .read(dashboardProvider.notifier)
                    .loadDashboard(refresh: true),
            borderRadius: BorderRadius.circular(24.r),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: state.isLoading
                  ? Padding(
                      padding: EdgeInsets.all(10.r),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      color: AppColors.primary,
                      size: 22.sp,
                    ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo-360.png',
              height: 38.h,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'OLYMPIA',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                    height: 1,
                  ),
                ),
                Text(
                  'PEINTURE',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 4,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: InkWell(
              onTap: () => context.goNamed(RouteNames.notifications),
              borderRadius: BorderRadius.circular(24.r),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 22.sp,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: state.isInitialLoad
                ? const _DashboardSkeleton()
                : RefreshIndicator(
                onRefresh: () => ref
                    .read(dashboardProvider.notifier)
                    .loadDashboard(refresh: true),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                  children: [
                    _buildWelcomeCard(),
                    // Error banner — shown over stale data during refresh
                    if (state.error != null) ...[
                      SizedBox(height: 12.h),
                      _ErrorBanner(
                        message: state.error!.message,
                        onRetry: () => ref
                            .read(dashboardProvider.notifier)
                            .loadDashboard(refresh: true),
                      ),
                    ],
                    SizedBox(height: 20.h),
                    _buildSectionTitle('Période'),
                    SizedBox(height: 10.h),
                    _buildPeriodSelector(state),
                    SizedBox(height: 22.h),
                    _buildSectionTitle('Activité'),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Visites ce mois',
                            value:
                                '${state.statsVisites?.moisEnCours ?? 0}',
                            icon: Icons.location_on_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Tâches ce mois',
                            value:
                                '${state.statsTaches?.moisEnCours ?? 0}',
                            icon: Icons.task_alt_outlined,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Visites trim.',
                            value:
                                '${state.statsVisites?.trimestreEnCours ?? 0}',
                            icon: Icons.calendar_month_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: StatsCardWidget(
                            title: 'Tâches trim.',
                            value:
                                '${state.statsTaches?.trimestreEnCours ?? 0}',
                            icon: Icons.assignment_turned_in_outlined,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    _buildSectionTitle('Chiffre d\'Affaires'),
                    SizedBox(height: 12.h),
                    const CAChartWidget(),
                    if (state.objectifs.isNotEmpty) ...[
                      SizedBox(height: 22.h),
                      _buildSectionTitle('Mes Objectifs'),
                      SizedBox(height: 12.h),
                      ...state.objectifs.asMap().entries.map(
                            (e) => _FadeSlideIn(
                              delayMs: e.key * 90,
                              child: _buildObjectifCard(e.value),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
          ),
          // Confetti overlay — plays when an objective is completed.
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 24,
              maxBlastForce: 22,
              minBlastForce: 8,
              gravity: 0.25,
              emissionFrequency: 0.05,
              colors: const [
                Color(0xFF003690),
                Color(0xFF2E7D32),
                Color(0xFFF59E0B),
                Color(0xFFAD5FE1),
                Color(0xFF00A3FF),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectifCard(ObjectifProgress o) {
    final pct = o.pct;
    final done = pct >= 100;
    final barColor = done ? AppColors.success : AppColors.primary;
    final isCa = o.type == 'chiffre_affaire';
    final periodeLabel = o.isMensuel ? 'mensuel' : 'trimestriel';
    final label = isCa
        ? 'Objectif CA $periodeLabel'
        : (o.titre.isNotEmpty
            ? '${o.titre} ($periodeLabel)'
            : 'Objectif tâches $periodeLabel');
    final realiseText = isCa
        ? '${o.caRealise} / ${o.valeur} TND'
        : '${o.caRealise.toInt()} / ${o.valeur.toInt()} tâches';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: done
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.success.withValues(alpha: 0.12),
                  AppColors.success.withValues(alpha: 0.02),
                ],
              )
            : null,
        color: done ? null : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: done
              ? AppColors.success.withValues(alpha: 0.35)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: (done ? AppColors.success : AppColors.primary)
                .withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _CircularObjectifGauge(pct: pct, color: barColor, size: 66.w),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(label,
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                    ),
                    if (done) _doneBadge(),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(realiseText,
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
                if (o.description.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(o.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10.5.sp, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _doneBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 12.sp, color: AppColors.success),
          SizedBox(width: 3.w),
          Text('Atteint',
              style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.success)),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final user = ref.watch(authProvider).user;
    final displayName = user?.fullName ?? 'Olympia User';
    final subtitle = [
      if (user?.role != null) user!.role == 'commercial' ? 'Commercial' : 'Admin',
    ].join(' · ');

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primarySoft, AppColors.secondarySoft],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.white20,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.waving_hand_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue',
                  style: TextStyle(
                    color: AppColors.white90,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.white90,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPeriodSelector(DashboardState state) {
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildPeriodTab(
            'Mensuel',
            state.selectedPeriod == PeriodType.mensuel,
            () => ref
                .read(dashboardProvider.notifier)
                .selectPeriod(PeriodType.mensuel),
          ),
          _buildPeriodTab(
            'Trimestriel',
            state.selectedPeriod == PeriodType.trimestriel,
            () => ref
                .read(dashboardProvider.notifier)
                .selectPeriod(PeriodType.trimestriel),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer skeleton ─────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Welcome card
          Container(
            height: 88.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          SizedBox(height: 20.h),
          // Period selector
          Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18.r),
            ),
          ),
          SizedBox(height: 22.h),
          // Stats row 1
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Stats row 2
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          // Chart area
          Container(
            height: 240.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13.sp, color: AppColors.error),
            ),
          ),
          InkWell(
            onTap: onRetry,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Text(
                'Réessayer',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Circular objective gauge (animated) ──────────────────────────────────────

class _CircularObjectifGauge extends StatelessWidget {
  final double pct; // real attainment (may exceed 100)
  final Color color;
  final double size;

  const _CircularObjectifGauge({
    required this.pct,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = (pct / 100).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        final shownPct = t * pct;
        final pctText = shownPct >= 10
            ? shownPct.toStringAsFixed(0)
            : shownPct.toStringAsFixed(1).replaceAll('.', ',');
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _GaugePainter(
                  progress: t * clamped,
                  color: color,
                  track: AppColors.border,
                ),
              ),
              Text(
                '$pctText%',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final Color track;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.12;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.color != color;
}

// ─── Entrance animation (fade + slide up, plays once) ─────────────────────────

class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const _FadeSlideIn({required this.child, this.delayMs = 0});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _offset = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

// ─── Celebration dialog (objective completed) ─────────────────────────────────

class _CelebrationDialog extends StatelessWidget {
  final ObjectifProgress objectif;

  const _CelebrationDialog({required this.objectif});

  @override
  Widget build(BuildContext context) {
    final isCa = objectif.type == 'chiffre_affaire';
    final periode = objectif.isMensuel ? 'mensuel' : 'trimestriel';
    final what = isCa
        ? 'ton objectif de chiffre d\'affaires $periode'
        : 'ton objectif de tâches $periode';

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Container(
                width: 84.w,
                height: 84.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFFFC85C)],
                  ),
                ),
                child: Icon(Icons.emoji_events_rounded,
                    size: 46.sp, color: Colors.white),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Félicitations ! 🎉',
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              'Bravo, tu as atteint $what.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.sp, color: AppColors.textSecondary, height: 1.4),
            ),
            SizedBox(height: 22.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Continuer',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
