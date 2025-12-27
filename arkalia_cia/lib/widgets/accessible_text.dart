import 'package:flutter/material.dart';
import '../services/accessibility_service.dart';

/// Widget Text qui applique automatiquement les paramètres d'accessibilité
/// Utilise AccessibilityService pour ajuster la taille du texte selon les préférences utilisateur
class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextDirection? textDirection;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final double? textScaleFactor;

  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textDirection,
    this.locale,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AccessibilityTextSize>(
      future: AccessibilityService.getTextSize(),
      builder: (context, snapshot) {
        final textSize = snapshot.data ?? AccessibilityTextSize.normal;
        final baseFontSize = style?.fontSize ?? 14.0;
        final adjustedFontSize = baseFontSize * textSize.multiplier;
        
        // S'assurer que la taille minimale est respectée (14px minimum)
        final finalFontSize = adjustedFontSize < 14.0 ? 14.0 : adjustedFontSize;

        return Text(
          text,
          style: style?.copyWith(fontSize: finalFontSize) ?? TextStyle(fontSize: finalFontSize),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
          textDirection: textDirection,
          locale: locale,
          strutStyle: strutStyle,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          textScaleFactor: textScaleFactor,
        );
      },
    );
  }
}

