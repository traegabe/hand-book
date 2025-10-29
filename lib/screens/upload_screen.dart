import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/book_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  String? _fileName;
  String? _filePath;
  bool _isLoading = false;

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _fileName = result.files.single.name;
          _filePath = result.files.single.path!;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ PDF selecionado: $_fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao selecionar arquivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadBook() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📖 Digite o título do livro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✍️ Digite o nome do autor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📄 Selecione um arquivo PDF'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final bookData = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'file_name': _fileName,
        'file_path': _filePath,
        'file_size': '0',
        'description': 'Livro adicionado via Hand Book App',
        'reading_progress': 0,
      };
      
      await BookService.addBook(bookData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Livro adicionado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        _titleController.clear();
        _authorController.clear();
        setState(() {
          _fileName = null;
          _filePath = null;
        });
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = '❌ Erro ao adicionar livro';
        
        if (e.toString().contains('PGRST204')) {
          errorMessage = '❌ Erro no banco de dados. Configure a tabela books no Supabase.';
        } else if (e.toString().contains('row-level security')) {
          errorMessage = '❌ Erro de permissão. Configure as políticas RLS.';
        } else {
          errorMessage = '❌ Erro: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearFile() {
    setState(() {
      _fileName = null;
      _filePath = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Adicionar Livro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF424242),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TÍTULO
            const Text(
              'Título do Livro',
              style: TextStyle(
                color: Color(0xFF424242),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Color(0xFF424242)),
                decoration: const InputDecoration(
                  hintText: 'Ex: Dom Casmurro',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // AUTOR
            const Text(
              'Autor',
              style: TextStyle(
                color: Color(0xFF424242),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: TextFormField(
                controller: _authorController,
                style: const TextStyle(color: Color(0xFF424242)),
                decoration: const InputDecoration(
                  hintText: 'Ex: Machado de Assis',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ARQUIVO PDF - SOLUÇÃO DEFINITIVA
            const Text(
              'Arquivo PDF',
              style: TextStyle(
                color: Color(0xFF424242),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // SOLUÇÃO: Remover completamente o BorderStyle.dashed
            _fileName == null
                ? Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      // SOLUÇÃO: Usar apenas borda sólida para evitar problemas
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 2,
                        // REMOVIDO: style: BorderStyle.dashed - causa problemas
                      ),
                    ),
                    child: TextButton(
                      onPressed: _pickPDF,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF757575),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, size: 40, color: Color(0xFF9E9E9E)),
                          SizedBox(height: 8),
                          Text(
                            'Clique para selecionar PDF',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Color(0xFF4CAF50), size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _fileName!,
                                style: const TextStyle(
                                  color: Color(0xFF424242),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _filePath!,
                                style: const TextStyle(
                                  color: Color(0xFF757575),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: _clearFile,
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 32),

            // BOTÃO ADICIONAR
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _uploadBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF424242),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Adicionar à Biblioteca',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}