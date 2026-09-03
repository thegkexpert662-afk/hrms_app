import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/hrms_app.dart';

class QrAttendanceScreen extends StatefulWidget {
  final HrmsService service;
  const QrAttendanceScreen({super.key, required this.service});
  @override State<QrAttendanceScreen> createState() => _QrAttendanceScreenState();
}

class _QrAttendanceScreenState extends State<QrAttendanceScreen> {
  final controller = MobileScannerController();
  bool processing = false;
  String message = 'Scan the company attendance QR code.';

  Future<void> _handle(String payload) async {
    if (processing) return;
    setState(() => processing = true);
    try {
      final valid = await widget.service.backend.validateQrSession(payload);
      if (!valid) throw StateError('Invalid or expired attendance QR code.');
      if (widget.service.employees.isEmpty) throw StateError('No employee profile is available.');
      final employee = widget.service.employees.first;
      final record = widget.service.punchIn(employee.id);
      if (mounted) setState(() => message = 'Attendance marked at ${_time(record.punchIn)}.');
      await controller.stop();
    } catch (e) {
      if (mounted) setState(() => message = e.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  String _time(DateTime? value) => value == null ? '--' : '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  @override void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('QR Attendance')),
    body: Column(children: [
      Expanded(child: Stack(children: [
        MobileScanner(controller: controller, onDetect: (capture) {
          if (capture.barcodes.isEmpty) return;
          final value = capture.barcodes.first.rawValue;
          if (value != null && value.isNotEmpty) _handle(value);
        }),
        Center(child: Container(width: 250, height: 250, decoration: BoxDecoration(border: Border.all(width: 3), borderRadius: BorderRadius.circular(24)))),
        if (processing) const Center(child: CircularProgressIndicator()),
      ])),
      Padding(padding: const EdgeInsets.all(20), child: Column(children: [Text(message, textAlign: TextAlign.center), const SizedBox(height: 12), FilledButton.icon(onPressed: processing ? null : () { controller.start(); setState(() => message = 'Scan the company attendance QR code.'); }, icon: const Icon(Icons.qr_code_scanner), label: const Text('Scan Again'))]))
    ]),
  );
}
