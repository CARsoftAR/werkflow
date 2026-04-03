import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class BusinessProvider with ChangeNotifier {
  BusinessInfo? _businessInfo;
  static const String _key = 'business_info';

  BusinessInfo? get businessInfo => _businessInfo;

  BusinessProvider() {
    loadBusinessInfo();
  }

  Future<void> loadBusinessInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_key);
      if (jsonString != null) {
        _businessInfo = BusinessInfo.fromJson(jsonDecode(jsonString));
      } else {
        _businessInfo = BusinessInfo(
          name: 'Electricista Dante',
          phone: '1550432855',
          email: 'info@electricistasur.com',
          website: 'www.electricistasur.com',
          address: 'Av. 12 de Octubre 620, Quilmes',
          footerTitle: 'Términos & y condiciones',
          footerText: 'Los presupuestos tienen una validez de 15 días desde la emisión del mismo, pasado ese periodo pueden sufrir modificaciones con previo aviso.',
        );
      }
    } catch (e) {
      debugPrint("Error loading business info: $e");
    }
    notifyListeners();
  }

  Future<void> saveBusinessInfo(BusinessInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(info.toJson()));
    _businessInfo = info;
    notifyListeners();
  }
}
