# Le décorateur @require_department - Explication du code

Ce document explique le fonctionnement du décorateur `@require_department` utilisé pour gérer les permissions dans l'application Epic Events CRM.

## Vue d'ensemble

Le décorateur `@require_department` est un mécanisme de contrôle d'accès qui :
1. Vérifie que l'utilisateur est authentifié (token JWT valide)
2. Vérifie que l'utilisateur appartient à un département autorisé (optionnel)
3. Injecte automatiquement l'utilisateur courant dans la fonction décorée

## Fichier source

**Fichier** : `src/cli/permissions.py`

### Syntaxe `*valid_departments`

L'étoile `*` dans `*valid_departments: Department` signifie **arguments variadiques** (variadic positional arguments). Cela permet de passer **zéro, un ou plusieurs** départements à la fonction :

```python
# Zéro argument - authentification seule
@require_department()
def my_command(): ...

# Un argument
@require_department(Department.GESTION)
def my_command(): ...

# Plusieurs arguments
@require_department(Department.COMMERCIAL, Department.GESTION)
def my_command(): ...
```

Tous les arguments passés sont regroupés dans un **tuple** :
- `require_department()` → `valid_departments = ()`
- `require_department(Department.GESTION)` → `valid_departments = (Department.GESTION,)`
- `require_department(Department.COMMERCIAL, Department.GESTION)` → `valid_departments = (Department.COMMERCIAL, Department.GESTION)`

L'annotation `: Department` indique que chaque élément doit être de type `Department` (vérification par les outils de typage comme mypy).

### Code du décorateur

```python
from src.containers import Container  # Import en haut du module

# Error messages (constantes PEP 8)
MSG_NOT_LOGGED_IN = "Vous devez être connecté pour effectuer cette action"
MSG_LOGIN_HINT = "Utilisez 'epicevents login' pour vous connecter"
MSG_UNAUTHORIZED = "Action non autorisée pour votre département"

def require_department(*valid_departments: Department):
    """Decorator to require authentication and optionally specific department(s)."""

    def decorator(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs):
            # 1. Instancier auth_service depuis le container
            container = Container()
            auth_service = container.auth_service()

            # 2. Vérifier si l'utilisateur est authentifié
            user = auth_service.get_current_user()

            if not user:
                print_error(MSG_NOT_LOGGED_IN)
                print_error(MSG_LOGIN_HINT)
                raise typer.Exit(code=1)

            # 3. Vérifier le département (si spécifié)
            if valid_departments and user.department not in valid_departments:
                print_error(MSG_UNAUTHORIZED)
                raise typer.Exit(code=1)

            # 4. Injecter current_user si la fonction l'attend
            sig = inspect.signature(func)
            if "current_user" in sig.parameters:
                kwargs["current_user"] = user

            return func(*args, **kwargs)

        return wrapper
    return decorator
```

## Fonctionnement étape par étape

### Étape 1 : Déclaration du décorateur

```python
@app.command()
@require_department(Department.COMMERCIAL, Department.GESTION)
def create_client(
    first_name: str = typer.Option(...),
    current_user=None,  # Injecté automatiquement par le décorateur
):
```

**Ce qui se passe** :
- `@require_department(Department.COMMERCIAL, Department.GESTION)` crée un décorateur avec les départements autorisés
- Les départements sont passés comme arguments variables (`*valid_departments`)

---

### Étape 2 : Vérification de l'authentification

```python
container = Container()
auth_service = container.auth_service()
user = auth_service.get_current_user()

if not user:
    print_error("Vous devez être connecté pour effectuer cette action")
    raise typer.Exit(code=1)
```

**Ce qui se passe** :
1. Le décorateur crée un nouveau `Container` pour obtenir `auth_service`
2. `get_current_user()` lit le token JWT stocké dans `~/.epicevents/token`
3. Si le token est valide, il retourne l'objet `User` correspondant
4. Si le token est absent/invalide/expiré, il retourne `None` → erreur

**Schéma du flux d'authentification** :
```
get_current_user()
    ↓
load_token() → Lit ~/.epicevents/token
    ↓
validate_token(token) → Vérifie la signature JWT et l'expiration
    ↓
Extrait user_id du payload JWT
    ↓
repository.get(user_id) → SELECT * FROM users WHERE id = ?
    ↓
Retourne l'objet User
```

---

### Étape 3 : Vérification du département

```python
if valid_departments and user.department not in valid_departments:
    dept_names = ", ".join(d.value for d in valid_departments)
    print_error(MSG_UNAUTHORIZED)
    print_error(f"Départements autorisés : {dept_names}")
    print_error(f"Votre département : {user.department.value}")
    raise typer.Exit(code=1)
```

