import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A class that provides access to environment variables
class EnvConfig {
  /// Supabase URL from environment
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase anonymous key from environment
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Google Client ID for Android from environment
  static String get googleClientIdAndroid => 
      dotenv.env['GOOGLE_CLIENT_ID_ANDROID'] ?? '';

  /// Google Client ID for iOS from environment
  static String get googleClientIdIos => 
      dotenv.env['GOOGLE_CLIENT_ID_IOS'] ?? '';
      
  /// Google Client ID for Web from environment
  static String get googleClientIdWeb => 
      dotenv.env['GOOGLE_CLIENT_ID_WEB'] ?? '';
      
  /// Authorized redirect URIs for OAuth
  static String get authorizedRedirectUris => 
      dotenv.env['Authorized_redirect_URIs'] ?? '';

  /// Deep link scheme from environment
  static String get deepLinkScheme => dotenv.env['DEEP_LINK_SCHEME'] ?? '';

  /// Deep link host from environment
  static String get deepLinkHost => dotenv.env['DEEP_LINK_HOST'] ?? '';
}
