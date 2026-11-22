/// User model returned by the authentication endpoints.
///
/// Represents a registered user account with an identifier, display name, and
/// email address.
class UserModel {
  /// Unique identifier of the user.
  final String id;

  /// Display name of the user.
  final String name;

  /// Email address of the user.
  final String email;

  /// Creates a [UserModel] with the given [id], [name], and [email].
  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  /// Creates a [UserModel] from a JSON map as returned by the API.
  ///
  /// Expects keys: `id`, `name`, `email`.
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
      );

  /// Converts this [UserModel] into a JSON map suitable for storage or sending.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}

/// Authentication response returned by register and login endpoints.
///
/// Bundles the JWT [token] with the authenticated [user].
class AuthResponse {
  /// JWT access token used to authenticate subsequent API requests.
  final String token;

  /// The authenticated user profile.
  final UserModel user;

  /// Creates an [AuthResponse] with the given [token] and [user].
  AuthResponse({required this.token, required this.user});

  /// Creates an [AuthResponse] from a JSON map as returned by the API.
  ///
  /// Expects keys: `token` (String) and `user` (Map).
  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'] as String,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}
