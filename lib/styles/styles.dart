import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AppStyles {
  // ================ CORES ================
  static const Color backgroundColor = Color(0xFFF1FFFD);
  static const Color primaryGreen = Color(0xFF1F4549);
  static const Color accentBrown = Color(0xFFD1BEBE);
  static const Color textBrownDark = Color(0xFF1F4549);
  static const Color borderColor = Color(0xFF1F4549);
  static const Color avatarBackground = Color(0xFFFFE1CC);
  static const Color testamentButtonActive = Color(0xFFF3E9D7);
  static const Color dialogBackground = Color(0xFFF1FFFD);
  static const Color verseHighlight = Color(0xFFf1fffd);
  static const Color diaryHighlight = Color(0xFFFFF5E6);
  static const Color pinColor = Color(0xFF1F4549);
  static const Color accentColor = Color(0xFF81C784);
  static const double sectionIndicatorSize = 8.0;
  static const Color sectionIndicatorActive = primaryGreen;
  static const Color sectionIndicatorInactive = Color(0xFFD3D3D3);
  static const Color textMutedBrown = Color(0xFF1F4549);

  static const Color missionProgress = Color(0xFFF1FFFD);
  static const Color calendarDay = Color(0xFF6B4F3A);

  // ================ TEMA PRINCIPAL ================
  static ThemeData mainTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: accentColor,
      background: backgroundColor,
    ),
    fontFamily: 'Merriweather, Trocchi',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: primaryGreen,
      ),
      displayMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: primaryGreen,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textBrownDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: textBrownDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textBrownDark,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textBrownDark,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
    ),
  );

  // ================ DECORAÇÕES ================
  static final BoxDecoration bookTileDecoration = BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: borderColor, width: 1),
    boxShadow: const [bookTileShadow],
  );

  static final BoxDecoration verseHeaderDecoration = BoxDecoration(
    color: verseHighlight,
    borderRadius: BorderRadius.circular(10),
    boxShadow: const [defaultShadow],
  );

  static final BoxDecoration chapterTileDecoration = BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderColor, width: 1),
  );

  static final BoxDecoration searchBarDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
  );

  static BoxDecoration testamentButtonDecoration(bool isActive) =>
      BoxDecoration(
        color: isActive ? primaryGreen : testamentButtonActive,
        borderRadius: BorderRadius.circular(24),
      );

  static final BoxDecoration diaryCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [diaryCardShadow],
  );

  // ================ SOMBRAS ================
  static const BoxShadow defaultShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow bookTileShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 4,
    offset: Offset(2, 2),
  );

  static const BoxShadow diaryCardShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 8,
    offset: Offset(2, 2),
  );



  // ================ BANNER ================
  static const TextStyle bannerTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 20,
  fontWeight: FontWeight.bold,
  shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
  );

  // ================ FORMULÁRIOS ================
  static final InputDecoration diaryInputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.all(16),
  );

  // ================ BOTÕES ================
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: backgroundColor,
    foregroundColor: primaryGreen,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Colors.transparent),
    ),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  );

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  );

  static final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryGreen,
    side: BorderSide(color: primaryGreen),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  );

  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: primaryGreen,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  );

  // ================ CAMPOS DE TEXTO ================
  static final InputDecoration textFieldDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.all(16),
  );

  static final InputDecoration searchFieldDecoration = InputDecoration(
    hintText: 'Pesquisar...',
    prefixIcon: Icon(Icons.search, color: primaryGreen),
    filled: true,
    fillColor: backgroundColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.all(16),
  );

  // ================ CARDS ================
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [defaultShadow],
  );

  static final BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [diaryCardShadow],
  );

  // ================ ESPAÇAMENTOS ================
  static const EdgeInsets defaultPadding = EdgeInsets.all(16);
  static const EdgeInsets tilePadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  // ================ ANIMAÇÕES ================
  static const Duration animationDuration = Duration(milliseconds: 375);
  static const double animationVerticalOffset = 50.0;

  static const BoxShadow boxShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static Widget slideAnimation(Widget child) => SlideAnimation(
        verticalOffset: animationVerticalOffset,
        child: FadeInAnimation(child: child),
      );

  static Widget slideDialogAnimation(Widget child) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: animationDuration,
      child: SlideAnimation(
        verticalOffset: animationVerticalOffset,
        child: FadeInAnimation(child: child),
      ),
    );
  }

  static AnimationConfiguration staggeredAnimation(int index, Widget child) =>
      AnimationConfiguration.staggeredGrid(
        position: index,
        columnCount: 1,
        duration: animationDuration,
        delay: const Duration(milliseconds: 100),
        child: SlideAnimation(
          verticalOffset: animationVerticalOffset,
          child: FadeInAnimation(
            child: child,
          ),
        ),
      );

  static Widget fadeSlideAnimation(Widget child, {double verticalOffset = 50.0}) {
    return SlideAnimation(
      verticalOffset: verticalOffset,
      child: FadeInAnimation(child: child),
    );
  }

  static Widget staggeredListAnimation(Widget child, int index) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: animationDuration,
      child: fadeSlideAnimation(child),
    );
  }

  static Widget staggeredGridAnimation(Widget child, int index) {
    return AnimationConfiguration.staggeredGrid(
      position: index,
      columnCount: 1,
      duration: animationDuration,
      delay: const Duration(milliseconds: 100),
      child: fadeSlideAnimation(child),
    );
  }

  // ================ FONTES ================

  static const double baseFontSize = 16.0;
  static const double fontSizeStep = 2.0;

  // ================ INPUT DECORATION ================
  InputDecoration customInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade700),
      filled: true,
      fillColor: Colors.grey.shade200,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }
}