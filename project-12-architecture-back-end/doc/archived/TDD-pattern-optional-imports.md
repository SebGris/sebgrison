# Pattern TDD : Gestion des imports optionnels avec pytest

## Le problème

En **Test-Driven Development (TDD)**, vous écrivez les tests **AVANT** le code d'implémentation. Cela signifie que lorsque vous essayez d'importer des modules qui n'existent pas encore, Python lève une `ImportError`.

## La solution : Try-Except ImportError

Le pattern utilisé dans `conftest.py` est une approche standard pour gérer les imports optionnels :

```python
# Import will fail until implementation exists - this is expected for TDD
try:
    from sqlalchemy import create_engine
    from sqlalchemy.orm import sessionmaker, Session
    from src.models.user import User, Department, Base
    from src.models.client import Client
    from src.models.contract import Contract
    from src.models.event import Event
except ImportError:
    # Mock for TDD phase
    User = None
    Client = None
    Contract = None
    Event = None
    Base = None
    Department = None
```

## Pourquoi cette approche ?

### 1. **Phase Red (Tests SKIPPED)**
- Les modules `src.models.*` n'existent pas encore
- L'`ImportError` est capturée
- Les variables sont mises à `None`
- Les fixtures vérifient si les modules existent :
  ```python
  if User is None or Department is None:
      pytest.skip("User model not implemented yet (TDD)")
  ```
- **Résultat** : Tests SKIPPED (attendu en TDD)

### 2. **Phase Red → Yellow (Tests FAILED)**
- Les modules sont créés (squelettes minimum)
- L'import fonctionne maintenant
- Les fixtures ne skip plus
- Le code n'est pas implémenté → tests échouent
- **Résultat** : Tests FAILED (attendu en TDD)

### 3. **Phase Green (Tests PASSED)**
- Le code est implémenté complètement
- Les tests passent
- **Résultat** : Tests PASSED ✅

## Références officielles