**Ce qui se passe** :
1. Si des départements sont spécifiés (`valid_departments` non vide)
2. Vérifie si le département de l'utilisateur est dans la liste autorisée
3. Si non autorisé → affiche un message d'erreur et quitte

**Exemples de restrictions** :

| Commande | Départements autorisés |
|----------|------------------------|
| `create-client` | COMMERCIAL, GESTION |
| `create-user` | GESTION |
| `update-event` | SUPPORT, GESTION |
| `list-clients` | Tous (pas de restriction) |

---

### Étape 4 : Injection de l'utilisateur courant

```python
sig = inspect.signature(func)
if "current_user" in sig.parameters:
    kwargs["current_user"] = user

return func(*args, **kwargs)
```

**Ce qui se passe** :
1. `inspect.signature(func)` analyse la signature de la fonction décorée
2. Si la fonction a un paramètre nommé `current_user`, on l'injecte
3. La fonction originale est appelée avec tous les arguments + `current_user`

**Avantage** : La commande CLI n'a pas besoin de récupérer l'utilisateur elle-même.

---

## Cas d'utilisation

### Cas 1 : Authentification seule (sans restriction de département)

```python
@app.command()
@require_department()  # Pas de départements spécifiés
def list_my_events(current_user=None):
    # Accessible à tous les utilisateurs authentifiés
    # current_user est injecté automatiquement par le décorateur
    ...
```

### Cas 2 : Restriction à un département

```python
@app.command()
@require_department(Department.GESTION)
def create_user(username: str = typer.Option(...), current_user=None):
    # Accessible uniquement au département GESTION
    # current_user est injecté automatiquement
    ...
```

### Cas 3 : Restriction à plusieurs départements

```python
@app.command()
@require_department(Department.COMMERCIAL, Department.GESTION)
def create_client(
    first_name: str = typer.Option(...),
    current_user=None,  # Injecté automatiquement
):
    # Accessible à COMMERCIAL et GESTION
    # Plus besoin de: auth_service.get_current_user()
    ...
```

### Cas 4 : Sans injection de current_user

```python
@app.command()
@require_department(Department.SUPPORT)
def list_events():  # Pas de paramètre current_user
    # Authentification vérifiée, mais current_user non injecté
    ...
```

**Note importante sur Typer** : Le paramètre `current_user` doit être déclaré sans annotation de type (`current_user=None` au lieu de `current_user: User = None`). Sinon, Typer tenterait d'interpréter `User` comme un type CLI et échouerait.

### Avantage de l'injection automatique

Grâce à l'injection automatique, les commandes n'ont plus besoin de récupérer l'utilisateur manuellement :

```python
# ❌ Avant (code répétitif dans chaque commande)
@app.command()
@require_department(Department.COMMERCIAL)
def create_client(...):
    container = Container()
    auth_service = container.auth_service()
    current_user = auth_service.get_current_user()  # Répété partout
    ...

# ✅ Après (injection automatique)
@app.command()
@require_department(Department.COMMERCIAL)
def create_client(..., current_user=None):
    # current_user est déjà disponible, injecté par le décorateur
    container = Container()
    # Plus besoin de auth_service pour get_current_user()
    ...
```

---

## Schéma du flux complet

```
┌──────────────────────────────────────────────────────────────┐
│ Utilisateur exécute: epicevents create-client                 │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ Typer appelle la fonction create_client()                     │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ @require_department s'exécute EN PREMIER (wrapper)            │
│                                                               │
│  1. Container() → auth_service()                              │
│  2. auth_service.get_current_user()                           │
│     └─> Lit token, valide JWT, récupère User                  │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
              ┌──────┴──────┐
              │ User trouvé? │
              └──────┬──────┘
           Non ↓           ↓ Oui
    ┌──────────────┐  ┌─────────────────────────────────────────┐
    │ Erreur:      │  │ Département autorisé?                   │
    │ "Vous devez  │  │ user.department in valid_departments?   │
    │ être connecté│  └────────────────┬────────────────────────┘
    │ ..."         │            Non ↓           ↓ Oui
    │ Exit(1)      │      ┌──────────────┐  ┌──────────────────────┐
    └──────────────┘      │ Erreur:      │  │ Injection:           │
                          │ "Action non  │  │ kwargs["current_user"]│
                          │ autorisée"   │  │ = user               │
                          │ Exit(1)      │  └────────────┬─────────┘
                          └──────────────┘               ↓
                                              ┌──────────────────────┐
                                              │ func(*args, **kwargs)│
                                              │ → Exécute la commande│
                                              └──────────────────────┘
```

