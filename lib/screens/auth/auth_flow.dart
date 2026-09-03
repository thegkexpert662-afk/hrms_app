import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';
import '../hrms/hrms_navigator.dart';

/// Five-step authentication/onboarding flow:
/// Splash -> Mobile Login -> OTP -> Profile Setup -> Company Setup.
class AuthFlow extends StatefulWidget {
  final HrmsService service;
  const AuthFlow({super.key, required this.service});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  int step = 0;
  String phone = '';
  String fullName = '';
  String email = '';
  String companyName = '';
  String officeAddress = '';
  String city = '';
  String pinCode = '';

  void next() {
    if (mounted) setState(() => step++);
  }

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return _Splash(onDone: next);
      case 1:
        return _MobileLogin(
          initialPhone: phone,
          onVerified: (value) {
            phone = value;
            next();
          },
        );
      case 2:
        return _OtpVerification(
          phone: phone,
          onVerified: next,
          onBack: () => setState(() => step = 1),
        );
      case 3:
        return _ProfileSetup(
          initialName: fullName,
          initialEmail: email,
          onDone: (name, mail) {
            fullName = name;
            email = mail;
            next();
          },
        );
      case 4:
        return _CompanySetup(
          initialCompany: companyName,
          initialAddress: officeAddress,
          initialCity: city,
          initialPin: pinCode,
          onDone: (company, address, cityName, pin) {
            companyName = company;
            officeAddress = address;
            city = cityName;
            pinCode = pin;
            next();
          },
        );
      default:
        return HrmsNavigator(service: widget.service);
    }
  }
}

class _AuthShell extends StatelessWidget {
  final Widget child;
  final int step;
  final bool showBack;
  final VoidCallback? onBack;

  const _AuthShell({
    required this.child,
    required this.step,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBack)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(Icons.business_center_rounded,
                            color: scheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      const Text('HRMS Management',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 26),
                  if (step > 0) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(value: step / 4),
                    ),
                    const SizedBox(height: 22),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Splash extends StatefulWidget {
  final VoidCallback onDone;
  const _Splash({required this.onDone});

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(Icons.business_center_rounded,
                    size: 58, color: scheme.primary),
              ),
              const SizedBox(height: 24),
              const Text('HRMS Management System',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Smart Human Resource Management',
                  style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 30),
              const SizedBox(width: 28, height: 28, child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileLogin extends StatefulWidget {
  final String initialPhone;
  final ValueChanged<String> onVerified;
  const _MobileLogin({required this.initialPhone, required this.onVerified});

  @override
  State<_MobileLogin> createState() => _MobileLoginState();
}

class _MobileLoginState extends State<_MobileLogin> {
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
            if (mounted) widget.onVerified(value);
          } on FirebaseAuthException catch (e) {
            if (mounted) setState(() => error = e.message ?? 'Verification failed');
          }
        },
        verificationFailed: (e) {
          if (mounted) {
            setState(() {
              loading = false;
              error = e.message ?? 'Could not send OTP';
            });
          }
        },
        codeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() => loading = false);
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _OtpVerification(
                phone: value,
                verificationId: verificationId,
                resendToken: resendToken,
                onVerified: () {
                  Navigator.of(context).pop();
                  widget.onVerified(value);
                },
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (_) {
          if (mounted) setState(() => loading = false);
        },
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = e.message ?? 'Could not send OTP';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => _AuthShell(
        step: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.phone_android_rounded, size: 54),
            const SizedBox(height: 18),
            const Text('Welcome back',
                style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Sign in with your registered mobile number.'),
            const SizedBox(height: 28),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              enabled: !loading,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '+91 ',
                border: const OutlineInputBorder(),
                counterText: '',
                errorText: error,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: loading ? null : sendOtp,
                icon: loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.sms_rounded),
                label: Text(loading ? 'Sending OTP...' : 'Send OTP'),
              ),
            ),
          ],
        ),
      );
}

class _OtpVerification extends StatefulWidget {
  final String phone;
  final String? verificationId;
  final int? resendToken;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  const _OtpVerification({
    required this.phone,
    required this.onVerified,
    required this.onBack,
    this.verificationId,
    this.resendToken,
  });