### Pytest Documentation
Source : [pytest.org - How to skip tests](https://docs.pytest.org/en/stable/how-to/skipping.html)

#### pytest.importorskip()
Pytest fournit une fonction dédiée pour skipper les tests quand un import échoue :

```python
import pytest

def test_example():
    numpy = pytest.importorskip("numpy")
    # Test code using numpy
```

Avec version minimum :
```python
docutils = pytest.importorskip("docutils", minversion="0.3")
```

#### pytest.skip() au niveau du module
Pour skipper un module entier :

```python
import pytest

try:
    import matplotlib
except ImportError:
    pytest.skip("Matplotlib not available", allow_module_level=True)
```

### Approche utilisée dans Epic Events CRM

Notre approche combine les deux patterns :

1. **Try-except ImportError** au niveau du module (conftest.py)
2. **pytest.skip()** au niveau de la fixture :

```python
@pytest.fixture(scope="function")
def db_session():
    """
    Create an in-memory SQLite database session for each test.
    Automatically rolls back after each test.
    """
    if Base is None:
        pytest.skip("Models not implemented yet (TDD)")

    # Setup database...
```

## Avantages de cette approche

### ✅ Transparence
Les tests montrent clairement qu'ils sont skippés en attendant l'implémentation :
```
tests/contract/test_auth_commands.py::test_login_contract_success_schema SKIPPED
  (Models not implemented yet (TDD))
```

### ✅ Pas de pollution du code
Les tests ne cassent pas la build, ils sont juste skippés.

### ✅ Progression visible
```
Phase 1: 8 skipped           → Tests écrits, code pas encore créé
Phase 2: 3 failed, 3 passed  → Code créé mais pas implémenté
Phase 3: 8 passed            → Code complètement implémenté
```

### ✅ CI/CD compatible
- Les tests skippés ne font pas échouer la pipeline
- On peut suivre la progression (nombre de tests skippés qui diminue)

## Pattern alternatif : pytest.mark.skipif

Vous pourriez aussi utiliser des décorateurs :

```python
import pytest

try:
    from src.models.user import User
except ImportError:
    User = None

@pytest.mark.skipif(User is None, reason="User model not implemented yet")
def test_user_creation():
    user = User(username="test")
    assert user.username == "test"
```

**Inconvénient** : Répétitif si vous avez beaucoup de tests.

**Avantage de notre approche** : Centralisation dans les fixtures.

## Bonnes pratiques

### 1. Documenter le pattern
Toujours ajouter un commentaire expliquant pourquoi vous faites cela :

```python
# Import will fail until implementation exists - this is expected for TDD
try:
    from src.models.user import User
except ImportError:
    User = None
```

### 2. Utiliser pytest -rs pour voir les skips
```bash
poetry run pytest tests/contract/ -v -rs
```

Affiche :
```
SKIPPED [1] tests/conftest.py:35: Models not implemented yet (TDD)
```

### 3. Suivre la progression
Créez un fichier pour tracker l'état des tests :

```markdown
# État des tests (7 octobre 2025)

## Phase actuelle : Yellow (FAILED)
- Tests contract auth : 3 failed, 3 passed, 2 errors
- Tests contract client : Pas encore créés
- Tests integration : Pas encore créés

## Objectif : Green (PASSED)
- Implémenter T031 : AuthService
- Implémenter T038 : Auth commands
```

## Références web

### Articles TDD avec pytest

1. **Modern Test-Driven Development in Python**
   - Source : [testdriven.io](https://testdriven.io/blog/modern-tdd/)
   - Explique le cycle GIVEN-WHEN-THEN
   - Montre comment écrire des tests avant le code

2. **How To Practice Test-Driven Development In Python**
   - Source : [pytest-with-eric.com](https://pytest-with-eric.com/tdd/pytest-tdd/)
   - Cycle Red-Green-Refactor détaillé
   - Exemples pratiques avec pytest

3. **Pytest Official Documentation - Skipping**
   - Source : [docs.pytest.org](https://docs.pytest.org/en/stable/how-to/skipping.html)
   - Documentation officielle sur `pytest.importorskip()`
   - Exemples avec `pytest.skip()` et `allow_module_level=True`

### Stack Overflow discussions

1. **Is it safe to catch ImportError for optional modules?**
   - Source : [Software Engineering Stack Exchange](https://softwareengineering.stackexchange.com/questions/262697)
   - Discussion sur la sécurité de ce pattern
   - Cas où ça peut poser problème (imports transitifs)

2. **PyTest: skip entire module/file**
   - Source : [Stack Overflow](https://stackoverflow.com/questions/42511879)
   - Exemples de skip au niveau module
   - Solutions avec `pytestmark = pytest.mark.skip`

## Cas d'usage dans d'autres projets

### Django
Django utilise ce pattern pour les settings locaux optionnels :

```python
try:
    from .local_settings import *
except ImportError:
    pass  # Local settings not required
```

### Scientific Python packages
Beaucoup de packages scientifiques utilisent `pytest.importorskip` :

```python
import pytest

def test_scientific_computation():
    np = pytest.importorskip("numpy")
    scipy = pytest.importorskip("scipy", minversion="1.0")

    # Test code using numpy and scipy
```

## Notre implémentation dans Epic Events CRM

### Structure des tests

```
tests/
├── conftest.py              # Fixtures centralisées avec try-except ImportError
├── contract/
│   ├── test_auth_commands.py   # Tests avec if cli is None: pytest.skip()
│   └── test_client_commands.py # À créer (même pattern)
└── integration/
    └── test_auth_flow.py       # À créer (même pattern)
```

### Fixture centralisée (conftest.py)

```python
# Try to import models (will fail in TDD phase)
try:
    from src.models.user import User, Department, Base
    from src.models.client import Client
    from src.models.contract import Contract
    from src.models.event import Event
except ImportError:
    # Mock for TDD phase - set to None
    User = None
    Client = None
    Contract = None
    Event = None
    Base = None
    Department = None

# Fixture checks if imports succeeded
@pytest.fixture(scope="function")
def db_session():
    if Base is None:
        pytest.skip("Models not implemented yet (TDD)")
    # Create in-memory SQLite database...
```

### Tests avec vérification CLI

```python
# Try to import CLI (will fail in TDD phase)
try:
    from src.cli.main import cli
except ImportError:
    cli = None

class TestLoginContract:
    @pytest.mark.contract
    def test_login_contract_success_schema(self, cli_runner, db_session, test_users):
        # Check if CLI exists
        if cli is None:
            pytest.skip("CLI not implemented yet (TDD)")

        # Test code...
```

## Évolution des tests dans le temps

### État initial (7 oct 2025 - matin)
```
8 skipped in 0.05s
```
Raison : `src.models.*` et `src.cli.main` n'existaient pas

### État actuel (7 oct 2025 - après-midi)
```
3 failed, 3 passed, 2 errors in 0.62s
```
Raison : Models et CLI créés (squelettes), mais logique non implémentée

### État cible (après T031, T038)
```
8 passed in 0.5s
```
Raison : AuthService et auth commands implémentés

## Conclusion

Le pattern **try-except ImportError + pytest.skip()** est :
- ✅ **Standard** dans la communauté Python
- ✅ **Documenté** dans pytest officiel
- ✅ **Utilisé** par Django et d'autres frameworks
- ✅ **Adapté** au TDD strict (Red-Green-Refactor)
- ✅ **Transparent** pour les développeurs (raisons de skip claires)

**Ce n'est pas un hack, c'est une bonne pratique TDD !**