# 🌐 Projet 10 Django REST - Aide-mémoire

## Installation de Poetry
### **Étape 1 : Installation de pipx**
```bash
python -m pip install --user pipx
```
### **Étape 2 : Ajouter pipx au PATH**
```bash
python -m pipx ensurepath
```
**Pour que les changements prennent effet, vous devez :**

1. **Fermer cette fenêtre de terminal**
2. **Ouvrir un nouveau terminal**
3. **Ou redémarrer VS Code**

Après cela, vous pourrez utiliser directement `pipx` au lieu de `python -m pipx`.

### **Étape 3 : Installation de Poetry**

```bash
pipx install poetry
```

### **Étape 4 : Vérification de l’installation**

```bash
poetry --version
```

## Utilisation de Poetry
### **Étape 1 : Créer un projet**
Poetry configure tout pour vous, générant un fichier `pyproject.toml` pour centraliser la configuration.
```bash
poetry init
```
Vous serez guidé à travers une série de questions interactives :
- Nom du projet
- Version initiale
- Description
- Auteur(s)
- Dépendances et compatibilité Python

Si vous préférez sauter les questions, utilisez l’option `--no-interaction` pour une initialisation rapide avec des valeurs par défaut.
```bash
poetry init --no-interaction
``` 

### **Étape 2 : Ajouter des dépendances**
Pour ajouter une dépendance dans un projet Poetry, il suffit de faire :
```bash
poetry add Django
poetry add djangorestframework
``` 

### **Étape 3 : Activer l’environnement virtuel**
```bash
poetry env activate
``` 
Ensuite, Poetry vous donne le chemin vers le script d'activation de l'environnement virtuel. Cette réponse est normale avec `poetry env activate` - elle vous indique où se trouve le script d'activation.

## Utilisation de Django
### **Étape 1 : Créer un nouveau projet**
Lançons un projet Django à l'aide de la commande Django admin :
```bash
poetry run django-admin startproject softdesk_support .
```
Pour tester que tout est configuré comme il se doit, lançons le serveur local :
```bash
poetry run python manage.py runserver
```
Tapez Ctrl+C pour arrêter le serveur.

### **Étape 2 : Créer la base de données du projet**
Appliquez les migrations initiales :
```bash
poetry run python manage.py migrate
```

### **Étape 3 : Créer une application**
```bash
poetry run python manage.py startapp issues
cd softdesk_support
```
### **Étape 4 : Configurer l'application**
Ajouter votre application dans `settings.py` :
```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',  # Django REST Framework
    'issues',          # Votre application
]
```
#### Tester le serveur de développement
Démarrez le serveur pour vérifier que tout fonctionne :
```bash
poetry run python manage.py runserver
```
Ouvrez http://127.0.0.1:8000/ dans votre navigateur pour vérifier que le site Django fonctionne.
Tapez Ctrl+C pour arrêter le serveur.

## Ajoutez l’authentification des utilisateurs
### **Étape 1 : Installer djangorestframework-simple-jwt**

```bash
poetry add djangorestframework-simplejwt
``` 
### **Étape 2 : Configurer djangorestframework-simple-jwt**
Ajouter JWT dans les applications Django dans `settings.py` :
```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework_simplejwt', # JWT Authentication
    'issues',
]
```
Ensuite, votre projet django doit être configuré pour utiliser la bibliothèque. Dans `settings.py`, ajoutez `rest_framework_simplejwt.authentication.JWTAuthentication` à la liste des classes d'authentification :
```python
REST_FRAMEWORK = {
    ...
    'DEFAULT_AUTHENTICATION_CLASSES': (
        ...
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    )
    ...
}
```
De plus, dans votre fichier `urls.py`, incluez des routes pour les vues `TokenObtainPairView` et `TokenRefreshView` de Simple JWT :
```python
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

urlpatterns = [
    ...
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    ...
]
```

