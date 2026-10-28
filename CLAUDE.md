# En Route ! — jeux d'ambiance pass and play pour la voiture

> Ce fichier est relu par Claude Code au début de chaque session.
> Il décrit le projet, les règles de travail et la feuille de route.
> Nom de travail : **En Route !** (modifiable : voir « Changer le nom » en bas).

---

## 1. Le projet en deux phrases

Une appli Android (Flutter) qui regroupe plusieurs **jeux d'ambiance où l'on se passe le téléphone**, pensés pour jouer **en voiture** en famille.
On regarde l'écran quelques secondes, puis on joue surtout **à voix haute**.

- **Public** : une famille de 5 — deux adultes et trois enfants de 8, 11 et 14 ans. Les règles doivent être compréhensibles par un enfant de 8 ans.
- **Téléphone de test** : Poco F8 (Android), branché en USB sur un PC Windows.
- **Développeur** : Sébastien (pseudo GitHub `svaug12345`). Il apprend Flutter en construisant ses applis : **il doit comprendre le code**.

---

## 2. Règles de travail (à respecter à chaque modification)

1. **Code très commenté, en français.** Chaque fichier commence par un commentaire qui dit à quoi il sert. Chaque classe, chaque méthode non triviale et chaque bloc un peu subtil est expliqué simplement (le *pourquoi*, pas seulement le *quoi*).
2. **Expliquer ce qu'on fait.** À la fin de chaque étape, résumer en quelques phrases ce qui a été fait et le concept Flutter/Dart appris (ex. « un `StatefulWidget` garde un état qui change… »).
3. **Incrémenter la version à CHAQUE mise à jour** dans `pubspec.yaml` (`version: X.Y.Z+N`) :
   - correctif → `Z` + 1 ; nouvelle fonctionnalité ou nouveau jeu → `Y` + 1 ; le build `N` augmente **toujours** de 1 ;
   - ajouter une ligne dans `CHANGELOG.md` (date, version, ce qui change) ;
   - la version est affichée dans l'écran « À propos ».
4. **Avant chaque commit** : `flutter analyze` sans erreur, et `flutter test` si des tests existent.
5. **Git** : un commit par étape, message clair en français (`feat: jeu Bruitage`, `fix: chrono qui ne s'arrête pas`). Dépôt GitHub `svaug12345/en-route` : Sébastien veut pouvoir reprendre le projet depuis n'importe quel PC, donc on **pousse régulièrement**.
6. **Simple d'abord.** Pas de dépendance si quelques lignes de Dart suffisent. Pas d'architecture « usine à gaz » : le code doit rester lisible par un débutant motivé.
7. **Avancer par petites étapes testables** sur le téléphone (`flutter run`), et demander validation avant de passer au jalon suivant.
8. **Tout le texte de l'interface est en français**, en tutoiement, phrases courtes (voir le ton de la charte SV, §7).

---

## 3. Choix techniques

| Sujet | Choix | Pourquoi |
|---|---|---|
| Framework | Flutter (canal stable), Dart | Déjà installé et utilisé pour Agent Double |
| Plateforme | Android uniquement, `minSdk 24` | Toute la famille est sur Android |
| Identifiant | `com.svaug.en_route` | Même convention que `com.svaug.agent_double` |
| État de l'appli | `provider` + `ChangeNotifier` | Le plus simple à comprendre pour débuter |
| Stockage local | `shared_preferences` (réglages, joueurs) + fichiers JSON via `path_provider` (cartes en cache) | Pas besoin d'une base de données |
| Réseau | `http` (téléchargement des cartes depuis Google Sheets) | Une seule requête simple |
| Écran allumé | `wakelock_plus` pendant une partie | En voiture, l'écran ne doit pas se mettre en veille au milieu d'un chrono |
| Logo | `flutter_svg` | Les logos SV sont en SVG |
| Polices | **Embarquées** dans `assets/fonts/` (Manrope, JetBrains Mono, depuis Google Fonts) | Pas de réseau en voiture → pas de `google_fonts` en téléchargement |
| Vibrations | `HapticFeedback` (inclus dans Flutter) | Fin de chrono, vote révélé |

Agent Double reste **une appli à part** (déjà sur le Play Store). Plus tard, le jeu « Le Mot Secret » pourra reprendre son principe ici sans toucher à son code.

---

## 4. Architecture : des briques communes, des jeux qui les assemblent

