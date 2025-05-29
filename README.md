# 📖 Bibliapp

**Bibliapp** é um aplicativo cristão desenvolvido em **Flutter** com o objetivo de te aproximar mais da Palavra de Deus através de:

- 📅 Devocionais diários
- 📚 Leitura bíblica simples e eficiente
- 📝 Destaques, anotações e favoritos nos versículos
- 🎧 Áudios e reflexões para fortalecer a fé

---

## ✨ Funcionalidades

- **Leitura da Bíblia NVI** com navegação por livro, capítulo e versículo
- **Devocionais diários automáticos** gerados com inteligência artificial
- **Destaques personalizados**, com cores, notas e favoritos
- **Modo noturno**, **modo aleatório (shuffle)** e **modo de escuta noturna**
- **Player de áudios devocionais**
- **Sincronização com Firebase e Supabase** (dados e favoritos salvos na nuvem)
- **Versículos lado a lado** (duas versões simultâneas - em desenvolvimento)

---

## 📱 Imagens do App

> *Por enquanto em produção, pois, o APP ainda está em construção!*


---

## ⚙️ Tecnologias Utilizadas

- **Flutter** + Dart
- **Firebase** (Autenticação, Firestore, Storage)
- **Supabase** (Dados do usuário e destaques)
- **Bolls.life API** (Conteúdo bíblico NVI)
- **Google Drive** (para áudios devocionais)
- **Pipedream / GPT** (para geração dos devocionais)

---

## 🚀 Como Instalar

1. Clone o repositório:

```bash
git clone https://github.com/seuusuario/bibliapp.git
cd bibliapp
````
2. Instale as dependências:
```bash
flutter pub get
````

3. Rode o app:
```bash
flutter run
````
Certifique-se de ter o Flutter SDK instalado: https://docs.flutter.dev/get-started/install

## 📁 Estrutura de Pastas 
```bash
lib/
├── services/          # Integrações com Firebase, Supabase e APIs
├── pages/             # Telas principais do app
├── widgets/           # Componentes reutilizáveis
├── models/            # Modelos de dados como Livro, Versículo etc.
├── utils/             # Utilitários como formatação de datas e cores
└── main.dart          # Ponto de entrada do app
````

## 🧪 Testes
Atualmente sem cobertura de testes. Futuramente serão adicionados testes unitários e de integração.

## 🤝 Contribuindo
Contribuições são bem-vindas! Abra uma issue ou envie um pull request.

## 📄 Licença
Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.
