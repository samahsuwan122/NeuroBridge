import 'package:flutter/material.dart';

import '../../core/services/exercise_progress_service.dart';
import '../../core/services/patient_features_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import '../help_center_screen.dart';
import 'achievements_screen.dart';
import 'daily_check_in_screen.dart';
import 'encouragement_screen.dart';
import 'exercises_screen.dart';
import 'memory_tree_screen.dart';
import 'patient_family_screen.dart';
import 'today_plan_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  final int userId;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final int refreshToken;

  const PatientHomeScreen({
    super.key,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.refreshToken = 0,
  });

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  Map<String, dynamic> _data = const {};
  bool _loading = true;
  Map<String, dynamic>? _latestEncouragement;

  String get _firstName {
    final name = widget.fullName.trim();
    return name.isEmpty ? 'بك' : name.split(RegExp(r'\s+')).first;
  }

  int _int(String key) => int.tryParse(_data[key]?.toString() ?? '') ?? 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PatientHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait<dynamic>([ExerciseProgressService.loadDashboard(),PatientFeaturesService.loadEncouragements()]);
      final messages=results[1] as List<Map<String,dynamic>>;
      if (mounted) setState(() { _data = Map<String,dynamic>.from(results[0] as Map);_latestEncouragement=messages.isEmpty?null:messages.first; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openTodayPlan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TodayPlanScreen()),
    );
    if (mounted) await _load();
  }

  Future<void> _openExercises() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExercisesScreen()),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _int('today_progress');
    final remaining = _int('remaining');
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PatientPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('صباح الخير، $_firstName 🌷',
                    style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                const Text('خطوة بسيطة اليوم تصنع فرقًا جميلًا.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ])),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
              IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HelpCenterScreen())),
                icon: const Icon(Icons.help_outline_rounded),
              ),
            ]),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors:[Color(0xFFE9D9C4),Color(0xFFFAF5EC)]),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(color: const Color(0xFFD8C5A9)),
              ),
              child: Column(children: [
                Row(children: [
                  Container(width:52,height:52,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),
                      child:const Icon(Icons.psychology_alt_rounded,color:AppColors.primary)),
                  const SizedBox(width:12),
                  const Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                    Text('جلسة اليوم',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),
                    Text('الذاكرة والتركيز',style:TextStyle(color:AppColors.textSecondary)),
                  ])),
                  Container(width:62,height:62,alignment:Alignment.center,decoration:BoxDecoration(color:Colors.white,shape:BoxShape.circle,border:Border.all(color:AppColors.secondary,width:2)),
                      child:Text('$progress%',textDirection:TextDirection.ltr,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900))),
                ]),
                const SizedBox(height:16),
                ClipRRect(borderRadius:BorderRadius.circular(20),child:LinearProgressIndicator(value:progress/100,minHeight:9,backgroundColor:const Color(0xFFDECDB7),color:AppColors.secondaryDark)),
                const SizedBox(height:11),
                Row(children:[
                  const Icon(Icons.task_alt_rounded,size:16),const SizedBox(width:5),
                  Expanded(child:Text(remaining == 0 ? 'أكملت هدف اليوم ✓' : '$remaining تمارين متبقية',style:const TextStyle(fontSize:12))),
                  const Icon(Icons.schedule_rounded,size:16),const SizedBox(width:4),
                  Text('${_int('today_minutes')} دقيقة اليوم',style:const TextStyle(fontSize:12)),
                ]),
                const SizedBox(height:16),
                SizedBox(width:double.infinity,height:52,child:FilledButton.icon(
                  onPressed:_openTodayPlan,
                  icon:const Icon(Icons.play_arrow_rounded),label:Text(remaining == 0 ? 'عرض خطة اليوم' : 'متابعة جلسة اليوم'),
                  style:FilledButton.styleFrom(backgroundColor:AppColors.primary),
                )),
              ]),
            ),
            const SizedBox(height:22),
            Row(children:[
              Expanded(child:_Stat(Icons.local_fire_department_rounded,'${_int('streak')}','أيام استمرار',const Color(0xFFC98269))),
              const SizedBox(width:10),
              Expanded(child:_Stat(Icons.task_alt_rounded,'${_int('today_attempts')} / ${_int('today_goal')}','تمارين اليوم',const Color(0xFF71947A))),
              const SizedBox(width:10),
              Expanded(child:_Stat(Icons.insights_rounded,'${_int('today_average')}%','أداء اليوم',const Color(0xFF7895A4))),
            ]),
            const SizedBox(height:25),
            if (_latestEncouragement != null) ...[
              NeuroCard(
                onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const EncouragementScreen())),
                color:const Color(0xFFFFF7EC),
                child:Row(children:[
                  Container(width:48,height:48,decoration:BoxDecoration(color:const Color(0xFFF3DFCB),borderRadius:BorderRadius.circular(15)),child:const Icon(Icons.favorite_rounded,color:Color(0xFFB46F5B))),
                  const SizedBox(width:12),
                  Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                    Text('رسالة تشجيع من ${_latestEncouragement!['sender_name']??'العائلة'}',style:const TextStyle(fontWeight:FontWeight.w900)),
                    const SizedBox(height:4),
                    Text((_latestEncouragement!['message']?.toString().trim().isNotEmpty??false)?_latestEncouragement!['message'].toString():'وصلتك رسالة تحتوي على صورة أو تسجيل',maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(color:AppColors.textSecondary,height:1.5)),
                  ])),
                  const Icon(Icons.arrow_back_ios_new_rounded,size:14),
                ]),
              ),
              const SizedBox(height:18),
            ],
            const PatientSectionTitle(title:'وصول سريع'),
            const SizedBox(height:12),
            GridView.count(
              shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,
              mainAxisSpacing:11,crossAxisSpacing:11,childAspectRatio:1.35,
              children:[
                _Action(Icons.psychology_alt_rounded,'التمارين','جميع التمارين',_openExercises),
                _Action(Icons.today_rounded,'خطة اليوم','مهام الجلسة',_openTodayPlan),
                _Action(Icons.park_rounded,'شجرة الذاكرة','ذكرياتك الجميلة',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const MemoryTreeScreen()))),
                _Action(Icons.favorite_outline_rounded,'حالتي اليوم','كيف تشعر؟',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const DailyCheckInScreen()))),
                _Action(Icons.family_restroom_rounded,'العائلة','الأشخاص المرتبطون',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const PatientFamilyScreen()))),
                _Action(Icons.favorite_rounded,'رسائل التشجيع','رسائل العائلة',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const EncouragementScreen()))),
                _Action(Icons.emoji_events_outlined,'الإنجازات','شاهد إنجازاتك',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const AchievementsScreen()))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon; final String value; final String label; final Color color;
  const _Stat(this.icon,this.value,this.label,this.color);
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(vertical:14,horizontal:5),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20),border:Border.all(color:AppColors.border)),child:Column(children:[Icon(icon,color:color),const SizedBox(height:7),FittedBox(child:Text(value,textDirection:TextDirection.ltr,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900))),const SizedBox(height:3),Text(label,textAlign:TextAlign.center,style:const TextStyle(fontSize:9,color:AppColors.textSecondary))]));
}

class _Action extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback tap;
  const _Action(this.icon,this.title,this.subtitle,this.tap);
  @override Widget build(BuildContext context)=>NeuroCard(onTap:tap,child:Row(children:[Container(width:47,height:47,decoration:BoxDecoration(color:const Color(0xFFF1E7D8),borderRadius:BorderRadius.circular(15)),child:Icon(icon,color:AppColors.primary)),const SizedBox(width:10),Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(subtitle,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10,color:AppColors.textSecondary))])),const Icon(Icons.arrow_back_ios_new_rounded,size:13)]));
}