```
lib/
├── main.dart                  # Point d'entrée : thème SV, provider, écran d'accueil
├── theme/
│   └── sv_theme.dart          # Couleurs, polices, espacements de la charte SV (clair + sombre)
├── models/                    # Données pures (aucun widget)
│   ├── joueur.dart            # Un joueur : id, prénom, couleur, avatar (emoji ou initiale)
│   ├── carte.dart             # Classe de base d'une carte (id, niveau, actif)
│   └── partie.dart            # Joueurs de la partie en cours, scores, manche
├── services/
│   ├── joueurs_service.dart   # Sauvegarde/chargement des joueurs (shared_preferences)
│   ├── cartes_service.dart    # Charge les cartes : cache → assets ; synchro Google Sheet
│   └── tirage_service.dart    # Tire des cartes au hasard sans répétition (pioche + défausse)
├── widgets/                   # LES BRIQUES RÉUTILISABLES
│   ├── passe_telephone.dart   # « Passe le téléphone à Gaby » → appui long → contenu secret → cacher
│   ├── chrono.dart            # Compte à rebours géant, vibration à la fin, pause
│   ├── vote.dart              # Chaque joueur vote à son tour, en secret, puis révélation
│   ├── tableau_scores.dart    # Scores de la partie
│   ├── gros_bouton.dart       # Bouton plein écran style SV (label en capitales)
│   └── selection_joueurs.dart # Choisir qui joue (parmi les joueurs enregistrés)
├── jeux/
│   ├── jeu.dart               # Description d'un jeu : nom, icône, joueurs min/max, règles courtes, écran
│   ├── catalogue.dart         # LA liste des jeux affichés à l'accueil (ajouter un jeu = une ligne ici)
│   ├── espion/                # Un dossier par jeu : écrans + logique propres à ce jeu
│   ├── mots_interdits/
│   └── bruitage/
└── ecrans/
    ├── accueil.dart           # Grille des jeux + accès joueurs, réglages, à propos
    ├── joueurs.dart           # Créer / modifier / supprimer les joueurs
    ├── reglages.dart          # Thème, difficulté, vibrations, synchro des cartes
    └── a_propos.dart          # Logo SV, version, crédits
```

**Principe clé** : un jeu ne réécrit jamais une brique. S'il lui manque quelque chose, on améliore la brique dans `widgets/` pour que tous les jeux en profitent.

### Les briques en détail

- **Joueurs** : créés une fois, réutilisés dans tous les jeux et d'une partie à l'autre. Chaque joueur a une couleur (prise dans la charte) pour qu'on le reconnaisse d'un coup d'œil. Avant chaque partie : cocher qui joue (3 à 8 joueurs selon le jeu) ; l'ordre de passage peut être mélangé.
- **Passe le téléphone** : écran neutre avec le prénom en très gros et la couleur du joueur → le joueur **maintient** le bouton pour voir son contenu secret (on relâche = c'est caché, comme ça personne ne voit par-dessus l'épaule) → bouton « J'ai vu » → joueur suivant.
- **Paquets de cartes** : chaque jeu a son paquet. Les cartes ont un **niveau** (1 facile / 2 moyen / 3 difficile). Le tirage évite les répétitions tant que le paquet n'est pas épuisé (mémorisé entre les parties).
- **Chrono** : chiffres énormes (police JetBrains Mono), couleur qui passe à `danger` dans les 10 dernières secondes, vibration courte à 10 s et longue à 0.
- **Vote** : chacun vote en secret via « Passe le téléphone », puis écran de révélation avec le décompte.
- **Scores** : points par joueur ou par équipe, affichés entre les manches ; remis à zéro à chaque nouvelle partie.

---

## 5. Les jeux de la v1

### 5.1 L'Espion du trajet (3 à 8 joueurs)

Adaptation de Spyfall.

