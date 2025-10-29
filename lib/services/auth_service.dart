import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class AuthService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  // ✅ LOGIN
  static Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ✅ CADASTRO
  static Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // ✅ LOGOUT
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ✅ RECUPERAR SENHA
  static Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // ✅ VERIFICAR SE TEM SESSÃO SALVA
  static Future<bool> hasSavedSession() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  // ✅ OBTER USUÁRIO ATUAL
  static User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}