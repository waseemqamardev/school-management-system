import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase/supabase_config.dart';
import 'school_repository.dart';
import 'mock_school_repository.dart';
import 'supabase_school_repository.dart';

class RepositoryManager extends ChangeNotifier {
  static final RepositoryManager _instance = RepositoryManager._internal();
  factory RepositoryManager() => _instance;
  RepositoryManager._internal();

  late ISchoolRepository _repository;
  bool _isSupabaseConfigured = false;
  bool _isSupabaseInitialized = false;
  bool _isUsingMock = true;
  String _backendStatusMessage = '';
  bool _isOnline = true;

  ISchoolRepository get repository => _repository;
  bool get isSupabaseConfigured => _isSupabaseConfigured;
  bool get isSupabaseInitialized => _isSupabaseInitialized;
  bool get isUsingMock => _isUsingMock;
  bool get isSupabaseMode => !_isUsingMock;
  String get backendStatusMessage => _backendStatusMessage;
  String get firebaseStatusMessage => _backendStatusMessage; // backwards compatibility
  bool get isOnline => _isOnline;

  Future<bool> seedInitialData() async {
    await _repository.seedInitialData();
    notifyListeners();
    return true;
  }

  Future<void> initialize() async {
    // Default to mock repo initially so app never blocks or crashes
    _repository = MockSchoolRepository();
    _isUsingMock = true;

    try {
      if (SupabaseConfig.isConfigured) {
        await Supabase.initialize(
          url: SupabaseConfig.supabaseUrl,
          publishableKey: SupabaseConfig.supabaseAnonKey,
        );
        _isSupabaseConfigured = true;
        _isSupabaseInitialized = true;
        _repository = SupabaseSchoolRepository();
        _isUsingMock = false;
        _backendStatusMessage = 'Connected to Supabase PostgreSQL Database';
      } else {
        _isSupabaseConfigured = false;
        _isSupabaseInitialized = false;
        _isUsingMock = true;
        _backendStatusMessage =
            'Running in Prototype Demo Mode. Enter your Supabase URL & Anon Key in supabase_config.dart to connect live Supabase.';
      }
    } catch (e) {
      debugPrint('Supabase initialization note: $e');
      _isSupabaseInitialized = false;
      _isUsingMock = true;
      _backendStatusMessage =
          'Local Mock Mode active. (To use live Supabase, configure supabase_config.dart).';
      _repository = MockSchoolRepository();
    }
    notifyListeners();
  }

  void setOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  Future<void> switchToMock() async {
    _repository = MockSchoolRepository();
    _isUsingMock = true;
    _backendStatusMessage = 'Switched to Local In-Memory Demo Mode';
    notifyListeners();
  }

  Future<bool> switchToSupabaseIfPossible() async {
    try {
      if (!_isSupabaseInitialized) {
        await Supabase.initialize(
          url: SupabaseConfig.supabaseUrl,
          publishableKey: SupabaseConfig.supabaseAnonKey,
        );
        _isSupabaseInitialized = true;
      }
      _repository = SupabaseSchoolRepository();
      _isUsingMock = false;
      _backendStatusMessage = 'Connected to Supabase PostgreSQL Database';
      notifyListeners();
      return true;
    } catch (e) {
      _backendStatusMessage = 'Supabase connection failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> seedCurrentRepository() async {
    await _repository.seedInitialData();
    notifyListeners();
  }
}
