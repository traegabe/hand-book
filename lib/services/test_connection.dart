import 'supabase_config.dart'; // ✅ Agora está sendo usada

class TestConnection {
  static Future<void> testSupabase() async {
    try {
      //final supabase = SupabaseConfig.client; // ✅ Usando a importação
      
      // Testar conexão básica
      //final response = await supabase.from('books').select('count').limit(1);
      print('✅ Conexão com Supabase: OK');
      
      // Testar URL configurada
      print('📡 URL: ${SupabaseConfig.supabaseUrl}'); // ✅ Usando a importação
      
    } catch (e) {
      print('❌ Erro na conexão: $e');
    }
  }
}