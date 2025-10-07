# 🌐 SoftDesk API - Projet 10 OpenClassrooms

## 📋 Présentation

**SoftDesk** est une API REST sécurisée développée avec Django REST Framework pour la gestion collaborative de projets avec système de tickets (issues) et commentaires.

### ✨ Fonctionnalités principales
- 🔐 **Authentification JWT** sécurisée avec refresh tokens  
- 👥 **Gestion des contributeurs** par projet avec permissions granulaires
- 🎫 **Système de tickets (issues)** avec assignations et priorités
- 💬 **Commentaires** sur les issues
- 🛡️ **Sécurité RGPD** avec consentement et gestion des données
- ⚡ **Optimisations Green Code** pour les performances

## 📚 Documentation complète

### 🚀 Guides de démarrage
- **[Installation et configuration](#-installation-et-lancement-rapide)** - Setup complet avec Poetry

## 🚀 Installation et lancement rapide

### Prérequis
- Python 3.12+
- Poetry (gestionnaire de dépendances)

### 1. Installation de Poetry

```bash
# Installer pipx
python -m pip install --user pipx
python -m pipx ensurepath

# Redémarrer le terminal ou VS Code, puis :
pipx install poetry
poetry --version
```

### 2. Installation du projet

```bash
# Cloner le repository
git clone https://github.com/SebGris/project-10-django-REST.git
cd project-10-django-REST

# Installer les dépendances
poetry install

# Vérifier l'installation
poetry run python --version
poetry run python -c "import django; print(f'Django {django.get_version()}')"
```

### 3. Configuration de la base de données

```bash
# Créer les migrations
poetry run python manage.py makemigrations users
poetry run python manage.py makemigrations issues
poetry run python manage.py makemigrations

# Appliquer les migrations
poetry run python manage.py migrate
```

### 4. Créer un superutilisateur

```bash
# Méthode recommandée (script personnalisé)
poetry run python create_superuser.py

# Ou méthode Django standard
poetry run python manage.py createsuperuser
```

**Identifiants par défaut du script :**
- Username: `admin`
- Email: `admin@softdesk.local`
- Password: `SoftDesk2025!`

### 5. Lancer le serveur

```bash
poetry run python manage.py runserver
```

🎉 **L'API est accessible à :** http://127.0.0.1:8000/

## 🧪 Vérifier l'installation

### Tests de base
```bash
# Test de configuration Django
poetry run python manage.py check
```

### Interface d'administration
- URL : http://127.0.0.1:8000/admin/
- Connexion avec le superutilisateur créé

### Interface API
- URL : http://127.0.0.1:8000/api/
- Documentation interactive Django REST Framework

## 📋 Endpoints principaux

| Endpoint | Méthode | Description | Auth | Body Format |
|----------|---------|-------------|------|-------------|
| `/api/token/` | POST | Obtenir token JWT | Non | `{"username": "user", "password": "pass"}` |
| `/api/users/` | POST | Inscription | Non | `{"username": "user", "email": "...", "password": "..."}` |
| `/api/users/` | GET | Liste utilisateurs | Oui | - |
| `/api/projects/` | GET/POST | Projets | Oui | `{"name": "...", "description": "...", "type": "back-end"}` |
| `/api/projects/{id}/` | GET/PUT/DELETE | Détails projet | Oui | - |
| `/api/projects/{id}/add_contributor/` | POST | Ajouter contributeur | Oui | `{"user_id": 1}` |
| `/api/projects/{project_id}/issues/` | GET/POST | Issues du projet | Oui | `{"name": "...", "description": "...", "tag": "BUG", "assigned_to": 1}` |
| `/api/projects/{project_id}/issues/{issue_id}/comments/` | GET/POST | Commentaires d'une issue | Oui | `{"description": "..."}` |

### Valeurs autorisées pour les champs :
- **Project.type** : `"back-end"`, `"front-end"`, `"iOS"`, `"Android"`
- **Issue.priority** : `"LOW"`, `"MEDIUM"`, `"HIGH"`
- **Issue.tag** : `"BUG"`, `"FEATURE"`, `"TASK"`
- **Issue.status** : `"To Do"`, `"In Progress"`, `"Finished"`

## 🔐 Authentification JWT

### Obtenir un token
```bash
curl -X POST http://127.0.0.1:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "SoftDesk2025!"}'
```

### Utiliser le token
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://127.0.0.1:8000/api/projects/
```

## 🚨 Résolution des problèmes

<<<<<<< HEAD
### **Étape 7 : Créer un superutilisateur**

Créez un compte administrateur pour accéder à l'interface d'administration Django :

```bash
python manage.py createsuperuser --noinput --username admin --email admin@softdesk.com
```

**Note importante :** Cette commande crée un superutilisateur sans mot de passe. Pour définir un mot de passe, utilisez le shell Django :

```bash
python manage.py shell
```

Puis dans le shell Python :
```python
from django.contrib.auth.models import User
user = User.objects.get(username='admin')
user.set_password('votre_mot_de_passe')
user.save()
exit()
```

Vous pouvez maintenant accéder :
- À l'administration Django : http://127.0.0.1:8000/admin/
- À l'interface d'authentification DRF : http://127.0.0.1:8000/api-auth/login/

**Identifiants :** username: `admin` / password: `votre_mot_de_passe`

### **Étape 8 : Configurer Django REST Framework**

Ajoutez la configuration DRF dans le fichier `settings.py` du projet :

```python
# Django REST Framework configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.BasicAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}

# Redirect URLs after login/logout
LOGIN_REDIRECT_URL = '/'
LOGOUT_REDIRECT_URL = '/api-auth/login/'
```

Cette configuration :
- ✅ Active l'authentification par session et basique
- ✅ Exige une authentification pour toutes les vues API par défaut
- ✅ Configure les redirections après connexion/déconnexion

### **Étape 9 : Créer une page d'accueil API personnalisée**

Remplacez le contenu du fichier `urls.py` principal du projet par :

```python
from django.contrib import admin
from django.urls import path, include
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.reverse import reverse

@api_view(['GET'])
def api_root(request, format=None):
    """
    Page d'accueil de l'API SoftDesk Support
    """
    return Response({
        'message': 'Bienvenue sur l\'API SoftDesk Support',
        'description': 'API de gestion des problèmes techniques',
        'endpoints': {
            'admin': reverse('admin:index', request=request, format=format),
            'api_auth': {
                'login': request.build_absolute_uri('/api-auth/login/'),
                'logout': request.build_absolute_uri('/api-auth/logout/'),
            }
        }
    })

urlpatterns = [
    path('', api_root, name='api-root'),
    path('admin/', admin.site.urls),
    path('api-auth/', include('rest_framework.urls'))
]
```

Cette page d'accueil :
- ✅ Affiche un message de bienvenue personnalisé
- ✅ Liste les endpoints disponibles (admin, login, logout)
- ✅ Fournit une documentation simple de l'API
- ✅ Utilise le format JSON standard de DRF

Visitez http://127.0.0.1:8000/ pour voir la page d'accueil de votre API !

## 🔧 **Commandes de dépannage**
=======
### Erreurs courantes
>>>>>>> c11c2c4b542ac4b7aef4b6ab9d0d497f8a643146

**"No module named 'softdesk_support'"**
```bash
# Utiliser Poetry au lieu de Python directement
poetry run python (etc)
```

**Erreurs de migration**
```bash
# Réinitialiser la base de données
rm db.sqlite3  # Linux/Mac
del db.sqlite3  # Windows
poetry run python manage.py migrate
```

### Diagnostic complet
```bash
poetry run python manage.py check
```

## 🛠️ Développement

### Structure du projet
```
project-10-django-REST/
├── manage.py                # Gestionnaire Django
├── pyproject.toml           # Configuration Poetry
├── users/                   # App utilisateurs (auth, profils)
├── issues/                  # App projets (projects, issues, comments)
├── softdesk_support/        # Configuration Django
└── tests/                   # non utilisé
```

### Commandes utiles
```bash
# 🚀 Commandes rapides (après configuration)
poetry run server          # Démarrer le serveur
poetry run migrate         # Appliquer les migrations
poetry run makemigrations  # Créer les migrations
poetry run shell          # Shell Django

# Ou avec Makefile
make server               # Démarrer le serveur
make migrate              # Appliquer les migrations
make install              # Installation complète

# Commandes classiques
poetry run python manage.py runserver
poetry run python manage.py migrate
poetry run python manage.py makemigrations

# Linting et formatage avec Ruff
poetry run ruff check .           # Vérifier le code
poetry run ruff check . --fix     # Corriger automatiquement
poetry run ruff format .          # Formater le code
poetry run ruff check . --output-format=full  # Format détaillé
```

## 📄 Ressources

- [Django Documentation](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Poetry Documentation](https://python-poetry.org/docs/)
- [Django - Saving objects](https://docs.djangoproject.com/en/5.2/ref/models/instances/#saving-objects)
- [Django - Overriding model methods](https://docs.djangoproject.com/en/5.2/topics/db/models/#overriding-model-methods)
- [DRF ViewSets](https://www.django-rest-framework.org/api-guide/viewsets/)
- [DRF Authentication](https://www.django-rest-framework.org/api-guide/authentication/)
- [DRF Permissions](https://www.django-rest-framework.org/api-guide/permissions/)
- [SimpleJWT](https://django-rest-framework-simplejwt.readthedocs.io/en/latest/)
- [JWT Authentication in Django](https://code.tutsplus.com/how-to-authenticate-with-jwt-in-django--cms-30460t)
- [Tutoriel vidéo JWT _ Découverte du JWT _ Grafikart](https://grafikart.fr/tutoriels/json-web-token-presentation-958)
- [JSON Web Token (JWT) Le guide complet](https://www.primfx.com/json-web-token-jwt-guide-complet)

## 🎯 Codes de Statut HTTP

| Code | Nom | Contextes dans votre API |
|------|-----|--------------------------|
| 200 | OK | Récupération de données, modifications réussies |
| 201 | Created | Création d'utilisateurs, projets, issues, commentaires |
| 204 | No Content | Suppressions réussies |
| 400 | Bad Request | Données invalides, validation échouée |
| 401 | Unauthorized | Token manquant/invalide/expiré |
| 403 | Forbidden | Permissions insuffisantes |
| 404 | Not Found | Ressource inexistante |
| 405 | Method Not Allowed | Méthode HTTP non supportée |
| 500 | Internal Server Error | Erreurs serveur |

---

**Projet réalisé dans le cadre de la formation OpenClassrooms "Développeur d'application Python"**