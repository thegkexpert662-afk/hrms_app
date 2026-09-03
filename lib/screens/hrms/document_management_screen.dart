import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';

class DocumentManagementScreen extends StatefulWidget {
  final HrmsService service;
  const DocumentManagementScreen({super.key, required this.service});
  @override State<DocumentManagementScreen> createState() => _DocumentManagementScreenState();
}

class _DocumentManagementScreenState extends State<DocumentManagementScreen> {
  final List<Map<String,dynamic>> docs=[];

  Future<void> _upload() async {
    final employee=TextEditingController(); final name=TextEditingController(); final expiry=TextEditingController();
    String category='Employee Document';
    final ok=await showDialog<bool>(context:context,builder:(c)=>StatefulBuilder(builder:(c,setDialog)=>AlertDialog(
      title:const Text('Upload Document'),
      content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        DropdownButtonFormField<String>(initialValue:category,decoration:const InputDecoration(labelText:'Document Type',border:OutlineInputBorder()),items:const [DropdownMenuItem(value:'Employee Document',child:Text('Employee Document')),DropdownMenuItem(value:'Company Document',child:Text('Company Document'))],onChanged:(v){if(v!=null)setDialog(()=>category=v);}),
        const SizedBox(height:10),TextField(controller:employee,decoration:const InputDecoration(labelText:'Employee / Owner',border:OutlineInputBorder())),
        const SizedBox(height:10),TextField(controller:name,decoration:const InputDecoration(labelText:'Document Name',border:OutlineInputBorder())),
        const SizedBox(height:10),TextField(controller:expiry,decoration:const InputDecoration(labelText:'Expiry Date (optional)',border:OutlineInputBorder())),
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(c,name.text.trim().isNotEmpty),child:const Text('Upload'))],
    )));
    if(ok==true&&mounted)setState(()=>docs.add({'type':category,'owner':employee.text.trim(),'name':name.text.trim(),'expiry':expiry.text.trim(),'verified':false}));
    employee.dispose();name.dispose();expiry.dispose();
  }

  @override Widget build(BuildContext context){
    final employeeDocs=docs.where((d)=>d['type']=='Employee Document').length;
    final companyDocs=docs.where((d)=>d['type']=='Company Document').length;
    final pending=docs.where((d)=>d['verified']!=true).length;
    final expiry=docs.where((d)=>(d['expiry'] as String).isNotEmpty).length;
    return ListView(padding:const EdgeInsets.all(16),children:[
      Card(child:Padding(padding:const EdgeInsets.all(18),child:Row(children:[const Icon(Icons.folder_special,size:30),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Document Management',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.w800)),Text('${docs.length} document(s)')]))]))),
      const SizedBox(height:12),Wrap(spacing:10,runSpacing:10,children:[_stat('Employee Documents',employeeDocs,Icons.badge),_stat('Company Documents',companyDocs,Icons.business),_stat('Pending Verification',pending,Icons.verified_user_outlined),_stat('Expiry Alerts',expiry,Icons.warning_amber)]),
      const SizedBox(height:12),Card(child:ListTile(leading:const Icon(Icons.upload_file),title:const Text('Upload Document',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:const Text('Add employee or company documents'),trailing:FilledButton.icon(onPressed:_upload,icon:const Icon(Icons.add),label:const Text('Upload')))),
      Card(child:ExpansionTile(leading:const Icon(Icons.badge),title:const Text('Employee Documents',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('$employeeDocs document(s)'),children:_list('Employee Document'))),
      Card(child:ExpansionTile(leading:const Icon(Icons.business),title:const Text('Company Documents',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('$companyDocs document(s)'),children:_list('Company Document'))),
      Card(child:ExpansionTile(leading:const Icon(Icons.verified),title:const Text('Document Verification',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('$pending pending'),children:_verification())),
      Card(child:ExpansionTile(leading:const Icon(Icons.notifications_active),title:const Text('Expiry Alerts',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('$expiry document(s) with expiry date'),children:_expiryList())),
    ]);
  }

  Widget _stat(String title,int value,IconData icon)=>SizedBox(width:165,child:Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon),const SizedBox(height:8),Text('$value',style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900)),Text(title,maxLines:2,overflow:TextOverflow.ellipsis)]))));
  List<Widget> _list(String type){final list=docs.asMap().entries.where((e)=>e.value['type']==type).toList();if(list.isEmpty)return[const ListTile(title:Text('No documents yet.'))];return list.map((e)=>_tile(e.key,e.value)).toList();}
  List<Widget> _verification(){if(docs.isEmpty)return[const ListTile(title:Text('No documents uploaded.'))];return docs.asMap().entries.map((e)=>ListTile(leading:Icon(e.value['verified']==true?Icons.verified:Icons.pending),title:Text(e.value['name']),subtitle:Text(e.value['owner'].toString().isEmpty?e.value['type'].toString():'${e.value['type']} • ${e.value['owner']}'),trailing:e.value['verified']==true?const Text('Verified'):TextButton(onPressed:()=>setState(()=>docs[e.key]['verified']=true),child:const Text('Verify')))).toList();}
  List<Widget> _expiryList(){final list=docs.asMap().entries.where((e)=>(e.value['expiry'] as String).isNotEmpty).toList();if(list.isEmpty)return[const ListTile(title:Text('No expiry dates added.'))];return list.map((e)=>_tile(e.key,e.value,showDelete:false)).toList();}
  Widget _tile(int i,Map<String,dynamic>d,{bool showDelete=true})=>ListTile(leading:const Icon(Icons.description),title:Text(d['name'].toString()),subtitle:Text('${d['owner'].toString().isEmpty?'Company':d['owner']} • ${d['expiry'].toString().isEmpty?'No expiry date':'Expires: ${d['expiry']}'}'),trailing:showDelete?IconButton(onPressed:()=>setState(()=>docs.removeAt(i)),icon:const Icon(Icons.delete_outline)):const Icon(Icons.warning_amber));
}
