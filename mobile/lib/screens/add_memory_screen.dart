import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/patient_features_service.dart';
import '../../widgets/patient_page.dart';

class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({super.key});
  @override State<AddMemoryScreen> createState()=>_AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final formKey=GlobalKey<FormState>();
  final title=TextEditingController(),location=TextEditingController(),people=TextEditingController(),description=TextEditingController();
  final picker=ImagePicker(); XFile? image; Uint8List? preview; DateTime? date;
  String emoji='📷',visibility='family'; bool saving=false;
  @override void dispose(){for(final c in[title,location,people,description])c.dispose();super.dispose();}
  String get dateValue=>date==null?'':'${date!.year}-${date!.month.toString().padLeft(2,'0')}-${date!.day.toString().padLeft(2,'0')}';
  void message(String text){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(text)));}
  Future<void> pick(ImageSource source)async{try{final file=await picker.pickImage(source:source,imageQuality:85,maxWidth:1800,maxHeight:1800);if(file==null)return;final bytes=await file.readAsBytes();if(bytes.length>8*1024*1024){message('حجم الصورة يجب ألا يتجاوز 8MB');return;}if(mounted)setState((){image=file;preview=bytes;});}catch(_){message('تعذر اختيار الصورة. تحققي من صلاحية الصور أو الكاميرا.');}}
  Future<void> chooseDate()async{final value=await showDatePicker(context:context,initialDate:date??DateTime.now(),firstDate:DateTime(1900),lastDate:DateTime.now());if(value!=null)setState(()=>date=value);}
  Future<void> save()async{if(!formKey.currentState!.validate()||saving)return;setState(()=>saving=true);try{await PatientFeaturesService.addMemoryWithImage({'title':title.text.trim(),'memory_date':dateValue,'location':location.text.trim(),'people':people.text.trim(),'description':description.text.trim(),'emoji':emoji,'visibility':visibility},image);if(mounted)Navigator.pop(context,true);}catch(e){message(e.toString().replaceFirst('Exception: ',''));}finally{if(mounted)setState(()=>saving=false);}}
  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(body:PatientPage(child:Form(key:formKey,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    Row(children:[IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.arrow_forward_ios_rounded)),const Expanded(child:Text('إضافة ذكرى جديدة',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)))]),const SizedBox(height:18),
    NeuroCard(featured:true,child:Column(children:[ClipRRect(borderRadius:BorderRadius.circular(22),child:Container(height:250,width:double.infinity,color:Theme.of(context).colorScheme.surfaceContainerHighest,child:preview==null?Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(emoji,style:const TextStyle(fontSize:72)),const SizedBox(height:8),const Text('اختاري صورة لهذه الذكرى',style:TextStyle(fontWeight:FontWeight.w800))]):Image.memory(preview!,fit:BoxFit.cover))),const SizedBox(height:12),Row(children:[Expanded(child:OutlinedButton.icon(onPressed:()=>pick(ImageSource.gallery),icon:const Icon(Icons.photo_library_outlined),label:const Text('المعرض'))),const SizedBox(width:9),Expanded(child:OutlinedButton.icon(onPressed:()=>pick(ImageSource.camera),icon:const Icon(Icons.camera_alt_outlined),label:const Text('الكاميرا')))]),if(image!=null)TextButton.icon(onPressed:()=>setState((){image=null;preview=null;}),icon:const Icon(Icons.delete_outline),label:const Text('إزالة الصورة'))])),
    const SizedBox(height:16),NeuroCard(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      TextFormField(controller:title,decoration:const InputDecoration(labelText:'عنوان الذكرى *',prefixIcon:Icon(Icons.title_rounded)),validator:(v)=>(v?.trim().isEmpty??true)?'عنوان الذكرى مطلوب':null),const SizedBox(height:11),
      OutlinedButton.icon(onPressed:chooseDate,icon:const Icon(Icons.calendar_month_outlined),label:Text(date==null?'اختيار تاريخ الذكرى':dateValue)),const SizedBox(height:11),
      TextFormField(controller:location,decoration:const InputDecoration(labelText:'المكان',prefixIcon:Icon(Icons.location_on_outlined))),const SizedBox(height:11),
      TextFormField(controller:people,decoration:const InputDecoration(labelText:'الأشخاص الموجودون',prefixIcon:Icon(Icons.people_outline_rounded))),const SizedBox(height:11),
      TextFormField(controller:description,minLines:4,maxLines:7,decoration:const InputDecoration(labelText:'احكي عن هذه الذكرى',alignLabelWithHint:true)),const SizedBox(height:14),
      const Text('رمز الذكرى',style:TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:8),Wrap(spacing:8,runSpacing:8,children:['📷','❤️','🌷','🎂','🌊','👨‍👩‍👧'].map((x)=>ChoiceChip(selected:emoji==x,label:Text(x,style:const TextStyle(fontSize:21)),onSelected:(_)=>setState(()=>emoji=x))).toList()),const SizedBox(height:14),
      DropdownButtonFormField<String>(initialValue:visibility,decoration:const InputDecoration(labelText:'من يستطيع مشاهدة الذكرى؟',prefixIcon:Icon(Icons.lock_outline_rounded)),items:const[DropdownMenuItem(value:'family',child:Text('المريض والعائلة')),DropdownMenuItem(value:'patient',child:Text('المريض فقط'))],onChanged:(v)=>setState(()=>visibility=v??visibility))])),
    const SizedBox(height:18),FilledButton.icon(onPressed:saving?null:save,icon:saving?const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)):const Icon(Icons.cloud_upload_outlined),label:Text(saving?'جارٍ رفع الصورة وحفظ الذكرى...':'حفظ الذكرى')),const SizedBox(height:30)
  ])))));
}
