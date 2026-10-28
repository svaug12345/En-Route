# Démarrer le projet En Route ! avec Claude Code

## 1. Préparer le dossier

1. Dézippe ce kit dans `Bureau\Projets\android\en_route`.
2. Tu dois obtenir :

```
en_route/
├── CLAUDE.md              ← le cahier des charges, relu par Claude Code à chaque session
├── DEMARRAGE.md           ← ce fichier
├── CHANGELOG.md           ← l'historique des versions
└── assets/
    ├── brand/             ← logos SV (sv-mark, sv-icon, sv-icon-dark)
    └── data/              ← les cartes des 3 jeux (JSON inclus dans l'appli)
        └── sheets/        ← les mêmes cartes en CSV, à importer dans le Google Sheet
```

## 2. Créer le dépôt GitHub

Crée un dépôt vide `svaug12345/en-route` (sans README, Claude Code s'occupera du reste).

## 3. Premier message à Claude Code

Ouvre un terminal dans `Bureau\Projets\android\en_route`, lance Claude Code et colle :

> Lis CLAUDE.md. Crée le projet Flutter dans ce dossier (sans écraser CLAUDE.md, CHANGELOG.md ni le dossier assets), avec l'identifiant com.svaug.en_route, puis réalise le jalon 0.1.0. Télécharge les polices Manrope et JetBrains Mono depuis Google Fonts dans assets/fonts. Initialise Git, relie le dépôt github.com/svaug12345/en-route et pousse. Explique-moi ce que tu as fait.

Ensuite, jalon par jalon :

> Jalon suivant (0.2.0). Explique-moi les nouveaux concepts.

## 4. Le Google Sheet (au jalon 0.8.0)

1. Crée un Google Sheet « APP - En Route - BDD » avec 3 onglets : `espion`, `mots_interdits`, `bruitages`.
2. Dans chaque onglet : Fichier → Importer → `assets/data/sheets/<onglet>.csv` → « Remplacer la feuille actuelle ».
3. Fichier → Partager → Publier sur le Web → choisir l'onglet → format CSV → copier l'URL. Faire de même pour chaque onglet.
4. Donne les 3 URL à Claude Code.

Pour ajouter des cartes : une ligne de plus dans l'onglet, avec un `id` nouveau, `actif` = `oui`, `niveau` de 1 à 3. Les rôles de l'Espion sont séparés par des `;`.
