# Clean Architecture

## Origine

Le **Clean Architecture** est un pattern d'architecture logicielle créé par **Robert C. Martin** (surnommé "Uncle Bob") dans son livre *"Clean Architecture: A Craftsman's Guide to Software Structure and Design"* (2017).

## Principes clés

### 1. Indépendant des frameworks
L'architecture ne dépend pas d'une bibliothèque spécifique. Les frameworks sont des outils, pas des contraintes.

### 2. Testable
Les règles métier peuvent être testées sans UI, base de données, serveur web ou tout autre élément externe.

### 3. Indépendant de l'UI
L'interface utilisateur peut changer sans modifier le reste du système. Une interface web peut être remplacée par une interface CLI sans changer les règles métier.

### 4. Indépendant de la base de données
Vous pouvez changer de base de données (SQLite vers PostgreSQL, par exemple) sans toucher aux règles métier.

### 5. Indépendant de toute agence externe
Les règles métier ne connaissent rien du monde extérieur.

## La règle de dépendance

> Les dépendances du code source ne peuvent pointer que vers l'intérieur.

Les cercles concentriques représentent différentes zones du logiciel :
- **Cercles intérieurs** : Policies (règles métier de haut niveau)
- **Cercles extérieurs** : Mechanisms (détails techniques d'implémentation)

```
┌─────────────────────────────────────────────────────────────┐
│                  Frameworks & Drivers                        │
│                    (External Layer)                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Interface Adapters                      │    │
│  │           (Controllers, Presenters)                  │    │
│  │  ┌─────────────────────────────────────────────┐    │    │
│  │  │            Application Business Rules        │    │    │
│  │  │               (Use Cases)                    │    │    │
│  │  │  ┌─────────────────────────────────────┐    │    │    │
│  │  │  │     Enterprise Business Rules       │    │    │    │
│  │  │  │          (Entities)                 │    │    │    │
│  │  │  └─────────────────────────────────────┘    │    │    │
│  │  └─────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              ↑
                    Dependency Direction
                    (always points inward)
```

## Application dans Epic Events CRM

Notre architecture respecte ces principes :

```
┌─────────────────────────────────────────────────────────────┐
│                    CLI (Interface)                           │
│                  src/cli/commands.py                         │
│              (Typer - User Interface)                        │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  Services (Business Logic)                   │
│  src/services/{auth,user,client,contract,event}_service.py  │
│            (Logique métier pure)                             │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Repositories (Data Access)                      │
│  src/repositories/sqlalchemy_*_repository.py                 │
│        (Interface avec la base de données)                   │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  Models (Domain)                             │
│       src/models/{user,client,contract,event}.py             │
│          (Entités métier)                                    │
└─────────────────────────────────────────────────────────────┘
```

### Correspondance avec les couches Clean Architecture

| Couche Clean Architecture | Implémentation Epic Events |
|---------------------------|---------------------------|
| Entities | `src/models/` |
| Use Cases | `src/services/` |
| Interface Adapters | `src/repositories/`, `src/cli/` |
| Frameworks & Drivers | SQLAlchemy, Typer, Sentry |

## Comment Epic Events CRM respecte le Clean Architecture

### 1. Indépendant des frameworks

**Principe** : Les frameworks sont des outils, pas des contraintes.

**Dans notre code** :
- Les **services** (`src/services/`) ne connaissent pas Typer (CLI) ni SQLAlchemy directement
- Le service `UserService` travaille avec une abstraction `UserRepository`, pas avec `SqlAlchemyUserRepository`
- Si on veut remplacer Typer par une API REST (FastAPI), seule la couche `src/cli/` change

```python
# src/services/user_service.py
class UserService:
    def __init__(self, repository: UserRepository):  # Abstraction, pas SQLAlchemy
        self.repository = repository
```

### 2. Testable

**Principe** : Les règles métier peuvent être testées sans UI, base de données, etc.

**Dans notre code** :
- Les tests unitaires utilisent des **mocks** pour les repositories
- On peut tester `UserService` sans base de données réelle
- L'injection de dépendances (`src/containers.py`) permet de substituer les implémentations

```python
# tests/unit/test_user_service.py
def test_create_user():
    mock_repo = Mock(spec=UserRepository)
    service = UserService(repository=mock_repo)
    # Test sans base de données
```

### 3. Indépendant de l'UI

**Principe** : L'interface peut changer sans modifier le reste du système.

**Dans notre code** :
- La couche CLI (`src/cli/commands/`) appelle les services
- Les services ne savent pas qu'ils sont appelés depuis une CLI
- On pourrait créer une API REST qui appelle les mêmes services

```python
# src/cli/commands/user_commands.py (CLI)
@app.command()
def create_user(...):
    container = Container()
    user_service = container.user_service()
    user = user_service.create_user(...)  # Même appel depuis CLI ou API

# Hypothétique API REST (même logique)
@router.post("/users")
def create_user_api(...):
    container = Container()
    user_service = container.user_service()
    user = user_service.create_user(...)  # Même service réutilisé
```

### 4. Indépendant de la base de données

**Principe** : Changer de base de données sans toucher aux règles métier.

**Dans notre code** :
- Les **repositories abstraits** (`src/repositories/user_repository.py`) définissent l'interface
- Les **implémentations SQLAlchemy** (`src/repositories/sqlalchemy_user_repository.py`) sont interchangeables
- Pour passer de SQLite à PostgreSQL : changer uniquement `DATABASE_URL`
- Pour passer à MongoDB : créer `MongoUserRepository` qui implémente `UserRepository`

```python
# src/repositories/user_repository.py (abstraction)
class UserRepository(ABC):
    @abstractmethod
    def get_by_id(self, user_id: int) -> Optional[User]:
        pass

# src/repositories/sqlalchemy_user_repository.py (implémentation)
class SqlAlchemyUserRepository(UserRepository):
    def get_by_id(self, user_id: int) -> Optional[User]:
        return self.session.query(User).filter_by(id=user_id).first()

# Hypothétique implémentation MongoDB (même interface)
class MongoUserRepository(UserRepository):
    def get_by_id(self, user_id: int) -> Optional[User]:
        return self.collection.find_one({"id": user_id})
```

### 5. Règle de dépendance respectée

**Principe** : Les dépendances pointent vers l'intérieur (vers les règles métier).

**Dans notre code** :

```
CLI (commandes Typer)
    ↓ dépend de
Services (logique métier)
    ↓ dépend de
Repositories (abstractions)
    ↓ implémenté par
SQLAlchemy Repositories (détails techniques)
```

- `user_commands.py` importe `UserService` (pas l'inverse)
- `UserService` importe `UserRepository` (abstraction, pas SQLAlchemy)
- `SqlAlchemyUserRepository` implémente `UserRepository`

**Aucune couche interne ne connaît les couches externes** :
- `User` (model) ne sait pas qu'il est stocké avec SQLAlchemy
- `UserService` ne sait pas qu'il est appelé depuis une CLI
- `UserRepository` ne sait pas qu'il est implémenté avec SQLAlchemy

### Récapitulatif de conformité

| Principe Clean Architecture | Respecté | Comment |
|----------------------------|----------|---------|
| Indépendant des frameworks | ✅ | Services découplés de Typer et SQLAlchemy |
| Testable | ✅ | Mocks des repositories dans les tests |
| Indépendant de l'UI | ✅ | CLI appelle services, services ignorent CLI |
| Indépendant de la DB | ✅ | Repositories abstraits + implémentations |
| Règle de dépendance | ✅ | Dépendances pointent vers l'intérieur |

## Lien avec SOLID

Le principe **Dependency Inversion** (le "D" de SOLID) est essentiel au Clean Architecture. Il permet d'isoler les composants stables des changements dans les composants instables.

## Ressources

- [The Clean Architecture - Blog Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Clean Architecture - O'Reilly](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/)
- [Summary of Clean Architecture - GitHub](https://gist.github.com/ygrenzinger/14812a56b9221c9feca0b3621518635b)
