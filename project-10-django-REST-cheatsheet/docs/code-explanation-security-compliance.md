# 🔐 Explication du Code SoftDesk API - Conformité OWASP et RGPD

## 📋 Vue d'ensemble de l'API

L'API **SoftDesk** est une API de gestion de projets développée avec Django REST Framework. Elle permet la gestion de projets avec un système de tickets (issues) et de commentaires, tout en respectant les normes de sécurité OWASP et la réglementation RGPD.

### 🔒 Respect des normes OWASP
- Contrôle d’accès strict : Permissions par ressource, accès limité selon le rôle (IsAuthenticated, IsOwnerOrReadOnly, etc.).
- Gestion des identifiants : Authentification JWT, mots de passe jamais exposés dans les réponses.
- Validation côté serveur : Toutes les données sont validées côté backend (types, formats, unicité, contraintes).
- Gestion des erreurs : Pas de fuite d’informations sensibles dans les messages d’erreur.
- Protection contre l’injection : Utilisation des ORM Django, pas de requêtes SQL brutes.
- Sécurité des tokens : Expiration des tokens JWT, rafraîchissement sécurisé.
### 🛡️ Respect du RGPD
- Données minimales : Seules les données nécessaires sont collectées (username, email, âge, consentements explicites).
- Consentement explicite : Champs can_be_contacted et can_data_be_shared pour recueillir le consentement utilisateur.
- Droit à l’oubli : Endpoint de suppression d’utilisateur (DELETE /api/users/{id}/) pour effacer toutes les données liées.
- Transparence : Les utilisateurs peuvent consulter et modifier leurs données personnelles.
- Sécurité des données : Données sensibles (mots de passe) stockées de façon sécurisée (hashées), jamais retournées dans les réponses API.
- Traçabilité : Toutes les actions sont authentifiées et traçables via les tokens JWT.

## 🛡️ Conformité OWASP Top 10 (2021)

**Référence officielle :** [OWASP Top 10 - 2021](https://owasp.org/Top10/)

### ✅ A01 - Broken Access Control (Contrôle d'accès défaillant)

**Implémentation :** Permissions par ressource, accès limité selon le rôle (IsAuthenticated, IsOwnerOrReadOnly, etc.).

1. **`IsProjectAuthorOrContributor`** (Utilisée dans : `ProjectViewSet`)
   ```python
   class IsProjectAuthorOrContributor(permissions.BasePermission):
       def has_object_permission(self, request, view, obj):
            # Seuls les contributeurs peuvent accéder au projet
            if not obj.contributors.filter(user=request.user).exists():
                return False
           
            # Pour les actions de modification, suppression et ajout de contributeurs
            if view.action in ['update', 'partial_update', 'destroy', 'add_contributor']:
                return obj.author == request.user
                
            # Pour la lecture (tous les contributeurs)
            return True
   ```
   - Seuls les contributeurs peuvent accéder au projet
   - Seul l'auteur peut modifier/supprimer
   - Validation stricte via `obj.contributors.filter(user=request.user).exists()`

2. **`IsProjectContributorOrObjectAuthorOrReadOnly`** (Utilisée dans : `IssueViewSet`, `CommentViewSet`)
   - Vérification via nested routes (`project_pk`)
   - Protection contre l'accès non autorisé aux ressources
   - Gestion des cas d'erreur (projet inexistant)

3. **`IsOwnerOrReadOnly`** (Utilisée dans : `UserViewSet`)
   ```python
   class IsOwnerOrReadOnly(permissions.BasePermission):
       def has_object_permission(self, request, view, obj):
           # Pour la modification, seulement le propriétaire
           if request.method in ['PUT', 'PATCH', 'DELETE']:
               return obj == request.user
           # Pour la lecture, tous les utilisateurs authentifiés
           return request.user.is_authenticated
   ```
   - Protection des profils utilisateurs
   - Modification limitée au propriétaire uniquement

**Sécurité renforcée :**
- Toutes les vues protégées par `IsAuthenticated`
- Vérifications d'existence des objets avant accès
- Permissions combinées pour protection multicouche

### ✅ A02 - Cryptographic Failures (Défaillances cryptographiques)

**Implémentation :** Authentification JWT.

**Configuration JWT sécurisée :**
```python
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=5),    # Durée courte
    'REFRESH_TOKEN_LIFETIME': timedelta(days=1),      # Rotation fréquente
    'ROTATE_REFRESH_TOKENS': True,                    # Rotation automatique
    'BLACKLIST_AFTER_ROTATION': True,                 # Invalidation immédiate
    ...
}
```

**Protection des mots de passe :**
```python
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'UserAttributeSimilarityValidator'},     # Pas de similarité
    {'NAME': 'MinimumLengthValidator'},               # Longueur minimum
    {'NAME': 'CommonPasswordValidator'},              # Pas de mots courants
    {'NAME': 'NumericPasswordValidator'},             # Pas que numérique
]
```

### ✅ A03 - Injection

**Protection automatique Django :**
- Utilisation de l'ORM Django, pas de requêtes SQL brutes.
- Validation via serializers DRF

**Exemple concret de validation stricte :**
```python
class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer pour l'inscription d'un nouvel utilisateur"""
   ... 
   # Attention : inutile dans la dernière version du code ?
    def validate_age(self, value):
        """Valider que l'utilisateur a au moins 15 ans"""
        if value < 15:
            raise serializers.ValidationError("L'utilisateur doit avoir au moins 15 ans.")
        return value
    ...
```

**Protection contre l'injection via validation :**
- Validation des types de données (`IntegerField`, `CharField`)
- Validation des valeurs (`min_value=15`)
- Validation des formats (email, username)
- Validation métier personnalisée (`validate()`)
- Messages d'erreur sécurisés (pas de divulgation d'informations)

