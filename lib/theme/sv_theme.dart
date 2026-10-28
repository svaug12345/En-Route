// sv_theme.dart — la charte graphique SV traduite en code Flutter.
//
// On y trouve :
//   - SvCouleurs : les 12 couleurs de la charte (une version claire, une sombre) ;
//   - SvEspace / SvArrondi : les espacements et arrondis autorisés ;
//   - SvTheme.clair / SvTheme.sombre : les deux ThemeData complets utilisés par l'appli.
//
// Règle d'or : aucun écran n'écrit une couleur en dur (Color(0xFF...)).
// Il demande toujours la couleur au thème : `context.sv.teal`.
// Comme ça, le passage clair ↔ sombre marche partout automatiquement.

import 'package:flutter/material.dart';

/// Les couleurs de la charte SV (CLAUDE.md §7).
///
/// C'est une `ThemeExtension` : un moyen officiel d'ajouter NOS propres
/// valeurs au thème Flutter. Material ne connaît pas « tealSoft » ou
/// « inkMuted » ; avec une extension, on les range dans le thème et chaque
/// écran peut les retrouver avec `Theme.of(context).extension<SvCouleurs>()`.
@immutable
class SvCouleurs extends ThemeExtension<SvCouleurs> {
  const SvCouleurs({
    required this.surface,
    required this.surfaceRaised,
    required this.line,
    required this.ink,
    required this.inkMuted,
    required this.teal,
    required this.onTeal,
    required this.tealDeep,
    required this.tealSoft,
    required this.accent,
    required this.blue,
    required this.danger,
  });

  final Color surface; // Fond d'écran
  final Color surfaceRaised; // Cartes, panneaux
  final Color line; // Bordures 1 px
  final Color ink; // Texte principal
  final Color inkMuted; // Texte secondaire
  final Color teal; // Couleur de marque, boutons principaux
  final Color onTeal; // Texte posé sur du teal
  final Color tealDeep; // Bandeaux, écran de lancement
  final Color tealSoft; // Zones mises en avant, sélection
  final Color accent; // Décoratif uniquement (jamais de texte sur fond clair)
  final Color blue; // Information
  final Color danger; // Erreur, chrono qui se termine, mot interdit

  /// Palette du thème clair.
  static const clair = SvCouleurs(
    surface: Color(0xFFF6F9F9),
    surfaceRaised: Color(0xFFFFFFFF),
    line: Color(0xFFD6E2E3),
    ink: Color(0xFF102A2E),
    inkMuted: Color(0xFF4D6468),
    teal: Color(0xFF0F7C7B),
    onTeal: Color(0xFFFFFFFF),
    tealDeep: Color(0xFF0B4F55),
    tealSoft: Color(0xFFD4ECEA),
    accent: Color(0xFF20B2A6),
    blue: Color(0xFF1F5F8B),
    danger: Color(0xFFB23A34),
  );

  /// Palette du thème sombre (le soir, pour ne pas éblouir le conducteur).
  static const sombre = SvCouleurs(
    surface: Color(0xFF0E1A1C),
    surfaceRaised: Color(0xFF152427),
    line: Color(0xFF26393C),
    ink: Color(0xFFE6F1F1),
    inkMuted: Color(0xFF9DB3B5),
    teal: Color(0xFF3CC2B8),
    onTeal: Color(0xFF062022),
    tealDeep: Color(0xFF1D6B6E),
    tealSoft: Color(0xFF1C4245),
    accent: Color(0xFF5FE0D2),
    blue: Color(0xFF6FB0DD),
    danger: Color(0xFFF0857F),
  );

  // Les deux méthodes ci-dessous sont exigées par ThemeExtension.
  // copyWith : créer une variante en changeant seulement quelques couleurs.
  // lerp : mélanger deux palettes (Flutter s'en sert pour animer en douceur
  // le passage du thème clair au thème sombre).

  @override
  SvCouleurs copyWith({
    Color? surface,
    Color? surfaceRaised,
    Color? line,
    Color? ink,
    Color? inkMuted,
    Color? teal,
    Color? onTeal,
    Color? tealDeep,
    Color? tealSoft,
    Color? accent,
    Color? blue,
    Color? danger,
  }) {
    return SvCouleurs(
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      line: line ?? this.line,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      teal: teal ?? this.teal,
      onTeal: onTeal ?? this.onTeal,
      tealDeep: tealDeep ?? this.tealDeep,
      tealSoft: tealSoft ?? this.tealSoft,
      accent: accent ?? this.accent,
      blue: blue ?? this.blue,
      danger: danger ?? this.danger,
    );
  }

