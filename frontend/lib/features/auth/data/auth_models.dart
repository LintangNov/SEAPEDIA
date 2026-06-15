class LoginResponse {
  final String message;
  final String accessToken;
  final List<String> availableRoles;

  LoginResponse({
    required this.message,
    required this.accessToken,
    required this.availableRoles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String,
      accessToken: json['accessToken'] as String,
      availableRoles: List<String>.from(json['availableRoles'] ?? []),
    );
  }
}

class SelectRoleResponse {
  final String message;
  final String accessToken;

  SelectRoleResponse({required this.message, required this.accessToken});

  factory SelectRoleResponse.fromJson(Map<String, dynamic> json) {
    return SelectRoleResponse(
      message: json['message'] as String,
      accessToken: json['accessToken'] as String,
    );
  }
}

class UserProfile{
  final String id;
  final String username;
  final String activeRole;

  UserProfile({
    required this.id,
    required this.username,
    required this.activeRole,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json){
    return UserProfile(
      id: json['sub'] as String,
      username: json['username'] as String,
      activeRole: json['activeRole'] as String,
    );
  }
}