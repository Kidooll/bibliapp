import 'package:bibliapp/widgets/loading_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../styles/styles.dart';




class CitacaoTela extends StatelessWidget {
  final String imagemUrl;
  final String citacao;
  final String autor;

  const CitacaoTela({
    super.key,
    required this.imagemUrl,
    required this.citacao,
    required this.autor,
  });



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: imagemUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppStyles.accentBrown,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppStyles.accentBrown,
                child: const Icon(Icons.error_outline, color: Colors.red),
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  citacao,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  autor,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontStyle: FontStyle.italic),
                ),
                const Spacer(),
                ],
              ),
            ),
          ),

        // Botões Inferiores
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {/* Compartilhar */},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryGreen,
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('COMPARTILHAR', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.3),
                    ),
                    child: const Text('VOLTAR', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // Logo
          Positioned(
            top: 30,            
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.9,
              child: Image.asset('assets/logo.png', width: 60, height: 60),
            ),
          ),
        ],
      ),
    );
  }
}