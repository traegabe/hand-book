import 'package:flutter/material.dart';
import 'services/supabase_config.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/library_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/register_screen.dart';
import 'screens/pdf_viewer_screen.dart';
import 'screens/guest_welcome_screen.dart'; // ✅ ADICIONAR IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  print('✅ Supabase inicializado com sucesso!');
  runApp(const HandBookApp());
}

class HandBookApp extends StatelessWidget {
  const HandBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hand Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      // ✅ ROTA INICIAL COM VERIFICAÇÃO DE LOGIN - MODIFICADO
      home: FutureBuilder<bool>(
        future: AuthService.hasSavedSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          
          // ✅ SE TEM LOGIN → Biblioteca completa
          if (snapshot.data == true) {
            return const LibraryScreen();
          } else {
            // ✅ SE NÃO TEM LOGIN → Tela de convidado
            return const GuestWelcomeScreen();
          }
        },
      ),
      // ✅ ROTAS ATUALIZADAS
      routes: {
        '/guest_welcome': (context) => const GuestWelcomeScreen(), // ✅ ADICIONAR ROTA
        '/login': (context) => const LoginScreen(),
        '/library': (context) => const LibraryScreen(),
        '/upload': (context) => const UploadScreen(),
        '/register': (context) => const RegisterScreen(),
        '/pdf_viewer': (context) {
          final routeArgs = ModalRoute.of(context)?.settings.arguments;
          
          if (routeArgs is Map<String, dynamic>) {
            return PdfViewerScreen(
              book: routeArgs['book'],
              initialPage: routeArgs['initialPage'] ?? 0,
              onProgressUpdate: routeArgs['onProgressUpdate'],
            );
          } else {
            return const PdfViewerScreen(book: null);
          }
        },
      },
    );
  }
}

// ✅ TELA DE CARREGAMENTO INICIAL (mantida igual)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF757575),
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Hand Book',
              style: TextStyle(
                color: Color(0xFF424242),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF424242)),
            ),
          ],
        ),
      ),
    );
  }
}