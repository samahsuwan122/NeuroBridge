import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'session_service.dart';

class PatientFeaturesService {
  static const _url='https://toyoraljana.com/api_neuro/patient_features.php';
  static Future<Map<String,String>> _headers() async {final token=await SessionService.getToken();if(token==null||token.isEmpty)throw Exception('يرجى تسجيل الدخول');return {'Accept':'application/json','Content-Type':'application/json; charset=UTF-8','Authorization':'Bearer $token'};}
  static Future<Map<String,dynamic>> _get(String action) async {final r=await http.get(Uri.parse('$_url?action=$action'),headers:await _headers()).timeout(const Duration(seconds:25));return _decode(r);}
  static Future<Map<String,dynamic>> _post(String action,Map<String,dynamic> body) async {final r=await http.post(Uri.parse('$_url?action=$action'),headers:await _headers(),body:jsonEncode(body)).timeout(const Duration(seconds:25));return _decode(r);}
  static Map<String,dynamic> _decode(http.Response r){try{final d=Map<String,dynamic>.from(jsonDecode(utf8.decode(r.bodyBytes)));if(r.statusCode==200&&d['success']==true)return d;throw Exception(d['message']??'تعذر تنفيذ الطلب');}catch(e){if(e is Exception)rethrow;throw Exception('استجابة غير صالحة من الخادم');}}
  static Future<Map<String,dynamic>?> loadCheckin() async {final d=await _get('checkin');return d['checkin'] is Map?Map<String,dynamic>.from(d['checkin']):null;}
  static Future<void> saveCheckin(Map<String,dynamic> data) async=>_post('checkin',data);
  static Future<List<Map<String,dynamic>>> loadMemories() async {final d=await _get('memories');return (d['memories'] as List? ?? const[]).whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList();}
  static Future<void> addMemory(Map<String,dynamic> data) async=>_post('memories',data);
  static Future<void> addMemoryWithImage(Map<String, dynamic> data, XFile? image) async {
    if (image == null) {
      await addMemory(data);
      return;
    }
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) throw Exception('يرجى تسجيل الدخول');
    final request = http.MultipartRequest('POST', Uri.parse('$_url?action=memories'));
    request.headers.addAll({'Accept': 'application/json', 'Authorization': 'Bearer $token'});
    data.forEach((key, value) => request.fields[key] = value?.toString() ?? '');
    final bytes = await image.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: image.name));
    final streamed = await request.send().timeout(const Duration(seconds: 45));
    final response = await http.Response.fromStream(streamed);
    _decode(response);
  }
  static Future<Map<String, dynamic>> updateMemoryImage(int memoryId, XFile image) async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) throw Exception('يرجى تسجيل الدخول');
    final request = http.MultipartRequest('POST', Uri.parse('$_url?action=memory_image'));
    request.headers.addAll({'Accept': 'application/json', 'Authorization': 'Bearer $token'});
    request.fields['memory_id'] = memoryId.toString();
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      await image.readAsBytes(),
      filename: image.name,
    ));
    final streamed = await request.send().timeout(const Duration(seconds: 45));
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
  }
  static Future<void> deleteMemory(int id) async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) throw Exception('يرجى تسجيل الدخول');
    final response = await http.delete(
      Uri.parse('$_url?action=memories&id=$id'),
      headers: {'Accept':'application/json','Authorization':'Bearer $token'},
    ).timeout(const Duration(seconds: 25));
    _decode(response);
  }
  static Future<Map<String, dynamic>> loadFamily() =>
      _get('family');

  static Future<List<Map<String, dynamic>>>
      loadEncouragements() async {
    final data = await _get('encouragements');

    return (data['encouragements'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .toList();
  }

  static Future<Map<String, dynamic>>
      loadAchievements() async {
    final data = await _get('achievements');

    return Map<String, dynamic>.from(
      data['stats'] ?? const {},
    );
  }
}