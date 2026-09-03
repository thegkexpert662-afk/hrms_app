import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MobileLoginScreen extends StatefulWidget {
  final String initialPhone;
  final void Function(String phone, String verificationId, int? resendToken) onCodeSent;
  final void Function(String phone) onAutoVerified;

  const MobileLoginScreen({super.key, this.initialPhone = '', required this.onCodeSent, required this.onAutoVerified});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  late final TextEditingController controller;
  String? error;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    final value = controller.text.trim();
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      setState(() => error = 'Enter a valid 10-digit Indian mobile number');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$value',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (mounted) widget.onAutoVerified(value);
          } on FirebaseAuthException catch (e) {
            if (mounted) setState(() { loading = false; error = e.message ?? 'Verification failed'; });
          }
        },
        verificationFailed: (e) {
          if (mounted) setState(() { loading = false; error = e.message ?? 'Could not send OTP'; });
        },
        codeSent: (id, token) {
          if (mounted) {
            setState(() => loading = false);
            widget.onCodeSent(value, id, token);
          }
        },
        codeAutoRetrievalTimeout: (_) {
          if (mounted) setState(() => loading = false);
        },
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() { loading = false; error = e.message ?? 'Could not send OTP'; });
    } catch (_) {
      if (mounted) setState(() { loading = false; error = 'Something went wrong. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) => _AuthShell(
    step: 1,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      Center(child: Text('Secure employee access', style: TextStyle(fontSize: 14, color: Colors.black54))),
      const SizedBox(height: 28),
      const Text('Welcome back', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 7),
      const Text('Sign in securely with your registered mobile number.'),
      const SizedBox(height: 22),
      TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        enabled: !loading,
        decoration: InputDecoration(
          labelText: 'Mobile Number',
          hintText: 'Enter 10-digit mobile number',
          prefixIcon: const Icon(Icons.phone_android_rounded),
          prefixText: '+91  ',
          counterText: '',
          errorText: error,
          filled: true,
          fillColor: Colors.white.withValues(alpha: .88),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(width: 2)),
        ),
      ),
      const SizedBox(height: 18),
      SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton.icon(
          onPressed: loading ? null : sendOtp,
          icon: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.water_drop_rounded),
          label: Text(loading ? 'Sending OTP...' : 'Continue with OTP', style: const TextStyle(fontWeight: FontWeight.w700)),
          style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        ),
      ),
      const SizedBox(height: 18),
      const Center(child: Text('Your account is protected with Firebase phone verification.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54))),
    ]),
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
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8FCFF), Color(0xFFE9F7FF)],
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(painter: _WaterPainter(controller.value)),
            ),
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
                            Container(
                              width: 44,
                              height: 44,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .82), borderRadius: BorderRadius.circular(14)),
                              child: SvgPicture.asset('assets/hrms_logo.svg'),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: Text('Kopersay HRMS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                            Text('${widget.step}/4', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(value: widget.step / 4, minHeight: 5),
                        ),
                        const SizedBox(height: 18),
                        Card(
                          elevation: 10,
                          shadowColor: Colors.black.withValues(alpha: .10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          color: Colors.white.withValues(alpha: .93),
                          child: Padding(padding: const EdgeInsets.all(24), child: widget.child),
                        ),
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
      for (double x = 0; x <= size.width; x += 8) {
        final y = base + math.sin((x / size.width) * math.pi * 4 + speed) * amp;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      paint.color = [
        const Color(0x220A7BD5),
        const Color(0x1800A7A0),
        const Color(0x120756A6),
      ][i];
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
