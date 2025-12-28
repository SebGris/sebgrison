# Flux de création d'un client - Cheminement du code

Ce document explique le cheminement complet du code lors de l'exécution de la commande `epicevents create-client`.

## Vue d'ensemble

```
Commande CLI → main.py → Container → client_commands.py → Services → Repositories → Base de données
```

## Étape par étape

### 1. Point d'entrée : `poetry run epicevents create-client`

**Fichier** : `pyproject.toml`
```toml
[tool.poetry.scripts]
epicevents = "src.cli.main:main"
```

Poetry exécute la fonction `main()` du module `src.cli.main`.

---

### 2. Initialisation de l'application

**Fichier** : `src/cli/main.py`

```python
def main():
    """Main entry point for the application."""
    # 1. Initialize Sentry for error tracking
    init_sentry()

    # 2. Launch the Typer application
    try:
        commands.app()
    except Exception as e:
        # Capture unhandled exceptions in Sentry
        capture_exception(e, context={"location": "main"})
        raise
```

**Ce qui se passe** :
1. Initialisation de Sentry pour le monitoring des erreurs
2. Lancement de l'application Typer qui attend les commandes de l'utilisateur
3. Capture des exceptions non gérées dans Sentry

> **Note** : L'injection de dépendances se fait manuellement dans chaque commande via `Container()`, ce qui est plus simple et explicite.

---

### 3. Configuration des dépendances

**Fichier** : `src/containers.py`

```python
class Container(containers.DeclarativeContainer):
    # Database session resource (context manager)
    db_session = providers.Resource(get_db_session)

    # Repositories
    client_repository = providers.Factory(
        SqlAlchemyClientRepository,
        session=db_session,
    )

    user_repository = providers.Factory(
        SqlAlchemyUserRepository,
        session=db_session,
    )

    # Services
    client_service = providers.Factory(
        ClientService,
        repository=client_repository,
    )

    user_service = providers.Factory(
        UserService,
        repository=user_repository,
    )
```

**Ce qui se passe** :
- Le container définit comment créire chaque composant
- `Resource` : Gère le cycle de vie de la session DB (création/fermeture)
- `Factory` : Crée une nouvelle instance à chaque appel
- Les dépendances sont injectées automatiquement (ex: `client_service` reçoit `client_repository`)

---

### 4. Vérification des permissions (décorateur)

**Fichier** : `src/cli/permissions.py`

```python
@require_department(Department.COMMERCIAL, Department.GESTION)
def create_client(...):
```

**Ce qui se passe** :
1. Le décorateur `@require_department` s'exécute AVANT la commande
2. Il crée un `Container()` pour obtenir `auth_service`
3. Il vérifie que l'utilisateur est authentifié (token JWT valide)
4. Il vérifie que l'utilisateur appartient à COMMERCIAL ou GESTION
5. Si OK, la commande continue ; sinon, erreur et exit

---

### 5. Réception de la commande

**Fichier** : `src/cli/commands/client_commands.py`

```python
@app.command()
@require_department(Department.COMMERCIAL, Department.GESTION)
def create_client(
    first_name: str = typer.Option(..., prompt="Prénom", callback=validators.validate_first_name_callback),
    last_name: str = typer.Option(..., prompt="Nom", callback=validators.validate_last_name_callback),
    email: str = typer.Option(..., prompt="Email", callback=validators.validate_email_callback),
    phone: str = typer.Option(..., prompt="Téléphone", callback=validators.validate_phone_callback),
    company_name: str = typer.Option(..., prompt="Nom de l'entreprise", callback=validators.validate_company_name_callback),
    sales_contact_id: int = typer.Option(0, prompt="ID du contact commercial", callback=validators.validate_sales_contact_id_callback),
):
```

**Ce qui se passe** :
1. Typer affiche les prompts interactifs pour chaque paramètre
2. Chaque valeur saisie passe par un callback de validation (ex: `validate_email_callback`)
3. Si la validation échoue, une erreur `typer.BadParameter` est levée
4. Une fois toutes les données collectées et validées, la fonction continue

---

### 6. Récupération des services

**Fichier** : `src/cli/commands/client_commands.py`

```python
# Manually get services from container
container = Container()
client_service = container.client_service()
user_service = container.user_service()
auth_service = container.auth_service()
```

**Ce qui se passe** :
1. `container.client_service()` appelle le provider du container
2. Le container crée automatiquement :
   - Une session de base de données via `get_db_session()`
   - Un `SqlAlchemyClientRepository` avec cette session
   - Un `ClientService` avec ce repository
3. Même chose pour `user_service` et `auth_service`

**Graphe de création** :
```
container.client_service()
    └─> providers.Factory(ClientService)
        └─> repository=client_repository()
            └─> providers.Factory(SqlAlchemyClientRepository)
                └─> session=db_session()
                    └─> providers.Resource(get_db_session)
                        └─> return SessionLocal()
```

