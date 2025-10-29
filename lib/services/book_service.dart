import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'auth_service.dart';

class BookService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  // ✅ OBTER TODOS OS LIVROS (BIBLIOTECA COMPARTILHADA)
  static Future<List<Map<String, dynamic>>> getUserBooks() async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .order('created_at', ascending: false);

      if (response is List) {
        return response.map((book) {
          final Map<String, dynamic> bookMap = {};
          
          book.forEach((key, value) {
            bookMap[key.toString()] = value;
          });
          
          bookMap['id'] = bookMap['id']?.toString() ?? '';
          bookMap['title'] = bookMap['title']?.toString() ?? 'Sem título';
          bookMap['author'] = bookMap['author']?.toString() ?? 'Autor desconhecido';
          bookMap['file_path'] = bookMap['file_path']?.toString() ?? '';
          bookMap['file_name'] = bookMap['file_name']?.toString() ?? '';
          bookMap['reading_progress'] = bookMap['reading_progress'] ?? 0;
          
          return bookMap;
        }).toList();
      }
      
      return [];
    } catch (e) {
      print('❌ ERRO em getUserBooks: $e');
      throw e;
    }
  }

  // ✅ OBTER DADOS COMPLETOS DO PROGRESSO (página atual + total) - CORRIGIDO
  static Future<Map<String, dynamic>?> getReadingProgressData(String bookId) async {
    try {
      final user = AuthService.getCurrentUser();
      if (user == null) return null;

      print('📖 Buscando progresso salvo para livro: $bookId');

      final response = await _supabase
          .from('reading_progress')
          .select('progress, current_page, total_pages')
          .eq('book_id', bookId)
          .eq('user_id', user.id)
          .maybeSingle(); // ✅ CORREÇÃO: usar maybeSingle em vez de single

      print('📊 Progresso encontrado: $response');
      return response;
    } catch (e) {
      print('❌ ERRO em getReadingProgressData: $e');
      return null;
    }
  }

  // ✅ SALVAR PROGRESSO COM PÁGINA ATUAL - CORRIGIDO (USANDO UPSERT)
  static Future<void> saveReadingProgressWithPage(
    String bookId, 
    int progress, 
    int currentPage,
    int totalPages
  ) async {
    try {
      final user = AuthService.getCurrentUser();
      if (user == null) return;

      print('💾 Salvando progresso: Livro $bookId, Página $currentPage, Progresso $progress%, Total: $totalPages');

      // ✅ CORREÇÃO: USAR upsert para garantir que sempre funcione
      await _supabase
          .from('reading_progress')
          .upsert({
            'book_id': bookId,
            'user_id': user.id,
            'progress': progress,
            'current_page': currentPage,
            'total_pages': totalPages,
            'updated_at': DateTime.now().toIso8601String(),
            'last_read': DateTime.now().toIso8601String(),
          });

      print('✅ Progresso salvo com sucesso');
    } catch (e) {
      print('❌ ERRO em saveReadingProgressWithPage: $e');
    }
  }

  // ✅ ADICIONAR LIVRO (apenas usuários logados)
  static Future<void> addBook(Map<String, dynamic> bookData) async {
    final user = AuthService.getCurrentUser();
    if (user == null) throw Exception('Usuário não autenticado');

    print('📚 Adicionando livro: ${bookData['title']}');

    await _supabase.from('books').insert({
      ...bookData,
      'user_id': user.id,
      'created_at': DateTime.now().toIso8601String(),
    });

    print('✅ Livro adicionado com sucesso');
  }

  // ✅ REMOVER LIVRO (apenas dono pode remover)
  static Future<void> removeBook(String bookId, String filePath) async {
    final user = AuthService.getCurrentUser();
    if (user == null) throw Exception('Usuário não autenticado');

    await _supabase
        .from('books')
        .delete()
        .eq('id', bookId)
        .eq('user_id', user.id);
  }

  // ✅ OBTER PROGRESSO DE LEITURA (progresso individual)
  static Future<int> getReadingProgress(String bookId) async {
    try {
      final user = AuthService.getCurrentUser();
      if (user == null) return 0;

      final response = await _supabase
          .from('reading_progress')
          .select('progress')
          .eq('book_id', bookId)
          .eq('user_id', user.id)
          .maybeSingle() // ✅ CORREÇÃO: usar maybeSingle
          .catchError((_) => null);

      return response != null ? (response['progress'] ?? 0) : 0;
    } catch (e) {
      print('❌ ERRO em getReadingProgress: $e');
      return 0;
    }
  }

  // ✅ SALVAR PROGRESSO DE LEITURA (progresso individual)
  static Future<void> saveReadingProgress(String bookId, int progress) async {
    try {
      final user = AuthService.getCurrentUser();
      if (user == null) return;

      // ✅ CORREÇÃO: Usar upsert também aqui para consistência
      await _supabase
          .from('reading_progress')
          .upsert({
            'book_id': bookId,
            'user_id': user.id,
            'progress': progress,
            'updated_at': DateTime.now().toIso8601String(),
            'last_read': DateTime.now().toIso8601String(),
          });

      print('💾 Progresso simples salvo: $progress%');
    } catch (e) {
      print('❌ ERRO em saveReadingProgress: $e');
    }
  }

  // ✅ MÉTODO EXTRA: Buscar livro por ID
  static Future<Map<String, dynamic>?> getBookById(String bookId) async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .eq('id', bookId)
          .maybeSingle() // ✅ CORREÇÃO: usar maybeSingle
          .catchError((_) => null);

      if (response != null) {
        final Map<String, dynamic> bookMap = {};
        response.forEach((key, value) {
          bookMap[key.toString()] = value;
        });
        return bookMap;
      }
      return null;
    } catch (e) {
      print('❌ ERRO em getBookById: $e');
      return null;
    }
  }
}