  @override
  State<_OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<_OtpVerification> {
  final controller = TextEditingController();
  String? verificationId;
  int? resendToken;
  String? error;
  int seconds = 30;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    verificationId = widget.verificationId;
    resendToken = widget.resendToken;
    _countdown();
  }

  Future<void> _countdown() async {
    while (mounted && seconds > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && seconds > 0) setState(() => seconds--);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> verify() async {
    final code = controller.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => error = 'Enter the 6-digit OTP');
      return;
    }
    if (verificationId == null || verificationId!.isEmpty) {
      setState(() => error = 'Verification session expired. Please resend OTP.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) widget.onVerified();
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
          } catch (_) {
            if (mounted) setState(() => error = 'Automatic verification failed');
          }
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
  Widget build(BuildContext context) => _AuthShell(
        step: 2,
        showBack: true,
        onBack: widget.onBack,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.verified_user_rounded, size: 54),
            const SizedBox(height: 18),
            const Text('OTP Verification',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
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
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: loading ? null : verify,
                icon: loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.lock_open_rounded),
                label: Text(loading ? 'Verifying...' : 'Verify OTP'),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: seconds == 0 && !loading ? resend : null,
                child: Text(seconds == 0 ? 'Resend OTP' : 'Resend in ${seconds}s'),
              ),
            ),
          ],
        ),
      );
}

class _ProfileSetup extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final void Function(String name, String email) onDone;

  const _ProfileSetup({
    required this.initialName,
    required this.initialEmail,
    required this.onDone,
  });

  @override
  State<_ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<_ProfileSetup> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  String? error;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void submit() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    if (name.length < 2) {
      setState(() => error = 'Enter your full name');
      return;
    }
    if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => error = 'Enter a valid email address');
      return;
    }
    widget.onDone(name, email);
  }

  @override
  Widget build(BuildContext context) => _AuthShell(
        step: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.person_add_alt_1_rounded, size: 54),
            const SizedBox(height: 18),
            const Text('Profile Setup',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Tell us a little about the account owner.'),
            const SizedBox(height: 28),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(),
                errorText: error,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: submit,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Continue'),
              ),
            ),
          ],
        ),
      );
}

class _CompanySetup extends StatefulWidget {
  final String initialCompany;
  final String initialAddress;
  final String initialCity;
  final String initialPin;
  final void Function(String company, String address, String city, String pin) onDone;

  const _CompanySetup({
    required this.initialCompany,
    required this.initialAddress,
    required this.initialCity,
    required this.initialPin,
    required this.onDone,
  });

  @override
  State<_CompanySetup> createState() => _CompanySetupState();
}

class _CompanySetupState extends State<_CompanySetup> {
  late final TextEditingController companyController;
  late final TextEditingController addressController;
  late final TextEditingController cityController;
  late final TextEditingController pinController;
  String? error;

  @override
  void initState() {
    super.initState();
    companyController = TextEditingController(text: widget.initialCompany);
    addressController = TextEditingController(text: widget.initialAddress);
    cityController = TextEditingController(text: widget.initialCity);
    pinController = TextEditingController(text: widget.initialPin);
  }

  @override
  void dispose() {
    companyController.dispose();
    addressController.dispose();
    cityController.dispose();
    pinController.dispose();
    super.dispose();
  }

  void submit() {
    final company = companyController.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();
    final pin = pinController.text.trim();
    if (company.length < 2) {
      setState(() => error = 'Enter company name');
      return;
    }
    if (address.length < 3) {
      setState(() => error = 'Enter office address');
      return;
    }
    if (city.length < 2) {
      setState(() => error = 'Enter city');
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      setState(() => error = 'Enter a valid 6-digit PIN code');
      return;
    }
    widget.onDone(company, address, city, pin);
  }

  @override
  Widget build(BuildContext context) => _AuthShell(
        step: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.business_rounded, size: 54),
            const SizedBox(height: 18),
            const Text('Company Setup',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Create the company profile for your HRMS workspace.'),
            const SizedBox(height: 28),
            TextField(
              controller: companyController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Company Name *',
                prefixIcon: const Icon(Icons.apartment_rounded),
                border: const OutlineInputBorder(),
                errorText: error,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Office Address *',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      prefixIcon: Icon(Icons.location_city_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 145,
                  child: TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'PIN Code *',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: submit,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Finish Setup'),
              ),
            ),
          ],
        ),
      );
}
