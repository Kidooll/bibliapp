import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FeatureImageWidget extends StatelessWidget {
  final String? imageUrl;

  const FeatureImageWidget({
    super.key,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Center(child: Text('Nenhuma imagem disponível'));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: CachedNetworkImageProvider(imageUrl!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
