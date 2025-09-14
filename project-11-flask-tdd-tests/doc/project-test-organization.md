# Organisation du projet Python_Testing

## 📁 Structure des dossiers de tests

```
Python_Testing/
├── server.py
├── clubs.json
├── competitions.json
├── templates/
│   ├── index.html
│   ├── welcome.html
│   └── booking.html
├── tests/
│   ├── unit/                      # Tests unitaires
│   │   ├── __init__.py
│   │   ├── test_club_search.py    # Logique de recherche de clubs
│   │   ├── test_booking_logic.py  # Logique de réservation
│   │   ├── test_points_calc.py    # Calculs de points
│   │   └── test_validations.py    # Validations diverses
│   │
│   ├── functional/                # Tests fonctionnels
│   │   ├── __init__.py
│   │   ├── test_login_flow.py     # Issue email validation
│   │   ├── test_booking_flow.py   # Issue réservation places
│   │   ├── test_points_display.py # Issue affichage points
│   │   └── test_past_events.py    # Issue compétitions passées
│   │
│   ├── integration/               # Tests d'intégration (optionnel)
│   │   ├── __init__.py
│   │   └── test_full_workflow.py  # Test de scénarios complets
│   │
│   ├── fixtures/                  # Données de test partagées
│   │   ├── __init__.py
│   │   ├── clubs_test.json
│   │   └── competitions_test.json
│   │
│   └── conftest.py               # Configuration pytest globale
│
├── requirements.txt               # Dépendances du projet
├── requirements-dev.txt           # Dépendances de développement
├── pytest.ini                     # Configuration pytest
└── README.md
```

## 🌳 Organisation des branches

### Convention de nommage des branches

```
<type>/<issue-number>-<description-courte>
```

### Types de branches :
- `bug/` - Pour les corrections de bugs
- `feature/` - Pour les nouvelles fonctionnalités  
- `test/` - Pour ajouter uniquement des tests
- `refactor/` - Pour les refactorisations
- `qa/` - Pour l'intégration et les tests globaux

### Mapping Issues → Branches

| Issue | Type | Nom de branche suggéré | Tests à créer |
|-------|------|------------------------|---------------|
| Email validation crash | Bug | `bug/issue-1-email-validation` | `test_login_flow.py` (functional) + `test_validations.py` (unit) |
| Booking too many places | Bug | `bug/issue-2-booking-overflow` | `test_booking_flow.py` (functional) + `test_booking_logic.py` (unit) |
| Points display | Feature | `feature/issue-3-points-display` | `test_points_display.py` (functional) + `test_points_calc.py` (unit) |
| Past competitions | Bug | `bug/issue-4-past-competitions` | `test_past_events.py` (functional) + `test_validations.py` (unit) |

## 📝 Contenu des fichiers de configuration

### pytest.ini
```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = -v --tb=short --strict-markers
markers =
    unit: Unit tests
    functional: Functional tests
    integration: Integration tests
    slow: Slow running tests
```

### conftest.py
```python
import pytest
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__) + '/..'))

from server import app

@pytest.fixture
def client():
    """Client de test Flask pour les tests fonctionnels"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

@pytest.fixture
def mock_clubs():
    """Données de clubs pour les tests"""
    return [
        {'name': 'Test Club 1', 'email': 'club1@test.com', 'points': '15'},
        {'name': 'Test Club 2', 'email': 'club2@test.com', 'points': '20'}
    ]

@pytest.fixture
def mock_competitions():
    """Données de compétitions pour les tests"""
    return [
        {'name': 'Test Comp 1', 'date': '2025-12-01 10:00:00', 'numberOfPlaces': '25'},
        {'name': 'Test Comp 2', 'date': '2024-01-01 10:00:00', 'numberOfPlaces': '0'}
    ]
```

## 🔧 Workflow de développement

### Pour chaque issue :

1. **Créer la branche**
```bash
git checkout -b bug/issue-1-email-validation
```

2. **Créer les tests AVANT le fix (TDD)**
```bash
# Créer d'abord le test fonctionnel qui échoue
touch tests/functional/test_login_flow.py

# Créer le test unitaire correspondant
touch tests/unit/test_validations.py
```

3. **Vérifier que les tests échouent**
```bash
# Lancer uniquement les nouveaux tests
pytest tests/functional/test_login_flow.py -v
pytest tests/unit/test_validations.py -v
```

4. **Implémenter le fix**
```bash
# Modifier server.py pour corriger le bug
```

5. **Vérifier que les tests passent**
```bash
# Tests spécifiques
pytest tests/functional/test_login_flow.py tests/unit/test_validations.py -v

# Tous les tests pour s'assurer de ne rien casser
pytest
```

6. **Commit et push**
```bash
git add .
git commit -m "fix(issue-1): handle unknown email without crash

- Add validation for unknown email addresses
- Display error message to user
- Add unit and functional tests"

git push origin bug/issue-1-email-validation
```

## 🏷️ Marqueurs pytest pour organiser les tests

### Utilisation des marqueurs
```python
# Dans vos fichiers de test
import pytest

@pytest.mark.unit
def test_email_validation_logic():
    """Test unitaire"""
    pass

@pytest.mark.functional
def test_login_with_invalid_email():
    """Test fonctionnel"""
    pass

@pytest.mark.slow
@pytest.mark.integration
def test_complete_booking_workflow():
    """Test d'intégration complet"""
    pass
```

### Exécution sélective
```bash
# Lancer uniquement les tests unitaires
pytest -m unit

# Lancer uniquement les tests fonctionnels
pytest -m functional

# Lancer les tests sauf les lents
pytest -m "not slow"

# Lancer les tests d'une issue spécifique
pytest tests/functional/test_login_flow.py tests/unit/test_validations.py
```

## 📊 Tableau de suivi des branches et tests

| Branche | Tests Unitaires | Tests Fonctionnels | Status |
|---------|-----------------|-------------------|--------|
| `bug/issue-1-email-validation` | ✅ test_validations.py | ✅ test_login_flow.py | En cours |
| `bug/issue-2-booking-overflow` | ⏳ test_booking_logic.py | ⏳ test_booking_flow.py | À faire |
| `feature/issue-3-points-display` | ⏳ test_points_calc.py | ⏳ test_points_display.py | À faire |
| `bug/issue-4-past-competitions` | ⏳ test_validations.py | ⏳ test_past_events.py | À faire |
| `qa/integration` | - | ✅ test_full_workflow.py | À faire en dernier |

## 🎯 Bonnes pratiques

1. **Un fichier de test par fonctionnalité majeure** plutôt qu'un gros fichier
2. **Noms explicites** : `test_<ce_qui_est_testé>_<condition>_<résultat_attendu>`
3. **Tests isolés** : Chaque test doit pouvoir s'exécuter indépendamment
4. **Fixtures réutilisables** : Utiliser conftest.py pour partager les fixtures
5. **Documentation** : Docstring pour chaque test expliquant ce qui est testé

## 💡 Exemple de nommage de tests

```python
# ✅ Bons noms
def test_login_with_unknown_email_shows_error_message():
    pass

def test_booking_more_places_than_available_is_rejected():
    pass

def test_past_competition_booking_is_disabled():
    pass

# ❌ Mauvais noms
def test_email():  # Trop vague
    pass

def test_1():  # Pas descriptif
    pass

def test_booking_issue():  # Pas assez spécifique
    pass
```