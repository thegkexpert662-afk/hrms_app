import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class ReportsScreen extends StatelessWidget {
  final HrmsService service;
  const ReportsScreen({super.key, required this.service});

  static const _items = <_ReportItem>[
    _ReportItem('Reports Dashboard', Icons.dashboard_outlined),
    _ReportItem('Employee Reports', Icons.people_outline),
    _ReportItem('Attendance Reports', Icons.access_time_outlined),
    _ReportItem('Leave Reports', Icons.event_available_outlined),
    _ReportItem('Payroll Reports', Icons.payments_outlined),
    _ReportItem('Performance Reports', Icons.insights_outlined),
    _ReportItem('Expense / Asset Reports', Icons.receipt_long_outlined),
    _ReportItem('PDF / Excel Export', Icons.file_download_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(radius: 28, child: Icon(Icons.analytics)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Reports & Analytics',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ..._items.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(child: Icon(item.icon)),
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(_subtitle(item.title)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportDetailScreen(
                      service: service,
                      title: item.title,
                      icon: item.icon,
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  String _subtitle(String title) {
    switch (title) {
      case 'Reports Dashboard':
        return 'Overview of HR metrics and report categories';
      case 'Employee Reports':
        return 'Employee count, departments, joining and exits';
      case 'Attendance Reports':
        return 'Attendance, late, overtime and missing punch data';
      case 'Leave Reports':
        return 'Leave balance, usage and approval summaries';
      case 'Payroll Reports':
        return 'Salary, payroll processing and payslip summaries';
      case 'Performance Reports':
        return 'Goals, ratings and appraisal summaries';
      case 'Expense / Asset Reports':
        return 'Expense claims and company asset summaries';
      default:
        return 'Prepare data for PDF or Excel export';
    }
  }
}

class _ReportItem {
  final String title;
  final IconData icon;
  const _ReportItem(this.title, this.icon);
}

class ReportDetailScreen extends StatefulWidget {
  final HrmsService service;
  final String title;
  final IconData icon;
  const ReportDetailScreen({super.key, required this.service, required this.title, required this.icon});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  String period = 'Current Month';
  bool generated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(child: Icon(widget.icon)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: period,
                    decoration: const InputDecoration(labelText: 'Report Period', border: OutlineInputBorder()),
                    items: const ['Today', 'Current Week', 'Current Month', 'Quarter', 'Year'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                    onChanged: (value) => setState(() => period = value ?? period),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => setState(() => generated = true),
                      icon: const Icon(Icons.assessment_outlined),
                      label: const Text('Generate Report'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (generated) _ReportPreview(title: widget.title, period: period),
          if (widget.title == 'PDF / Excel Export') const _ExportOptions(),
          if (!generated && widget.title != 'PDF / Excel Export')
            const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Select a period and generate the report.'))),
        ],
      ),
    );
  }
}

class _ReportPreview extends StatelessWidget {
  final String title;
  final String period;
  const _ReportPreview({required this.title, required this.period});

  @override
  Widget build(BuildContext context) {
    final rows = <String, String>{
      'Report': title,
      'Period': period,
      'Records': 'Ready for review',
      'Status': 'Generated',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...rows.entries.map((entry) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.key),
                  trailing: Text(entry.value),
                )),
          ],
        ),
      ),
    );
  }
}

class _ExportOptions extends StatelessWidget {
  const _ExportOptions();

  void _showMessage(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$format export is ready to connect.')));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export Format', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showMessage(context, 'PDF'),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Export PDF'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showMessage(context, 'Excel'),
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Export Excel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