1. On choisit les joueurs, le niveau, et l'option **« avec rôles »** (activée par défaut : aide les plus jeunes).
2. L'appli tire un **lieu** et désigne un **espion** au hasard.
3. **Passe le téléphone** : chaque joueur voit soit « 📍 Lieu : Piscine — Ton rôle : maître-nageur », soit « 🕵️ Tu es l'espion ! Trouve le lieu sans te faire repérer ».
4. Écran de jeu : chrono (5 min par défaut, réglable 3–8 min) + rappel de la règle + **liste de tous les lieux possibles** (utile à l'espion, et ça rend le jeu plus juste) + qui commence à poser une question (tiré au hasard).
5. Fin : bouton « On vote » (brique Vote) ou « L'espion se dévoile » (il choisit un lieu dans la liste).
6. Révélation et points : espion démasqué → 1 point à chaque non-espion ; espion non démasqué ou qui trouve le lieu → 2 points à l'espion.

Données : `assets/data/espion_lieux.json` (lieu, niveau, emoji, rôles).

### 5.2 Trois mots interdits (2 équipes, ou chacun pour soi)

1. Mode **équipes** (ex. avant / arrière) ou **chacun pour soi**.
2. Le joueur actif reçoit le téléphone : **chrono 60 s**, une carte à la fois : le mot à faire deviner en gros, les 3 mots interdits dessous.
3. Boutons : ✅ **Trouvé** (+1), ⏭️ **Passer** (0), ❌ **Mot interdit dit** (−1 ou 0 selon réglage). Le voisin surveille.
4. Fin du chrono → récap des cartes de la manche → téléphone au joueur suivant.
5. Option **handicap** : les adultes ont un 4e mot interdit (champ `bonus` de la carte).

Données : `assets/data/mots_interdits.json` (mot, 3 interdits, 1 bonus, niveau).

### 5.3 Bruitage (2 joueurs et plus)

1. Le joueur actif voit une carte « Fais deviner : **une poule qui vient de pondre** » — **uniquement avec des sons**, pas de mots.
2. Chrono 30 s par carte (réglable), ou mode **Chrono** : 60 s pour en faire deviner le plus possible.
3. Le joueur qui devine le premier : on tape son prénom → 1 point pour lui et 1 point pour le bruiteur.
4. Variantes (réglages du jeu) : **bouche fermée**, **en duo** (2 joueurs bruitent ensemble).

Données : `assets/data/bruitages.json` (texte, niveau).

---

## 6. Les cartes : fichiers inclus + Google Sheet

**Principe « hors ligne d'abord »** : l'appli doit être 100 % jouable sans réseau.

1. Les fichiers JSON de `assets/data/` sont **inclus dans l'appli** : ils servent de paquet de base.
2. Si du réseau est disponible (bouton « Mettre à jour les cartes » dans Réglages, et une fois par jour au démarrage), l'appli télécharge les cartes depuis un **Google Sheet publié en CSV**, les valide et les enregistre en **cache** (fichier JSON dans le stockage de l'appli).
3. Au lancement : cache s'il existe et est valide, sinon cartes incluses. Si le téléchargement échoue : on garde l'ancien cache, sans bloquer le joueur (message discret).

**Google Sheet** « APP - En Route - BDD », un onglet par jeu (mêmes colonnes que les fichiers `assets/data/sheets/*.csv`, à importer pour démarrer) :

| Onglet | Colonnes |
|---|---|
| `espion` | `id, actif, niveau, emoji, lieu, roles` (rôles séparés par `;`) |
| `mots_interdits` | `id, actif, niveau, mot, interdit1, interdit2, interdit3, bonus` |
| `bruitages` | `id, actif, niveau, texte` |

- `actif` = `oui`/`non` : désactiver une carte sans la supprimer.
- Publication : Fichier → Partager → Publier sur le Web → onglet → CSV. Les URL sont mises dans `lib/services/cartes_service.dart` (constantes commentées).
- Une ligne mal remplie est **ignorée** (et comptée dans un petit rapport de synchro), elle ne fait jamais planter l'appli.

---

## 7. Charte graphique SV

L'appli porte la marque perso **SV** (logo « le geste », fichiers dans `assets/brand/`).

**Couleurs** (à mettre dans `sv_theme.dart`, thème clair ET sombre) :

| Token | Clair | Sombre | Usage |
|---|---|---|---|
| `surface` | `#f6f9f9` | `#0e1a1c` | Fond d'écran |
| `surfaceRaised` | `#ffffff` | `#152427` | Cartes, panneaux |
| `line` | `#d6e2e3` | `#26393c` | Bordures 1px |
| `ink` | `#102a2e` | `#e6f1f1` | Texte principal |
| `inkMuted` | `#4d6468` | `#9db3b5` | Texte secondaire |
| `teal` | `#0f7c7b` | `#3cc2b8` | Couleur de marque, boutons principaux |
| `onTeal` | `#ffffff` | `#062022` | Texte sur `teal` |
| `tealDeep` | `#0b4f55` | `#1d6b6e` | Bandeaux, écran de lancement |
| `tealSoft` | `#d4ecea` | `#1c4245` | Zones mises en avant, sélection |
| `accent` | `#20b2a6` | `#5fe0d2` | Décoratif uniquement (jamais de texte sur fond clair) |
| `blue` | `#1f5f8b` | `#6fb0dd` | Information |
| `danger` | `#b23a34` | `#f0857f` | Erreur, chrono qui se termine, mot interdit |

