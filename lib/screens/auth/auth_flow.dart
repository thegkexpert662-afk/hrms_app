import 'package:flutter/material.dart';

import '../../app/hrms_app.dart';
import '../hrms/hrms_navigator.dart';
import 'company/company_setup_screen.dart';
import 'login/mobile_login_screen.dart';
import 'otp/otp_verification_screen.dart';
import 'profile/profile_setup_screen.dart';
import 'splash/splash_screen.dart';

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

  void openProfile() {
    if (mounted) setState(() => step = 3);
  }

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return SplashScreen(onDone: next);

      case 1:
        return MobileLoginScreen(
          initialPhone: phone,
          onCodeSent: (value, verificationId, resendToken) {
            phone = value;
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => OtpVerificationScreen(
                  phone: value,
                  verificationId: verificationId,
                  resendToken: resendToken,
                  onVerified: () {
                    Navigator.of(context).pop();
                    openProfile();
                  },
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            );
          },
          onAutoVerified: (value) {
            phone = value;
            openProfile();
          },
        );

      case 2:
        // OTP is displayed as a separate route from Mobile Login.
        // Keep this state as a safe fallback instead of duplicating Login.
        return SplashScreen(onDone: openProfile);

      case 3:
        return ProfileSetupScreen(
          initialName: fullName,
          initialEmail: email,
          onDone: (name, mail) {
            fullName = name;
            email = mail;
            next();
          },
        );

      case 4:
        return CompanySetupScreen(
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
