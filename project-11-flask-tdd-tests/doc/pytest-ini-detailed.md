# Guide détaillé du fichier pytest.ini

## 📋 Qu'est-ce que pytest.ini ?

Le fichier `pytest.ini` est le fichier de configuration principal de pytest. Il doit être placé à la racine de votre projet et permet de définir des paramètres par défaut pour tous les tests du projet.

## 📍 Emplacement du fichier

```
Python_Testing/
├── pytest.ini          # ← Ici, à la racine du projet
├── server.py
├── tests/
│   ├── unit/
│   └── functional/
└── ...
```

## 🔧 Configuration détaillée ligne par ligne

### Configuration de base
```ini
[pytest]
# Section obligatoire qui indique que c'est un fichier de config pytest
```

### 1. testpaths - Où chercher les tests
```ini
testpaths = tests
# Indique à pytest de chercher les tests uniquement dans le dossier 'tests'
# Sans cette ligne, pytest parcourt TOUT le projet (plus lent)

# Peut aussi spécifier plusieurs dossiers :
# testpaths = tests src/tests
```

### 2. python_files - Quels fichiers sont des tests
```ini
python_files = test_*.py
# Pytest considérera comme tests tous les fichiers commençant par 'test_'
# Par défaut : test_*.py et *_test.py

# Exemples de fichiers détectés :
# ✅ test_login.py
# ✅ test_booking_flow.py
# ❌ login_test.py (ne commence pas par test_)
# ❌ my_tests.py (ne correspond pas au pattern)

# Pour accepter d'autres patterns :
# python_files = test_*.py *_test.py check_*.py
```

### 3. python_classes - Quelles classes contiennent des tests
```ini
python_classes = Test*
# Les classes dont le nom commence par 'Test' contiennent des tests

# Exemples :
# ✅ class TestEmailValidation:
# ✅ class TestBookingFlow:
# ❌ class EmailTests:  (ne commence pas par Test)
```

### 4. python_functions - Quelles fonctions sont des tests
```ini
python_functions = test_*
# Les fonctions commençant par 'test_' sont des tests

# Exemples :
# ✅ def test_invalid_email():
# ✅ def test_booking_overflow():
# ❌ def check_email():  (ne commence pas par test_)
```

### 5. addopts - Options automatiques
```ini
addopts = -v --tb=short --strict-markers
# Options ajoutées automatiquement à chaque exécution de pytest

# Détail de chaque option :
# -v (--verbose) : Affiche plus de détails sur les tests
# --tb=short : Format court pour les tracebacks d'erreur
# --strict-markers : Erreur si un marqueur non déclaré est utilisé
```

#### Exemples d'autres options utiles :
```ini
# Options d'affichage
addopts = 
    -v                    # Mode verbose
    --tb=short           # Traceback court
    --strict-markers     # Marqueurs stricts
    -ra                  # Afficher un résumé de tous les tests sauf passed
    --maxfail=3          # Arrêter après 3 échecs
    --color=yes          # Forcer les couleurs
    
# Pour la couverture de code
addopts = 
    --cov=server         # Mesurer la couverture du module server
    --cov-report=html    # Générer un rapport HTML
    --cov-report=term    # Afficher dans le terminal
```

### 6. markers - Définition des marqueurs personnalisés
```ini
markers =
    unit: Unit tests
    functional: Functional tests
    integration: Integration tests
    slow: Slow running tests
    
# Définit les marqueurs utilisables avec @pytest.mark.XXX
# La description après ':' est optionnelle mais recommandée
```

## 📝 Exemples de configurations complètes

### Configuration minimale pour votre projet
```ini
[pytest]
testpaths = tests
python_files = test_*.py
addopts = -v
```

### Configuration recommandée pour votre projet
```ini
[pytest]
# Chemins de recherche
testpaths = tests

# Patterns de découverte
python_files = test_*.py
python_classes = Test*
python_functions = test_*

# Options par défaut
addopts = 
    -v
    --tb=short
    --strict-markers
    -ra

# Marqueurs disponibles
markers =
    unit: Tests unitaires rapides et isolés
    functional: Tests fonctionnels de bout en bout
    integration: Tests d'intégration complets
    slow: Tests lents (plus de 1 seconde)
    issue1: Tests liés à l'issue #1 (email validation)
    issue2: Tests liés à l'issue #2 (booking overflow)
    issue3: Tests liés à l'issue #3 (points display)
    issue4: Tests liés à l'issue #4 (past competitions)

# Configuration de logs (optionnel)
log_cli = true
log_cli_level = INFO
```

### Configuration avancée avec couverture de code
```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*

addopts = 
    -v
    --tb=short
    --strict-markers
    --cov=server
    --cov-branch
    --cov-report=term-missing
    --cov-report=html:htmlcov
    --cov-fail-under=80

markers =
    unit: Unit tests
    functional: Functional tests
    integration: Integration tests
    slow: Slow running tests (deselect with '-m "not slow"')
    wip: Work in progress

# Ignorer certains warnings
filterwarnings =
    ignore::DeprecationWarning
    ignore::PendingDeprecationWarning
```

## 🎯 Utilisation pratique avec les marqueurs

### Dans vos tests
```python
import pytest

@pytest.mark.unit
@pytest.mark.issue1
def test_email_validation_logic():
    """Test unitaire pour l'issue #1"""
    pass

@pytest.mark.functional
@pytest.mark.issue2
def test_booking_overflow_prevention():
    """Test fonctionnel pour l'issue #2"""
    pass

@pytest.mark.slow
@pytest.mark.integration
def test_complete_user_journey():
    """Test d'intégration complet (lent)"""
    pass
```

### Exécution sélective via ligne de commande
```bash
# Lancer seulement les tests unitaires
pytest -m unit

# Lancer les tests de l'issue #1
pytest -m issue1

# Lancer tous les tests SAUF les lents
pytest -m "not slow"

# Combiner les marqueurs
pytest -m "unit and issue1"
pytest -m "functional and not slow"
```

## ⚠️ Points d'attention

### 1. Format du fichier
- Doit être en format INI (pas YAML, pas JSON)
- Les sections commencent par `[pytest]`
- Pas de guillemets autour des valeurs

### 2. Priorité des configurations
```
Ordre de priorité (du plus fort au plus faible) :
1. Ligne de commande
2. pytest.ini
3. pyproject.toml
4. tox.ini
5. setup.cfg
```

### 3. Erreurs courantes
```ini
# ❌ ERREUR : Marqueur non déclaré
@pytest.mark.smoke  # Erreur si 'smoke' pas dans markers

# ✅ CORRECT : Déclarer dans pytest.ini
markers =
    smoke: Smoke tests for quick validation
```

## 🔍 Vérifier la configuration

```bash
# Afficher la configuration active
pytest --help

# Voir tous les marqueurs disponibles
pytest --markers

# Tester la configuration sans lancer les tests
pytest --collect-only

# Voir quels tests seront exécutés
pytest --collect-only -q
```

## 💡 Conseils pour votre projet

1. **Commencez simple** : Ajoutez des options au fur et à mesure des besoins
2. **Documentez les marqueurs** : La description aide les autres développeurs
3. **Utilisez --strict-markers** : Évite les typos dans les marqueurs
4. **Versionnez le fichier** : pytest.ini doit être dans Git
5. **Testez la config** : Vérifiez que pytest trouve bien vos tests

Cette configuration centralisée garantit que tous les développeurs du projet utilisent les mêmes paramètres pytest, rendant les tests plus cohérents et maintenables.