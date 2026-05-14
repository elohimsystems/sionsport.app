class LoginResponse {
  final String accessToken;
  final LoginUser user;

  LoginResponse({required this.accessToken, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['access_token'] as String,
        user: LoginUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class LoginUser {
  final String nameToShow;
  final String target;
  final String? imagetoShow;
  final int entityId;

  LoginUser({
    required this.nameToShow,
    required this.target,
    this.imagetoShow,
    required this.entityId,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) => LoginUser(
        nameToShow: json['nameToShow'] as String,
        target: json['target'] as String,
        imagetoShow: json['imagetoShow'] as String?,
        entityId: json['entityId'] as int,
      );
}
