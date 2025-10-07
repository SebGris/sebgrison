[💫 boîte à outils pour vous aider à démarrer avec le développement piloté par les spécifications](https://github.com/github/spec-kit)

[Guide complet](https://github.com/github/spec-kit/blob/main/spec-driven.md)

# ⚡ Get started

## Étape 1
Utilisez l'outil directement :

```bash
specify init <PROJECT_NAME>
specify check
```

### Fichier important : constitution.md
Emplacement du fichier : `PROJECT_NAME\.specify\memory\constitution.md`

## Étape 2
Allez dans le dossier du projet.
```bash
cd PROJECT_NAME
dir
```
Devrait afficher `date heure <DIR>          .claude`

Lancer Claude Code.
```bash
claude
```

## Étape 3 : Établir les principes du projet
Demandez à Claude de renseigner le fichier `constitution.md`.
Tapez ce texte :

```
Mon projet est de réaliser une application Python autonome (qui peut fonctionner sans avoir Python installé sur le poste) qui analyse des fichiers Excel pour créer des fichiers texte d'écriture comptable. Peux-tu modifier le fichier @.specify\memory\constitution.md avec ce que tu penses être le plus adapté à mon projet.
```

## Étape 4 : Créez la spécification
Utilisez la commande `/speckit.specify` pour décrire ce que vous souhaitez générer. Concentrez-vous sur le quoi et le pourquoi, pas sur la pile technologique.
Exemple de spécification :
```bash
/speckit.specify Créez une application qui m'aide à organiser mes photos dans des albums photo distincts. Les albums sont regroupés par date et peuvent être réorganisés par glisser-déposer sur la page principale. Les albums ne sont jamais imbriqués dans d'autres albums. Dans chaque album, les photos sont prévisualisées dans une interface de type mosaïque.
```
Spécification pour le programme de facturation :
```
Voici deux fichiers de contexte pour la commande /specify que je détaillerai ensuite : @Ficher_entrée_ASCII_dans_QuadraCOMPTA.pdf @Exemple_7738_Facturation_Salaires_202508.txt
```

```bash
/speckit.specify Système de transformation de données de facturation de salaires depuis Excel vers format ASCII QuadraCOMPTA.

Le système traite des fichiers Excel contenant des données de refacturation de salaires entre établissements et génère trois types de structures de sortie organisées différemment.

**Entités principales** :
- **Établissements** : identifiés par un code à 4 chiffres (ex: 7716, 7004, 7702). Pour les comptes comptables, on utilise les 3 derniers chiffres (716, 004, 702)
- **Salariés** : nom, prénom, répartition de rémunération entre établissements
- **Écritures comptables** : montants, codes analytiques, comptes de débit/crédit, dates

**Structure des données source Excel** :
- Feuille nommée "Feuille6" contenant les lignes de facturation
- Colonnes nécessaires : Établissement origine, Nom salarié, Établissement(s) destination(s), Pourcentage(s) refacturé(s), Montants par nature de charge
- Codes analytiques à 6 chiffres visibles dans les lignes "Pour X % de sa rémunération" (ex: "700401-CRESCENDO MARTIN MPDC" → code analytique = 700401)

**Système de regroupement des charges** :
Les écritures Excel sont trop détaillées. Le système doit regrouper les charges de même nature avant de générer les écritures comptables :

| Compte racine | Comptes à regrouper |
|---------------|---------------------|
| 63110 | 63110, 63130 |
| 63331 | 63331, 63341 |
| 64111 | 64111, 64133, 64141, 64148, 64190 |
| 64511 | 64511, 64520, 64531, 64533, 64534 |
| 647211 | 64721, 64781, 64783 |
| 648000 | 64811 |

**Système de refacturation bidirectionnel** :
Les comptes comptables ont une longueur fixe de 8 chiffres (complétés par des zéros à droite si besoin).

- **Refacturation ÉMISE (suffixe 3)** - pour l'établissement qui facture :
  - Compte débit : `1851XXX1` où XXX = 3 derniers chiffres de l'établissement destination
  - Compte crédit : `{racine_compte}3` où racine_compte provient du regroupement (ex: 631100003 pour les charges du groupe 63110)

- **Refacturation REÇUE (suffixe 2)** - pour l'établissement qui reçoit la facture :
  - Compte débit : `{racine_compte}2` où racine_compte provient du regroupement (ex: 631100002)
  - Compte crédit : `1851XXX1` où XXX = 3 derniers chiffres de l'établissement origine

**Organisation des fichiers de sortie en 3 structures parallèles** :

1. **Par établissement et nom de salarié** : 
   - Arborescence : `{code_étab_4chiffres}/{nom_salarié}/{fichier}.txt`
   - Nom du fichier : `{code_4chiffres}_RefacSalaire_{nom}_{AAAAMM}.txt`
   - Usage : traçabilité individuelle par salarié

2. **Par mois** :
   - Arborescence : `AAAA MM/{fichier}.txt`
   - Nom du fichier : `{code_4chiffres}_Facturation_Salaires_{AAAAMM}.txt`
   - Contenu : consolidation mensuelle de tous les salariés d'un établissement
   - Usage : import mensuel en comptabilité

3. **Par année** :
   - Nom du fichier : `{code_4chiffres}_Facturation_Salaires.txt` (SANS période dans le nom)
   - Contenu : fusion de tous les mois de l'année
   - Usage : vue consolidée annuelle, clôture d'exercice

**Format de sortie ASCII QuadraCOMPTA** :
- Ligne M (Mouvement) : 146 caractères en longueur fixe
- Ligne I (Analytique) : suit chaque ligne M d'un compte de charge
- Montants exprimés en centimes sans décimales (ex: 150,50 € → 15050)
- Dates au format JJMMAA
- Numéro de pièce : "Claude" suivi du mois sur 2 chiffres (ex: "Claude07" pour juillet)
- Codes analytiques sur 10 caractères maximum
- Option d'anonymisation RGPD des noms de salariés
- **Référence technique** : voir le document `Fichier_entrée_ASCII_dans_QuadraCOMPTA.pdf` pour les spécifications détaillées du format et `Exemple_7738_Facturation_Salaires_202508.txt`

**Règles de gestion** :
- Génération automatique et simultanée des fichiers ÉMIS et REÇUS (système bidirectionnel complet)
- Pas d'ordre chronologique requis : les écritures sont empilées séquentiellement
- Intégrité stricte des blocs (chaque ligne M doit être suivie de sa ligne I pour les comptes de charges)
- Un fichier de sortie par salarié au niveau le plus détaillé, puis consolidations par mois et par année
```

## Étape 4 bis : facultative ou old ?

```
Analyse le fichier @specs/001---/spec.md et clarifie tous les points qui demandent à l'être en décidant de ce qui est le plus raisonnable et adapté dans l'intérêt du projet.
```

## Étape 5 : Créez un plan de mise en œuvre technique
Utilisez la commande `/speckit.plan` pour fournir votre pile technologique et vos choix d’architecture.
Exemple de plan :
```bash
/speckit.plan L'application utilise Vite avec un nombre minimal de bibliothèques. Utilisez autant que possible le HTML, le CSS et le JavaScript classiques. Les images ne sont téléchargées nulle part et les métadonnées sont stockées dans une base de données SQLite locale.
```
Plan pour le programme de facturation :
```bash
/speckit.plan Application Python autonome distribuable comme exécutable standalone.

**Stack technique** :
- Python 3.11 ou supérieur
- pandas pour la lecture des fichiers Excel (.xlsx)
- PyInstaller pour créer l'exécutable standalone (pas besoin de Python installé sur le poste utilisateur)
- pathlib pour la gestion des chemins de fichiers multi-plateformes

**Architecture de l'application** :
- Architecture en couches avec séparation claire :
  - Couche lecture : extraction des données depuis Excel
  - Couche métier : regroupement des comptes, calculs, génération des écritures bidirectionnelles
  - Couche écriture : formatage ASCII et création des fichiers de sortie
  - Couche orchestration : gestion des trois structures de sortie parallèles
- Gestion des erreurs et logging pour traçabilité du traitement
```

## Étape 6 : Décomposez en tâches
Utilisez `/speckit.tasks` pour créer une liste de tâches exploitables à partir de votre plan de mise en œuvre.

```bash
/speckit.tasks
```

## Étape 7 : Exécuter la mise en œuvre
Utilisez `/speckit.implement` pour exécuter toutes les tâches et construire votre fonctionnalité selon le plan.

```bash
/speckit.implement
```