### ✅ A05 - Mauvaise configuration de la sécurité

**Configuration sécurisée :**
```python
# Variables d'environnement pour les secrets
SECRET_KEY = os.getenv('SECRET_KEY', 'default-development-key')
DEBUG = os.getenv('DEBUG', 'True').lower() == 'true'
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', '').split(',')

# Middleware de sécurité complet
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',       # Protection CSRF
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
```

### ✅ A06 - Vulnerable and Outdated Components

**Gestion des dépendances avec Poetry :**
- Versions figées dans `poetry.lock`
- Dépendances à jour (Django 5.2.4, DRF récent)

```bash
# Vérifier les versions
poetry --version
poetry run python -c "import django; print(f'Django {django.get_version()}')"
```

### ✅ A08 - Software and Data Integrity Failures

**Intégrité des données :**
- Validation stricte des modèles Django
- Constraints de base de données
- Serializers pour validation des entrées

### ✅ A10 - Server-Side Request Forgery (SSRF) (Falsification de requête côté serveur)

**Protection native Django :**
- Validation des URLs
- Pas de requêtes externes non contrôlées
- Utilisation sécurisée de l'ORM

## 📋 Conformité RGPD

**Référence :** [Le RGPD expliqué ligne par ligne (Articles 1 à 23)](https://next.ink/8232/106135-le-rgpd-explique-ligne-par-ligne-articles-1-a-23/)

### ✅ Article 6 - Licéité du traitement

**Consentements explicites dans le modèle utilisateur :**
```python
class User(AbstractUser):
    can_be_contacted = models.BooleanField(
        default=False,
        help_text="L'utilisateur peut-il être contacté ?"
    )
    can_data_be_shared = models.BooleanField(
        default=False,
        help_text="Les données peuvent-elles être partagées ?"
    )
```

### ✅ Article 8 - Conditions applicables au consentement des enfants

**Validation d'âge obligatoire :**
```python
age = models.IntegerField(
    validators=[MinValueValidator(15, message="L'âge minimum requis est de 15 ans.")],
    help_text="Doit avoir au moins 15 ans (RGPD)"
)
```

**Vérification avant sauvegarde :**
```python
def save(self, *args, **kwargs):
    self.full_clean()  # Déclenche la validation des champs
    super().save(*args, **kwargs)
```

### ✅ Article 17 - Droit à l'effacement ("droit à l'oubli")

**Stratégie d'anonymisation :**
- Anonymisation plutôt que suppression pour préserver l'intégrité
- Relations protégées avec `on_delete=models.PROTECT`
- Fonction d'anonymisation complète :

```python
def anonymize_user(user):
    user.username = f"anonymous_user_{user.id}"
    user.email = f"anonymous_{user.id}@deleted.local"
    user.first_name = ""
    user.last_name = ""
    user.is_active = False
    user.can_be_contacted = False
    user.can_data_be_shared = False
    user.save()
```

### ✅ Article 5 - Principes relatifs au traitement

**Minimisation des données :**
- Pagination limitée (10 éléments par page)
- Exposition limitée des données sensibles
- Collecte uniquement des données nécessaires

**Limitation de la finalité :**
- Données utilisées uniquement pour la gestion de projets
- Pas de traitement secondaire non consenti

### ✅ Article 32 - Sécurité du traitement

**Mesures techniques et organisationnelles :**
- Chiffrement des mots de passe (PBKDF2 + SHA256)
- Transmission sécurisée (HTTPS recommandé)
- Contrôle d'accès granulaire
- Journalisation des accès (via Django admin)

---

**Erreurs trouvées après :**
- Le serializer `UserCreateSerializer` est à supprimer car non utilisé. Voir `UserRegistrationSerializer` qui est utlisé par `UserViewSet`.
- `def validate_age(self, value)` dans `UserRegistrationSerializer` est en doublon avec :
```python
class User(AbstractUser):
    """
    Modèle utilisateur personnalisé avec gestion RGPD et âge
    """
    age = models.IntegerField(
        verbose_name="Âge",
        validators=[MinValueValidator(15, message="L'âge minimum requis est de 15 ans.")],
        help_text="Doit avoir au moins 15 ans (RGPD)"
    )
```
---

*Dernière mise à jour : 8 août 2025*

*Auteur : GitHub Copilot et Sébastien Grison*

*Projet : SoftDesk API - OpenClassrooms Projet 10*
