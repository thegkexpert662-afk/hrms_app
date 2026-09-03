import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class EmployeeManagementScreen extends StatefulWidget {
  final HrmsService service;
  const EmployeeManagementScreen({super.key, required this.service});
  @override State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  String query = '';
  List<Employee> get filtered => widget.service.employees.where((e) {
    final q = query.toLowerCase();
    return q.isEmpty || e.name.toLowerCase().contains(q) || e.id.toLowerCase().contains(q) || e.department.toLowerCase().contains(q) || e.designation.toLowerCase().contains(q);
  }).toList();
  String date(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> addOrEdit({Employee? employee}) async {
    final e = await showModalBottomSheet<Employee>(context: context, isScrollControlled: true, builder: (_) => _EmployeeForm(employee: employee));
    if (!mounted || e == null) return;
    if (employee == null) widget.service.addEmployee(e); else widget.service.updateEmployee(e);
  }

  void profile(Employee e) {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => _EmployeeProfile(employee: e, date: date, onEdit: () { Navigator.pop(context); addOrEdit(employee: e); }, onDelete: () { Navigator.pop(context); widget.service.removeEmployee(e.id); }));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.service,
      builder: (_, __) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [Expanded(child: Text('Employee Management', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))), FilledButton.icon(onPressed: () => addOrEdit(), icon: const Icon(Icons.person_add), label: const Text('Add Employee'))]),
          const SizedBox(height: 14),
          TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search name, ID, department or designation', border: OutlineInputBorder())),
          const SizedBox(height: 14),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_stat('Total', widget.service.employees.length), _stat('Active', widget.service.employees.where((e) => e.status == 'Active').length), _stat('Inactive', widget.service.employees.where((e) => e.status != 'Active').length)]))),
          const SizedBox(height: 10),
          ...filtered.map(_employeeCard),
        ],
      ),
    );
  }

  Widget _employeeCard(Employee e) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(onTap: () => profile(e), leading: CircleAvatar(child: Text(e.name.isEmpty ? '?' : e.name[0].toUpperCase())), title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${e.id} • ${e.designation}\n${e.department} • ${e.phone}'), isThreeLine: true, trailing: PopupMenuButton<String>(onSelected: (v) { if (v == 'edit') addOrEdit(employee: e); if (v == 'delete') widget.service.removeEmployee(e.id); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))])));
  Widget _stat(String label, int value) => Column(children: [Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)), Text(label)]);
}

