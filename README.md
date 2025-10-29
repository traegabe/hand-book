# hand_book
A new Flutter project.

# 📚 Hand Book - Biblioteca Digital

![Flutter](https://img.shields.io/badge/Flutter-3.19+-blue)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

Uma aplicação moderna de biblioteca digital desenvolvida em Flutter com Supabase, permitindo leitura de PDFs com salvamento automático de progresso.

## 🎯 Funcionalidades

### 🔐 Autenticação & Acesso
- ✅ **Sistema de convidado** - Visualização sem login
- ✅ **Login/Cadastro** - Autenticação segura com Supabase
- ✅ **Acesso diferenciado** - Convidados veem, usuários logados fazem upload

### 📖 Leitor de PDF
- ✅ **Leitor integrado** - Visualização nativa de PDFs
- ✅ **Salvamento automático** - Volta exatamente onde parou
- ✅ **Navegação por páginas** - Pule para qualquer página
- ✅ **Zoom e pan** - Controles de visualização completos
- ✅ **Progresso visual** - Barra de progresso de leitura

### 🏪 Biblioteca Compartilhada
- ✅ **Upload de livros** - Usuários logados adicionam livros
- ✅ **Biblioteca pública** - Todos os livros visíveis para todos
- ✅ **Controle de acesso** - Apenas dono edita/exclui
- ✅ **Busca inteligente** - Encontre livros por título ou autor

## 🛠️ Tecnologias

- **Flutter 3.19+** - Framework principal
- **Supabase** - Backend como Serviço (BaaS)
- **PostgreSQL** - Banco de dados
- **SfPdfViewer** - Leitor de PDFs
- **Riverpod** - Gerenciamento de estado (opcional)

## 📁 Estrutura do Projeto
lib/
├── screens/
│ ├── guest_welcome_screen.dart # Tela inicial convidado
│ ├── library_screen.dart # Biblioteca principal
│ ├── login_screen.dart # Tela de login
│ ├── register_screen.dart # Tela de cadastro
│ ├── upload_screen.dart # Upload de livros
│ └── pdf_viewer_screen.dart # Leitor de PDF
├── services/
│ ├── auth_service.dart # Gerenciamento de autenticação
│ ├── book_service.dart # Operações com livros
│ ├── supabase_config.dart # Configuração do Supabase
│ └── test_connection.dart # Teste de conexão
└── main.dart # Arquivo principal


## 🚀 Como Executar

### Pré-requisitos
- Flutter 3.19+
- Conta no Supabase
- Android Studio/VSCode

### Configuração

1. Clone o repositório
git clone https://github.com/SEU_USUARIO/hand-book.git
cd hand-book

2. Instale as dependências
flutter pub get

3.Configure o Supabase
Crie um projeto em supabase.com
Execute o SQL do arquivo database/schema.sql
Configure as variáveis no lib/services/supabase_config.dart

4.Execute o app
flutter run

🔧 Configuração do Supabase
Variáveis de Ambiente
// lib/services/supabase_config.dart
class SupabaseConfig {
  static const String url = 'https://seu-projeto.supabase.co';
  static const String anonKey = 'sua-chave-anon-aqui';
}


Estrutura do Banco
-- Tabelas principais:
-- books: Armazena informações dos livros
-- reading_progress: Progresso individual de leitura
-- user_profiles: Perfis de usuários
-- reading_sessions: Histórico de sessões
-- bookmarks: Marcadores de páginas

📊 Funcionalidades Técnicas
Sistema de Progresso
Salvamento automático a cada mudança de página
Restauração precisa ao reabrir o livro
Progresso individual por usuário
Cálculo de porcentagem baseado no total de páginas

Segurança (RLS)
sql
-- Políticas implementadas:
-- SELECT: Todos podem ver livros
-- INSERT: Apenas usuários autenticados
-- UPDATE/DELETE: Apenas dono do livro

🤝 Contribuição
Fork o projeto

Crie uma branch (git checkout -b feature/nova-funcionalidade)
Commit suas mudanças (git commit -m 'Add nova funcionalidade')
Push para a branch (git push origin feature/nova-funcionalidade)
Abra um Pull Request

📝 Licença
Este projeto está sob licença MIT. Veja o arquivo LICENSE para detalhes.

👨‍💻 Autor
Gabriel Lopes - gabriellopescosta2003@gmail.com

🙏 Agradecimentos
Equipe do Flutter

Supabase pelo backend incrível

Syncfusion pelo leitor de PDF


### **ARQUIVOS ADICIONAIS RECOMENDADOS:**

#### **1. `.gitignore`** (se não existir)
```gitignore
# Flutter
.dart_tool/
.packages
.pub-cache/
.pub/
build/
.flutter-plugins
.flutter-plugins-dependencies

# Android
/android/**/gradle-wrapper.jar
/android/.gradle
/android/captures/
/android/gradlew
/android/gradlew.bat
/android/local.properties
/android/**/GeneratedPluginRegistrant.java

# iOS
/ios/**/*.mode1v3
/ios/**/*.mode2v3
/ios/**/*.moved-aside
/ios/**/*.pbxuser
/ios/**/*.perspectivev3
/ios/**/*sync/
/ios/**/.sconsign.dblite
/ios/**/.tags*
/ios/**/.vagrant/
/ios/**/DerivedData/
/ios/**/Icon?
/ios/**/Pods/
/ios/**/.symlinks/

# Environment
.env
.env.*

. LICENSE (opcional - MIT)
text
MIT License

Copyright (c) 2025 Gabriel Lopes


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