**Polices** : Manrope (titres 700–800, texte 400) ; JetBrains Mono pour les chiffres (chronos, scores, version). Boutons en capitales espacées (`JOUER`, `MANCHE SUIVANTE`).
**Espacements** : 4 / 8 / 16 / 24 / 32 / 48 px. **Arrondis** : 6 px (badges), 12 px (boutons, cartes).
**Ton** : tutoiement, phrases courtes, une règle = une phrase. Pas de points d'exclamation partout.
**Signature SV** : `sv-icon.svg` comme base de l'icône d'appli (ou icône propre avec le geste en petit en bas à droite) ; `sv-mark.svg` sur l'écran de lancement (~1 s) et dans « À propos ».

Chaque jeu peut avoir **sa couleur d'accent** (prise dans la palette) pour sa tuile à l'accueil, mais l'interface commune reste SV.

---

## 8. Contraintes « voiture »

- **Lisible en un coup d'œil** : textes de jeu ≥ 28 px, boutons hauts d'au moins 64 px, tout faisable d'une main.
- **Mode sombre par défaut le soir** (suivre le réglage du téléphone, avec un choix forcé dans Réglages) pour ne pas éblouir le conducteur.
- **Écran toujours allumé** pendant une partie (`wakelock_plus`), relâché en sortant du jeu.
- **Peu d'écran** : le jeu se passe à voix haute ; l'écran sert à distribuer les rôles, tenir le chrono et compter les points.
- **Reprise** : si l'appli passe en arrière-plan (appel, GPS), la partie en cours reprend où elle en était (chrono en pause).
- **Aucun son obligatoire**, vibrations désactivables.

---

## 9. Feuille de route (jalons)

Chaque jalon = une version testée sur le Poco F8, commitée et poussée.

| Version | Jalon |
|---|---|
| 0.1.0 | Projet Flutter créé, thème SV clair/sombre, polices embarquées, écran d'accueil avec 3 tuiles (inactives), écran À propos avec version et logo |
| 0.2.0 | Gestion des joueurs (créer, modifier, supprimer, sauvegarde) + sélection des joueurs avant une partie |
| 0.3.0 | Briques : Passe le téléphone, Chrono, Gros bouton (+ un écran de démo pour les tester) |
| 0.4.0 | Chargement des cartes depuis `assets/data/` + tirage sans répétition |
| 0.5.0 | Jeu **Bruitage** jouable de bout en bout |
| 0.6.0 | Jeu **Trois mots interdits** (équipes, chrono, score) |
| 0.7.0 | Brique Vote + jeu **L'Espion du trajet** |
| 0.8.0 | Synchro Google Sheet + cache hors ligne + rapport de synchro |
| 0.9.0 | Finitions : écran de lancement SV, icône, reprise après arrière-plan, wakelock, réglages |
| 1.0.0 | Version famille : APK installé sur les téléphones, puis test fermé Play Console |

### Jeux prévus ensuite (même briques)

Le Menteur, Le Tribunal, Tu préfères… ?, Devine qui je suis, Histoire à relais, Chasse au trésor de la route, Le Juste Kilomètre, Le Mot Secret (principe Agent Double).
**Ajouter un jeu** = un dossier dans `lib/jeux/`, un paquet de cartes, une ligne dans `catalogue.dart`.

---

## 10. Commandes utiles (rappel pour Sébastien)

```bash
flutter pub get          # installe les dépendances listées dans pubspec.yaml
flutter analyze          # cherche les erreurs et les mauvaises pratiques
flutter run              # lance l'appli sur le téléphone branché (r = recharger, R = redémarrer)
flutter build apk --release   # fabrique l'APK à installer
```

## Changer le nom

Le nom affiché est centralisé dans `lib/main.dart` (constante `nomAppli`) et dans `android/app/src/main/AndroidManifest.xml` (`android:label`). L'identifiant `com.svaug.en_route` ne doit plus changer une fois l'appli envoyée sur le Play Store.
