import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
              child: Icon(Icons.business_center_rounded, size: 58, color: scheme.primary),
            ),
            const SizedBox(height: 24),
            const Text('HRMS Management System', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Smart Human Resource Management',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 30),
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
