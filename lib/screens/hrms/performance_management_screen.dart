import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class PerformanceManagementScreen extends StatefulWidget {
  final HrmsService service;
  const PerformanceManagementScreen({super.key,required this.service});
  @override State<PerformanceManagementScreen> createState()=>_PerformanceManagementScreenState();
}

class _PerformanceManagementScreenState extends State<PerformanceManagementScreen>{
  final Map<String,List<Map<String,String>>> records={'Goals':[],'KPI':[],'Self Assessment':[],'Manager Review':[],'Rating / Appraisal':[],'Promotion / Increment History':[]};

  Future<void> addRecord(String section)async{
    final employee=TextEditingController(),title=TextEditingController(),detail=TextEditingController();
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:Text('Add $section'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:employee,decoration:const InputDecoration(labelText:'Employee',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:title,decoration:const InputDecoration(labelText:'Title / Metric',border:OutlineInputBorder())),const SizedBox(height:10),TextField(controller:detail,maxLines:3,decoration:const InputDecoration(labelText:'Details / Comments',border:OutlineInputBorder()))])),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(c,title.text.trim().isNotEmpty),child:const Text('Save'))]));
    if(ok==true&&mounted)setState(()=>records[section]!.add({'employee':employee.text.trim(),'title':title.text.trim(),'detail':detail.text.trim()}));
    employee.dispose();title.dispose();detail.dispose();
  }

  @override Widget build(BuildContext context){
    final total=records.values.fold<int>(0,(a,b)=>a+b.length);
    return ListView(padding:const EdgeInsets.all(16),children:[
      Card(child:Padding(padding:const EdgeInsets.all(18),child:Row(children:[const Icon(Icons.insights,size:30),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Performance Management',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:4),Text('$total performance record(s)')]))]))),
      const SizedBox(height:12),_dashboard(),const SizedBox(height:12),...records.keys.map(_section),
    ]);
  }

  Widget _dashboard()=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Performance Dashboard',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),const SizedBox(height:14),Wrap(spacing:10,runSpacing:10,children:records.entries.map((e)=>SizedBox(width:145,child:Card(color:Theme.of(context).colorScheme.surfaceContainerHighest,child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${e.value.length}',style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900)),Text(e.key,maxLines:2,overflow:TextOverflow.ellipsis)]))))).toList())])));

  Widget _section(String section)=>Card(margin:const EdgeInsets.only(bottom:12),child:ExpansionTile(leading:Icon(_icon(section)),title:Text(section,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${records[section]!.length} record(s)'),children:[if(records[section]!.isEmpty)const ListTile(title:Text('No records yet.')),...List.generate(records[section]!.length,(i){final r=records[section]![i];return ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),title:Text(r['title']??''),subtitle:Text('${(r['employee']??'').isEmpty?'Employee not specified':r['employee']}\n${r['detail']??''}'),isThreeLine:true,trailing:IconButton(onPressed:()=>setState(()=>records[section]!.removeAt(i)),icon:const Icon(Icons.delete_outline)));}),Padding(padding:const EdgeInsets.all(12),child:Align(alignment:Alignment.centerRight,child:FilledButton.icon(onPressed:()=>addRecord(section),icon:const Icon(Icons.add),label:const Text('Add'))))]));
  IconData _icon(String s)=>switch(s){'Goals'=>Icons.flag,'KPI'=>Icons.track_changes,'Self Assessment'=>Icons.person_search,'Manager Review'=>Icons.supervisor_account,'Rating / Appraisal'=>Icons.star,_=>Icons.trending_up};
}