  @override
  SvCouleurs lerp(SvCouleurs? other, double t) {
    if (other == null) return this;
    // Color.lerp(a, b, t) : t = 0 → couleur a, t = 1 → couleur b, entre les deux → mélange.
    return SvCouleurs(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      line: Color.lerp(line, other.line, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
      onTeal: Color.lerp(onTeal, other.onTeal, t)!,
      tealDeep: Color.lerp(tealDeep, other.tealDeep, t)!,
      tealSoft: Color.lerp(tealSoft, other.tealSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

/// Raccourci pour écrire `context.sv.teal` au lieu de
/// `Theme.of(context).extension<SvCouleurs>()!.teal`.
///
/// Une « extension » Dart ajoute des méthodes à une classe existante
/// (ici BuildContext) sans la modifier.
extension SvContexte on BuildContext {
  SvCouleurs get sv => Theme.of(this).extension<SvCouleurs>()!;
}

/// Les seuls espacements autorisés par la charte (en pixels logiques).
class SvEspace {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Les arrondis de la charte.
class SvArrondi {
  static const double badge = 6;
  static const double carte = 12; // Boutons et cartes
}

/// Noms des polices embarquées (déclarées dans pubspec.yaml).
class SvPolice {
  static const String texte = 'Manrope';
  static const String chiffres = 'JetBrainsMono';
}

/// Les couleurs des joueurs : une par joueur, pour le reconnaître d'un coup d'œil.
///
/// La charte n'a que 4 couleurs vives (teal, bleu, rouge, accent) : trop peu
/// pour 8 joueurs. On garde donc teal, bleu et rouge de la charte, et on ajoute
/// 5 teintes de même intensité. Chacune existe en version claire et sombre,
/// comme le reste de la charte.
///
/// Un joueur enregistre seulement le *numéro* de sa couleur (0 à 7) : la vraie
/// couleur est choisie au moment de dessiner, selon le thème.
class SvCouleursJoueurs {
  static const List<String> noms = [
    'Teal', 'Bleu', 'Rouge', 'Orange', 'Violet', 'Vert', 'Rose', 'Ocre',
  ];

  static const List<Color> _clair = [
    Color(0xFF0F7C7B), // teal (charte)
    Color(0xFF1F5F8B), // bleu (charte)
    Color(0xFFB23A34), // rouge = danger (charte)
    Color(0xFFB85A14), // orange
    Color(0xFF6B4FA0), // violet
    Color(0xFF3D7D2F), // vert
    Color(0xFFA83C73), // rose
    Color(0xFF8A6D0F), // ocre
  ];

  static const List<Color> _sombre = [
    Color(0xFF3CC2B8),
    Color(0xFF6FB0DD),
    Color(0xFFF0857F),
    Color(0xFFF2A65A),
    Color(0xFFB49BE6),
    Color(0xFF8FD37A),
    Color(0xFFEC8FC0),
    Color(0xFFE8C95A),
  ];

  /// Nombre de couleurs disponibles.
  static int get nombre => _clair.length;

  /// La couleur n° [index] pour le thème actuel.
  /// Le `%` (reste de la division) évite tout plantage si l'index est trop grand.
  static Color couleur(BuildContext context, int index) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final liste = sombre ? _sombre : _clair;
    return liste[index % liste.length];
  }

  /// Couleur du texte posé sur une couleur de joueur (comme `onTeal`) :
  /// blanc sur les couleurs foncées du thème clair, presque noir sur les
  /// couleurs vives du thème sombre.
  static Color texteSur(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF062022)
          : const Color(0xFFFFFFFF);
}

/// Fabrique les deux thèmes de l'appli à partir des palettes.
class SvTheme {
  static ThemeData get clair => _construire(SvCouleurs.clair, Brightness.light);
  static ThemeData get sombre => _construire(SvCouleurs.sombre, Brightness.dark);

  /// Construit un ThemeData complet pour une palette donnée.
  ///
  /// On remplit aussi le `ColorScheme` de Material : les widgets standards
  /// (AppBar, boutons, interrupteurs…) prennent leurs couleurs dedans.
  /// Sans ça, ils resteraient violets (la couleur par défaut de Material 3).
  static ThemeData _construire(SvCouleurs c, Brightness luminosite) {
    final schema = ColorScheme(
      brightness: luminosite,
      primary: c.teal,
      onPrimary: c.onTeal,
      primaryContainer: c.tealSoft,
      onPrimaryContainer: c.ink,
      secondary: c.blue,
      onSecondary: c.onTeal,
      error: c.danger,
      onError: c.onTeal,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.inkMuted,
      outline: c.line,
      outlineVariant: c.line,
    );

    // Texte de base : Manrope partout, couleur « ink ».
    final texteBase = ThemeData(brightness: luminosite).textTheme.apply(
          fontFamily: SvPolice.texte,
          bodyColor: c.ink,
          displayColor: c.ink,
        );

    // Forme commune des boutons : arrondi 12, au moins 64 px de haut
    // (contrainte « voiture » : on doit pouvoir viser sans regarder longtemps).
    final formeBouton = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SvArrondi.carte),
    );
    const tailleMiniBouton = Size(64, 64);
    const texteBouton = TextStyle(
      fontFamily: SvPolice.texte,
      fontWeight: FontWeight.w800,
      fontSize: 16,
      letterSpacing: 1.5, // Capitales espacées : JOUER, MANCHE SUIVANTE
    );

    return ThemeData(
      useMaterial3: true,
      brightness: luminosite,
      colorScheme: schema,
      scaffoldBackgroundColor: c.surface,
      fontFamily: SvPolice.texte,
      textTheme: texteBase.copyWith(
        headlineLarge: texteBase.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        headlineMedium: texteBase.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        titleLarge: texteBase.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: texteBase.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: SvPolice.texte,
          fontWeight: FontWeight.w800,
          fontSize: 22,
          color: c.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SvArrondi.carte),
          side: BorderSide(color: c.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.teal,
          foregroundColor: c.onTeal,
          minimumSize: tailleMiniBouton,
          shape: formeBouton,
          textStyle: texteBouton,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.teal,
          minimumSize: tailleMiniBouton,
          shape: formeBouton,
          side: BorderSide(color: c.line),
          textStyle: texteBouton,
        ),
      ),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1),
      extensions: [c], // ← c'est ici qu'on range nos couleurs SV dans le thème
    );
  }
}
