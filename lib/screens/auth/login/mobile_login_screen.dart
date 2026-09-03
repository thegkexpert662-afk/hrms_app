import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MobileLoginScreen extends StatefulWidget {
  final String initialEmail;
  final void Function(String email) onSignedIn;

  const MobileLoginScreen({super.key, this.initialEmail = '', required this.onSignedIn});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  String? error;
  bool loading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initialEmail);
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => error = 'Enter a valid email address');
      return;
    }
    if (password.isEmpty) {
      setState(() => error = 'Enter your password');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (mounted) widget.onSignedIn(credential.user?.email ?? email);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = 'Incorrect email or password';
          break;
        case 'invalid-email':
          message = 'Enter a valid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your internet connection.';
          break;
        default:
          message = e.message ?? 'Unable to sign in. Please try again.';
      }
      if (mounted) setState(() { loading = false; error = message; });
    } catch (_) {
      if (mounted) setState(() { loading = false; error = 'Something went wrong. Please try again.'; });
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => error = 'Enter your email first to reset your password');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent. Check your inbox.')));
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => error = e.message ?? 'Could not send reset email');
    }
  }

  @override
  Widget build(BuildContext context) => _AuthShell(
    step: 1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: .96, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutBack,
            builder: (_, value, child) => Transform.scale(scale: value, child: child),
            child: SvgPicture.asset('assets/hrms_logo.svg', width: 260, height: 112, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 8),
        const Center(child: Text('Kopersay HRMS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
        const SizedBox(height: 6),
        const Center(child: Text('Secure employee access', style: TextStyle(fontSize: 14, color: Colors.black54))),
        const SizedBox(height: 28),
        const Text('Welcome back', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        const Text('Sign in with your registered email and password.'),
        const SizedBox(height: 22),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !loading,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter your email address',
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: error,
            filled: true,
            fillColor: Colors.white.withValues(alpha: .88),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(width: 2)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          enabled: !loading,
          onSubmitted: (_) => signIn(),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              tooltip: obscurePassword ? 'Show password' : 'Hide password',
              onPressed: loading ? null : () => setState(() => obscurePassword = !obscurePassword),
              icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: .88),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(width: 2)),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(onPressed: loading ? null : resetPassword, child: const Text('Forgot password?')),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: loading ? null : signIn,
            icon: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login_rounded),
            label: Text(loading ? 'Signing in...' : 'Sign In', style: const TextStyle(fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
          ),
        ),
        const SizedBox(height: 18),
        const Center(child: Text('Your account is protected with Firebase Authentication.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54))),
      ],
    ),
  );
}

class _AuthShell extends StatefulWidget {
  final Widget child;
  final int step;
  const _AuthShell({required this.child, required this.step});

  @override
  State<_AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<_AuthShell> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: controller,
        builder: (_, __) => Stack(
          children: [
            Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF8FCFF), Color(0xFFE9F7FF)]))),
            Positioned.fill(child: CustomPaint(painter: _WaterPainter(controller.value))),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(width: 44, height: 44, padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .82), borderRadius: BorderRadius.circular(14)), child: SvgPicture.asset('assets/hrms_logo.svg')),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('Kopersay HRMS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                            Text('${widget.step}/4', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: widget.step / 4, minHeight: 5)),
                        const SizedBox(height: 18),
                        Card(elevation: 10, shadowColor: Colors.black.withValues(alpha: .10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), color: Colors.white.withValues(alpha: .93), child: Padding(padding: const EdgeInsets.all(24), child: widget.child)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterPainter extends CustomPainter {
  final double progress;
  _WaterPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 3; i++) {
      final path = Path();
      final base = size.height * (.80 + i * .055);
      final amp = 22.0 + i * 8;
      final speed = progress * math.pi * 2 * (i.isEven ? 1 : -1);
      path.moveTo(0, base);
      for (double x = 0; x <= size.width; x += 8) path.lineTo(x, base + math.sin((x / size.width) * math.pi * 4 + speed) * amp);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      paint.color = [const Color(0x220A7BD5), const Color(0x1800A7A0), const Color(0x120756A6)][i];
      canvas.drawPath(path, paint);
    }

    final bubblePaint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 7; i++) {
      final x = ((i * 73) % 100) / 100 * size.width;
      final y = size.height * (0.72 - ((progress + i * .13) % 1) * .35);
      bubblePaint.color = Colors.white.withValues(alpha: .30);
      canvas.drawCircle(Offset(x, y), 4.0 + (i % 3) * 2, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterPainter oldDelegate) => oldDelegate.progress != progress;
}
