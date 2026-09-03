import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class RecruitmentManagementScreen extends StatefulWidget {
  final HrmsService service;
  const RecruitmentManagementScreen({super.key,required this.service});
  @override State<RecruitmentManagementScreen> createState()=>_RecruitmentManagementScreenState();
}

class _RecruitmentManagementScreenState extends State<RecruitmentManagementScreen>{
  final Map<String,List<Map<String,String>>> records={'Job Openings':[],'Applications':[],'Candidate Profile':[],'Resume':[],'Interview & Feedback':[],'Shortlist / Selection / Rejection':[]};

  Future<void> _add(String section)async{
    final candidate=TextEditingController(),title=TextEditingController(),details=TextEditingController();
    String status='Pending';
    const statuses=['Pending','Shortlisted','Selected','Rejected'];
    final ok=await showDialog<bool>(context:context,builder:(c)=>StatefulBuilder(builder:(c,sd)=>AlertDialog(title:Text('Add $section'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:candidate,decoration:const InputDecoration(labelText:'Candidate / Owner',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:title,decoration:const InputDecoration(labelText:'Job / Role / Interview',border:OutlineInputBorder())),const SizedBox(height:10),DropdownButtonFormField<String>(initialValue:status,decoration:const InputDecoration(labelText:'Status',border:OutlineInputBorder()),items:statuses.map((s)=>DropdownMenuItem(value:s,child:Text(s))).toList(),onChanged:(v){if(v!=null)sd(()=>status=v);}),const SizedBox(height:10),TextField(controller:details,maxLines:3,decoration:const InputDecoration(labelText:'Details / Feedback / Resume info',border:OutlineInputBorder()))])),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(c,title.text.trim().isNotEmpty),child:const Text('Save'))])));
    if(ok==true&&mounted)setState(()=>records[section]!.add({'candidate':candidate.text.trim(),'title':title.text.trim(),'status':status,'details':details.text.trim()}));
    candidate.dispose();title.dispose();details.dispose();
  }

  @override Widget build(BuildContext context){
    final applications=records['Applications']!.length;
    final shortlisted=records['Shortlist / Selection / Rejection']!.where((r)=>r['status']=='Shortlisted').length;
    final selected=records['Shortlist / Selection / Rejection']!.where((r)=>r['status']=='Selected').length;
    return ListView(padding:const EdgeInsets.all(16),children:[
      Card(child:Padding(padding:const EdgeInsets.all(18),child:Row(children:[const Icon(Icons.work_outline,size:30),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Recruitment Management',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),Text('${records.values.fold<int>(0,(a,b)=>a+b.length)} recruitment record(s)')]))]))),
      const SizedBox(height:12),Wrap(spacing:10,runSpacing:10,children:[_stat('Job Openings',records['Job Openings']!.length,Icons.work),_stat('Applications',applications,Icons.assignment),_stat('Shortlisted',shortlisted,Icons.filter_alt),_stat('Selected',selected,Icons.check_circle)]),
      const SizedBox(height:12),...records.keys.map(_section),
    ]);
  }

  Widget _stat(String title,int value,IconData icon)=>SizedBox(width:155,child:Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon),const SizedBox(height:8),Text('$value',style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900)),Text(title)]))));
  Widget _section(String section)=>Card(margin:const EdgeInsets.only(bottom:12),child:ExpansionTile(leading:Icon(_icon(section)),title:Text(section,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${records[section]!.length} record(s)'),children:[if(records[section]!.isEmpty)const ListTile(title:Text('No records yet.')),...List.generate(records[section]!.length,(i){final r=records[section]![i];return ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),title:Text(r['title']??''),subtitle:Text('${(r['candidate']??'').isEmpty?'Candidate not specified':r['candidate']} • ${r['status']??''}\n${r['details']??''}'),isThreeLine:true,trailing:IconButton(onPressed:()=>setState(()=>records[section]!.removeAt(i)),icon:const Icon(Icons.delete_outline)));}),Padding(padding:const EdgeInsets.all(12),child:Align(alignment:Alignment.centerRight,child:FilledButton.icon(onPressed:()=>_add(section),icon:const Icon(Icons.add),label:const Text('Add'))))]));
  IconData _icon(String s)=>switch(s){'Job Openings'=>Icons.work,'Applications'=>Icons.assignment,'Candidate Profile'=>Icons.person,'Resume'=>Icons.description,'Interview & Feedback'=>Icons.forum,_=>Icons.fact_check};
}
