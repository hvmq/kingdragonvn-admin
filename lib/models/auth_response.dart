class User {
  final String id;
  final String username;
  final String phoneNumber;
  final String refId;

  User({
    required this.id,
    required this.username,
    required this.phoneNumber,
    required this.refId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      phoneNumber: json['phoneNumber'],
      refId: json['refId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phoneNumber': phoneNumber,
      'refId': refId,
    };
  }
}

class AuthResponse {
  final String message;
  final String token;
  final User user;

  AuthResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print('AuthResponse.fromJson - Raw data: $json');
    final response = AuthResponse(
      message: json['message'] as String,
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
    print('AuthResponse.fromJson - Parsed response: ${response.toJson()}');
    return response;
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
      'user': user.toJson(),
    };
  }
}
