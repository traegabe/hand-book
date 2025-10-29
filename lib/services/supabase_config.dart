import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ktmvqxkvwxlyhwyxyjrr.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0bXZxeGt2d3hseWh3eXh5anJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4MjUwNTIsImV4cCI6MjA3NjQwMTA1Mn0.UR7qp2k0Mi-tYA9tNm14w_WZr9TM9P3CxC0CXo_yyO4';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  // ✅ MÉTODO CORRIGIDO - CADASTRO
  static Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow; // ✅ CORRIGIDO: use 'rethrow' em vez de 'throw e'
    }
  }

  // ✅ MÉTODO CORRIGIDO - LOGIN
  static Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow; // ✅ CORRIGIDO: use 'rethrow' em vez de 'throw e'
    }
  }

  // ✅ MÉTODO PARA LOGOUT
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ✅ VERIFICAR SE USUÁRIO ESTÁ LOGADO
  static User? get currentUser => client.auth.currentUser;

  // ✅ OBTER SESSÃO ATUAL
  static Session? get currentSession => client.auth.currentSession;

  // ✅ VERIFICAR SE TEM UM USUÁRIO LOGADO
  static bool get isLoggedIn => currentUser != null;

  // ✅ OUVIR MUDANÇAS DE AUTENTICAÇÃO
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}