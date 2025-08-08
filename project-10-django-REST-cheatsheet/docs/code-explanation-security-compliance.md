# 🔐 Explication du Code SoftDesk API - Conformité OWASP et RGPD

## 📋 Vue d'ensemble de l'API

L'API **SoftDesk** est une API de gestion de projets développée avec Django REST Framework. Elle permet la gestion de projets avec un système de tickets (issues) et de commentaires, tout en respectant les normes de sécurité OWASP et la réglementation RGPD.

## 🛡️ Conformité OWASP Top 10 (2021)

**Référence officielle :** [OWASP Top 10 - 2021](https://owasp.org/Top10/)

### ✅ A01 - Broken Access Control (Contrôle d'accès défaillant)

**Implémentation :** Système de permissions à plusieurs niveaux

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

2. **`IsProjectContributor`**
   - Vérification via nested routes (`project_pk`)
   - Protection contre l'accès non autorisé aux ressources
   - Gestion des cas d'erreur (projet inexistant)
   - **Utilisée dans :** `IssueViewSet`, `ContributorViewSet`

3. **`IsAuthorOrProjectAuthorOrReadOnly`**
   - Double vérification : contributeur ET auteur/auteur du projet
   - Permissions en cascade pour issues et commentaires
   - **Utilisée dans :** `CommentViewSet`

4. **`IsOwnerOrReadOnly`** (Utilisée dans : `UserViewSet`)
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
- ORM Django prévient les injections SQL automatiquement
- Validation stricte via serializers DRF

**Exemple concret de validation stricte :**
```python
class UserRegistrationSerializer(serializers.ModelSerializer):
    """Validation multicouche pour l'inscription utilisateur"""
    password = serializers.CharField(write_only=True, required=True)
    password_confirm = serializers.CharField(write_only=True, required=True)
    age = serializers.IntegerField(min_value=15, error_messages={
        'min_value': 'L\'âge minimum requis est de 15 ans (conformité RGPD).'
    })
    
    def validate(self, attrs):
        """Validation personnalisée multicritères"""
        # 1. Validation des mots de passe
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError("Les mots de passe ne correspondent pas.")
        
        # 2. Validation RGPD - âge minimum (double vérification)
        if attrs.get('age', 0) < 15:
            raise serializers.ValidationError({
                'age': 'Vous devez avoir au moins 15 ans (conformité RGPD).'
            })
        
        return attrs
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

*Dernière mise à jour : 5 août 2025*
*Auteur : GitHub Copilot*
*Projet : SoftDesk API - OpenClassrooms Projet 10*
