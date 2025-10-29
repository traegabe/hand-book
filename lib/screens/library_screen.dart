import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import 'pdf_viewer_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';

  // ✅ CONTROLE DE LIVROS LENDO (apenas para lógica interna)
  final Map<String, int> _readingProgress = {};
  final Map<String, bool> _readingBooks = {};

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  // ✅ OUVIR MUDANÇAS DE NAVEGAÇÃO
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForUpdates();
  }

  void _checkForUpdates() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map && arguments['refresh'] == true) {
      _loadBooks();
    }
  }

  Future<void> _loadBooks() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final books = await BookService.getUserBooks();
      
      if (mounted) {
        setState(() {
          _books = _sortBooksAlphabetically(books);
        });
        // ✅ CARREGAR PROGRESSO DE LEITURA (apenas para lógica interna)
        await _loadReadingProgress();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar livros: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ MÉTODO CORRIGIDO - _loadReadingProgress (apenas para lógica interna)
  Future<void> _loadReadingProgress() async {
    for (var book in _books) {
      final bookId = book['id']?.toString();
      if (bookId != null) {
        try {
          final progress = await BookService.getReadingProgress(bookId);
          if (mounted) {
            setState(() {
              _readingProgress[bookId] = progress;
              _readingBooks[bookId] = progress > 0 && progress < 95;
            });
          }
        } catch (e) {
          print('❌ Erro ao carregar progresso do livro $bookId: $e');
          if (mounted) {
            setState(() {
              _readingProgress[bookId] = 0;
              _readingBooks[bookId] = false;
            });
          }
        }
      }
    }
  }

  List<Map<String, dynamic>> _sortBooksAlphabetically(List<Map<String, dynamic>> books) {
    books.sort((a, b) {
      final titleA = (a['title'] ?? '').toString().toLowerCase();
      final titleB = (b['title'] ?? '').toString().toLowerCase();
      return titleA.compareTo(titleB);
    });
    return books;
  }

  // ✅ MARCAR LIVRO COMO "LENDO" QUANDO ABRIR PELA PRIMEIRA VEZ (lógica interna)
  void _markAsReading(String bookId) {
    setState(() {
      _readingBooks[bookId] = true;
    });
  }

  Future<void> _deleteBook(Map<String, dynamic> book) async {
    final bookId = book['id']?.toString();
    final bookTitle = book['title'] ?? 'este livro';
    final filePath = book['file_path']?.toString();
    
    if (bookId == null || filePath == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Livro'),
        content: Text('Tem certeza que deseja excluir "$bookTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await BookService.removeBook(bookId, filePath);
        
        if (mounted) {
          setState(() {
            _books.removeWhere((b) => b['id']?.toString() == bookId);
            _readingProgress.remove(bookId);
            _readingBooks.remove(bookId);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🗑️ "$bookTitle" excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erro ao excluir livro: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  List<Map<String, dynamic>> get _filteredBooks {
    var filtered = _books;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((book) {
        final title = (book['title'] ?? '').toString().toLowerCase();
        final author = (book['author'] ?? '').toString().toLowerCase();
        return title.contains(_searchQuery.toLowerCase()) || 
               author.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do App'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        await AuthService.signOut();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('👋 Até logo!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/guest_welcome');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erro ao sair: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ✅ ABRIR PDF REAL (MANTIDO - salva página automaticamente)
  void _openBook(Map<String, dynamic> book) {
    final bookId = book['id']?.toString() ?? 'unknown';
    final bookTitle = book['title'] ?? 'Livro sem título';
    final filePath = book['file_path'] ?? '';
    
    if (!_readingBooks.containsKey(bookId) || _readingBooks[bookId] == false) {
      _markAsReading(bookId);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          book: book,
          initialPage: 0,
          onProgressUpdate: (progress) {
            // ✅ SALVAR PROGRESSO QUANDO ATUALIZADO (funcionalidade mantida)
            if (bookId != 'unknown') {
              BookService.saveReadingProgress(bookId, progress);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book, int index) {
    final bookId = book['id']?.toString() ?? 'unknown';
    final currentProgress = _readingProgress[bookId] ?? 0;
    final isReading = _readingBooks[bookId] ?? false;
    final isFinished = currentProgress >= 95;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isFinished 
                  ? const Color(0xFF4CAF50).withOpacity(0.1) 
                  : isReading 
                    ? const Color(0xFF2196F3).withOpacity(0.1)
                    : const Color(0xFF9E9E9E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isFinished 
                    ? const Color(0xFF4CAF50)
                    : isReading 
                      ? const Color(0xFF2196F3)
                      : const Color(0xFF9E9E9E),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.book,
                color: isFinished 
                  ? const Color(0xFF4CAF50)
                  : isReading 
                    ? const Color(0xFF2196F3)
                    : const Color(0xFF9E9E9E),
                size: 30,
              ),
            ),
            if (isReading || isFinished)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFinished ? Icons.check_circle : Icons.play_arrow,
                    color: isFinished ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book['title']?.toString() ?? 'Título não disponível',
              style: const TextStyle(
                color: Color(0xFF424242),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'por ${book['author']?.toString() ?? 'Autor desconhecido'}',
              style: const TextStyle(
                color: Color(0xFF757575),
                fontSize: 14,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // ✅ REMOVIDA A PORCENTAGEM DE PROGRESSO
            // ✅ APENAS INDICADOR VISUAL SIMPLES
            Row(
              children: [
                Icon(
                  isFinished ? Icons.check_circle : Icons.book,
                  size: 16,
                  color: isFinished 
                    ? const Color(0xFF4CAF50)
                    : isReading 
                      ? const Color(0xFF2196F3)
                      : const Color(0xFF9E9E9E),
                ),
                const SizedBox(width: 4),
                Text(
                  isFinished ? 'Concluído' : (isReading ? 'Em leitura' : 'Não lido'),
                  style: TextStyle(
                    color: isFinished 
                      ? const Color(0xFF4CAF50)
                      : isReading 
                        ? const Color(0xFF2196F3)
                        : const Color(0xFF9E9E9E),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Color(0xFF2196F3), size: 24),
              onPressed: () => _openBook(book),
              tooltip: 'Ler livro',
            ),
            // ✅ BOTÃO DE EXCLUIR SÓ APARECE PARA USUÁRIOS LOGADOS
            FutureBuilder<bool>(
              future: AuthService.hasSavedSession(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                    onPressed: () => _deleteBook(book),
                    tooltip: 'Excluir livro',
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
        onTap: () => _openBook(book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Biblioteca', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF424242),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _showSearch, tooltip: 'Buscar'),
          // ✅ BOTÃO SAIR SÓ APARECE PARA USUÁRIOS LOGADOS
          FutureBuilder<bool>(
            future: AuthService.hasSavedSession(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return IconButton(
                  icon: const Icon(Icons.logout), 
                  onPressed: _handleLogout, 
                  tooltip: 'Sair'
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // ✅ REMOVIDOS OS FILTROS "LENDO", "NÃO LIDOS", "CONCLUÍDOS"
          // ✅ APENAS BARRA DE BUSCA MANTIDA

          // ✅ RESUMO SIMPLES DE LEITURA (apenas contagem total)
          if (_books.isNotEmpty) ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total de Livros', _books.length.toString(), Icons.library_books, const Color(0xFF424242)),
                ],
              ),
            ),
          ],

          // ✅ LISTA DE LIVROS
          Expanded(
            child: _isLoading
                ? _buildLoadingWidget()
                : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : _filteredBooks.isEmpty
                        ? _buildEmptyWidget()
                        : RefreshIndicator(
                            onRefresh: _loadBooks,
                            backgroundColor: Colors.white,
                            color: const Color(0xFF424242),
                            child: ListView.builder(
                              itemCount: _filteredBooks.length,
                              itemBuilder: (context, index) => _buildBookCard(_filteredBooks[index], index),
                            ),
                          ),
          ),
        ],
      ),
      // ✅ FLOATING ACTION BUTTON CONDICIONAL
      floatingActionButton: FutureBuilder<bool>(
        future: AuthService.hasSavedSession(),
        builder: (context, snapshot) {
          // ✅ MOSTRA APENAS SE USUÁRIO ESTÁ LOGADO
          if (snapshot.data == true) {
            return FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/upload').then((_) => _loadBooks()),
              backgroundColor: const Color(0xFF424242),
              child: const Icon(Icons.add),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: _BookSearchDelegate(_books, _openBook),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF424242))),
          SizedBox(height: 16),
          Text('Carregando sua biblioteca...', style: TextStyle(color: Color(0xFF757575))),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadBooks,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF424242), foregroundColor: Colors.white),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_rounded, size: 80, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),
          const Text('Nenhum livro encontrado', style: TextStyle(color: Color(0xFF757575), fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ? 'Tente alterar a busca' : 'Adicione seu primeiro livro!',
            style: const TextStyle(color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 24),
          // ✅ BOTÃO ADICIONAR SÓ APARECE PARA USUÁRIOS LOGADOS
          FutureBuilder<bool>(
            future: AuthService.hasSavedSession(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/upload').then((_) {
                    _loadBooks();
                  }),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF424242), foregroundColor: Colors.white),
                  child: const Text('Adicionar Livro'),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _BookSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> books;
  final Function(Map<String, dynamic>) onBookSelected;

  _BookSearchDelegate(this.books, this.onBookSelected);

  @override List<Widget> buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override Widget buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  @override Widget buildResults(BuildContext context) => _buildSearchResults();
  @override Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = books.where((book) {
      final title = (book['title'] ?? '').toString().toLowerCase();
      final author = (book['author'] ?? '').toString().toLowerCase();
      return title.contains(query.toLowerCase()) || author.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final book = results[index];
        return ListTile(
          leading: const Icon(Icons.book, color: Color(0xFF424242)),
          title: Text(book['title']?.toString() ?? 'Título não disponível'),
          subtitle: Text('por ${book['author']?.toString() ?? 'Autor desconhecido'}'),
          onTap: () { onBookSelected(book); close(context, null); },
        );
      },
    );
  }
}