import 'package:flutter/material.dart';
import '../../core/services/patient_features_service.dart';
import '../../widgets/patient_page.dart';

class MemoryDetailsScreen extends StatefulWidget{
 final Map<String,dynamic> memory;const MemoryDetailsScreen({super.key,required this.memory});
 @override State<MemoryDetailsScreen> createState()=>_MemoryDetailsScreenState();}
class _MemoryDetailsScreenState extends State<MemoryDetailsScreen>{bool deleting=false;
 Future<void> delete()async{final yes=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(title:const Text('حذف الذكرى؟'),content:const Text('سيتم حذف الذكرى والصورة نهائيًا.'),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('إلغاء')),FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('حذف'))]));if(yes!=true)return;setState(()=>deleting=true);try{await PatientFeaturesService.deleteMemory(int.parse(widget.memory['id'].toString()));if(mounted)Navigator.pop(context,true);}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString().replaceFirst('Exception: ',''))));}finally{if(mounted)setState(()=>deleting=false);}}
 @override Widget build(BuildContext context){final m=widget.memory,url=m['image_url']?.toString()??'';return Directionality(textDirection:TextDirection.rtl,child:Scaffold(body:PatientPage(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  Row(children:[IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.arrow_forward_ios_rounded)),const Spacer(),IconButton(onPressed:deleting?null:delete,icon:const Icon(Icons.delete_outline_rounded,color:Colors.red))]),
  ClipRRect(borderRadius:BorderRadius.circular(28),child:Container(height:380,color:Theme.of(context).colorScheme.surfaceContainerHighest,alignment:Alignment.center,child:url.isEmpty?Text(m['emoji']?.toString()??'📷',style:const TextStyle(fontSize:110)):Image.network(url,width:double.infinity,height:380,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const Icon(Icons.broken_image_outlined,size:70)))),const SizedBox(height:22),
  Text(m['title']?.toString()??'',style:const TextStyle(fontSize:29,fontWeight:FontWeight.w900)),if((m['memory_date']?.toString()??'').isNotEmpty)...[const SizedBox(height:5),Text(m['memory_date'].toString(),style:TextStyle(color:Theme.of(context).colorScheme.onSurfaceVariant))],const SizedBox(height:17),
  if((m['description']?.toString()??'').isNotEmpty)NeuroCard(child:Text(m['description'].toString(),style:const TextStyle(fontSize:16,height:1.8))),
  if((m['people']?.toString()??'').isNotEmpty)...[const SizedBox(height:12),NeuroCard(child:Row(children:[const Icon(Icons.people_outline_rounded),const SizedBox(width:10),Expanded(child:Text('الأشخاص في الذكرى: ${m['people']}'))]))],
  if((m['location']?.toString()??'').isNotEmpty)...[const SizedBox(height:12),NeuroCard(child:Row(children:[const Icon(Icons.location_on_outlined),const SizedBox(width:10),Expanded(child:Text(m['location'].toString()))]))],
  const SizedBox(height:25)
 ]))));}}
