import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/livro.dart';
import '../../providers/biblia_provider.dart';
import '../../styles/styles.dart';

class BookTile extends StatelessWidget {
  final Livro book;

  const BookTile({Key? key, required this.book}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BibliaProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FFFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppStyles.borderColor, width: 1),
      ),
      child: ListTile(
        title: Text(
          book.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () => provider.openChaptersModal(context, book.toJson()),
      ),
    );
  }
}
