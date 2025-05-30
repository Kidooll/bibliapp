import 'package:flutter/material.dart';
import 'package:bibliapp/styles/styles.dart';

class BibleVerseTile extends StatelessWidget {
  final String verseText;
  final int verseNumber;
  final VoidCallback onHighlightPressed;
  final VoidCallback onComparePressed;
  final double textSize;
  final Color? highlightColor;

  const BibleVerseTile({
    super.key,
    required this.verseText,
    required this.verseNumber,
    required this.onHighlightPressed,
    required this.onComparePressed,
    required this.textSize,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: highlightColor,
        borderRadius: BorderRadius.circular(8),
        border: highlightColor != null
            ? Border.all(color: highlightColor!.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onHighlightPressed,
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
          ),
          IconButton(
            icon: Icon(
              Icons.compare_arrows,
              color: Colors.blueGrey,
              size: 24,
            ),
            onPressed: onComparePressed,
            tooltip: 'Comparar versículos',
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
