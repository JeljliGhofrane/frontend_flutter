import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  static String get _base {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
    return 'http://127.0.0.1:3000';
  }

  Map<String, String> get _h => {
    'Content-Type' : 'application/json',
    'Authorization': 'Bearer ${AuthService().token}',
  };

  Future<dynamic> get(String path) async {
    try {
      final res = await http.get(Uri.parse('$_base$path'), headers: _h)
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (_) { return {'error': 'Serveur inaccessible'}; }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http.post(Uri.parse('$_base$path'), headers: _h, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (_) { return {'error': 'Serveur inaccessible'}; }
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    try {
      final res = await http.put(Uri.parse('$_base$path'), headers: _h, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (_) { return {'error': 'Serveur inaccessible'}; }
  }

  Future<dynamic> delete(String path) async {
    try {
      final res = await http.delete(Uri.parse('$_base$path'), headers: _h)
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (_) { return {'error': 'Serveur inaccessible'}; }
  }

  // Capteurs
  Future<dynamic> getDonnees()    => get('/donnees');
  Future<dynamic> getPrediction() => get('/prediction');
  Future<dynamic> getStatus()     => get('/status');

  // Alertes
  Future<dynamic> getAlertes({String? type, bool? resolue}) {
    var p = '/api/alertes?limite=50';
    if (type    != null) p += '&type=$type';
    if (resolue != null) p += '&resolue=$resolue';
    return get(p);
  }
  Future<dynamic> getAlertesStats()       => get('/api/alertes/stats');
  Future<dynamic> resoudreAlerte(String id) => put('/api/alertes/$id/resoudre', {});

  // Journaux
  Future<dynamic> getJournaux({String? statut, int limite = 100}) {
    var p = '/api/journaux?limite=$limite';
    if (statut != null) p += '&statut=$statut';
    return get(p);
  }
  Future<dynamic> getJournauxStats() => get('/api/journaux/stats');

  // RFID
  Future<dynamic> getRfids()                                  => get('/api/rfid');
  Future<dynamic> addRfid(Map<String, dynamic> d)             => post('/api/rfid', d);
  Future<dynamic> updateRfid(String id, Map<String, dynamic> d) => put('/api/rfid/$id', d);
  Future<dynamic> deleteRfid(String id)                       => delete('/api/rfid/$id');

  // Visages
  Future<dynamic> getVisages()            => get('/api/visages');
  Future<dynamic> deleteVisage(String nom) => delete('/api/visages/$nom');

  // Historique
  Future<dynamic> getHistorique({int limite = 200}) => get('/api/historique?limite=$limite');
  Future<dynamic> getHistoriqueStats()              => get('/api/historique/stats');

  // Utilisateurs (admin)
  Future<dynamic> getUsers()                                    => get('/api/auth/users');
  Future<dynamic> getUserStats()                                => get('/api/auth/stats');
  Future<dynamic> updateUser(String id, Map<String, dynamic> d) => put('/api/auth/users/$id', d);
  Future<dynamic> deleteUser(String id)                         => delete('/api/auth/users/$id');
  Future<dynamic> approveUser(String id)                        => put('/api/auth/approve/$id', {});
  Future<dynamic> rejectUser(String id)                         => put('/api/auth/reject/$id', {});
}