# T007: Contract test - Authentication commands

## Description
Écrire les tests de contrat (contract tests) pour valider les schémas d'entrée/sortie des commandes d'authentification `epic-crm login` et `epic-crm logout`.

## Contexte
Cette tâche fait partie de la **Phase 3.2: Tests First (TDD)**. Elle doit être complétée AVANT toute implémentation du code. Les tests doivent d'abord être **SKIPPED** (imports échouent), puis **FAILED** (après création des models/CLI), puis **PASSED** (après implémentation complète).

## Objectif
Définir le contrat d'interface des commandes d'authentification pour garantir :
- La validation des schémas de réponse (success/error)
- La cohérence des types d'erreur et exit codes
- La gestion du fichier de token JWT
- Les règles de validation des entrées (longueur min username/password)

## Fichier créé
`tests/contract/test_auth_commands.py`

## Structure des tests

### Classe 1: TestLoginContract (6 tests)

#### 1. test_login_contract_success_schema
**GIVEN** : Des credentials valides (username + password)
**WHEN** : La commande `epic-crm login` est exécutée
**THEN** : La sortie doit correspondre au schéma de succès :
```json
{
  "status": "success",
  "message": "Login successful",
  "user": {
    "id": 1,
    "username": "admin",
    "first_name": "Admin",
    "last_name": "Gestion",
    "department": "GESTION"
  },
  "token_expires_at": "2025-10-07T14:30:00Z"
}
```
**Validations** :
- Exit code = 0
- `status` = "success"
- Message contient "Login successful"
- Objet `user` avec tous les champs requis
- `token_expires_at` au format ISO 8601 (avec T et Z)

#### 2. test_login_contract_invalid_credentials_error
**GIVEN** : Des credentials invalides
**WHEN** : La commande `epic-crm login` est exécutée
**THEN** : La sortie doit correspondre au schéma d'erreur :
```json
{
  "status": "error",
  "error_type": "AuthenticationError",
  "message": "Invalid username or password"
}
```
**Validations** :
- Exit code = 1 (general error)
- `status` = "error"
- `error_type` = "AuthenticationError"
- Message explicite sur les credentials invalides

#### 3. test_login_contract_validation_error_missing_fields
**GIVEN** : Champs requis manquants (username OU password)
**WHEN** : La commande `epic-crm login --username admin` (sans --password)
**THEN** : Click affiche une erreur de validation
**Validations** :
- Exit code ≠ 0
- Message contient "Error" ou "Missing option"

#### 4. test_login_contract_token_file_created
**GIVEN** : Credentials valides
**WHEN** : Login réussit
**THEN** : Un fichier token doit être créé à `~/.epic-crm/token`
**Validations** :
- Exit code = 0
- Message mentionne "token"
- Fichier créé dans le système de fichiers

#### 5. test_login_contract_username_min_length
**GIVEN** : Username < 3 caractères (ex: "ab")
**WHEN** : La commande `epic-crm login` est exécutée
**THEN** : Erreur de validation
**Validations** :
- Exit code ≠ 0
- Validation Pydantic échoue

#### 6. test_login_contract_password_min_length
**GIVEN** : Password < 8 caractères (ex: "short")
**WHEN** : La commande `epic-crm login` est exécutée
**THEN** : Erreur de validation
**Validations** :
- Exit code ≠ 0
- Validation Pydantic échoue

### Classe 2: TestLogoutContract (2 tests)

#### 7. test_logout_contract_success
**GIVEN** : Une session active (fichier token existe)
**WHEN** : La commande `epic-crm logout` est exécutée
**THEN** : Succès et suppression du token
**Validations** :
- Exit code = 0
- Message contient "Logout successful"
- Message contient "Token deleted"
- Fichier token supprimé du système de fichiers

#### 8. test_logout_contract_no_active_session
**GIVEN** : Aucune session active (pas de fichier token)
**WHEN** : La commande `epic-crm logout` est exécutée
**THEN** : Message informatif (pas forcément une erreur)
**Validations** :
- Message contient "No active session" OU "Already logged out"

## Fixtures utilisées

### cli_runner (fixture locale)
```python
@pytest.fixture
def cli_runner():
    """Create a Click CLI runner for testing."""
    return CliRunner()
```
Permet de tester les commandes Click sans exécution réelle.

### token_file_path (fixture locale)
```python
@pytest.fixture
def token_file_path(tmp_path):
    """Create a temporary token file path."""
    return tmp_path / ".epic-crm" / "token"
```
Fournit un chemin temporaire pour le fichier token (évite pollution du système).

### db_session (fixture globale - conftest.py)
Crée une base SQLite en mémoire pour chaque test.

### test_users (fixture globale - conftest.py)
Fournit 3 utilisateurs de test (admin, commercial1, support1).

## Pattern TDD : Les 3 états des tests

### 1. État SKIPPED (Actuel) ✅
```python
try:
    from src.cli.main import cli
except ImportError:
    cli = None

# Dans le test :
if cli is None:
    pytest.skip("CLI not implemented yet (TDD)")
```
**Raison** : Les modules `src.cli.main`, `src.models.*` n'existent pas encore.
**Sortie pytest** :
```
tests/contract/test_auth_commands.py::test_login_contract_success_schema SKIPPED
  (CLI not implemented yet (TDD))
```

