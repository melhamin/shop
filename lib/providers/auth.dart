import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  static const _API_KEY = 'AIzaSyCyg0pRnoFhWrAEGBuGBsCEG8EROJQHPzA';
  static const databaseURL = 'https://flutter-shopapp-8a17f.firebaseio.com/';
  String _token;
  DateTime _expireDate;
  String _userID;
  Timer _authTimer;

  String get token {
    if (_expireDate != null &&
        _expireDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  bool get isAuth {
    return _token != null;
  }

  String get userID {
    return _userID;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$_API_KEY';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _userID = responseData['localId'];

      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final authData = json.encode({
        'token': _token,
        'expireDate': _expireDate.toIso8601String(),
        'userID': _userID,
      });
      prefs.setString('authData', authData);
    } catch (error) {
      throw error;
    }

    // print(json.decode(response.body));
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authData')) return false;
    final extractedUserdata =
        json.decode(prefs.getString('authData')) as Map<String, dynamic>;
    final expireDate = DateTime.parse(extractedUserdata['expireDate']);
    if (expireDate.isBefore(DateTime.now())) return false;

    _token = extractedUserdata['token'];
    _userID = extractedUserdata['userID'];
    _expireDate = expireDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userID = null;
    _expireDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpire = _expireDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logout);
  }
}
