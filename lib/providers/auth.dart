import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  String _refreshToken;
  DateTime _expiryDate;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

 

  Future<void> login(String username, String password) async {
    print('$username================================================$password');
    final url =
        'https://ymukeshyadavmrj.pythonanywhere.com/gettoken/';
    try {
      final response = await http.post(url,headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },body: json.encode({
          'username': username,
          'password':password,
      }));
      print(response);
      print("------------------------------------------------------------");
      final responseData = json.decode(response.body) as Map<String,dynamic>;
      if (responseData.containsKey('code')) {
        throw HttpException(responseData['message']['message']);
      }
      print("------------------------------------------------------------");
      _token = responseData['access'];
      print(_token);
      _refreshToken = responseData['refresh'];
      print(_refreshToken);
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: 300,
        ),
      );
      print(_expiryDate);
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'refreshToken':_refreshToken,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String username,String email, String password) async {
      final url =
        Uri.parse('https://ymukeshyadavmrj.pythonanywhere.com/register/');
    try {
      final jb = jsonEncode({
          'username': username,
          'email':email,
          'password':password,
          'password2':password,
      });
      print(jb);
      final response = await http.post(url,body:jb,headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

      final responseData = json.decode(response.body) as Map<String,dynamic>;
      print("responseData===========================================$responseData");
      if (responseData.containsKey('code')) {
        throw HttpException(responseData['message']['message']);
      }
      _token = responseData['access'];
      print("Token =======$_token");

      _refreshToken = responseData['refresh'];
      print("Refresh token ====================================================== $_refreshToken");
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: 300,
        ),
      );
      print(_expiryDate);
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'refreshToken':_refreshToken,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    _refreshToken = extractedUserData['refreshToken'];
    if(_refreshToken==null)
    return false;
    if (expiryDate.isBefore(DateTime.now())) {
      final url = 'https://ymukeshyadavmrj.pythonanywhere.com/refreshtoken/';
      print(_refreshToken);
      final response = await http.post(url,headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },body: json.encode({
      'refresh':_refreshToken,
    })) as Map<String,dynamic>;
      if(!response.containsKey('access'))
      {
        logout();
        return false;
      }
      _token = response['access'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: 300,
        ),
      );
      
      notifyListeners();
          _autoLogout();
      return true;
    }
    _token = extractedUserData['token'];
    _expiryDate = expiryDate;
    _refreshToken = extractedUserData['refreshToken'];
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), tryAutoLogin);
  }
}