📋 Modèles créés selon les spécifications
1. User (Utilisateur personnalisé)
Hérite de `AbstractUser` pour étendre le modèle utilisateur Django
Attributs RGPD : `can_be_contacted`, `can_data_be_shared`
Validation d'âge : minimum 15 ans (conformité RGPD)
Horodatage : `created_time`
2. Project
Attributs : `name`, `description`, `type`
Types disponibles : back-end, front-end, iOS, Android
Relations : `author` (créateur du projet)
Horodatage : `created_time`
3. Contributor
Relations : `user` et `project`
Contrainte unique : un utilisateur ne peut être contributeur qu'une fois par projet
Horodatage : `created_time`
4. Issue (Problème/Tâche)
Attributs : `name`, `description`
Priorité : LOW, MEDIUM, HIGH
Tag : BUG, FEATURE, TASK
Statut : To Do, In Progress, Finished (défaut: To Do)
Relations : `project`, `author`, `assigned_to` (optionnel)
Horodatage : `created_time`
5. Comment
ID unique : UUID (comme spécifié)
Attributs : `description`
Relations : `issue`, `author`
Horodatage : `created_time`
🔧 Configuration ajoutée
Modèle User personnalisé configuré dans settings.py
Configuration JWT pour l'authentification
Interface d'administration complète pour tous les modèles

📝 Récapitulatif des routes API implémentées
J'ai implémenté un système complet de gestion des projets avec les fonctionnalités suivantes :

🎯 Routes principales pour les projets
| Méthode | URL      | Description | Permission |
|---------|----------|-------------|------------|
|GET | /api/projects/ |	Lister tous les projets accessibles | Contributeur |
|POST | /api/projects/ | Créer un nouveau projet | Authentifié |
|GET | /api/projects/{id}/ | Détails d'un projet | Contributeur |
|PUT/PATCH | /api/projects/{id}/ | Modifier un projet | Auteur seulement |
|DELETE | /api/projects/{id}/ | Supprimer un projet	| Auteur seulement |

🔧 Routes spéciales pour la gestion des contributeurs
| Méthode | URL      | Description | Permission |
|---------|----------|-------------|------------|
|GET | /api/projects/{id}/contributors/ | Lister les contributeurs | Contributeur |
|POST | /api/projects/{id}/add-contributor/ | Ajouter un contributeur | Auteur seulement |
|DELETE | /api/projects/{id}/remove-contributor/{user_id}/ | Supprimer un contributeur | Auteur seulement |

🛡️ Logique de sécurité implémentée
Authentification obligatoire : Toutes les routes nécessitent un token JWT
Isolation des projets : Un utilisateur ne voit que les projets où il est contributeur
Permissions d'auteur : Seul l'auteur peut modifier/supprimer son projet
Auto-ajout comme contributeur : L'auteur devient automatiquement contributeur
Protection de l'auteur : L'auteur ne peut pas être supprimé des contributeurs

💡 Fonctionnalités spéciales
Serializers adaptatifs : Différents serializers pour la lecture et l'écriture
Validation des types : Vérification des types de projets autorisés
Gestion des erreurs : Messages d'erreur explicites
Relations automatiques : Gestion automatique des relations contributeur/projet

🧪 Pour tester les routes
Une fois les migrations appliquées et un superutilisateur créé, vous pourrez tester avec :

Obtenir un token : POST /api/token/ avec username/password
Créer un projet : POST /api/projects/ avec le token
Ajouter des contributeurs : POST /api/projects/{id}/add-contributor/
Modifier/supprimer : Selon les permissions

Les routes sont maintenant prêtes pour être utilisées ! 🚀

## 📄 Aide

- [Poetry le gestionnaire de dépendances Python moderne](https://blog.stephane-robert.info/docs/developper/programmation/python/poetry/)
- [pipx — Install and Run Python Applications in Isolated Environments](https://pipx.pypa.io/stable/)
- [Setting up a basic Django project with Poetry](https://builtwithdjango.com/blog/basic-django-setup)
- [Poetry — Installation](https://python-poetry.org/docs/#installing-with-pipx)
- [Getting started — Simple JWT documentation](https://django-rest-framework-simplejwt.readthedocs.io/en/latest/getting_started.html#project-configuration)