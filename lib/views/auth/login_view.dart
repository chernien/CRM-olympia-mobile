import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && mounted) {
      context.go(RouteNames.dashboard);
    }
  }

  // Custom Input Decoration for perfect soft UI fields
  InputDecoration _customInputDecoration(String hint, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22.sp),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF4F7FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Vector Logo integrated beautifully
                  Hero(
                    tag: 'olympia_logo',
                    child: SvgPicture.asset(
                      'assets/images/OLY-svg.svg',
                      height: 70.h,
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // Clean Minimalist Form Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(32.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 30.r,
                          offset: Offset(0, 10.h),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                // Welcome Text
                                Text(
                                  'Connexion',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.5,
                                        fontSize: 28.sp,
                                      ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Accédez à votre espace Olympia',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 14.sp,
                                      ),
                                ),
                                SizedBox(height: 32.h),

                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16.sp),
                                  decoration: _customInputDecoration('Adresse email', Icons.email_outlined),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Veuillez saisir votre email';
                                    if (!value.contains('@')) return 'Email invalide';
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16.sp),
                                  decoration: _customInputDecoration(
                                    'Mot de passe',
                                    Icons.lock_outline_rounded,
                                    suffixIcon: Padding(
                                      padding: EdgeInsets.only(right: 8.w),
                                      child: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                          color: AppColors.textSecondary,
                                          size: 22.sp,
                                        ),
                                        onPressed: () {
                                          setState(() => _obscurePassword = !_obscurePassword);
                                        },
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Veuillez saisir votre mot de passe';
                                    return null;
                                  },
                                ),
                                
                                // Forgot Password Link
                                SizedBox(height: 12.h),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Mot de passe oublié ?',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 32.h),

                                // Error Message
                                if (authState.error != null)
                                  Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(bottom: 24.h),
                                    padding: EdgeInsets.all(12.r),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            authState.error!.message,
                                            style: TextStyle(color: AppColors.error, fontSize: 13.sp, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Premium Login Button
                                Container(
                                  width: double.infinity,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28.r),
                                    color: AppColors.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.4),
                                        blurRadius: 20.r,
                                        offset: Offset(0, 8.h),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(28.r),
                                      onTap: authState.isLoading ? null : _handleLogin,
                                      child: Center(
                                        child: authState.isLoading
                                            ? SizedBox(
                                                width: 24.w,
                                                height: 24.h,
                                                child: const CircularProgressIndicator.adaptive(
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      'Se connecter',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16.sp,
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20.sp),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      
                      // Bottom Text
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Problème d'accès ?",
                            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                            child: const Text(
                              'Contacter l\'admin',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}