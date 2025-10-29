import 'package:flutter/material.dart';

class GuestWelcomeScreen extends StatelessWidget {
  const GuestWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Color(0xFF757575), size: 70),
              ),
              
              const SizedBox(height: 32),
              const Text('Hand Book', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
              const SizedBox(height: 8),
              const Text('Sua biblioteca sempre á mão', style: TextStyle(color: Color(0xFF757575), fontSize: 16)),
              const SizedBox(height: 60),
              
              // Botão Convidado
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/library'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF424242), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Entrar como Convidado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Botão Login
              SizedBox(
                width: double.infinity, height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF424242), side: const BorderSide(color: Color(0xFF424242), width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Acesso Premium', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}