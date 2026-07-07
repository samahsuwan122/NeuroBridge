/// Non-sensitive authenticated-user info returned by the backend.
class AuthUser {
  const AuthUser({
    required this.fullName,
    required this.roles,
    this.email,
    this.phone,
  });

  final String fullName;
  final String? email;
  final String? phone;
  final List<String> roles;

  /// Parses the shared shape used by both /auth/login and /auth/me
  /// ({ "user": {...}, "roles": [...] }).
  factory AuthUser.fromResponse(Map<String, dynamic> json) {
    final user = (json['user'] as Map).cast<String, dynamic>();
    final roles = ((json['roles'] as List?) ?? const <dynamic>[])
        .map((dynamic e) => e.toString())
        .toList();
    return AuthUser(
      fullName: (user['full_name'] as String?) ?? '',
      email: user['email'] as String?,
      phone: user['phone'] as String?,
      roles: roles,
    );
  }
}
