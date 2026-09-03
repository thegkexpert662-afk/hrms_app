import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final void Function(String name, String email) onDone;

  const ProfileSetupScreen({
    super.key,
    this.initialName = '',
    this.initialEmail = '',
    required this.onDone,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  String? nameError;
  String? emailError;

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

  void save() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    setState(() {
      nameError = null;
      emailError = null;
    });

    if (name.length < 2) {
      setState(() => nameError = 'Enter your full name');
      return;
    }

    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => emailError = 'Enter a valid email address');
      return;
    }

    widget.onDone(name, email);
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(
                          Icons.business_center_rounded,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'HRMS Management',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const LinearProgressIndicator(value: .75),
                  const SizedBox(height: 28),
                  const Icon(Icons.person_outline_rounded, size: 54),
                  const SizedBox(height: 18),
                  const Text(
                    'Profile Setup',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tell us a little about yourself.'),
                  const SizedBox(height: 28),
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: const OutlineInputBorder(),
                      errorText: nameError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email (optional)',
                      border: const OutlineInputBorder(),
                      errorText: emailError,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: save,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Continue'),
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
