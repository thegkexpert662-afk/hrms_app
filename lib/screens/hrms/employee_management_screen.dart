import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

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
      final matchesSearch = query.isEmpty || employee.values.any((value) => value.toString().toLowerCase().contains(query));
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEmployeeForm(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Employee'),
      ),
      body: AnimatedBuilder(
        animation: widget.service,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search employee...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.clear)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _stat('Total', _employees.length.toString(), Icons.people_alt_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _stat('Active', _employees.where((e) => e['status'] == 'Active').length.toString(), Icons.check_circle_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _stat('Leave', _employees.where((e) => e['status'] == 'On Leave').length.toString(), Icons.event_busy_rounded)),
            ]),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: ['All', 'Active', 'On Leave'].map((status) => ChoiceChip(label: Text(status), selected: _filter == status, onSelected: (_) => setState(() => _filter = status))).toList(),
            ),
            const SizedBox(height: 14),
            ..._visibleEmployees.map((employee) => _employeeCard(context, employee)),
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, String value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [Icon(icon, size: 24), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(title, style: const TextStyle(fontSize: 12))]),
    ),
  );

  Widget _employeeCard(BuildContext context, Map<String, dynamic> employee) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(child: Text(employee['name'].toString().substring(0, 1))),
      title: Text(employee['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${employee['role']} • ${employee['department']}\n${employee['id']} • ${employee['email']}'),
      isThreeLine: true,
      trailing: PopupMenuButton<String>(
        onSelected: (value) { if (value == 'edit') _showEmployeeForm(context, employee: employee); else _showProfile(context, employee); },
        itemBuilder: (_) => const [PopupMenuItem(value: 'profile', child: Text('View Profile')), PopupMenuItem(value: 'edit', child: Text('Edit'))],
      ),
    ),
  );

  void _showProfile(BuildContext context, Map<String, dynamic> employee) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(employee['name'].toString(), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text('Employee ID: ${employee['id']}'),
          Text('Role: ${employee['role']}'),
          Text('Department: ${employee['department']}'),
          Text('Status: ${employee['status']}'),
          Text('Email: ${employee['email']}'),
          Text('Phone: ${employee['phone']}'),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  void _showEmployeeForm(BuildContext context, {Map<String, dynamic>? employee}) {
    final name = TextEditingController(text: employee?['name']?.toString());
    final role = TextEditingController(text: employee?['role']?.toString());
    final department = TextEditingController(text: employee?['department']?.toString());
    final email = TextEditingController(text: employee?['email']?.toString());
    final phone = TextEditingController(text: employee?['phone']?.toString());
    String status = employee?['status']?.toString() ?? 'Active';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.viewInsetsOf(context).bottom + 16),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(employee == null ? 'Add Employee' : 'Edit Employee', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: role, decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: department, decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: const [DropdownMenuItem(value: 'Active', child: Text('Active')), DropdownMenuItem(value: 'On Leave', child: Text('On Leave'))],
                onChanged: (value) { if (value != null) setSheetState(() => status = value); },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  if (name.text.trim().isEmpty) return;
                  setState(() {
                    if (employee == null) {
                      _employees.add({'id': 'EMP${(_employees.length + 1).toString().padLeft(3, '0')}', 'name': name.text.trim(), 'role': role.text.trim(), 'department': department.text.trim(), 'status': status, 'email': email.text.trim(), 'phone': phone.text.trim()});
                    } else {
                      employee['name'] = name.text.trim(); employee['role'] = role.text.trim(); employee['department'] = department.text.trim(); employee['status'] = status; employee['email'] = email.text.trim(); employee['phone'] = phone.text.trim();
                    }
                  });
                  Navigator.pop(sheetContext);
                },
                icon: const Icon(Icons.save_rounded),
                label: Text(employee == null ? 'Save Employee' : 'Update Employee'),
              ),
            ]),
          ),
        ),
      ),
    ).whenComplete(() { name.dispose(); role.dispose(); department.dispose(); email.dispose(); phone.dispose(); });
  }
}
