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
  String phone = '', name = '', email = '', address = '';
  void next() => setState(() => step++);
  @override Widget build(BuildContext context) {
    switch (step) {
      case 0: return _Splash(onDone: next);
      case 1: return _Login(onNext: (v){phone=v;next();});
      case 2: return _Otp(phone: phone, onNext: next);
      case 3: return _Profile(onNext: (n,e){name=n;email=e;next();});
      case 4: return _CompanyProfile(onNext: (v){address=v;next();});
      default: return HrmsNavigator(service: widget.service);
    }
  }
}

class _Shell extends StatelessWidget {
  final Widget child; const _Shell({required this.child});
  @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:480),child:child)))));
}

class _Splash extends StatefulWidget { final VoidCallback onDone; const _Splash({required this.onDone}); @override State<_Splash> createState()=>_SplashState(); }
class _SplashState extends State<_Splash>{
  @override void initState(){super.initState();Future.delayed(const Duration(seconds:2),(){if(mounted)widget.onDone();});}
  @override Widget build(BuildContext c)=>Scaffold(body:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Container(width:96,height:96,decoration:BoxDecoration(color:Theme.of(c).colorScheme.primary,borderRadius:BorderRadius.circular(28)),child:const Icon(Icons.business_center_rounded,color:Colors.white,size:50)),const SizedBox(height:22),const Text('HRMS Management System',style:TextStyle(fontSize:25,fontWeight:FontWeight.w800)),const SizedBox(height:8),const Text('Smart Human Resource Management'),const SizedBox(height:32),const CircularProgressIndicator()]));
}

class _Login extends StatefulWidget { final ValueChanged<String> onNext; const _Login({required this.onNext}); @override State<_Login> createState()=>_LoginState(); }
class _LoginState extends State<_Login>{ final c=TextEditingController(); String? error;
  @override Widget build(BuildContext context)=>_Shell(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.phone_android_rounded,size:52),const SizedBox(height:18),const Text('Welcome back',style:TextStyle(fontSize:31,fontWeight:FontWeight.w800)),const SizedBox(height:8),const Text('Enter your registered mobile number'),const SizedBox(height:28),TextField(controller:c,keyboardType:TextInputType.phone,maxLength:10,decoration:InputDecoration(labelText:'Mobile Number',prefixText:'+91 ',border:const OutlineInputBorder(),counterText:'',errorText:error)),const SizedBox(height:20),SizedBox(width:double.infinity,height:54,child:FilledButton(onPressed:(){if(RegExp(r'^\d{10}$').hasMatch(c.text.trim())){error=null;widget.onNext(c.text.trim());}else setState(()=>error='Enter a valid 10-digit number');},child:const Text('Send OTP')))]));
}

class _Otp extends StatefulWidget { final String phone; final VoidCallback onNext; const _Otp({required this.phone,required this.onNext}); @override State<_Otp> createState()=>_OtpState(); }
class _OtpState extends State<_Otp>{ final c=TextEditingController(); String? error; int seconds=30;
  @override void initState(){super.initState();Future.doWhile(()async{await Future.delayed(const Duration(seconds:1));if(!mounted||seconds==0)return false;setState(()=>seconds--);return true;});}
  @override Widget build(BuildContext context)=>_Shell(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.verified_user_rounded,size:52),const SizedBox(height:18),const Text('OTP Verification',style:TextStyle(fontSize:30,fontWeight:FontWeight.w800)),const SizedBox(height:8),Text('Enter the 6-digit OTP sent to +91 ${widget.phone}'),const SizedBox(height:28),TextField(controller:c,keyboardType:TextInputType.number,maxLength:6,textAlign:TextAlign.center,style:const TextStyle(fontSize:25,letterSpacing:8),decoration:InputDecoration(labelText:'OTP',border:const OutlineInputBorder(),counterText:'',errorText:error)),const SizedBox(height:20),SizedBox(width:double.infinity,height:54,child:FilledButton(onPressed:(){if(RegExp(r'^\d{6}$').hasMatch(c.text.trim())){error=null;widget.onNext();}else setState(()=>error='Enter the 6-digit OTP');},child:const Text('Verify OTP'))),const SizedBox(height:8),Center(child:TextButton(onPressed:seconds==0?(){setState(()=>seconds=30);}:null,child:Text(seconds==0?'Resend OTP':'Resend in ${seconds}s')))]));
}

class _Profile extends StatefulWidget { final void Function(String,String) onNext; const _Profile({required this.onNext}); @override State<_Profile> createState()=>_ProfileState(); }
class _ProfileState extends State<_Profile>{ final n=TextEditingController(),e=TextEditingController();
  @override Widget build(BuildContext c)=>_Shell(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.person_rounded,size:52),const SizedBox(height:18),const Text('Profile Setup',style:TextStyle(fontSize:30,fontWeight:FontWeight.w800)),const SizedBox(height:8),const Text('Create your HRMS profile'),const SizedBox(height:28),TextField(controller:n,decoration:const InputDecoration(labelText:'Full Name *',border:OutlineInputBorder())),const SizedBox(height:16),TextField(controller:e,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Email',border:OutlineInputBorder())),const SizedBox(height:24),SizedBox(width:double.infinity,height:54,child:FilledButton(onPressed:()=>n.text.trim().isEmpty?null:widget.onNext(n.text.trim(),e.text.trim()),child:const Text('Continue')))]));
}

class _CompanyProfile extends StatefulWidget { final ValueChanged<String> onNext; const _CompanyProfile({required this.onNext}); @override State<_CompanyProfile> createState()=>_CompanyProfileState(); }
class _CompanyProfileState extends State<_CompanyProfile>{ final company=TextEditingController(),address=TextEditingController(),city=TextEditingController(),pin=TextEditingController();
  @override Widget build(BuildContext c)=>_Shell(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.business_rounded,size:52),const SizedBox(height:18),const Text('Address / Company Profile',style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),const SizedBox(height:8),const Text('Complete company information'),const SizedBox(height:28),TextField(controller:company,decoration:const InputDecoration(labelText:'Company Name *',border:OutlineInputBorder())),const SizedBox(height:16),TextField(controller:address,decoration:const InputDecoration(labelText:'Office Address *',border:OutlineInputBorder()),maxLines:2),const SizedBox(height:16),TextField(controller:city,decoration:const InputDecoration(labelText:'City *',border:OutlineInputBorder())),const SizedBox(height:16),TextField(controller:pin,keyboardType:TextInputType.number,maxLength:6,decoration:const InputDecoration(labelText:'PIN Code',border:OutlineInputBorder(),counterText:'')),const SizedBox(height:22),SizedBox(width:double.infinity,height:54,child:FilledButton(onPressed:()=>company.text.trim().isEmpty||address.text.trim().isEmpty||city.text.trim().isEmpty?null:widget.onNext('${company.text.trim()} | ${address.text.trim()} | ${city.text.trim()} ${pin.text.trim()}'),child:const Text('Finish Setup')))]));
}
