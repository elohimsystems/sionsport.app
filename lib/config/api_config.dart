class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';
  static const String apiPrefix = 'api-sionsport';

  // ──────────────────────────────
  // Auth endpoints
  // ──────────────────────────────
  static const String login = '$apiPrefix/app-auth/login';
  static const String registerPerson = '$apiPrefix/app-auth/register-user-person';
  static const String registerOrganization = '$apiPrefix/app-auth/register-user-organization';
  static const String editPerson = '$apiPrefix/app-auth/edit-user-person';
  static const String editOrganization = '$apiPrefix/app-auth/edit-user-organization';
  static const String changePassword = '$apiPrefix/app-auth/change-password';
  static const String deleteAccount = '$apiPrefix/app-auth/delete-account';

  // ──────────────────────────────
  // Entity endpoints (GET /{id})
  // ──────────────────────────────
  static const String person = '$apiPrefix/person';
  static const String organization = '$apiPrefix/organization';

  // ──────────────────────────────
  // Location endpoints
  // ──────────────────────────────
  static const String country = '$apiPrefix/country';
  static const String stateByCountry = '$apiPrefix/state/by-country';
  static const String localityByState = '$apiPrefix/locality/by-state';

  // ──────────────────────────────
  // Other endpoints
  // ──────────────────────────────
  static const String discipline = '$apiPrefix/discipline';
  static const String profileByTarget = '$apiPrefix/profile/by-target';

  // ──────────────────────────────
  // Helper methods
  // ──────────────────────────────
  static Uri uri(String endpoint) => Uri.parse('$baseUrl/$endpoint');
  static Uri uriWithId(String endpoint, dynamic id) =>
      Uri.parse('$baseUrl/$endpoint/$id');
  static String imageUrl(String imagePath) =>
      '$baseUrl/${imagePath.replaceAll('\\', '/')}';
}
