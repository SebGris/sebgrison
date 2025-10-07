# Guide Coverage : Tracer les Tests par Ligne de Code

## 📊 Introduction

Ce guide explique comment identifier précisément quel test couvre quelle ligne de code dans votre application Flask.

## 🔧 Installation des outils

```bash
pip install pytest-cov coverage
```

## 📈 Méthodes de traçage

### Méthode 1 : Rapport HTML Interactif

La méthode la plus visuelle et intuitive.

```bash
# Générer le rapport HTML
pytest --cov=server --cov-report=html

# Ouvrir le rapport (Windows)
start htmlcov/index.html

# Ouvrir le rapport (Mac/Linux)
open htmlcov/index.html
```

**Comment l'utiliser :**
1. Ouvrez `htmlcov/index.html` dans votre navigateur
2. Cliquez sur `server.py`
3. Les lignes vertes sont couvertes par des tests
4. Les lignes rouges ne sont pas testées
5. Survolez une ligne verte pour voir les tests qui l'exécutent

### Méthode 2 : Coverage avec Contextes

Pour un traçage plus détaillé de chaque test.

```bash
# Activer les contextes pour tracer quel test couvre quelle ligne
pytest --cov=server --cov-report=html --cov-context=test

# Ouvrir le rapport enrichi
start htmlcov/index.html
```

### Méthode 3 : Configuration Avancée avec .coveragerc

Créez un fichier `.coveragerc` à la racine du projet :

```ini
[run]
source = .
omit = 
    .venv/*
    tests/*
    */__pycache__/*
dynamic_context = test_function

[report]
exclude_lines =
    if __name__ == .__main__.:
    raise AssertionError
    raise NotImplementedError

[html]
show_contexts = True
```

Puis exécutez :

```bash
# Lancer avec la configuration
coverage run -m pytest tests/
coverage html --show-contexts
start htmlcov/index.html
```

## 📋 Tableau de Correspondance Tests/Lignes

Voici un exemple de correspondance entre les lignes de `server.py` et les tests qui les couvrent :

| Ligne | Fonction | Description | Test qui la couvre |
|-------|----------|-------------|-------------------|
| 24-25 | `index()` | Route principale | `test_homepage` |
| 39 | `index()` | Rendu de index.html | `test_homepage` |
| 42-45 | `showSummary()` | Validation email | `test_valid_email_shows_summary` |
| 47-48 | `showSummary()` | Email invalide | `test_invalid_email_redirects` |
| 57-65 | `book()` | Route de réservation | `test_book_with_valid_entities` |
| 64-65 | `book()` | Entités invalides | `test_book_with_invalid_club` |
| 85 | `book()` | Rendu booking.html | `test_book_with_valid_entities` |
| 101-102 | `purchasePlaces()` | Validation échouée | `test_purchase_places_with_invalid_club` |
| 107-109 | `purchasePlaces()` | ValueError sur places | `test_purchase_with_invalid_number` |
| 126-129 | `validate_booking()` | Compétition passée | `test_cannot_book_past_competition` |
| 159 | `display_points()` | Affichage des points | `test_points_display_shows_all_clubs` |

## 🎯 Commandes Utiles

### Voir uniquement les lignes non couvertes

```bash
pytest --cov=server --cov-report=term-missing
```

Sortie exemple :
```
Name        Stmts   Miss  Cover   Missing
-----------------------------------------
server.py     105     20    81%   39, 64-65, 67-68, 75-85, 102, 107-109
```

### Générer plusieurs formats de rapport

```bash
# Terminal + HTML + XML
pytest --cov=server \
       --cov-report=term \
       --cov-report=html \
       --cov-report=xml
```

### Définir un seuil minimum de couverture

```bash
# Échoue si la couverture est < 80%
pytest --cov=server --cov-fail-under=80
```

## 📊 Interpréter les Résultats

### Codes couleur dans le HTML

- **Vert** : Ligne exécutée par au moins un test
- **Rouge** : Ligne jamais exécutée
- **Jaune** : Branche partiellement couverte (conditions if/else)

### Métriques importantes

- **Statements** : Nombre total de lignes exécutables
- **Missing** : Nombre de lignes non couvertes
- **Coverage** : Pourcentage de couverture
- **Branch Coverage** : Couverture des branches conditionnelles

## 💡 Bonnes Pratiques

1. **Viser 80% de couverture** : Un bon objectif pour la plupart des projets
2. **Tester les cas limites** : Ne pas seulement tester le "happy path"
3. **Ignorer le code non testable** : Utiliser `# pragma: no cover` pour le code de debug
4. **Automatiser** : Intégrer coverage dans votre CI/CD

## 🔧 Configuration pytest.ini

Pour automatiser les options de coverage :

```ini
[pytest]
testpaths = tests
addopts = 
    --cov=server 
    --cov-report=term-missing
    --cov-report=html
    --cov-fail-under=80
```

## 📈 Exemple de Workflow

```bash
# 1. Lancer les tests avec coverage
pytest --cov=server --cov-report=html

# 2. Ouvrir le rapport
start htmlcov/index.html

# 3. Identifier les lignes rouges

# 4. Écrire un test pour ces lignes

# 5. Relancer et vérifier l'amélioration
pytest --cov=server --cov-report=term

# 6. Commiter quand satisfait
git add tests/
git commit -m "test: improve coverage to 85%"
```

## 🚀 Commande All-in-One

Pour une analyse complète en une commande :

```bash
pytest --cov=server \
       --cov-report=term-missing \
       --cov-report=html \
       --cov-context=test \
       -v
```

Cette commande :
- Lance tous les tests
- Affiche la couverture dans le terminal
- Génère un rapport HTML détaillé
- Inclut le contexte des tests
- Mode verbose pour voir chaque test

---

*Ce guide vous permet de tracer précisément la couverture de votre code et d'identifier rapidement les zones non testées.*
