import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  void dispose() { controller.dispose(); super.dispose(); }

  Future<void> sendOtp() async {
    final value = controller.text.trim();
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      setState(() => error = 'Enter a valid 10-digit Indian mobile number');
      return;
    }
    setState(() { loading = true; error = null; });
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
        codeAutoRetrievalTimeout: (_) { if (mounted) setState(() => loading = false); },
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
      const Icon(Icons.phone_android_rounded, size: 54),
      const SizedBox(height: 18),
      const Text('Welcome back', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Sign in with your registered mobile number.'),
      const SizedBox(height: 28),
      TextField(controller: controller, keyboardType: TextInputType.phone, maxLength: 10, enabled: !loading,
        decoration: InputDecoration(labelText: 'Mobile Number', prefixText: '+91 ', border: const OutlineInputBorder(), counterText: '', errorText: error)),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, height: 54, child: FilledButton.icon(
        onPressed: loading ? null : sendOtp,
        icon: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sms_rounded),
        label: Text(loading ? 'Sending OTP...' : 'Send OTP'),
      )),
    ]),
  );
}

class _AuthShell extends StatelessWidget {
  final Widget child;
  final int step;
  const _AuthShell({required this.child, required this.step});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [CircleAvatar(radius: 22, backgroundColor: scheme.primaryContainer, child: Icon(Icons.business_center_rounded, color: scheme.onPrimaryContainer)), const SizedBox(width: 12), const Text('HRMS Management', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))]),
        const SizedBox(height: 26),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: step / 4)),
        const SizedBox(height: 22),
        child,
      ])),
    ))));
  }
}
