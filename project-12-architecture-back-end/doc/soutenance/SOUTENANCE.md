# Guide de Soutenance - Epic Events CRM

**Durée totale** : 25 minutes (10 min présentation + 15 min discussion)

---

## 📋 Structure de la soutenance

### Partie 1 : Présentation des livrables (10 minutes)

> **6 commandes CLI + explications de code**

1. [Vue d'ensemble](#1-vue-densemble-30-sec) (30 sec)
2. [Authentification](#2-authentification-3-min) - 2 commandes + code (3 min)
3. [Création utilisateur - Contrôle d'accès](#3-création-dutilisateur---contrôle-daccès-2-min-30) - 2 commandes + code (2 min 30)
4. [Lecture/Modification des données](#4-lecturemodification-des-données-3-min) - 2 commandes + code (3 min)
5. [Récapitulatif](#5-récapitulatif-1-min) (1 min)

### Partie 2 : Discussion technique (15 minutes)

1. [Schéma de la base de données](#schéma-de-la-base-de-données)
2. [Sécurité - Risques classiques](#sécurité---risques-classiques)
3. [Bonnes pratiques de l'industrie](#bonnes-pratiques-de-lindustrie)

---

# PARTIE 1 : PRÉSENTATION DES LIVRABLES (10 minutes)

> **⚠️ IMPORTANT** : Cette démonstration combine commandes CLI + explications de code.
> Ouvrir VS Code avec le projet AVANT la soutenance.

---

## 1. Vue d'ensemble (30 sec)

**Dire** :
> "Bonjour Dawn, je vais vous présenter le système CRM Epic Events. C'est une application CLI sécurisée avec :
> - Authentification JWT
> - Contrôle d'accès par rôles (3 départements)
> - Protection injection SQL via SQLAlchemy
> - Monitoring Sentry"

---

## 2. Authentification (3 min)

### Commande 1 : Tentative sans auth

```bash
poetry run epicevents whoami
```

**Dire** : "Sans authentification, l'accès est refusé."

### 💻 Montrer le code : `src/cli/commands/auth_commands.py` (lignes 124-130)

```python
user = auth_service.get_current_user()

if not user:
    console.print_error(
        "Vous n'êtes pas connecté. Utilisez 'epicevents login' pour vous connecter."
    )
    raise typer.Exit(code=1)
```

**Dire** :
> "La commande vérifie si un token JWT valide existe. `get_current_user()` retourne None si pas de token ou token expiré → refus."

### Commande 2 : Connexion GESTION

```bash
poetry run epicevents login
# admin / Admin123!
```

### 💻 Montrer le code : `src/services/token_service.py` (lignes 31-32 + 73-85)

```python
# Configuration JWT (lignes 31-32)
TOKEN_EXPIRATION_HOURS = 24
ALGORITHM = "HS256"  # HMAC-SHA256

# Génération du token (lignes 73-85)
now = datetime.now(timezone.utc)
expiration = now + timedelta(hours=self.TOKEN_EXPIRATION_HOURS)

payload = {
    "user_id": user.id,
    "username": user.username,
    "department": user.department.value,
    "exp": expiration,
    "iat": now,
}
token = jwt.encode(payload, self._secret_key, algorithm=self.ALGORITHM)
```

**Dire** :
> "Le token JWT est signé avec HMAC-SHA256. La clé secrète vient des variables d'environnement, jamais hardcodée."

---

## 3. Création d'utilisateur - Contrôle d'accès (2 min 30)

### Commande 3 : Créer un utilisateur (connecté admin/GESTION)

```bash
poetry run epicevents create-user
# demo_user / Demo / User / demo@test.com / 0123456789 / Demo123! / 1
```

### 💻 Montrer le code : `src/cli/commands/user_commands.py` (lignes 13-15)

```python
@app.command()
@require_department(Department.GESTION)  # ← Seul GESTION autorisé
def create_user(...):
```

### 💻 Montrer le code : `src/services/password_hashing_service.py` (lignes 38-41)

```python
def hash_password(self, password: str) -> str:
    password_bytes = password.encode("utf-8")
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password_bytes, salt)
    return hashed.decode("utf-8")
```

**Dire** :
> "Le mot de passe est hashé avec bcrypt + salt unique. Jamais stocké en clair."

### Commande 4 : Test refus COMMERCIAL

```bash
poetry run epicevents logout && poetry run epicevents login
# commercial1 / Commercial123!
poetry run epicevents create-user
```

**Dire** : "COMMERCIAL ne peut pas créer d'utilisateurs → refus avec message explicite."

---

## 4. Lecture/Modification des données (3 min)

### Commande 5 : Créer un client (connecté commercial1)

```bash
poetry run epicevents create-client
# Jean / Test / jean@test.com / 0612345678 / TestCorp / (ENTRER)
```

### 💻 Montrer le code : `src/cli/commands/client_commands.py` (lignes 76-78)

```python
if sales_contact_id == 0:
    if current_user.department == Department.COMMERCIAL:
        sales_contact_id = current_user.id  # Auto-assignation
```

**Dire** :
> "Auto-assignation : un commercial est automatiquement assigné à ses propres clients. Sécurité contre l'usurpation."

### Commande 6 : Filtrer contrats non signés

```bash
poetry run epicevents filter-unsigned-contracts
```

### 💻 Montrer le code : `src/repositories/sqlalchemy_contract_repository.py`

```python
def get_unsigned_contracts(self) -> List[Contract]:
    return self.session.query(Contract).filter_by(is_signed=False).all()
```

**Dire** :
> "Pas de `get_all()` dans l'application. Tout est filtré contextuellement. C'est le principe du moindre privilège."

### 💻 Montrer le code : Protection injection SQL

```python
# ✅ SQLAlchemy génère des requêtes paramétrées
session.query(Contract).filter_by(is_signed=False)
# → SELECT * FROM contracts WHERE is_signed = ?

# ❌ Jamais de concaténation SQL directe
```

**Dire** :
> "SQLAlchemy ORM protège contre l'injection SQL avec des requêtes paramétrées."

---

## 5. Récapitulatif (1 min)

**Dire** :
> "En résumé, l'application implémente :
>
> 1. **Auth JWT** signé HMAC-SHA256, expiration 24h
> 2. **Contrôle d'accès par rôles** avec décorateur `@require_department`
> 3. **Bcrypt** pour les mots de passe
> 4. **ORM SQLAlchemy** contre injection SQL
> 5. **Filtres contextuels** au lieu de get_all()
> 6. **Sentry** pour le monitoring
>
> L'architecture suit Clean Architecture : CLI → Services → Repositories → Models."

---

# PARTIE 2 : DISCUSSION TECHNIQUE (15 minutes)

## Schéma de la base de données

### Question attendue
> "Pouvez-vous expliquer la logique du schéma de votre base de données ?"

### 📊 Réponse structurée

#### Diagramme à présenter

```
┌──────────────────────────┐
│         User             │
│ ──────────────────────── │
│ PK  id                   │
│ UQ  username             │
│ UQ  email                │
│     password_hash        │◄─────┐
│     first_name           │      │
│     last_name            │      │
│     phone                │      │
│     department (ENUM)    │      │
│     created_at           │      │
│     updated_at           │      │
└────────────┬─────────────┘      │
             │ 1                  │
             │                    │
             │ *                  │
      ┌──────▼──────────────┐    │
      │     Client          │    │
      │ ─────────────────── │    │
      │ PK  id              │    │
      │ UQ  email           │    │
      │     first_name      │    │
      │     last_name       │    │
      │     phone           │    │
      │     company_name    │    │
      │ FK  sales_contact_id├────┘
      │     created_at      │
      │     updated_at      │
      └──────┬──────────────┘
             │ 1
             │
             │ *
      ┌──────▼──────────────┐
      │     Contract        │
      │ ─────────────────── │
      │ PK  id              │
      │ FK  client_id       │
      │     total_amount    │
      │     remaining_amount│
      │     is_signed       │
      │     created_at      │
      │     updated_at      │
      └──────┬──────────────┘
             │ 1
             │
             │ *
      ┌──────▼──────────────┐       ┌──────────────────────┐
      │     Event           │       │         User         │
      │ ─────────────────── │       │  (SUPPORT contact)   │
      │ PK  id              │     * │                      │
      │     name            ├───────┤                      │
      │ FK  contract_id     │       │                      │
      │ FK  support_contact ├───────►                      │
      │     event_start     │       └──────────────────────┘
      │     event_end       │
      │     location        │
      │     attendees       │
      │     notes           │
      │     created_at      │
      │     updated_at      │
      └─────────────────────┘
```

#### Explication détaillée

**1. Entité User (pivot central)**
> "La table User est centrale car elle sert pour deux rôles distincts :
> - **Sales contact** : Un utilisateur COMMERCIAL assigné à des clients
> - **Support contact** : Un utilisateur SUPPORT assigné à des événements
>
> Le champ `department` (ENUM) définit le rôle : COMMERCIAL, GESTION, ou SUPPORT."

**2. Relations hiérarchiques**
> "Les relations suivent le flux métier :
> - Un **Commercial** (User) gère plusieurs **Clients**
> - Un **Client** a plusieurs **Contrats**
> - Un **Contrat** (signé) génère plusieurs **Événements**
> - Un **Support** (User) est assigné à plusieurs **Événements**
>
> C'est une cascade logique qui reflète le processus commercial."

**3. Contraintes d'intégrité**

| Contrainte | Table | Colonne | Rôle de sécurité |
|------------|-------|---------|------------------|
| PRIMARY KEY | Toutes | id | Identification unique |
| UNIQUE | User | username, email | Empêche les doublons d'utilisateurs |
| UNIQUE | Client | email | Un client = un email unique |
| FOREIGN KEY | Client | sales_contact_id | Garantit l'existence du commercial |
| FOREIGN KEY | Contract | client_id | Garantit l'existence du client |
| FOREIGN KEY | Event | contract_id | Garantit l'existence du contrat |
| FOREIGN KEY | Event | support_contact_id | Garantit l'existence du support |
| NOT NULL | User | password_hash | Impossible de créer un user sans mdp |
| NOT NULL | Contract | total_amount | Montant obligatoire |
| CHECK (implicite) | Contract | remaining_amount >= 0 | Validé par l'application |

**4. Timestamps automatiques**
> "Chaque table a `created_at` et `updated_at` :
> - **Traçabilité** : Savoir quand une donnée a été créée/modifiée
> - **Audit** : Détecter les modifications suspectes
> - **Sécurité** : Logs temporels pour Sentry"

**5. Types de données sécurisés**

| Colonne | Type SQL | Longueur | Justification |
|---------|----------|----------|---------------|
| username | VARCHAR | 50 | Limite les attaques par buffer overflow |
| email | VARCHAR | 255 | Standard RFC 5321 |
| password_hash | VARCHAR | 255 | Bcrypt génère ~60 caractères |
| phone | VARCHAR | 20 | Numéros internationaux |
| total_amount | DECIMAL | 10,2 | Précision monétaire |

---

## Sécurité - Risques classiques

### Question attendue
> "Comment votre implémentation limite-t-elle les risques classiques comme l'injection SQL, les fuites de données, et la validation des données utilisateur ?"

### 🛡️ Réponse structurée

#### 1. Protection contre l'injection SQL

**Risque** :
> "L'injection SQL permet à un attaquant d'exécuter du code SQL arbitraire en manipulant les inputs."

**Exemple d'attaque** :
```python
# ❌ Code vulnérable (que nous N'UTILISONS PAS)
username = input("Username: ")
query = f"SELECT * FROM users WHERE username = '{username}'"
# Un attaquant entre : ' OR '1'='1' --
# Résultat : SELECT * FROM users WHERE username = '' OR '1'='1' --'
# Accès à tous les utilisateurs !
```

**Notre protection** :
> "Nous utilisons SQLAlchemy ORM qui génère automatiquement des requêtes paramétrées :"

```python
# ✅ Code sécurisé (notre implémentation)
user = session.query(User).filter_by(username=username).first()
# SQLAlchemy génère : SELECT * FROM users WHERE username = ?
# Paramètre bindé séparément, impossible d'injecter du SQL
```

**Démonstration de code** : `src/repositories/sqlalchemy_user_repository.py:46-55`

```python
def get_by_username(self, username: str) -> Optional[User]:
    return self.session.query(User).filter_by(username=username).first()
```

**Points clés** :
- ✅ Aucune concaténation de chaînes SQL
- ✅ ORM avec requêtes paramétrées
- ✅ Validation des types avant la requête

---

#### 2. Protection contre les fuites de données

**Risque** :
> "Les fuites de données surviennent quand un utilisateur accède à plus de données qu'il ne devrait."

**Exemple de vulnérabilité** :
```python
# ❌ Méthode dangereuse (que nous avons SUPPRIMÉE)
def get_all_clients():
    return session.query(Client).all()
# Un commercial peut voir TOUS les clients, même ceux des autres !
```

**Notre protection - Principe du moindre privilège** :

**a) Suppression des get_all()**
> "Nous avons supprimé toutes les méthodes `get_all()` et les avons remplacées par des filtres contextuels :"

```python
# ✅ Filtre contextuel (notre implémentation)
def get_clients_by_sales_contact(self, sales_contact_id: int):
    return self.session.query(Client).filter_by(
        sales_contact_id=sales_contact_id
    ).all()
# Un commercial voit uniquement SES clients
```

**b) Vérification d'ownership dans les commandes**

`src/cli/commands/client_commands.py`

```python
# Permission check: COMMERCIAL can only update their own clients
if current_user.department == Department.COMMERCIAL:
    if client.sales_contact_id != current_user.id:
        console.print_error("Vous ne pouvez modifier que vos propres clients")
        raise typer.Exit(code=1)
# GESTION peut modifier tous les clients (pas de restriction)
```

**c) Décorateurs de permission**

`src/cli/permissions.py:22-90`

```python
@require_department(Department.COMMERCIAL, Department.GESTION)
def create_client(...):
    # Seuls COMMERCIAL et GESTION peuvent créer des clients
```

**Matrice de contrôle d'accès** :

| Action | GESTION | COMMERCIAL | SUPPORT |
|--------|---------|------------|---------|
| Voir tous les clients | ✅ | ❌ | ❌ |
| Voir ses clients | ✅ | ✅ | ❌ |
| Modifier tous les clients | ✅ | ❌ | ❌ |
| Modifier ses clients | ✅ | ✅ | ❌ |

**Points clés** :
- ✅ Pas de `get_all()` - tout est filtré
- ✅ Vérification d'ownership systématique
- ✅ Contrôle d'accès par rôles avec décorateurs
- ✅ Filtres contextuels uniquement

---

#### 3. Validation des données utilisateur

**Risque** :
> "Des données invalides peuvent causer des erreurs, des bugs, ou être exploitées pour des attaques (XSS, buffer overflow, etc.)."

**Notre protection - Triple validation** :

**a) Validation au niveau CLI (première ligne)**

`src/cli/validators.py`

```python
def validate_email_callback(value: str) -> str:
    email_regex = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    if not re.match(email_regex, value):
        raise typer.BadParameter("Format d'email invalide")
    return value

def validate_phone_callback(value: str) -> str:
    phone_clean = re.sub(r"[\s\-\(\)]", "", value)
    if len(phone_clean) < 10:
        raise typer.BadParameter("Le numéro doit contenir au moins 10 chiffres")
    return value

def validate_amount_callback(value: str) -> str:
    try:
        amount = Decimal(value)
        if amount < 0:
            raise typer.BadParameter("Le montant ne peut pas être négatif")
        return value
    except InvalidOperation:
        raise typer.BadParameter("Format de montant invalide")
```

**b) Validation au niveau Service (logique métier)**

`src/services/contract_service.py`

```python
from src.cli.validators import validate_contract_amounts

def create_contract(self, ...):
    # Validation métier
    validate_contract_amounts(
        Decimal(total_amount),
        Decimal(remaining_amount)
    )
    # Vérifie que remaining_amount <= total_amount
```

**c) Validation au niveau Base de données (contraintes)**

```python
# Modèle SQLAlchemy
class User(Base):
    username: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    # SQLAlchemy garantit l'unicité et la non-nullité
```

**Liste complète des validations** :

| Donnée | Validation CLI | Validation Service | Contrainte DB |
|--------|----------------|-------------------|---------------|
| Email | Regex RFC 5322 | - | UNIQUE, NOT NULL |
| Username | Regex (4-50 chars) | - | UNIQUE, NOT NULL, VARCHAR(50) |
| Password | Min 8 caractères | Hachage bcrypt | NOT NULL, VARCHAR(255) |
| Phone | Min 10 chiffres | - | NOT NULL, VARCHAR(20) |
| Montants | Decimal >= 0 | remaining <= total | NOT NULL, DECIMAL(10,2) |
| Dates | Format ISO | Parsing datetime | NOT NULL |
| Department | Enum valide | - | ENUM |

**Points clés** :
- ✅ Validation en trois couches (défense en profondeur)
- ✅ Regex pour formats structurés
- ✅ Type checking avec Decimal, datetime
- ✅ Contraintes DB comme dernier rempart
- ✅ Messages d'erreur clairs sans détails techniques

---

#### 4. Protection des mots de passe

**Risque** :
> "Stockage en clair des mots de passe = catastrophe en cas de fuite de la base de données."

**Notre protection - Bcrypt avec salt** :

`src/services/password_hashing_service.py:23-63`

```python
def hash_password(self, password: str) -> str:
    """Hash a plain text password using bcrypt."""
    password_bytes = password.encode("utf-8")
    salt = bcrypt.gensalt()  # Salt unique automatique
    hashed = bcrypt.hashpw(password_bytes, salt)
    return hashed.decode("utf-8")

def verify_password(self, password: str, password_hash: str) -> bool:
    """Verify a password against its hash using bcrypt."""
    password_bytes = password.encode("utf-8")
    hash_bytes = password_hash.encode("utf-8")
    return bcrypt.checkpw(password_bytes, hash_bytes)
```

**Pourquoi bcrypt ?**
- ✅ **Salt automatique** : Chaque mot de passe a un salt unique
- ✅ **Lenteur intentionnelle** : Résistant aux attaques par force brute (~100ms/hash)
- ✅ **Work factor ajustable** : Peut augmenter la difficulté avec le temps
- ✅ **Standard de l'industrie** : Recommandé par OWASP

**Exemple de hash bcrypt** :
```
$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5jtRq5CcH6RM6
 │  │  │                        │
 │  │  │                        └─ Hash (31 chars)
 │  │  └─────────────────────────── Salt (22 chars)
 │  └────────────────────────────── Cost factor (2^12 = 4096 rounds)
 └───────────────────────────────── Algorithme (bcrypt)
```

**Points clés** :
- ✅ Jamais de mot de passe en clair dans la DB
- ✅ Salt unique par utilisateur
- ✅ Algorithme de hachage moderne (bcrypt)
- ✅ Impossible de retrouver le mot de passe d'origine

---

#### 5. Sécurité des tokens JWT

**Risque** :
> "Tokens JWT non signés ou mal configurés peuvent être forgés par un attaquant."

**Notre protection** :

`src/services/token_service.py:57-85`

```python
def generate_token(self, user: User) -> str:
    now = datetime.now(timezone.utc)
    expiration = now + timedelta(hours=self.TOKEN_EXPIRATION_HOURS)

    payload = {
        "user_id": user.id,
        "username": user.username,
        "department": user.department.value,
        "exp": expiration,  # Expiration automatique
        "iat": now,          # Issued at
    }

    token = jwt.encode(payload, self._secret_key, algorithm=self.ALGORITHM)
    return token
```

**Configuration sécurisée** :
- ✅ **Algorithme HMAC-SHA256** : Signature cryptographique forte
- ✅ **Secret key de 256 bits minimum** : Clé robuste
- ✅ **Expiration 24h** : Limite la fenêtre d'exposition
- ✅ **Stockage local sécurisé** : Permissions 600 (Unix)
- ✅ **Variable d'environnement** : Secret key non hardcodée

**Points clés** :
- ✅ Signature vérifiée à chaque requête
- ✅ Expiration automatique
- ✅ Secret key robuste et externalisée
- ✅ Impossible de forger un token sans la clé

---

## Bonnes pratiques de l'industrie

### Question attendue
> "Comment votre implémentation suit-elle les bonnes pratiques actuelles de l'industrie ?"

### 📚 Réponse structurée

#### 1. Architecture Clean Architecture / Hexagonale

**Principe** :
> "Séparation stricte des responsabilités en couches indépendantes."

**Notre implémentation** :

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

**Avantages** :
- ✅ **Testabilité** : Chaque couche testable indépendamment
- ✅ **Maintenabilité** : Changement DB sans toucher la logique
- ✅ **Réutilisabilité** : Services réutilisables (CLI → API REST)
- ✅ **Séparation des préoccupations** : Chaque couche a un rôle unique

**Référence industrie** : Clean Architecture (Robert C. Martin)

---

#### 2. Dependency Injection

**Principe** :
> "Inversion de contrôle - les dépendances sont injectées, pas instanciées."

**Notre implémentation** :

`src/containers.py`

```python
class Container(containers.DeclarativeContainer):
    # Database
    db_session = providers.Factory(get_db_session)

    # Repositories
    user_repository = providers.Factory(
        SqlAlchemyUserRepository,
        session=db_session,
    )

    # Services
    auth_service = providers.Factory(
        AuthService,
        repository=user_repository,
    )
```

**Utilisation dans les commandes** :

```python
@app.command()
def create_user(...):
    container = Container()
    user_service = container.user_service()
    # Toutes les dépendances sont injectées automatiquement
```

**Avantages** :
- ✅ **Loose coupling** : Composants découplés
- ✅ **Testabilité** : Mock facile des dépendances
- ✅ **Configuration centralisée** : Un seul endroit pour les dépendances
- ✅ **Gestion du cycle de vie** : Factory pattern pour les sessions DB

**Référence industrie** : Dependency Injection (Martin Fowler)

---

#### 3. Repository Pattern

**Principe** :
> "Abstraction de l'accès aux données - la source de données peut changer sans impacter le code."

**Notre implémentation** :

`src/repositories/user_repository.py` (Interface)

```python
class UserRepository(ABC):
    @abstractmethod
    def create(self, user: User) -> User:
        pass

    @abstractmethod
    def get_by_id(self, user_id: int) -> Optional[User]:
        pass

    @abstractmethod
    def get_by_username(self, username: str) -> Optional[User]:
        pass
```

`src/repositories/sqlalchemy_user_repository.py` (Implémentation)

```python
class SqlAlchemyUserRepository(UserRepository):
    def create(self, user: User) -> User:
        self.session.add(user)
        self.session.commit()
        return user

    # Implémentation spécifique à SQLAlchemy
```

**Avantages** :
- ✅ **Abstraction** : Le service ne connaît pas SQLAlchemy
- ✅ **Changement de DB facile** : PostgreSQL → MongoDB sans toucher les services
- ✅ **Test avec mock** : Repository mockable pour les tests unitaires
- ✅ **Single Responsibility** : Repository = accès données uniquement

**Référence industrie** : Repository Pattern (Domain-Driven Design)

---

#### 4. OWASP Top 10 - Conformité

**Référence industrie** : [OWASP Top 10 2021](https://owasp.org/Top10/)

| Risque OWASP | Notre protection | Implémentation |
|--------------|------------------|----------------|
| **A01 - Broken Access Control** | Contrôle d'accès par rôles + Ownership checks | `src/cli/permissions.py` |
| **A02 - Cryptographic Failures** | Bcrypt + JWT HMAC-SHA256 | `src/models/user.py`, `src/services/auth_service.py` |
| **A03 - Injection** | ORM SQLAlchemy paramétré | `src/repositories/sqlalchemy_*.py` |
| **A04 - Insecure Design** | Clean Architecture | Architecture globale |
| **A05 - Security Misconfiguration** | Variables d'environnement | `.env` |
| **A06 - Vulnerable Components** | Dependencies à jour (Poetry) | `pyproject.toml` |
| **A07 - Authentication Failures** | JWT + Password validation | `src/services/auth_service.py` |
| **A08 - Software/Data Integrity** | Foreign keys + Constraints | Modèles SQLAlchemy |
| **A09 - Security Logging** | Sentry + Breadcrumbs | `src/sentry_config.py` |
| **A10 - SSRF** | N/A (CLI, pas de requêtes externes) | - |

---

#### 5. Twelve-Factor App

**Référence industrie** : [12factor.net](https://12factor.net/)

| Facteur | Notre implémentation | Conformité |
|---------|---------------------|------------|
| **I. Codebase** | Git repository unique | ✅ |
| **II. Dependencies** | Poetry + pyproject.toml | ✅ |
| **III. Config** | Variables d'environnement (.env) | ✅ |
| **IV. Backing services** | Database URL configurable | ✅ |
| **V. Build, release, run** | Poetry build + run | ✅ |
| **VI. Processes** | Stateless (token JWT externe) | ✅ |
| **VII. Port binding** | N/A (CLI) | - |
| **VIII. Concurrency** | N/A (single process CLI) | - |
| **IX. Disposability** | Graceful shutdown (finally block) | ✅ |
| **X. Dev/prod parity** | ENVIRONMENT variable | ✅ |
| **XI. Logs** | Sentry pour centralisation | ✅ |
| **XII. Admin processes** | seed_database.py séparé | ✅ |

---

#### 6. Principe SOLID

**Référence industrie** : SOLID Principles (Robert C. Martin)

| Principe | Implémentation | Exemple |
|----------|----------------|---------|
| **S - Single Responsibility** | Une classe = une responsabilité | `AuthService` fait auth uniquement |
| **O - Open/Closed** | Extension sans modification | Repository interface + implémentations |
| **L - Liskov Substitution** | Implémentations interchangeables | Tous les repositories respectent l'interface |
| **I - Interface Segregation** | Interfaces minimales | Repository interfaces ciblées |
| **D - Dependency Inversion** | Injection de dépendances | Container IoC |

**Exemple concret - Single Responsibility** :

```python
# ✅ BON : Chaque classe a UNE responsabilité
class AuthService:
    # Responsabilité : Authentification uniquement
    def authenticate(self, username, password): ...
    def generate_token(self, user): ...
    def validate_token(self, token): ...

class UserService:
    # Responsabilité : Gestion des utilisateurs
    def create_user(self, ...): ...
    def get_user(self, user_id): ...

# ❌ MAUVAIS (que nous N'UTILISONS PAS)
class UserAuthService:
    # Deux responsabilités mélangées
    def authenticate(self, ...): ...
    def create_user(self, ...): ...
```

---

#### 7. Logging et Monitoring (Sentry)

**Référence industrie** : Observability Best Practices

**Notre implémentation** :

`src/sentry_config.py`

```python
# Initialisation Sentry
sentry_sdk.init(
    dsn=sentry_dsn,
    traces_sample_rate=1.0,     # 100% des transactions (ajustable en prod)
    profiles_sample_rate=1.0,   # 100% des profils
    environment=environment,    # dev/staging/production
    send_default_pii=False,     # Pas de PII
)
```

**Test d'envoi d'erreur à Sentry** (dans `src/cli/main.py`) :

```python
try:
    raise ValueError("Test erreur Sentry - provoquée volontairement")
except Exception as e:
    capture_exception(e, context={"test": True, "source": "manual_test"})
    print("Exception capturée et envoyée à Sentry!")
```

**Événements journalisés** :
- ✅ Tentatives de connexion (succès/échecs)
- ✅ Exceptions non gérées
- ✅ Breadcrumbs (parcours utilisateur)
- ✅ Contexte utilisateur (user_id, department)

**Avantages** :
- ✅ **Détection proactive** : Alertes en temps réel
- ✅ **Debugging facilité** : Stack traces complètes
- ✅ **Analyse de sécurité** : Tentatives d'intrusion détectées
- ✅ **Monitoring de performance** : Traces et profils

---

#### 8. Security by Design

**Principe** :
> "La sécurité est intégrée dès la conception, pas ajoutée après."

**Décisions de conception sécurisées** :

| Décision | Justification | Implémentation |
|----------|---------------|----------------|
| Supprimer `get_all()` | Éviter fuites de données | Filtres contextuels uniquement |
| JWT signé HMAC-SHA256 | Impossible de forger des tokens | `auth_service.py` |
| Bcrypt avec salt | Rainbow tables inefficaces | `user.py:set_password()` |
| Validation triple couche | Défense en profondeur | CLI + Service + DB |
| Contrôle d'accès par rôles dès le départ | Principe du moindre privilège | `permissions.py` |
| Messages d'erreur génériques | Pas de divulgation d'infos | "Username ou password incorrect" |
| Permissions 600 token file | Lecture restreinte au propriétaire | `auth_service.py:save_token()` |

---

## 📋 Checklist avant la soutenance

### Préparation technique

- [ ] Base de données initialisée : `poetry run python seed_database.py`
- [ ] `.env` configuré avec `EPICEVENTS_SECRET_KEY`
- [ ] Application testée : `poetry run epicevents whoami`
- [ ] Tests unitaires passent : `poetry run pytest tests/unit/ -v`

### Documents à avoir sous la main

- [ ] `docs/DEMO_AUTHENTICATION.md` - Scénarios de démonstration
- [ ] `docs/SENTRY_SETUP.md` - Configuration Sentry
- [ ] `docs/SECURITY_SUMMARY.md` - Résumé sécurité
- [ ] `docs/AUTHENTICATION.md` - Architecture auth
- [ ] Diagramme ERD de la base de données (ci-dessus)

### Code à pouvoir montrer rapidement

- [ ] `src/models/` - Modèles avec contraintes
- [ ] `src/repositories/` - Pattern Repository
- [ ] `src/services/` - Logique métier
- [ ] `src/cli/permissions.py` - Contrôle d'accès par rôles
- [ ] `src/cli/validators.py` - Validation inputs
- [ ] `src/services/auth_service.py` - JWT + Bcrypt
- [ ] `src/sentry_config.py` - Logging

### Réponses préparées

- [ ] Pourquoi SQLAlchemy ORM ?
- [ ] Pourquoi bcrypt et pas SHA256 ?
- [ ] Pourquoi JWT et pas sessions serveur ?
- [ ] Comment gérer les tokens expirés ?
- [ ] Que faire en cas de fuite de la clé secrète ?
- [ ] Comment migrer vers PostgreSQL ?
- [ ] Comment ajouter une nouvelle permission ?

---

## 🎯 Conseils pour la soutenance

### Attitude et communication

1. **Confiance** : Vous avez implémenté une application sécurisée et complète
2. **Clarté** : Utilisez des termes techniques mais expliquez-les simplement
3. **Honnêteté** : Si vous ne savez pas, dites "Je ne sais pas, mais voici comment je chercherais la réponse"
4. **Démonstration** : Montrez le code, ne vous contentez pas de décrire

### Gestion du temps

- **Présentation (10 min)** : Préparez un timer, respectez le timing
- **Discussion (15 min)** : Laissez l'évaluateur poser ses questions, ne monopolisez pas

### Points forts à mettre en avant

1. ✅ **Conformité totale** au cahier des charges (100%)
2. ✅ **Sécurité** : OWASP Top 10, JWT, Bcrypt, contrôle d'accès par rôles
3. ✅ **Architecture** : Clean Architecture, SOLID, DI
4. ✅ **Bonnes pratiques** : Repository Pattern, Validation triple couche
5. ✅ **Production-ready** : Sentry, variables d'env, tests

### Questions difficiles anticipées

**Q: "Pourquoi ne pas utiliser OAuth2 au lieu de JWT simple ?"**
> R: "OAuth2 est excellent pour les applications multi-tenant ou les connexions tierces (Google, Facebook). Ici, c'est une application interne CLI avec authentification basique username/password. JWT suffit largement et est plus simple à maintenir. En production, on pourrait ajouter un refresh token pour améliorer la sécurité."

**Q: "Et si un attaquant vole le fichier token ?"**
> R: "Plusieurs mesures de mitigation :
> 1. Permissions 600 (Unix) - seul le propriétaire peut lire
> 2. Expiration 24h - fenêtre d'exposition limitée
> 3. Logging Sentry - tentatives suspectes détectées
> 4. En production, on pourrait ajouter device fingerprinting ou IP whitelisting"

**Q: "Votre application est-elle résistante aux attaques par force brute ?"**
> R: "Oui, grâce à bcrypt qui est intentionnellement lent (~100ms/hash). Un attaquant ne peut tester que ~10 mots de passe par seconde. Pour améliorer, on pourrait ajouter :
> 1. Rate limiting (max 5 tentatives / 15 minutes)
> 2. CAPTCHA après 3 échecs
> 3. Blocage temporaire du compte"

---

**Bonne chance pour votre soutenance ! 🚀**

**Date de dernière mise à jour** : 2025-11-03
**Version** : 1.0
