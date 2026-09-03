import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  final int? resendToken;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.verificationId,
    this.resendToken,
    required this.onVerified,
    required this.onBack,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController controller = TextEditingController();
  late String verificationId;
  int? resendToken;
  int seconds = 30;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    verificationId = widget.verificationId;
    resendToken = widget.resendToken;
    _countdown();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _countdown() async {
    while (mounted && seconds > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && seconds > 0) {
        setState(() => seconds--);
      }
    }
  }

  Future<void> verify() async {
    final code = controller.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => error = 'Enter the 6-digit OTP');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        widget.onVerified();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = e.message ?? 'Invalid OTP';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'Verification failed. Please try again.';
        });
      }
    }
  }

  Future<void> resend() async {
    if (seconds != 0 || loading) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phone}',
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
        verificationCompleted: (credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (mounted) widget.onVerified();
          } catch (_) {}
        },
        verificationFailed: (e) {
          if (mounted) {
            setState(() {
              loading = false;
              error = e.message ?? 'Could not resend OTP';
            });
          }
        },
        codeSent: (id, token) {
          if (mounted) {
            setState(() {
              verificationId = id;
              resendToken = token;
              loading = false;
              seconds = 30;
            });
            _countdown();
          }
        },
        codeAutoRetrievalTimeout: (id) {
          if (mounted) {
            setState(() {
              verificationId = id;
              loading = false;
            });
          }
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'Could not resend OTP';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    alignment: Alignment.centerLeft,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(Icons.business_center_rounded, color: scheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      const Text('HRMS Management', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 26),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(value: .5),
                  ),
                  const SizedBox(height: 28),
                  const Icon(Icons.verified_user_rounded, size: 54),
                  const SizedBox(height: 18),
                  const Text('OTP Verification', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Enter the 6-digit OTP sent to +91 ${widget.phone}.'),
                  const SizedBox(height: 28),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    enabled: !loading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      labelText: 'OTP',
                      border: const OutlineInputBorder(),
                      counterText: '',
                      errorText: error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: loading ? null : verify,
                      icon: loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.lock_open_rounded),
                      label: Text(loading ? 'Verifying...' : 'Verify OTP'),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: seconds == 0 && !loading ? resend : null,
                      child: Text(seconds == 0 ? 'Resend OTP' : 'Resend in ${seconds}s'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
