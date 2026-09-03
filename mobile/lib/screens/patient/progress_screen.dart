import 'package:flutter/material.dart';
import '../../core/services/exercise_progress_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';

class ProgressScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final int refreshToken;
  const ProgressScreen({super.key,this.onBack,this.refreshToken=0});
  @override State<ProgressScreen> createState()=>_ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String,dynamic> _data=const{}; bool _loading=true; String? _error;
  int _int(String key)=>int.tryParse(_data[key]?.toString()??'')??0;
  @override void initState(){super.initState();_load();}
  @override void didUpdateWidget(covariant ProgressScreen oldWidget){super.didUpdateWidget(oldWidget);if(oldWidget.refreshToken!=widget.refreshToken)_load();}
  Future<void> _load() async{try{final d=await ExerciseProgressService.loadDashboard();if(mounted)setState((){_data=d;_loading=false;_error=null;});}catch(e){if(mounted)setState((){_loading=false;_error=e.toString().replaceFirst('Exception: ','');});}}
  @override Widget build(BuildContext context){
    final weekly=(_data['weekly'] as List? ?? const[]).whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList();
    final recent=(_data['recent'] as List? ?? const[]).whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList();
    return Directionality(textDirection:TextDirection.rtl,child:Scaffold(body:PatientPage(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      if(_loading)const LinearProgressIndicator(minHeight:2),
      Row(children:[IconButton(onPressed:widget.onBack,icon:const Icon(Icons.arrow_forward_ios_rounded)),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('تقدّمي',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900)),Text('نتائج حقيقية من تمارينك المكتملة.',style:TextStyle(color:AppColors.textSecondary))])),IconButton(onPressed:_load,icon:const Icon(Icons.refresh_rounded))]),
      if(_error!=null)...[const SizedBox(height:15),NeuroCard(child:Column(children:[Text(_error!,textAlign:TextAlign.center),TextButton(onPressed:_load,child:const Text('إعادة المحاولة'))]))]else...[
        const SizedBox(height:22),
        Row(children:[Expanded(child:_ProgressStat(Icons.task_alt_rounded,'${_int('total_attempts')}','تمرين مكتمل')),const SizedBox(width:10),Expanded(child:_ProgressStat(Icons.local_fire_department_rounded,'${_int('streak')}','أيام استمرار'))]),
        const SizedBox(height:10),
        Row(children:[Expanded(child:_ProgressStat(Icons.timer_outlined,_time(_int('total_minutes')),'وقت التدريب')),const SizedBox(width:10),Expanded(child:_ProgressStat(Icons.insights_rounded,'${_int('average')}%','متوسط الأداء'))]),
        const SizedBox(height:25),const PatientSectionTitle(title:'نشاط آخر 7 أيام'),const SizedBox(height:12),
        NeuroCard(child:SizedBox(height:190,child:weekly.isEmpty?const Center(child:Text('أكمل تمرينًا ليظهر نشاطك هنا.')):Row(crossAxisAlignment:CrossAxisAlignment.end,children:List.generate(weekly.length,(i){final value=int.tryParse(weekly[i]['value']?.toString()??'')??0;final date=DateTime.tryParse(weekly[i]['date']?.toString()??'');const days=['ث','أ','ن','ث','خ','ج','س'];return Expanded(child:Padding(padding:const EdgeInsets.symmetric(horizontal:4),child:Column(mainAxisAlignment:MainAxisAlignment.end,children:[Text('$value%',style:const TextStyle(fontSize:9)),const SizedBox(height:4),Expanded(child:Align(alignment:Alignment.bottomCenter,child:AnimatedContainer(duration:const Duration(milliseconds:400),height:140*(value/100),decoration:BoxDecoration(color:AppColors.secondaryDark,borderRadius:BorderRadius.circular(8))))),const SizedBox(height:7),Text(date==null?'':days[date.weekday%7],style:const TextStyle(fontWeight:FontWeight.w800))])));})))),
        const SizedBox(height:25),const PatientSectionTitle(title:'آخر التمارين'),const SizedBox(height:12),
        if(recent.isEmpty)const NeuroCard(child:Center(child:Text('لا توجد نتائج محفوظة بعد.')))else ...recent.map((row){final score=int.tryParse(row['score']?.toString()??'')??0;final total=int.tryParse(row['total_questions']?.toString()??'')??0;final percent=total==0?0:(score*100/total).round();return Padding(padding:const EdgeInsets.only(bottom:9),child:NeuroCard(child:Row(children:[Container(width:45,height:45,decoration:BoxDecoration(color:const Color(0xFFF1E7D8),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.psychology_alt_rounded)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(row['title']?.toString()??'تمرين',style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(row['completed_at']?.toString()??'',style:const TextStyle(fontSize:10,color:AppColors.textSecondary))])),Text('$percent%',style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900,color:AppColors.primary))])));}),
      ]
    ]))));
  }
  static String _time(int minutes)=>minutes<60?'$minutes دقيقة':'${(minutes/60).toStringAsFixed(1)} ساعة';
}

class _ProgressStat extends StatelessWidget{final IconData icon;final String value;final String label;const _ProgressStat(this.icon,this.value,this.label);@override Widget build(BuildContext context)=>NeuroCard(child:Column(children:[Icon(icon,color:AppColors.primary),const SizedBox(height:7),FittedBox(child:Text(value,textDirection:TextDirection.ltr,style:const TextStyle(fontSize:21,fontWeight:FontWeight.w900))),const SizedBox(height:4),Text(label,style:const TextStyle(fontSize:11,color:AppColors.textSecondary))]));}
