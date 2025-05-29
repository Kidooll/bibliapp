import 'package:flutter/material.dart';
import 'package:bibliapp/styles/styles.dart';

class BibleVerseTile extends StatelessWidget {
  final String verseText;
  final int verseNumber;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onComparePressed;
  final double textSize;
  final Color? highlightColor;

  const BibleVerseTile({super.key, 
    required this.verseText,
    required this.verseNumber,
    this.isFavorite = false,
    required this.onFavoritePressed,
    required this.onComparePressed,
    required this.textSize,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(8),
      decoration: isFavorite
          ? BoxDecoration(
            color: highlightColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$verseNumber ',
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: textSize,
                    ),
                  ),
                  TextSpan(
                    text: verseText,
                    style: TextStyle(
                      color: AppStyles.textBrownDark,
                      fontSize: textSize,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.orange : Colors.grey,
            ),
            onPressed: onFavoritePressed,
          ),
          IconButton(
            icon: Icon(Icons.compare_arrows, color: Colors.blueGrey),
            onPressed: onComparePressed,
          ),
        ],
      ),
    );
  }
}
