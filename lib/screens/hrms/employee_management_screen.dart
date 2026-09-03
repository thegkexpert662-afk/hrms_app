import 'package:flutter/material.dart';
import '../../services/hrms_service.dart';

class EmployeeManagementScreen extends StatefulWidget {
  final HrmsService service;
  const EmployeeManagementScreen({super.key, required this.service});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final _search = TextEditingController();
  String _filter = 'All';
  final List<Map<String, dynamic>> _employees = [
    {'id': 'EMP001', 'name': 'Rahul Sharma', 'role': 'Manager', 'department': 'HR', 'status': 'Active', 'email': 'rahul@example.com', 'phone': '9876543210'},
    {'id': 'EMP002', 'name': 'Priya Singh', 'role': 'Executive', 'department': 'Finance', 'status': 'Active', 'email': 'priya@example.com', 'phone': '9876543211'},
    {'id': 'EMP003', 'name': 'Amit Kumar', 'role': 'Developer', 'department': 'IT', 'status': 'On Leave', 'email': 'amit@example.com', 'phone': '9876543212'},
  ];

  List<Map<String, dynamic>> get _visibleEmployees {
    final query = _search.text.trim().toLowerCase();
    return _employees.where((employee) {
      final matchesFilter = _filter == 'All' || employee['status'] == _filter;
      final matchesSearch = query.isEmpty ||
          employee.values.any((value) => value.toString().toLowerCase().contains(query));
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openEmployeeForm([Map<String, dynamic>? employee]) {
    final name = TextEditingController(text: employee?['name'] ?? '');
    final role = TextEditingController(text: employee?['role'] ?? '');
    final department = TextEditingController(text: employee?['department'] ?? '');
    final email = TextEditingController(text: employee?['email'] ?? '');
    final phone = TextEditingController(text: employee?['phone'] ?? '');
    String status = employee?['status'] ?? 'Active';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(employee == null ? 'Add Employee' : 'Edit Employee', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Full Name')),
                TextField(controller: role, decoration: const InputDecoration(labelText: 'Role')),
                TextField(controller: department, decoration: const InputDecoration(labelText: 'Department')),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'On Leave', child: Text('On Leave')),
                    DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    if (value != null) setSheetState(() => status = value);
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    final data = <String, dynamic>{
                      'name': name.text.trim(),
                      'role': role.text.trim(),
                      'department': department.text.trim(),
                      'email': email.text.trim(),
                      'phone': phone.text.trim(),
                      'status': status,
                    };
                    setState(() {
                      if (employee == null) {
                        data['id'] = 'EMP${(_employees.length + 1).toString().padLeft(3, '0')}';
                        _employees.add(data);
                      } else {
                        employee.addAll(data);
                      }
                    });
                    Navigator.of(sheetContext).pop();
                  },
                  child: Text(employee == null ? 'Add Employee' : 'Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      name.dispose();
      role.dispose();
      department.dispose();
      email.dispose();
      phone.dispose();
    });
  }

  void _showProfile(Map<String, dynamic> employee) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee['name'].toString()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee ID: ${employee['id']}'),
            Text('Role: ${employee['role']}'),
            Text('Department: ${employee['department']}'),
            Text('Email: ${employee['email']}'),
            Text('Phone: ${employee['phone']}'),
            Text('Status: ${employee['status']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          FilledButton(onPressed: () { Navigator.pop(context); _openEmployeeForm(employee); }, child: const Text('Edit')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleEmployees;
    final activeCount = _employees.where((e) => e['status'] == 'Active').length;
    final leaveCount = _employees.where((e) => e['status'] == 'On Leave').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
          IconButton(onPressed: () => _openEmployeeForm(), icon: const Icon(Icons.person_add_alt_1)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search employees',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.clear)),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['All', 'Active', 'On Leave', 'Inactive'].map((filter) => ChoiceChip(
                label: Text(filter),
                selected: _filter == filter,
                onSelected: (_) => setState(() => _filter = filter),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _statCard('Total', _employees.length.toString(), Icons.groups)),
                const SizedBox(width: 8),
                Expanded(child: _statCard('Active', activeCount.toString(), Icons.check_circle_outline)),
                const SizedBox(width: 8),
                Expanded(child: _statCard('Leave', leaveCount.toString(), Icons.event_busy)),
              ],
            ),
            const SizedBox(height: 16),
            if (visible.isEmpty)
              const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No employees found.')))
            else
              ...visible.map((employee) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(employee['name'].toString().substring(0, 1).toUpperCase())),
                  title: Text(employee['name'].toString()),
                  subtitle: Text('${employee['role']} • ${employee['department']}\n${employee['id']}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'view') _showProfile(employee);
                      if (value == 'edit') _openEmployeeForm(employee);
                      if (value == 'delete') setState(() => _employees.remove(employee));
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'view', child: Text('View Profile')),
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEmployeeForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Employee'),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label),
          ],
        ),
      ),
    );
  }
}