---

### 7. Auto-assignation pour les commerciaux

**Fichier** : `src/cli/commands/client_commands.py`

```python
# Get current user from auth_service
current_user = auth_service.get_current_user()

# Auto-assign for COMMERCIAL users if no sales_contact_id provided
if sales_contact_id == 0:
    if current_user.department == Department.COMMERCIAL:
        sales_contact_id = current_user.id
        console.print_field("Contact commercial", f"Auto-assigné à {current_user.username}")
    else:
        console.print_error("Vous devez spécifier un ID de contact commercial")
        raise typer.Exit(code=1)
```

**Ce qui se passe** :
1. Récupération de l'utilisateur connecté via le token JWT
2. Si l'utilisateur est COMMERCIAL et n'a pas spécifié de contact, auto-assignation
3. Sinon (GESTION), un ID de contact commercial est obligatoire

---

### 8. Validation métier : Vérification du contact commercial

**Fichier** : `src/cli/commands/client_commands.py`

```python
# Business validation: check if sales contact exists and is from COMMERCIAL dept
user = user_service.get_user(sales_contact_id)

if not user:
    console.print_error(f"Utilisateur avec l'ID {sales_contact_id} n'existe pas")
    raise typer.Exit(code=1)

try:
    validators.validate_user_is_commercial(user)
except ValueError as e:
    console.print_error(str(e))
    raise typer.Exit(code=1)
```

**Ce qui se passe** :
1. Appel de `user_service.get_user()` → Chemin : **Service → Repository → Base de données**
2. Vérification que l'utilisateur existe
3. Vérification que l'utilisateur est bien du département COMMERCIAL

**Détail du chemin d'exécution** :

```
user_service.get_user(sales_contact_id)
    ↓
[src/services/user_service.py]
def get_user(self, user_id: int) -> User:
    return self.repository.get(user_id)
    ↓
[src/repositories/sqlalchemy_user_repository.py]
def get(self, user_id: int) -> User:
    return self.session.query(User).filter_by(id=user_id).first()
    ↓
[Base de données] SELECT * FROM users WHERE id = ?
    ↓
Retourne un objet User ou None
```

---

### 9. Création du client via le service

**Fichier** : `src/cli/commands/client_commands.py`

```python
client = client_service.create_client(
    first_name=first_name,
    last_name=last_name,
    email=email,
    phone=phone,
    company_name=company_name,
    sales_contact_id=sales_contact_id,
)
```

**Détail du chemin d'exécution** :

```
client_service.create_client(...)
    ↓
[src/services/client_service.py]
def create_client(self, first_name, last_name, ...):
    # 1. Créer l'objet Client
    client = Client(
        first_name=first_name,
        last_name=last_name,
        email=email,
        phone=phone,
        company_name=company_name,
        sales_contact_id=sales_contact_id,
    )

    # 2. Persister via le repository
    self.repository.add(client)

    # 3. Retourner le client créé
    return client
    ↓
[src/repositories/sqlalchemy_client_repository.py]
def add(self, client: Client) -> Client:
    self.session.add(client)      # Ajoute à la session SQLAlchemy
    self.session.commit()          # Commit la transaction en base
    self.session.refresh(client)   # Rafraîchit pour récupérer l'ID
    return client
    ↓
[Base de données] INSERT INTO clients (first_name, last_name, ...) VALUES (?, ?, ...)
    ↓
Le client est créé en base avec un ID auto-généré
```

---

### 10. Affichage du résultat

**Fichier** : `src/cli/commands/client_commands.py`

```python
console.print_separator()
console.print_success(f"Client {client.first_name} {client.last_name} créé avec succès!")
console.print_field("ID", str(client.id))
console.print_field("Email", client.email)
console.print_field("Téléphone", client.phone)
console.print_field("Entreprise", client.company_name)
console.print_field("Contact commercial", f"{client.sales_contact.first_name} {client.sales_contact.last_name}")
console.print_field("Date de création", client.created_at.strftime("%d/%m/%Y %H:%M"))
console.print_separator()
```

**Ce qui se passe** :
- Affichage du message de succès avec les informations du client
- L'ID est maintenant disponible car SQLAlchemy l'a récupéré après l'INSERT
- Les relations (sales_contact) sont chargées automatiquement par SQLAlchemy

---

## Schéma complet du flux

