// a_propos.dart — l'écran « À propos » : logo SV, nom et version de l'appli,
// crédits (polices, Flutter).
//
// La version est lue automatiquement dans pubspec.yaml grâce au paquet
// package_info_plus : pas besoin de la recopier ici à chaque mise à jour.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../main.dart';
import '../theme/sv_theme.dart';

/// Écran « À propos ».
class APropos extends StatelessWidget {
  const APropos({super.key});

  @override
  Widget build(BuildContext context) {
    final sv = context.sv;
    final texte = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SvEspace.l),
          children: [
            const SizedBox(height: SvEspace.l),
            // Le logo SV « le geste ». Le fichier SVG est dessiné en `currentColor` :
            // on lui donne la couleur teal du thème avec un ColorFilter.
            Center(
              child: SvgPicture.asset(
                'assets/brand/sv-mark.svg',
                width: 96,
                height: 96,
                colorFilter: ColorFilter.mode(sv.teal, BlendMode.srcIn),
                semanticsLabel: 'Logo SV',
              ),
            ),
            const SizedBox(height: SvEspace.l),
            Text(nomAppli, textAlign: TextAlign.center, style: texte.headlineMedium),
            const SizedBox(height: SvEspace.s),
            const Center(child: _Version()),
            const SizedBox(height: SvEspace.l),
            Text(
              'Des jeux pour la voiture. On se passe le téléphone, on joue à voix haute.',
              textAlign: TextAlign.center,
              style: texte.bodyLarge?.copyWith(color: sv.inkMuted),
            ),
            const SizedBox(height: SvEspace.xl),
            const Divider(),
            const SizedBox(height: SvEspace.m),
            _LigneCredit(titre: 'Conception', detail: 'Sébastien · SV'),
            _LigneCredit(titre: 'Polices', detail: 'Manrope et JetBrains Mono (licence SIL OFL)'),
            _LigneCredit(titre: 'Fabriqué avec', detail: 'Flutter'),
          ],
        ),
      ),
    );
  }
}

/// Affiche « Version 0.1.0 (build 1) » en police chiffres.
///
/// Lire la version prend un petit instant (il faut la demander à Android) :
/// `PackageInfo.fromPlatform()` renvoie donc un `Future`, une valeur « promise
/// pour plus tard ». Le `FutureBuilder` affiche d'abord un texte d'attente,
/// puis se redessine tout seul quand la réponse arrive.
class _Version extends StatelessWidget {
  const _Version();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final libelle = info == null
            ? 'Version …'
            : 'Version ${info.version} (build ${info.buildNumber})';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: SvEspace.m, vertical: SvEspace.s),
          decoration: BoxDecoration(
            color: context.sv.tealSoft,
            borderRadius: BorderRadius.circular(SvArrondi.badge),
          ),
          child: Text(
            libelle,
            style: TextStyle(
              fontFamily: SvPolice.chiffres,
              fontSize: 15,
              color: context.sv.ink,
            ),
          ),
        );
      },
    );
  }
}

/// Une ligne de crédit : un petit titre en gris, le détail dessous.
class _LigneCredit extends StatelessWidget {
  const _LigneCredit({required this.titre, required this.detail});

  final String titre;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final texte = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SvEspace.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre.toUpperCase(),
              style: texte.labelMedium?.copyWith(
                color: context.sv.inkMuted,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: SvEspace.xs),
          Text(detail, style: texte.bodyLarge),
        ],
      ),
    );
  }
}
