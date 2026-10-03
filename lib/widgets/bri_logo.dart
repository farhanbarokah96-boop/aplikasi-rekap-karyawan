import 'package:flutter/material.dart';

enum BriLogoTheme {
  blueOnWhite, // Kotak Putih dengan Teks BRI Biru Navy (Desain Asli)
  whiteOnNavy,  // Kotak Biru Navy dengan Teks BRI Putih
}

/// Widget Logo BRI yang bersih, rapi, dan responsif (Tanpa CustomPainter berbelit-belit).
class BriLogo extends StatelessWidget {
  final double size;
  final BriLogoTheme logoTheme;

  const BriLogo({
    super.key,
    this.size = 64,
    this.logoTheme = BriLogoTheme.blueOnWhite,
  });

  @override
  Widget build(BuildContext context) {
    Color boxColor;
    Color textColor;

    switch (logoTheme) {
      case BriLogoTheme.blueOnWhite:
        boxColor = Colors.white;
        textColor = const Color(0xFF0C447C); // AppColors.navy
        break;
      case BriLogoTheme.whiteOnNavy:
        boxColor = const Color(0xFF0C447C);
        textColor = Colors.white;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'BRI',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.36,
            letterSpacing: size * 0.03,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}