class _EmployeeForm extends StatefulWidget {
  final Employee? employee;
  const _EmployeeForm({this.employee});
  @override State<_EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<_EmployeeForm> {
  final form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> c;
  DateTime joining = DateTime.now();
  String employment = 'Full Time', status = 'Active';
  final fields = const ['name','phone','email','gender','dob','address','city','state','pinCode','department','designation','manager','emergencyName','emergencyRelation','emergencyPhone','bankName','accountNumber','ifsc','documentName','documentNumber','bloodGroup','skills','education','experience'];

  @override void initState() {
    super.initState();
    final e = widget.employee;
    c = {for (final f in fields) f: TextEditingController(text: _value(e, f))};
    joining = e?.joiningDate ?? DateTime.now();
    employment = e?.employmentType ?? 'Full Time';
    status = e?.status ?? 'Active';
  }

  String _value(Employee? e, String f) {
    if (e == null) return '';
    switch (f) {
      case 'name': return e.name; case 'phone': return e.phone; case 'email': return e.email; case 'gender': return e.gender; case 'dob': return e.dob; case 'address': return e.address; case 'city': return e.city; case 'state': return e.state; case 'pinCode': return e.pinCode; case 'department': return e.department; case 'designation': return e.designation; case 'manager': return e.manager; case 'emergencyName': return e.emergencyName; case 'emergencyRelation': return e.emergencyRelation; case 'emergencyPhone': return e.emergencyPhone; case 'bankName': return e.bankName; case 'accountNumber': return e.accountNumber; case 'ifsc': return e.ifsc; case 'documentName': return e.documentName; case 'documentNumber': return e.documentNumber; case 'bloodGroup': return e.bloodGroup; case 'skills': return e.skills; case 'education': return e.education; default: return e.experience;
    }
  }

  @override void dispose() { for (final x in c.values) x.dispose(); super.dispose(); }
  Widget field(String key, String label, {bool required = false, int lines = 1}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: c[key], maxLines: lines, validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())));
  Widget section(String title, List<Widget> children) => Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 14), ...children])));

  @override Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom), child: DraggableScrollableSheet(initialChildSize: .92, maxChildSize: .98, minChildSize: .7, expand: false, builder: (_, scroll) => Material(child: Form(key: form, child: ListView(controller: scroll, padding: const EdgeInsets.all(16), children: [
      Row(children: [Expanded(child: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]),
      section('Personal & Contact Details', [field('name','Full Name',required:true), field('phone','Mobile Number',required:true), field('email','Email'), field('gender','Gender'), field('dob','Date of Birth'), field('bloodGroup','Blood Group')]),
      section('Employment Details', [field('department','Department',required:true), field('designation','Designation',required:true), field('manager','Manager / Reporting'), DropdownButtonFormField<String>(initialValue: employment, decoration: const InputDecoration(labelText:'Employment Type',border:OutlineInputBorder()), items: const ['Full Time','Part Time','Contract','Intern'].map((x) => DropdownMenuItem(value:x,child:Text(x))).toList(), onChanged:(v){if(v!=null)setState(()=>employment=v);}), const SizedBox(height:12), DropdownButtonFormField<String>(initialValue: status, decoration: const InputDecoration(labelText:'Status',border:OutlineInputBorder()), items: const ['Active','Inactive','On Notice'].map((x) => DropdownMenuItem(value:x,child:Text(x))).toList(), onChanged:(v){if(v!=null)setState(()=>status=v);}), const SizedBox(height:12), ListTile(contentPadding:EdgeInsets.zero,title:const Text('Joining Date'),subtitle:Text('${joining.day}/${joining.month}/${joining.year}'),trailing:IconButton(icon:const Icon(Icons.calendar_month),onPressed:()async{final d=await showDatePicker(context:context,firstDate:DateTime(2000),lastDate:DateTime(2100),initialDate:joining);if(d!=null)setState(()=>joining=d);})]),
      section('Address', [field('address','House / Street / Address',lines:2), field('city','City'), field('state','State'), field('pinCode','PIN Code')]),
      section('Emergency Contact', [field('emergencyName','Contact Name'), field('emergencyRelation','Relationship'), field('emergencyPhone','Emergency Phone')]),
      section('Bank Details', [field('bankName','Bank Name'), field('accountNumber','Account Number'), field('ifsc','IFSC Code')]),
      section('Documents', [field('documentName','Document Name'), field('documentNumber','Document Number')]),
      section('Skills / Education / Experience', [field('skills','Skills',lines:2), field('education','Education',lines:2), field('experience','Experience',lines:2)]),
      const SizedBox(height:6),
      SizedBox(height:52, child: FilledButton.icon(onPressed: () { if (!form.currentState!.validate()) return; final old=widget.employee; final e=Employee(id:old?.id??'EMP${DateTime.now().millisecondsSinceEpoch}',name:c['name']!.text.trim(),department:c['department']!.text.trim(),designation:c['designation']!.text.trim(),manager:c['manager']!.text.trim(),joiningDate:joining,employmentType:employment,status:status,phone:c['phone']!.text.trim(),email:c['email']!.text.trim(),gender:c['gender']!.text.trim(),dob:c['dob']!.text.trim(),address:c['address']!.text.trim(),city:c['city']!.text.trim(),state:c['state']!.text.trim(),pinCode:c['pinCode']!.text.trim(),emergencyName:c['emergencyName']!.text.trim(),emergencyRelation:c['emergencyRelation']!.text.trim(),emergencyPhone:c['emergencyPhone']!.text.trim(),bankName:c['bankName']!.text.trim(),accountNumber:c['accountNumber']!.text.trim(),ifsc:c['ifsc']!.text.trim(),documentName:c['documentName']!.text.trim(),documentNumber:c['documentNumber']!.text.trim(),bloodGroup:c['bloodGroup']!.text.trim(),skills:c['skills']!.text.trim(),education:c['education']!.text.trim(),experience:c['experience']!.text.trim()); Navigator.pop(context,e); }, icon: const Icon(Icons.save), label: Text(widget.employee==null?'Add Employee':'Save Changes'))),
    ]))));
  }
}

class _EmployeeProfile extends StatelessWidget {
  final Employee employee; final String Function(DateTime) date; final VoidCallback onEdit, onDelete;
  const _EmployeeProfile({required this.employee, required this.date, required this.onEdit, required this.onDelete});
  Widget row(String a,String b)=>ListTile(title:Text(a,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w600)),subtitle:Text(b.isEmpty?'Not provided':b,style:const TextStyle(fontSize:16)));
  Widget group(String title,List<Widget> rows)=>Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800)),...rows])));
  @override Widget build(BuildContext context)=>DraggableScrollableSheet(initialChildSize:.9,maxChildSize:.98,expand:false,builder:(_,scroll)=>Material(child:ListView(controller:scroll,padding:const EdgeInsets.all(16),children:[Row(children:[CircleAvatar(radius:30,child:Text(employee.name.isEmpty?'?':employee.name[0].toUpperCase())),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(employee.name,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800)),Text('${employee.id} • ${employee.designation}')]))]),const SizedBox(height:12),Row(children:[Expanded(child:FilledButton.icon(onPressed:onEdit,icon:const Icon(Icons.edit),label:const Text('Edit'))),const SizedBox(width:10),OutlinedButton.icon(onPressed:onDelete,icon:const Icon(Icons.delete_outline),label:const Text('Delete'))]),group('Personal & Contact Details',[row('Mobile',employee.phone),row('Email',employee.email),row('Gender',employee.gender),row('Date of Birth',employee.dob),row('Blood Group',employee.bloodGroup)]),group('Employment Details',[row('Department',employee.department),row('Designation',employee.designation),row('Manager',employee.manager),row('Joining Date',date(employee.joiningDate)),row('Employment Type',employee.employmentType),row('Status',employee.status)]),group('Address',[row('Address',employee.address),row('City',employee.city),row('State',employee.state),row('PIN Code',employee.pinCode)]),group('Emergency Contact',[row('Name',employee.emergencyName),row('Relationship',employee.emergencyRelation),row('Phone',employee.emergencyPhone)]),group('Bank Details',[row('Bank',employee.bankName),row('Account Number',employee.accountNumber),row('IFSC',employee.ifsc)]),group('Documents',[row('Document',employee.documentName),row('Document Number',employee.documentNumber)]),group('Skills / Education / Experience',[row('Skills',employee.skills),row('Education',employee.education),row('Experience',employee.experience)])]))));
}
