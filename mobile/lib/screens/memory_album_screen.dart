import 'package:flutter/material.dart';
import '../../core/services/patient_features_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/patient_page.dart';
import 'add_memory_screen.dart';
import 'memory_details_screen.dart';

class MemoryAlbumScreen extends StatefulWidget{const MemoryAlbumScreen({super.key});@override State<MemoryAlbumScreen> createState()=>_MemoryAlbumScreenState();}
class _MemoryAlbumScreenState extends State<MemoryAlbumScreen>{List<Map<String,dynamic>> items=[];bool loading=true;String? error;
 @override void initState(){super.initState();load();}
 Future<void> load()async{if(mounted)setState((){loading=true;error=null;});try{final rows=await PatientFeaturesService.loadMemories();if(mounted)setState(()=>items=rows);}catch(e){if(mounted)setState(()=>error=e.toString().replaceFirst('Exception: ',''));}finally{if(mounted)setState(()=>loading=false);}}
 Future<void> add()async{final changed=await Navigator.push<bool>(context,MaterialPageRoute(builder:(_)=>const AddMemoryScreen()));if(changed==true)await load();}
 Future<void> open(Map<String,dynamic> item)async{final changed=await Navigator.push<bool>(context,MaterialPageRoute(builder:(_)=>MemoryDetailsScreen(memory:item)));if(changed==true)await load();}
 @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(floatingActionButton:FloatingActionButton.extended(onPressed:add,icon:const Icon(Icons.add_photo_alternate_outlined),label:const Text('إضافة ذكرى')),body:PatientPage(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  Row(children:[IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.arrow_forward_ios_rounded)),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('ألبوم الذكريات',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),Text('صورك ولحظاتك الجميلة في مكان واحد',style:TextStyle(color:AppColors.textSecondary))])),IconButton(onPressed:load,icon:const Icon(Icons.refresh_rounded))]),const SizedBox(height:20),
  if(loading)const Center(child:Padding(padding:EdgeInsets.all(45),child:CircularProgressIndicator()))else if(error!=null)NeuroCard(child:Column(children:[Text(error!,textAlign:TextAlign.center),const SizedBox(height:10),OutlinedButton(onPressed:load,child:const Text('إعادة المحاولة'))]))else if(items.isEmpty)NeuroCard(child:Padding(padding:const EdgeInsets.symmetric(vertical:38),child:Column(children:[const Icon(Icons.add_photo_alternate_outlined,size:58,color:AppColors.secondaryDark),const SizedBox(height:12),const Text('لا توجد ذكريات بعد',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('أضيفي أول صورة أو لحظة جميلة إلى شجرتك.'),const SizedBox(height:15),FilledButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('إضافة أول ذكرى'))])))else LayoutBuilder(builder:(context,c){final columns=c.maxWidth>=900?4:c.maxWidth>=620?3:2;return GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:items.length,gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:columns,mainAxisSpacing:13,crossAxisSpacing:13,mainAxisExtent:250),itemBuilder:(_,i)=>_MemoryCard(memory:items[i],onTap:()=>open(items[i])));}),const SizedBox(height:90)
 ]))));}

class _MemoryCard extends StatelessWidget {
  final Map<String, dynamic> memory;
  final VoidCallback onTap;
  const _MemoryCard({required this.memory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = memory['image_url']?.toString() ?? '';
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                child: SizedBox(
                  width: double.infinity,
                  child: url.isEmpty
                      ? Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, alignment: Alignment.center, child: Text(memory['emoji']?.toString() ?? '📷', style: const TextStyle(fontSize: 58)))
                      : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, alignment: Alignment.center, child: const Icon(Icons.broken_image_outlined, size: 45))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(memory['title']?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(memory['memory_date']?.toString() ?? '', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
