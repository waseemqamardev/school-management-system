import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/school_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/firebase_status_dialog.dart';
import '../../widgets/connectivity_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(auth.errorMessage ?? 'Authentication failed.')),
            ],
          ),
          backgroundColor: AppColors.absent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _quickLogin(String role) async {
    final auth = context.read<AuthProvider>();
    switch (role) {
      case 'admin':
        _emailController.text = 'admin@daralarqam.demo';
        _passwordController.text = '123456';
        break;
      case 'teacher':
        _emailController.text = 'teacher@daralarqam.demo';
        _passwordController.text = '123456';
        break;
      case 'parent':
        _emailController.text = 'parent@daralarqam.demo';
        _passwordController.text = '123456';
        break;
    }
    await auth.quickDemoLogin(role);
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_reset, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Text('Reset Password', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your registered email address and we will send password reset instructions.',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: resetEmailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Password reset instructions sent to your email.'),
                  backgroundColor: AppColors.present,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 soft backdrop
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const ConnectivityIndicatorBadge(),
          IconButton(
            tooltip: 'Supabase / Backend Setup',
            icon: const Icon(Icons.dns_rounded, color: AppColors.primary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const BackendStatusDialog(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 14, vertical: 14),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 480 : double.infinity),
              child: RepaintBoundary(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 18, vertical: 26),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Bismillah Subtitle Header
                          Center(
                            child: Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              style: GoogleFonts.amiri(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldAccentDark,
                                letterSpacing: 1.2,
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),

                          const SizedBox(height: 18),

                          // Animated School Logo & Crest
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glowing background aura
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withAlpha(20),
                                  ),
                                )
                                    .animate(onPlay: (c) => c.repeat(reverse: true))
                                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 2.seconds),

                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(90),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      SchoolConstants.logoAsset,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        color: AppColors.primary,
                                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 40),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 100.ms)
                              .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

                          const SizedBox(height: 16),

                          // Title & Tagline
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Dar-e-Arqam',
                                  style: GoogleFonts.outfit(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Digital School Management Portal',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 200.ms)
                              .slideY(begin: 0.1, end: 0),

                          const SizedBox(height: 26),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.plusJakartaSans(fontSize: 14),
                            decoration: const InputDecoration(
                              labelText: 'Email Address or Mobile',
                              hintText: 'e.g. teacher@daralarqam.demo',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email or mobile';
                              }
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(duration: 350.ms, delay: 250.ms)
                              .slideX(begin: -0.05, end: 0),

                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.plusJakartaSans(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          )
                              .animate()
                              .fadeIn(duration: 350.ms, delay: 300.ms)
                              .slideX(begin: 0.05, end: 0),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Login Button
                          ElevatedButton(
                            onPressed: auth.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign In to Portal',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                          )
                              .animate()
                              .fadeIn(duration: 350.ms, delay: 350.ms)
                              .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack),

                          const SizedBox(height: 28),

                          // Demo Login Section Header
                          Row(
                            children: [
                              const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '1-CLICK DEMO ACCOUNTS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMuted,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                            ],
                          ).animate().fadeIn(duration: 350.ms, delay: 400.ms),

                          const SizedBox(height: 16),

                          // Quick Demo Cards
                          _buildQuickRoleCard(
                            role: 'Admin / Principal',
                            badge: 'admin@daralarqam.demo',
                            icon: Icons.admin_panel_settings_rounded,
                            color: AppColors.primary,
                            delayMs: 450,
                            onTap: () => _quickLogin('admin'),
                          ),
                          const SizedBox(height: 8),
                          _buildQuickRoleCard(
                            role: 'Teacher (Sir Ahmed)',
                            badge: 'teacher@daralarqam.demo',
                            icon: Icons.school_rounded,
                            color: AppColors.primaryLight,
                            delayMs: 500,
                            onTap: () => _quickLogin('teacher'),
                          ),
                          const SizedBox(height: 8),
                          _buildQuickRoleCard(
                            role: 'Parent (Tariq Khan)',
                            badge: 'parent@daralarqam.demo',
                            icon: Icons.family_restroom_rounded,
                            color: AppColors.yellowAccentDark,
                            delayMs: 550,
                            onTap: () => _quickLogin('parent'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRoleCard({
    required String role,
    required String badge,
    required IconData icon,
    required Color color,
    required int delayMs,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: color.withAlpha(40),
          highlightColor: AppColors.rippleYellow.withAlpha(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withAlpha(50)),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        badge,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Login',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(Icons.chevron_right_rounded, size: 14, color: color),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: delayMs.ms)
        .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
        .slideX(begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
  }
}
