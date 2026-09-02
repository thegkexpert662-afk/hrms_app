import 'package:flutter/material.dart';
import '../../app/hrms_app.dart';
import '../hrms/hrms_navigator.dart';

class AuthFlow extends StatefulWidget {
  final HrmsService service;
  const AuthFlow({super.key, required this.service});
  @override State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  int step = 0;
  String phone = '';
  String name = '';
  String email = '';
  String address = '';

  void next() => setState(() => step++);
  @override
  Widget build(BuildContext context) {
    if (step == 0) return _Splash(onDone: next);
    if (step == 1) return _Login(onNext: (v) { phone = v; next(); });
    if (step == 2) return _Otp(onNext: next);
    if (step == 3) return _Profile(onNext: (n, e) { name = n; email = e; next(); });
    if (step == 4) return _Address(onNext: (a) { address = a; next(); });
    return HrmsNavigator(service: widget.service);
  }
}

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: child))));
}

class _Splash extends StatefulWidget { final VoidCallback onDone; const _Splash({required this.onDone}); @override State<_Splash> createState()=>_SplashState(); }
class _SplashState extends State<_Splash> {
  @override void initState(){super.initState(); Future.delayed(const Duration(seconds:2), widget.onDone);}
  @override Widget build(BuildContext context)=>Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children:[Container(width:92,height:92,decoration:BoxDecoration(color:Theme.of(context).colorScheme.primary,borderRadius:BorderRadius.circular(24)),child:const Icon(Icons.business_center_rounded,color:Colors.white,size:48)),const SizedBox(height:20),const Text('HRMS Management System',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Smart Human Resource Management'),const SizedBox(height:32),const CircularProgressIndicator()]));
}

class _Login extends StatefulWidget { final ValueChanged<String> onNext; const _Login({required this.onNext}); @override State<_Login> createState()=>_LoginState(); }
class _LoginState extends State<_Login>{ final c=TextEditingController(); @override Widget build(BuildContext context)=>_Shell(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.lock_person_rounded,size:52),const SizedBox(height:18),const Text('Welcome back',style:TextStyle(fontSize:30,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Login with your mobile number'),const SizedBox(height:28),TextField(controller:c,keyboardType:TextInputType.phone,maxLength:10,decoration:const InputDecoration(labelText:'Mobile Number',prefixText:'+91 ',border:OutlineInputBorder(),counterText:'')),const SizedBox(height:18),SizedBox(width:double.infinity,height:52,child:FilledButton(onPressed:()=>c.text.length==10?widget.onNext(c.text):null,child:const Text('Send OTP')))])); }

class _Otp extends StatefulWidget { final VoidCallback onNext; const _Otp({required this.onNext}); @override State<_Otp> createState()=>_OtpState(); }
class _OtpState extends State<_Otp>{ final c=TextEditingController(); @override Widget build(BuildContext context)=>_Shell(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.verified_user_rounded,size:52),const SizedBox(height:18),const Text('OTP Verification',style:TextStyle(fontSize:30,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Enter the 6-digit OTP sent to your mobile'),const SizedBox(height:28),TextField(controller:c,keyboardType:TextInputType.number,maxLength:6,textAlign:TextAlign.center,style:const TextStyle(fontSize:24,letterSpacing:8),decoration:const InputDecoration(labelText:'OTP',border:OutlineInputBorder(),counterText:'')),const SizedBox(height:18),SizedBox(width:double.infinity,height:52,child:FilledButton(onPressed:()=>c.text.length==6?widget.onNext():null,child:const Text('Verify OTP'))),TextButton(onPressed:(){},child:const Text('Resend OTP'))])); }

class _Profile extends StatefulWidget { final void Function(String,String) onNext; const _Profile({required this.onNext}); @override State<_Profile> createState()=>_ProfileState(); }
class _ProfileState extends State<_Profile>{ final n=TextEditingController(); final e=TextEditingController(); @override Widget build(BuildContext context)=>_Shell(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.person_rounded,size:52),const SizedBox(height:18),const Text('Profile Setup',style:TextStyle(fontSize:30,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Complete your profile to continue'),const SizedBox(height:28),TextField(controller:n,decoration:const InputDecoration(labelText:'Full Name',border:OutlineInputBorder())),const SizedBox(height:16),TextField(controller:e,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Email (Optional)',border:OutlineInputBorder())),const SizedBox(height:22),SizedBox(width:double.infinity,height:52,child:FilledButton(onPressed:()=>n.text.trim().isNotEmpty?widget.onNext(n.text.trim(),e.text.trim()):null,child:const Text('Continue')))])); }

class _Address extends StatefulWidget { final ValueChanged<String> onNext; const _Address({required this.onNext}); @override State<_Address> createState()=>_AddressState(); }
class _AddressState extends State<_Address>{ final h=TextEditingController(); final a=TextEditingController(); final c=TextEditingController(); @override Widget build(BuildContext context)=>_Shell(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.location_on_rounded,size:52),const SizedBox(height:18),const Text('Address / Company Profile',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Add your basic address details'),const SizedBox(height:28),TextField(controller:h,decoration:const InputDecoration(labelText:'House / Flat / Building',border:OutlineInputBorder())),const SizedBox(height:16),TextField(controller:a,decoration:const InputDecoration(labelText:'Area / Locality',border:OutlineInputBorder())),const SizedBox(height:16),TextField(controller:c,decoration:const InputDecoration(labelText:'City / Company Location',border:OutlineInputBorder())),const SizedBox(height:22),SizedBox(width:double.infinity,height:52,child:FilledButton(onPressed:()=>h.text.trim().isNotEmpty&&a.text.trim().isNotEmpty&&c.text.trim().isNotEmpty?widget.onNext('${h.text}, ${a.text}, ${c.text}'):null,child:const Text('Finish Setup')))])); }