```
┌──────────────────────────────────────────────────────────────┐
│ 1. CLI: poetry run epicevents create-client                  │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ 2. main.py                                                    │
│    - Initialise Sentry                                        │
│    - Lance l'app Typer                                        │
│    - Capture les exceptions non gérées                        │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ 3. Décorateur @require_department                             │
│    - Vérifie l'authentification (token JWT)                   │
│    - Vérifie le département de l'utilisateur                  │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ 4. client_commands.py: create_client()                        │
│    - Prompts interactifs (Typer)                              │
│    - Validation des entrées (callbacks)                       │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ 5. Récupération des services depuis le container             │
│    container = Container()                                    │
│    client_service = container.client_service()                │
│    user_service = container.user_service()                    │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ 6. Auto-assignation (si COMMERCIAL)                           │
│    current_user = auth_service.get_current_user()             │
│    sales_contact_id = current_user.id                         │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ 7. Validation métier                                          │
│    user_service.get_user(sales_contact_id)                    │
│      → UserService.get_user()                                 │
│        → UserRepository.get()                                 │
│          → SELECT FROM users WHERE id = ?                     │
│    Vérifie: existe? + département COMMERCIAL?                 │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ 8. Création du client                                         │
│    client_service.create_client(...)                          │
│      → ClientService.create_client()                          │
│        1. Crée l'objet Client                                 │
│        2. repository.add(client)                              │
│          → INSERT INTO clients                                │
│        3. Return client (avec ID)                             │
└────────────────────┬─────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────────────┐
│ 9. Affichage du résultat                                      │
│    [SUCCÈS] Client créé avec succès!                          │
│    ID: 1                                                      │
│    Email: ...                                                 │
└──────────────────────────────────────────────────────────────┘
```

## Points clés de l'architecture

### Séparation des responsabilités

| Couche | Responsabilité | Fichiers |
|--------|----------------|----------|
| **CLI** | Interface utilisateur, validation des entrées | `src/cli/commands/*.py` |
| **Services** | Logique métier | `src/services/*_service.py` |
| **Repositories** | Accès aux données | `src/repositories/sqlalchemy_*_repository.py` |
| **Models** | Structure des données | `src/models/*.py` |
| **Container** | Injection de dépendances | `src/containers.py` |

### Avantages de cette architecture

1. **Testabilité** : Chaque couche peut être testée indépendamment
2. **Maintenabilité** : Changement localisé (ex: changer de DB n'affecte que les repositories)
3. **Réutilisabilité** : Les services peuvent être utilisés depuis d'autres interfaces (API, GUI, etc.)
4. **Découplage** : Les commandes CLI ne connaissent pas les détails de la base de données
5. **Injection de dépendances** : Facilite le mocking et les tests

### Cycle de vie des objets

```
Container (créé par commande)
    ↓
db_session (Resource - gère le cycle de vie)
    ↓
Repositories (Factory - nouveaux par commande)
    ↓
Services (Factory - nouveaux par commande)
```

Chaque commande reçoit ses propres instances de services et repositories avec une nouvelle session DB, évitant les problèmes de partage d'état entre commandes.

## Fichiers impliqués

| Fichier | Rôle |
|---------|------|
| `pyproject.toml` | Point d'entrée de l'application |
| `src/cli/main.py` | Initialisation et lancement |
| `src/containers.py` | Configuration des dépendances |
| `src/cli/permissions.py` | Décorateurs de permissions |
| `src/cli/commands/client_commands.py` | Commandes CLI clients |
| `src/services/client_service.py` | Logique métier clients |
| `src/services/user_service.py` | Logique métier utilisateurs |
| `src/repositories/sqlalchemy_client_repository.py` | Accès données clients |
| `src/repositories/sqlalchemy_user_repository.py` | Accès données utilisateurs |
| `src/models/client.py` | Modèle Client |
| `src/models/user.py` | Modèle User |
| `src/database.py` | Configuration de la base de données |

## Exemple d'exécution complète

```bash
$ poetry run epicevents create-client

Prénom: Jean
Nom: Dupont
Email: jean.dupont@example.com
Téléphone: 0612345678
Nom de l'entreprise: Acme Corp
ID du contact commercial: [ENTRER pour auto-assignation]

══════════════════════════════════════════════════════════════
  Création d'un nouveau client
══════════════════════════════════════════════════════════════
Contact commercial : Auto-assigné à commercial1
──────────────────────────────────────────────────────────────
[SUCCÈS] Client Jean Dupont créé avec succès!
  ID           : 42
  Email        : jean.dupont@example.com
  Téléphone    : 0612345678
  Entreprise   : Acme Corp
  Commercial   : Commercial User (ID: 1)
  Créé le      : 28/12/2025 14:30
══════════════════════════════════════════════════════════════
```

**Ce qui s'est passé en coulisses** :
1. Vérification de l'authentification (token JWT valide)
2. Vérification des permissions (COMMERCIAL ou GESTION)
3. Validation de chaque input (email, téléphone, etc.)
4. Auto-assignation du commercial (utilisateur connecté)
5. Vérification que l'utilisateur ID=1 existe et est COMMERCIAL
6. Création de l'objet Client en mémoire
7. INSERT en base de données
8. Récupération de l'ID auto-généré (42)
9. Affichage du résultat
