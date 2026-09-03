import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class CommunicationScreen extends StatelessWidget {
  final HrmsService service;

  const CommunicationScreen({super.key, required this.service});

  static const items = <_CommunicationItem>[
    _CommunicationItem('Announcements', Icons.campaign_outlined),
    _CommunicationItem('Notices', Icons.notifications_active_outlined),
    _CommunicationItem('Circulars', Icons.description_outlined),
    _CommunicationItem('Events / Holidays', Icons.event_outlined),
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
                const CircleAvatar(radius: 28, child: Icon(Icons.campaign)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Company Communication',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...items.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(child: Icon(item.icon)),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(_subtitle(item.title)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CommunicationDetailScreen(
                    service: service,
                    title: item.title,
                    icon: item.icon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _subtitle(String title) {
    switch (title) {
      case 'Announcements':
        return 'Create and publish company-wide announcements';
      case 'Notices':
        return 'Manage important HR and workplace notices';
      case 'Circulars':
        return 'Publish official policies and circulars';
      default:
        return 'Manage events, holidays and company activities';
    }
  }
}

class _CommunicationItem {
  final String title;
  final IconData icon;
  const _CommunicationItem(this.title, this.icon);
}

class CommunicationDetailScreen extends StatefulWidget {
  final HrmsService service;
  final String title;
  final IconData icon;

  const CommunicationDetailScreen({super.key, required this.service, required this.title, required this.icon});

  @override
  State<CommunicationDetailScreen> createState() => _CommunicationDetailScreenState();
}

class _CommunicationDetailScreenState extends State<CommunicationDetailScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final records = <_CommunicationRecord>[];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void _addRecord() {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a title')));
      return;
    }

    setState(() {
      records.insert(
        0,
        _CommunicationRecord(
          title: title,
          description: descriptionController.text.trim(),
          date: dateController.text.trim(),
        ),
      );
      titleController.clear();
      descriptionController.clear();
      dateController.clear();
    });
  }

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
                children: [
                  Row(
                    children: [
                      CircleAvatar(child: Icon(widget.icon)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description / Details', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: 'Date / Schedule', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _addRecord,
                      icon: const Icon(Icons.publish),
                      label: Text('Publish ${widget.title}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (records.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No records yet. Create the first one above.'),
              ),
            ),
          ...records.asMap().entries.map(
            (entry) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(child: Icon(widget.icon)),
                title: Text(entry.value.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${entry.value.description.isEmpty ? 'No description' : entry.value.description}\n${entry.value.date.isEmpty ? 'Date not set' : entry.value.date}',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => records.removeAt(entry.key)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunicationRecord {
  final String title;
  final String description;
  final String date;

  const _CommunicationRecord({required this.title, required this.description, required this.date});
}