---

## Points clés de l'architecture

### Pattern Decorator

Le décorateur utilise le pattern **Decorator** de Python :
- `require_department(*args)` retourne une fonction `decorator`
- `decorator(func)` retourne une fonction `wrapper`
- `wrapper(*args, **kwargs)` est appelée à chaque exécution de la commande

### Injection de dépendances

Le décorateur importe `Container` en haut du module et l'utilise pour obtenir `auth_service` :
```python
from src.containers import Container  # En haut du module

# Dans le wrapper
container = Container()
auth_service = container.auth_service()
```

Cela permet de garder le décorateur découplé des commandes CLI.

### Introspection avec inspect

```python
sig = inspect.signature(func)
if "current_user" in sig.parameters:
    kwargs["current_user"] = user
```

L'utilisation de `inspect.signature` permet d'injecter `current_user` uniquement si la fonction l'attend, rendant le décorateur flexible.

---

## Tests unitaires

Les tests du décorateur se trouvent dans `tests/unit/test_permissions.py` et couvrent :

| Test | Description |
|------|-------------|
| `test_unauthenticated_user_raises_exit` | Vérifie que l'accès est refusé sans authentification |
| `test_authenticated_user_allowed` | Vérifie que l'accès est autorisé avec authentification |
| `test_wrong_department_single_dept` | Vérifie le refus pour un mauvais département |
| `test_correct_department_multiple_depts` | Vérifie l'accès avec un des départements autorisés |
| `test_function_with_current_user_param` | Vérifie l'injection de `current_user` |
| `test_function_without_current_user_param` | Vérifie le fonctionnement sans injection |

### Règle de patching pour les tests

**Important** : Pour mocker `Container` dans les tests, il faut patcher **là où il est importé**, pas là où il est défini :

```python
# ❌ Incorrect - patche le module source
mocker.patch("src.containers.Container", return_value=mock_container)

# ✅ Correct - patche là où Container est importé
mocker.patch("src.cli.permissions.Container", return_value=mock_container)
```

C'est une règle Python standard : on patche toujours l'objet **à l'endroit où il est utilisé**, pas à l'endroit où il est défini.

---

## Comment créer un décorateur Python

### Concept de base

Un **décorateur** est une fonction qui prend une fonction en paramètre et retourne une nouvelle fonction. C'est le pattern **Decorator** appliqué en Python.

### Les 3 types de décorateurs

#### 1. Décorateur simple (sans paramètres)

```python
def mon_decorateur(func):
    def wrapper(*args, **kwargs):
        print("Avant l'exécution")
        result = func(*args, **kwargs)
        print("Après l'exécution")
        return result
    return wrapper

@mon_decorateur
def dire_bonjour():
    print("Bonjour!")

# Équivalent à: dire_bonjour = mon_decorateur(dire_bonjour)
```

#### 2. Décorateur avec paramètres (decorator factory)

C'est le cas de `@require_department`. Il faut **3 niveaux de fonctions** :

```python
def decorateur_avec_params(param1, param2):  # Niveau 1: reçoit les paramètres
    def decorator(func):                       # Niveau 2: reçoit la fonction
        def wrapper(*args, **kwargs):          # Niveau 3: exécute la logique
            print(f"Params: {param1}, {param2}")
            return func(*args, **kwargs)
        return wrapper
    return decorator

@decorateur_avec_params("a", "b")
def ma_fonction():
    pass

# Équivalent à: ma_fonction = decorateur_avec_params("a", "b")(ma_fonction)
```

#### 3. Décorateur de classe (moins courant)

```python
class MonDecorateur:
    def __init__(self, func):
        self.func = func

    def __call__(self, *args, **kwargs):
        print("Avant")
        return self.func(*args, **kwargs)
```

### Bonnes pratiques

1. **Utiliser `@wraps`** pour préserver les métadonnées de la fonction originale :

```python
from functools import wraps

def mon_decorateur(func):
    @wraps(func)  # Préserve __name__, __doc__, etc.
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper
```

2. **Accepter `*args, **kwargs`** pour rendre le décorateur générique

3. **Retourner le résultat** de la fonction décorée

### Ressources pour approfondir

- [Real Python - Primer on Python Decorators](https://realpython.com/primer-on-python-decorators/) - Tutorial complet et bien illustré
- [PEP 318 - Decorators for Functions and Methods](https://peps.python.org/pep-0318/) - La PEP officielle
- [Python Documentation - Decorators](https://docs.python.org/3/glossary.html#term-decorator)
