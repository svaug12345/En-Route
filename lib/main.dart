// main.dart — point d'entrée de l'appli « En Route ! ».
//
// C'est le premier code exécuté au lancement : il crée l'application,
// lui donne le thème SV (clair et sombre) et affiche l'écran d'accueil.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ecrans/accueil.dart';
import 'services/joueurs_service.dart';
import 'theme/sv_theme.dart';

/// Nom affiché de l'appli. Pour le changer, modifier aussi `android:label`
/// dans android/app/src/main/AndroidManifest.xml (voir CLAUDE.md « Changer le nom »).
const String nomAppli = 'En Route !';

/// `main()` est la fonction que Dart appelle en premier.
/// `runApp` prend le widget racine et le dessine à l'écran.
void main() {
  runApp(
    // ChangeNotifierProvider « pose » le JoueursService tout en haut de l'appli :
    // n'importe quel écran en dessous peut le retrouver avec
    // context.watch<JoueursService>() ou context.read<JoueursService>().
    // `..charger()` : on crée le service puis on lance tout de suite le
    // chargement des joueurs sauvegardés (les `..` appellent une méthode
    // sur l'objet et renvoient l'objet lui-même).
    ChangeNotifierProvider(
      create: (_) => JoueursService()..charger(),
      child: const EnRouteApp(),
    ),
  );
}

/// Le widget racine de l'appli.
///
/// C'est un `StatelessWidget` : il ne garde aucune donnée qui change.
/// Il se contente de décrire l'appli (titre, thèmes, premier écran).
class EnRouteApp extends StatelessWidget {
  const EnRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: nomAppli,
      debugShowCheckedModeBanner: false, // Enlève le bandeau « DEBUG » en haut à droite.
      theme: SvTheme.clair,
      darkTheme: SvTheme.sombre,
      // ThemeMode.system : suit le réglage clair/sombre du téléphone.
      // (Un choix forcé arrivera dans l'écran Réglages, jalon 0.9.0.)
      themeMode: ThemeMode.system,
      home: const Accueil(),
    );
  }
}
