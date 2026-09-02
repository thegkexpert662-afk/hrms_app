import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';
import '../hrms/hrms_navigator.dart';

class AuthFlow extends StatefulWidget {
  final HrmsService service;
  const AuthFlow({super.key, required this.service});
  @override State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  int step = 0;
  String phone = '';
  void next() => setState(() => step++);
  @override Widget build(BuildContext context) {
    switch (step) {
      case 0: return _Splash(onDone: next);
      case 1: return _Login(onNext: (v) { phone = v; next(); });
      case 2: return _Otp(phone: phone, onNext: next);
      case 3: return _Form(title: 'Profile Setup', fields: const ['Full Name', 'Email'], onDone: next);
      case 4: return _Form(title: 'Company Profile', fields: const ['Company Name', 'Office Address', 'City', 'PIN Code'], onDone: next);
      default: return HrmsNavigator(service: widget.service);
    }
  }
}

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});
  @override Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: child))),),
  );
}

class _Splash extends StatefulWidget {
  final VoidCallback onDone;
  const _Splash({required this.onDone});
  @override State<_Splash> createState() => _SplashState();
}
class _SplashState extends State<_Splash> {
  @override void initState() { super.initState(); Future.delayed(const Duration(seconds: 2), () { if (mounted) widget.onDone(); }); }
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.business_center_rounded, size: 72, color: Theme.of(context).colorScheme.primary),
    const SizedBox(height: 20), const Text('HRMS Management System', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8), const Text('Smart Human Resource Management'), const SizedBox(height: 30), const CircularProgressIndicator(),
  ])));
}

class _Login extends StatefulWidget {
  final ValueChanged<String> onNext;
  const _Login({required this.onNext});
  @override State<_Login> createState() => _LoginState();
}
class _LoginState extends State<_Login> {
  final c = TextEditingController(); String? error;
  @override void dispose() { c.dispose(); super.dispose(); }
  void submit() { final v = c.text.trim(); if (RegExp(r'^\d{10}$').hasMatch(v)) { widget.onNext(v); } else { setState(() => error = 'Enter a valid 10-digit number'); } }
  @override Widget build(BuildContext context) => _Shell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Icon(Icons.phone_android_rounded, size: 52), const SizedBox(height: 18), const Text('Welcome back', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8), const Text('Enter your registered mobile number'), const SizedBox(height: 28),
    TextField(controller: c, keyboardType: TextInputType.phone, maxLength: 10, decoration: InputDecoration(labelText: 'Mobile Number', prefixText: '+91 ', border: const OutlineInputBorder(), counterText: '', errorText: error)),
    const SizedBox(height: 20), SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: submit, child: const Text('Send OTP'))),
  ]));
}

class _Otp extends StatefulWidget {
  final String phone; final VoidCallback onNext;
  const _Otp({required this.phone, required this.onNext});
  @override State<_Otp> createState() => _OtpState();
}
class _OtpState extends State<_Otp> {
  final c = TextEditingController(); String? error; int seconds = 30;
  @override void initState() { super.initState(); _countdown(); }
  Future<void> _countdown() async { while (mounted && seconds > 0) { await Future.delayed(const Duration(seconds: 1)); if (mounted && seconds > 0) setState(() => seconds--); } }
  @override void dispose() { c.dispose(); super.dispose(); }
  void verify() { if (RegExp(r'^\d{6}$').hasMatch(c.text.trim())) widget.onNext(); else setState(() => error = 'Enter the 6-digit OTP'); }
  @override Widget build(BuildContext context) => _Shell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Icon(Icons.verified_user_rounded, size: 52), const SizedBox(height: 18), const Text('OTP Verification', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8), Text('Enter the 6-digit OTP sent to +91 ${widget.phone}'), const SizedBox(height: 28),
    TextField(controller: c, keyboardType: TextInputType.number, maxLength: 6, textAlign: TextAlign.center, decoration: InputDecoration(labelText: 'OTP', border: const OutlineInputBorder(), counterText: '', errorText: error)),
    const SizedBox(height: 20), SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: verify, child: const Text('Verify OTP'))),
    Center(child: TextButton(onPressed: seconds == 0 ? () { setState(() => seconds = 30); _countdown(); } : null, child: Text(seconds == 0 ? 'Resend OTP' : 'Resend in ${seconds}s'))),
  ]));
}

class _Form extends StatefulWidget {
  final String title; final List<String> fields; final VoidCallback onDone;
  const _Form({required this.title, required this.fields, required this.onDone});
  @override State<_Form> createState() => _FormState();
}
class _FormState extends State<_Form> {
  late final List<TextEditingController> controllers = List.generate(widget.fields.length, (_) => TextEditingController());
  @override void dispose() { for (final c in controllers) c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => _Shell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Icon(Icons.edit_note_rounded, size: 52), const SizedBox(height: 18), Text(widget.title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)), const SizedBox(height: 28),
    ...List.generate(widget.fields.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 16), child: TextField(controller: controllers[i], maxLines: widget.fields[i].contains('Address') ? 2 : 1, keyboardType: widget.fields[i] == 'PIN Code' ? TextInputType.number : TextInputType.text, decoration: InputDecoration(labelText: widget.fields[i], border: const OutlineInputBorder())))),
    SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: () { if (controllers.first.text.trim().isNotEmpty) widget.onDone(); }, child: Text(widget.title == 'Company Profile' ? 'Finish Setup' : 'Continue'))),
  ]));
}
