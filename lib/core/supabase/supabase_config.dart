class SupabaseConfig {
  // Replace these with your Supabase Project URL and Anon Key from Project Settings -> API
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-placeholder';

  // Returns true once real credentials are provided
  static bool get isConfigured =>
      supabaseUrl != 'https://your-project-id.supabase.co' &&
      supabaseAnonKey != 'your-anon-key-placeholder' &&
      supabaseUrl.startsWith('https://');
}
