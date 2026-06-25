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

class UserProfile {
  final String id;
  final String username;
  final String activeRole;
  final List<String> roles;

  UserProfile({
    required this.id,
    required this.username,
    required this.activeRole,
    required this.roles,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['sub']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? 'Unknown',
      activeRole: json['activeRole']?.toString() ?? 'None',
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}
