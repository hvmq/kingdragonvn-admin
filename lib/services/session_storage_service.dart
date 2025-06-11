import 'dart:html' as html;

class SessionStorageService {
  static const String _tokenKey = 'auth_token';

  static void setToken(String token) {
    html.window.sessionStorage[_tokenKey] = token;
  }

  static String? getToken() {
    return html.window.sessionStorage[_tokenKey];
  }

  static void clearToken() {
    html.window.sessionStorage.remove(_tokenKey);
  }
}
