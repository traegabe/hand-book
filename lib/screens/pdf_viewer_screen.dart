import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import '../services/book_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final Map<String, dynamic>? book;
  final int initialPage;
  final Function(int)? onProgressUpdate;

  const PdfViewerScreen({
    super.key,
    this.book,
    this.initialPage = 0,
    this.onProgressUpdate,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  bool _hasLoadedSavedProgress = false;
  final TextEditingController _pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage + 1;
    _loadPdf();
    _loadSavedProgress();
  }

  // ✅ CARREGAR PROGRESSO SALVO - ATUALIZADO
  Future<void> _loadSavedProgress() async {
    if (widget.book != null) {
      final bookId = widget.book!['id']?.toString();
      if (bookId != null && bookId != 'unknown') {
        try {
          final progressData = await BookService.getReadingProgressData(bookId);
          if (progressData != null && mounted) {
            final savedPage = (progressData['current_page'] ?? 0) + 1; // +1 porque SfPdfViewer usa 1-based
            final totalPages = progressData['total_pages'] ?? 0;
            
            print('📖 Progresso salvo carregado: Página $savedPage, Total: $totalPages');
            
            setState(() {
              _currentPage = savedPage;
              _totalPages = totalPages;
            });

            // ✅ IR PARA PÁGINA SALVA SE EXISTIR
            if (savedPage > 1 && _pdfViewerController.pageCount > 0) {
              await Future.delayed(const Duration(milliseconds: 1000));
              _pdfViewerController.jumpToPage(savedPage);
              print('🎯 Indo para página salva: $savedPage');
            }
          }
        } catch (e) {
          print('❌ Erro ao carregar progresso salvo: $e');
        }
      }
    }
  }

  void _loadPdf() async {
    try {
      final filePath = widget.book?['file_path'];
      if (filePath != null && File(filePath).existsSync()) {
        setState(() => _isLoading = false);
        
        await Future.delayed(const Duration(milliseconds: 1500));
        _restoreSavedPage();
      } else {
        setState(() => _isLoading = false);
        print('❌ Arquivo PDF não encontrado: $filePath');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Erro ao carregar PDF: $e');
    }
  }

  void _restoreSavedPage() async {
    if (_hasLoadedSavedProgress) return;
    
    try {
      final bookId = widget.book?['id']?.toString();
      if (bookId != null && bookId != 'unknown') {
        final savedProgress = await BookService.getReadingProgress(bookId);
        print('📖 Buscando progresso salvo: $savedProgress%');
        
        if (savedProgress > 0) {
          for (int i = 0; i < 5; i++) {
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (_pdfViewerController.pageCount > 0) {
              final totalPages = _pdfViewerController.pageCount;
              final pageFromProgress = ((savedProgress / 100) * totalPages).round();
              final targetPage = pageFromProgress.clamp(1, totalPages);
              
              print('🎯 Restaurando para página $targetPage de $totalPages');
              
              setState(() {
                _currentPage = targetPage;
                _totalPages = totalPages;
                _hasLoadedSavedProgress = true;
              });
              
              _pdfViewerController.jumpToPage(targetPage);
              break;
            }
            
            if (i == 4) print('⚠️ Não conseguiu carregar total de páginas após 5 tentativas');
          }
        } else {
          print('📖 Nenhum progresso salvo encontrado');
        }
      }
    } catch (e) {
      print('❌ Erro ao restaurar página salva: $e');
    }
  }

  // ✅ SALVAR PROGRESSO QUANDO MUDAR PÁGINA
  void _onPageChanged(PdfPageChangedDetails details) {
    final int newPage = details.newPageNumber;
    final int totalPages = _pdfViewerController.pageCount;
    
    setState(() {
      _currentPage = newPage;
      _totalPages = totalPages;
    });

    if (!_hasLoadedSavedProgress && totalPages > 0) {
      _restoreSavedPage();
    }

    final progress = _calculateProgress(newPage, totalPages);
    _saveCurrentPage(newPage, progress);

    if (widget.onProgressUpdate != null) {
      widget.onProgressUpdate!(progress);
    }
    
    print('📄 Página $newPage/$totalPages - Progresso: $progress%');
  }

  // ✅ SALVAR PÁGINA ATUAL NO BANCO
  Future<void> _saveCurrentPage(int page, int progress) async {
    if (widget.book != null) {
      final bookId = widget.book!['id']?.toString();
      if (bookId != null && bookId != 'unknown') {
        try {
          await BookService.saveReadingProgressWithPage(
            bookId, 
            progress, 
            page - 1,
            _totalPages
          );
          print('💾 Página salva: $page/$_totalPages - $progress%');
        } catch (e) {
          print('❌ Erro ao salvar página: $e');
        }
      }
    }
  }

  // ✅ OBTER TOTAL DE PÁGINAS QUANDO PDF CARREGAR
  void _onPdfLoaded() {
    if (!mounted) return;
    
    final totalPages = _pdfViewerController.pageCount;
    if (totalPages > 0) {
      setState(() {
        _totalPages = totalPages;
      });
      
      if (_currentPage > 0 && totalPages > 0) {
        final progress = _calculateProgress(_currentPage, totalPages);
        widget.onProgressUpdate?.call(progress);
        _saveCurrentPage(_currentPage, progress);
      }
    }
  }

  // ✅ MANTIDO para cálculo interno
  int _calculateProgress(int currentPage, int totalPages) {
    if (totalPages == 0) return 0;
    
    double rawProgress = (currentPage / totalPages) * 100;
    int progress = rawProgress.round();
    
    if (currentPage >= totalPages) {
      progress = 100;
    }
    
    return progress.clamp(0, 100);
  }

  void _showJumpToPageDialog() {
    _pageController.text = _currentPage.toString();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ir para página'),
        content: TextField(
          controller: _pageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Digite o número da página (1-$_totalPages)',
            labelText: 'Página',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final pageText = _pageController.text.trim();
              if (pageText.isNotEmpty) {
                final page = int.tryParse(pageText);
                if (page != null && page >= 1 && page <= _totalPages) {
                  _jumpToPage(page);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Página inválida! Digite entre 1 e $_totalPages'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Ir'),
          ),
        ],
      ),
    );
  }

  void _jumpToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _pdfViewerController.jumpToPage(page);
      setState(() {
        _currentPage = page;
      });
      
      final progress = _calculateProgress(page, _totalPages);
      _saveCurrentPage(page, progress);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📖 Indo para página $page'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // ✅ LAYOUT MELHORADO DO LEITOR PDF
  Widget _buildPdfViewer() {
    final filePath = widget.book?['file_path'];
    
    return Container(
      color: Colors.grey[900], // Fundo escuro para melhor contraste
      child: InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 5.0,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(8), // ✅ MENOR MARGEM
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SfPdfViewer.file(
              File(filePath!),
              controller: _pdfViewerController,
              onPageChanged: _onPageChanged,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                _onPdfLoaded();
              },
              pageLayoutMode: PdfPageLayoutMode.single,
              canShowScrollHead: false,
              canShowScrollStatus: false,
              pageSpacing: 0,
              scrollDirection: PdfScrollDirection.vertical,
              interactionMode: PdfInteractionMode.pan,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookTitle = widget.book?['title'] ?? 'PDF Sem Título';
    final filePath = widget.book?['file_path'];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bookTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              _totalPages > 0 
                ? 'Página $_currentPage de $_totalPages'
                : 'Carregando...',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF424242),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '$_currentPage/${_totalPages > 0 ? _totalPages : "?"}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _totalPages > 0 ? _showJumpToPageDialog : null,
            tooltip: 'Ir para página',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF424242)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Carregando PDF...',
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                ],
              ),
            )
          : filePath != null && File(filePath).existsSync()
              ? Column(
                  children: [
                    // ✅ Barra de progresso mantida (visual apenas)
                    LinearProgressIndicator(
                      value: _totalPages > 0 ? _currentPage / _totalPages : 0,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                      minHeight: 2,
                    ),
                    Expanded(
                      child: _buildPdfViewer(), // ✅ CHAMADA DO LAYOUT MELHORADO
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'PDF não encontrado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Caminho: ${filePath ?? "N/A"}',
                        style: const TextStyle(
                          color: Color(0xFF757575),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF424242),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Voltar'),
                      ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    final progress = _calculateProgress(_currentPage, _totalPages);
    _saveCurrentPage(_currentPage, progress);
    print('🚪 Saindo - Página final: $_currentPage/$_totalPages ($progress%)');
    
    _pageController.dispose();
    super.dispose();
  }
}