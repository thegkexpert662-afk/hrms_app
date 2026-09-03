import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class AssetsScreen extends StatelessWidget {
  final HrmsService service;

  const AssetsScreen({super.key, required this.service});

  static const List<Map<String, dynamic>> items = [
    {
      'title': 'Asset List',
      'icon': Icons.inventory_2_outlined,
      'subtitle': 'View and manage company assets',
    },
    {
      'title': 'Add Asset',
      'icon': Icons.add_box_outlined,
      'subtitle': 'Register a new company asset',
    },
    {
      'title': 'Assign Asset',
      'icon': Icons.assignment_ind_outlined,
      'subtitle': 'Assign an asset to an employee',
    },
    {
      'title': 'Return Asset',
      'icon': Icons.assignment_return_outlined,
      'subtitle': 'Record an asset return',
    },
    {
      'title': 'Asset History',
      'icon': Icons.history,
      'subtitle': 'View asset assignment and return history',
    },
  ];

  void openScreen(BuildContext context, String title) {
    late final Widget screen;

    switch (title) {
      case 'Asset List':
        screen = AssetListScreen(service: service);
        break;
      case 'Add Asset':
        screen = AddAssetScreen(service: service);
        break;
      case 'Assign Asset':
        screen = AssignAssetScreen(service: service);
        break;
      case 'Return Asset':
        screen = ReturnAssetScreen(service: service);
        break;
      case 'Asset History':
        screen = AssetHistoryScreen(service: service);
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

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
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.devices),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Asset Management',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
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
              leading: CircleAvatar(
                child: Icon(item['icon'] as IconData),
              ),
              title: Text(
                item['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(item['subtitle'] as String),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openScreen(
                context,
                item['title'] as String,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AssetListScreen extends StatelessWidget {
  final HrmsService service;

  const AssetListScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return _AssetPage(
      title: 'Asset List',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _AssetCard(
            name: 'Company Laptop',
            type: 'Laptop',
            status: 'Available',
            employee: 'Unassigned',
          ),
          _AssetCard(
            name: 'Office Mobile',
            type: 'Mobile',
            status: 'Assigned',
            employee: 'Employee',
          ),
          _AssetCard(
            name: 'ID Card',
            type: 'ID Card',
            status: 'Assigned',
            employee: 'Employee',
          ),
        ],
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final String name;
  final String type;
  final String status;
  final String employee;

  const _AssetCard({
    required this.name,
    required this.type,
    required this.status,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.devices_other),
        ),
        title: Text(name),
        subtitle: Text('$type • $employee'),
        trailing: Chip(label: Text(status)),
      ),
    );
  }
}

class AddAssetScreen extends StatefulWidget {
  final HrmsService service;

  const AddAssetScreen({super.key, required this.service});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final serialController = TextEditingController();
  final valueController = TextEditingController();

  String type = 'Laptop';

  @override
  void dispose() {
    nameController.dispose();
    serialController.dispose();
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AssetPage(
      title: 'Add Asset',
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(
                labelText: 'Asset Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                'Laptop',
                'Desktop',
                'Mobile',
                'ID Card',
                'SIM',
                'Accessories',
              ]
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => type = value);
                }
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Asset Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter asset name';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: serialController,
              decoration: const InputDecoration(
                labelText: 'Serial / Asset ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Purchase Value',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Asset'),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignAssetScreen extends StatefulWidget {
  final HrmsService service;

  const AssignAssetScreen({super.key, required this.service});

  @override
  State<AssignAssetScreen> createState() => _AssignAssetScreenState();
}

class _AssignAssetScreenState extends State<AssignAssetScreen> {
  final employeeController = TextEditingController();
  String asset = 'Company Laptop';

  @override
  void dispose() {
    employeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AssetPage(
      title: 'Assign Asset',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: asset,
            decoration: const InputDecoration(
              labelText: 'Available Asset',
              border: OutlineInputBorder(),
            ),
            items: const [
              'Company Laptop',
              'Office Mobile',
              'ID Card',
              'SIM',
            ]
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => asset = value);
              }
            },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: employeeController,
            decoration: const InputDecoration(
              labelText: 'Employee Name / ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Assignment Notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.assignment_ind),
            label: const Text('Assign Asset'),
          ),
        ],
      ),
    );
  }
}

class ReturnAssetScreen extends StatefulWidget {
  final HrmsService service;

  const ReturnAssetScreen({super.key, required this.service});

  @override
  State<ReturnAssetScreen> createState() => _ReturnAssetScreenState();
}

class _ReturnAssetScreenState extends State<ReturnAssetScreen> {
  String condition = 'Good';

  @override
  Widget build(BuildContext context) {
    return _AssetPage(
      title: 'Return Asset',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Asset ID / Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Employee Name / ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: condition,
            decoration: const InputDecoration(
              labelText: 'Asset Condition',
              border: OutlineInputBorder(),
            ),
            items: const [
              'Good',
              'Needs Repair',
              'Damaged',
              'Lost',
            ]
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => condition = value);
              }
            },
          ),
          const SizedBox(height: 14),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Return Notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.assignment_return),
            label: const Text('Record Return'),
          ),
        ],
      ),
    );
  }
}

class AssetHistoryScreen extends StatelessWidget {
  final HrmsService service;

  const AssetHistoryScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return _AssetPage(
      title: 'Asset History',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HistoryTile(
            title: 'Company Laptop',
            action: 'Assigned to Employee',
            date: 'Today',
          ),
          _HistoryTile(
            title: 'Office Mobile',
            action: 'Returned by Employee',
            date: 'Yesterday',
          ),
          _HistoryTile(
            title: 'ID Card',
            action: 'Assigned to Employee',
            date: '01 Sep 2026',
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String title;
  final String action;
  final String date;

  const _HistoryTile({
    required this.title,
    required this.action,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.history),
        ),
        title: Text(title),
        subtitle: Text('$action\n$date'),
        isThreeLine: true,
      ),
    );
  }
}

class _AssetPage extends StatelessWidget {
  final String title;
  final Widget child;

  const _AssetPage({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child,
    );
  }
}