### 2. État FAILED (Après T021-T025) ⏳
Une fois les models créés, les imports fonctionneront mais les tests échoueront :
```
tests/contract/test_auth_commands.py::test_login_contract_success_schema FAILED
  AssertionError: Command 'login' not found
```
**Raison** : Les commandes CLI ne sont pas encore implémentées.

### 3. État PASSED (Après T031-T038) 🎯
Une fois les services et CLI implémentés :
```
tests/contract/test_auth_commands.py::test_login_contract_success_schema PASSED
```

## Dépendances
- **T005** : Configuration pytest (✅ complétée)

## Critères de complétion
✅ Le fichier `tests/contract/test_auth_commands.py` existe
✅ 8 tests définis (6 pour login, 2 pour logout)
✅ Tous les tests utilisent le pattern TDD (skip si imports échouent)
✅ Tous les tests sont marqués `@pytest.mark.contract`
✅ Tous les tests sont **SKIPPED** lors de l'exécution

## Commandes de test

### Exécuter uniquement les tests d'authentification
```bash
poetry run pytest tests/contract/test_auth_commands.py -v
```

### Exécuter tous les tests contract
```bash
poetry run pytest tests/contract/ -v
```

### Exécuter avec les raisons de skip affichées
```bash
poetry run pytest tests/contract/test_auth_commands.py -v -rs
```

### Exécuter un seul test
```bash
poetry run pytest tests/contract/test_auth_commands.py::TestLoginContract::test_login_contract_success_schema -v
```

## Sortie attendue (état SKIPPED)

```
============================= test session starts =============================
platform win32 -- Python 3.13.7, pytest-8.4.2, pluggy-1.6.0
rootdir: D:\...\project-12-architecture-back-end
configfile: pytest.ini
testpaths: tests
plugins: cov-7.0.0, mock-3.15.1
collected 8 items

tests/contract/test_auth_commands.py::TestLoginContract::test_login_contract_success_schema SKIPPED (Models not implemented yet (TDD))    [ 12%]
tests/contract/test_auth_commands.py::TestLoginContract::test_login_contract_invalid_credentials_error SKIPPED (Models not implemented yet (TDD)) [ 25%]
tests/contract/test_auth_commands.py::TestLoginContract::test_login_contract_validation_error_missing_fields SKIPPED (CLI not implemented yet (TDD)) [ 37%]
tests/contract/test_auth_commands.py::TestLoginContract::test_login_contract_token_file_created SKIPPED (Models not implemented yet (TDD)) [ 50%]
tests/contract/test_auth_commands.py::TestLoginContract::test_login_contract_username_min_length SKIPPED (CLI not implemented yet (TDD))  [ 62%]
tests/contract/test_auth_commands.py::TestLoginContract::test_login_contract_password_min_length SKIPPED (CLI not implemented yet (TDD))  [ 75%]
tests/contract/test_auth_commands.py::TestLogoutContract::test_logout_contract_success SKIPPED (CLI not implemented yet (TDD))            [ 87%]
tests/contract/test_auth_commands.py::TestLogoutContract::test_logout_contract_no_active_session SKIPPED (CLI not implemented yet (TDD))  [100%]

========================== 8 skipped in 0.05s ==========================
```

## Ce que ces tests garantissent

### 1. Contrat d'interface stable
Les consommateurs de l'API CLI savent exactement quel format de données attendre.

### 2. Validation des entrées
- Username ≥ 3 caractères
- Password ≥ 8 caractères
- Champs requis présents

### 3. Exit codes et types d'erreur cohérents
- **Exit code 0** : Success
- **Exit code 1** : General error (authentication, validation)
- **Exit code 2** : Misuse of shell command (Click usage error)
- **error_type** : "AuthenticationError", "ValidationError", etc.

### 4. Gestion du token JWT
- Création automatique du fichier `~/.epic-crm/token`
- Suppression lors du logout
- Expiration trackée

## Tâches liées

### Tâches précédentes
- T005 : Configuration pytest ✅

### Tâches parallèles (peuvent être faites en même temps)
- T008 : Contract test - Client commands ⏳
- T009 : Contract test - Contract commands ⏳
- T010 : Contract test - Event commands ⏳
- T011 : Contract test - User commands ⏳

### Tâches suivantes (implémentation)
- T021 : Implement User model (Phase 3.3)
- T031 : Implement AuthService
- T038 : Implement auth commands (login, logout)

## Prochaines étapes
Une fois cette tâche complétée, vous pourrez :
1. **T008** : Écrire les contract tests pour les commandes Client
2. **T009-T011** : Continuer les autres contract tests
3. **T012-T019** : Écrire les tests d'intégration
4. **T020** : Compléter les fixtures dans conftest.py

## Notes importantes

### Pattern GIVEN-WHEN-THEN
Tous les tests utilisent ce pattern pour clarifier le scénario :
```python
"""
GIVEN valid credentials
WHEN login command is executed
THEN success schema is returned
"""
```

### Markers pytest
Utilisez `@pytest.mark.contract` pour filtrer :
```bash
# Exécuter uniquement les contract tests
poetry run pytest -m contract
```

### Click Testing
Utilisation de `CliRunner()` de Click pour tester les commandes sans I/O réel.

### Filesystem isolation
Utilisation de `cli_runner.isolated_filesystem()` pour éviter pollution du système.

## Statut
✅ **Complétée** - Les 8 tests sont écrits et tous SKIPPED (TDD)

## Prochaine tâche recommandée
**T008** : Contract test - Client commands (5 tests pour create, update, list, delete, reassign)
