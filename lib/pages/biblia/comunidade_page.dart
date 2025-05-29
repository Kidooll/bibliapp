// comunidade_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../styles/styles.dart';

class ComunidadePage extends StatefulWidget {
  // ignore: use_super_parameters
  const ComunidadePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ComunidadePageState createState() => _ComunidadePageState();
}

class _ComunidadePageState extends State<ComunidadePage> {
  List<Contact> contatos = [];
  List<Contact> contatosFiltrados = [];
  bool isLoading = true;
  final List<String> usuariosApp = [
    '+5582988251040',
    '+5582993893138',
    '+558282203260',
    '+558230306696',
    '+5582994026589',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      buscarContatos();
    });
  }

  Future<void> buscarContatos() async {
    setState(() => isLoading = true);
    if (!await FlutterContacts.requestPermission()) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final allContacts =
          await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        contatos = allContacts;
        contatosFiltrados = contatos;
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar contatos: $e");
      setState(() => isLoading = false);
    }
  }

  void filtrarContatos(String value) {
    setState(() {
      contatosFiltrados = contatos.where((c) {
        final nome = c.displayName.toLowerCase();
        final telefone = c.phones.isNotEmpty ? c.phones.first.number : '';
        return nome.contains(value.toLowerCase()) || telefone.contains(value);
      }).toList();
    });
  }

  bool isUsuarioApp(String? telefone) {
    if (telefone == null) return false;
    final t = telefone.replaceAll(RegExp(r'[^0-9+]'), '');
    return usuariosApp
        .any((u) => t.endsWith(u.replaceAll(RegExp(r'[^0-9+]'), '')));
  }

  void convidarWhatsApp(String telefone) async {
    final url =
        'https://wa.me/${telefone.replaceAll(RegExp(r'[^0-9]'), '')}?text=Oi!%20Venha%20fazer%20parte%20da%20comunidade%20do%20app!';
    if (await canLaunch(url)) await launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppStyles.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            Text('COMUNIDADE', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppStyles.primaryGreen))
          : Column(
              children: [
                Padding(
                  padding: AppStyles.defaultPadding,
                  child: TextField(
                    autofocus: false,
                    focusNode: FocusNode(canRequestFocus: false),
                    decoration: InputDecoration(
                      hintText: 'Procurar companheiros',
                      prefixIcon:
                          Icon(Icons.search, color: AppStyles.primaryGreen),
                      filled: true,
                      fillColor: AppStyles.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: filtrarContatos,
                  ),
                ),
                Padding(
                  padding: AppStyles.defaultPadding,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [AppStyles.boxShadow],
                    ),
                    child: ListTile(
                      leading: Icon(Icons.share, color: AppStyles.primaryGreen),
                      title: Text('Convidar por Link',
                          style: Theme.of(context).textTheme.bodyMedium),
                      onTap: () =>
                          Share.share('Baixe nosso app: [LINK_DA_PLAY_STORE]'),
                    ),
                  ),
                ),
                Expanded(
                  child: AnimationLimiter(
                    child: ListView.builder(
                      itemCount: contatosFiltrados.length,
                      itemBuilder: (context, index) =>
                          AnimationConfiguration.staggeredList(
                        position: index,
                        duration: AppStyles.animationDuration,
                        child: SlideAnimation(
                          verticalOffset: AppStyles.animationVerticalOffset,
                          child: FadeInAnimation(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppStyles.avatarBackground,
                                child: Text(
                                  contatosFiltrados[index]
                                          .displayName
                                          .isNotEmpty
                                      ? contatosFiltrados[index]
                                          .displayName[0]
                                          .toUpperCase()
                                      : '?',
                                  style:
                                      TextStyle(color: AppStyles.primaryGreen),
                                ),
                              ),
                              title: Text(contatosFiltrados[index].displayName,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              subtitle: Text(
                                  contatosFiltrados[index].phones.isNotEmpty
                                      ? contatosFiltrados[index]
                                          .phones
                                          .first
                                          .number
                                      : '',
                                  style:
                                      Theme.of(context).textTheme.labelSmall),
                              trailing:
                                  _buildActionButton(contatosFiltrados[index]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionButton(Contact contato) {
    final telefone =
        contato.phones.isNotEmpty ? contato.phones.first.number : '';
    return isUsuarioApp(telefone)
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryGreen,
                foregroundColor: Colors.white),
            onPressed: () {},
            child: Text('ADICIONAR'),
          )
        : OutlinedButton(
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppStyles.primaryGreen)),
            onPressed: () => convidarWhatsApp(telefone),
            child: Text('CONVIDAR',
                style: TextStyle(color: AppStyles.primaryGreen)),
          );
  }
}
