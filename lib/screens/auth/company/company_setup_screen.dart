import 'package:flutter/material.dart';

class CompanySetupScreen extends StatefulWidget {
  final String initialCompany;
  final String initialAddress;
  final String initialCity;
  final String initialPin;
  final Future<void> Function(String company, String address, String city, String pin) onDone;

  const CompanySetupScreen({
    super.key,
    this.initialCompany = '',
    this.initialAddress = '',
    this.initialCity = '',
    this.initialPin = '',
    required this.onDone,
  });

  @override
  State<CompanySetupScreen> createState() => _CompanySetupScreenState();
}

class _CompanySetupScreenState extends State<CompanySetupScreen> {
  late final TextEditingController companyController;
  late final TextEditingController addressController;
  late final TextEditingController cityController;
  late final TextEditingController pinController;
  String? error;
  bool saving = false;

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

  Future<void> finish() async {
    if (saving) return;
    final company = companyController.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();
    final pin = pinController.text.trim();

    if (company.length < 2 || address.length < 3 || city.length < 2 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
      setState(() => error = 'Please complete all company details. PIN must be 6 digits.');
      return;
    }

    setState(() {
      error = null;
      saving = true;
    });

    try {
      await widget.onDone(company, address, city, pin);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  InputDecoration fieldDecoration(String label) {
    return InputDecoration(labelText: label, border: const OutlineInputBorder());
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
                        child: Icon(Icons.business_center_rounded, color: scheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      const Text('HRMS Management', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const LinearProgressIndicator(value: 1),
                  const SizedBox(height: 28),
                  const Icon(Icons.business_rounded, size: 54),
                  const SizedBox(height: 18),
                  const Text('Company Setup', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Set up your company profile to continue.'),
                  const SizedBox(height: 28),
                  TextField(
                    controller: companyController,
                    textCapitalization: TextCapitalization.words,
                    decoration: fieldDecoration('Company Name').copyWith(errorText: error),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: fieldDecoration('Office Address'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityController,
                          textCapitalization: TextCapitalization.words,
                          decoration: fieldDecoration('City'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: pinController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: fieldDecoration('PIN Code').copyWith(counterText: ''),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: saving ? null : finish,
                      icon: saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check_rounded),
                      label: Text(saving ? 'Saving...' : 'Complete Setup'),
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
