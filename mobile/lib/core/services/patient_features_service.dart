import 'dart:convert';
import 'package:http/http.dart' as http;
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
  static Future<Map<String,dynamic>> loadFamily()=>_get('family');
  static Future<Map<String,dynamic>> loadAchievements() async {final d=await _get('achievements');return Map<String,dynamic>.from(d['stats']??const{});}
}
