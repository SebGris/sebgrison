# 🌐 Projet 10 Django REST - Aide-mémoire

## Installation à partir de zéro
### **Étape 1 : Créer le fichier requirements.txt**

```txt
Django==3.2.5
djangorestframework==3.12.4
```

### **Étape 2 : Créer et activer un environnement virtuel**

Il est recommandé d’utiliser un environnement virtuel pour isoler les dépendances de votre projet.
Dans le terminal de Visual Studio Code, exécutez :
```bash
python -m venv venv
```
Pour activer exécutez :
```bash
venv\Scripts\activate
```

### **Étape 3 : Installer les dépendances Python**

Installez les dépendances nécessaires :
```bash
pip install -r requirements.txt
```

### **Étape 4 : Mettre à jour le fichier requirements.txt**

Après installation, mettez à jour le fichier requirements.txt avec toutes les dépendances installées par Django :
```bash
pip freeze > requirements.txt
```

### **Étape 5 : Créer une application Django**

Créez un nouveau projet Django :
```bash
django-admin startproject softdesk_support
cd softdesk_support
```

#### Créer la base de données du projet
Appliquez les migrations initiales :
```bash
python manage.py migrate
```

#### Créer une application
Créez une application dans le projet :
```bash
python manage.py startapp issues
```

#### Configurer l'application
N'oubliez pas d'ajouter votre application dans `settings.py` :
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
python manage.py runserver
```
Ouvrez http://127.0.0.1:8000/ dans votre navigateur pour vérifier que le site Django fonctionne.
Tapez Ctrl+C pour arrêter le serveur.

### **Étape 6 : Activer l'authentification DRF**

Ajoutez l'authentification Django REST Framework dans le fichier `urls.py` principal du projet :

```python
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api-auth/', include('rest_framework.urls')),
]
```

Cette configuration permet d'utiliser l'interface d'authentification web de DRF accessible à l'adresse http://127.0.0.1:8000/api-auth/login/

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

### **En cas de problème**
```bash
# Vérifier l'environnement virtuel
venv\Scripts\activate
python -c "import sys; print(sys.prefix)"

# Réinstaller les dépendances
pip install -r requirements.txt --force-reinstall

# Vérifier Python
python --version  # Doit être 3.8+
```

### **Commandes Django utiles**
```bash
# Créer un nouveau projet Django
django-admin startproject nom_du_projet

# Créer une nouvelle app
python manage.py startapp nom_de_lapp

# Créer et appliquer les migrations
python manage.py makemigrations
python manage.py migrate

# Créer un superutilisateur
python manage.py createsuperuser

# Lancer le serveur de développement
python manage.py runserver

# Collecter les fichiers statiques
python manage.py collectstatic

# Tests
python manage.py test
```

## 📄 Aide

https://openclassrooms.com/fr/courses/7172076-debutez-avec-le-framework-django/7514454-installez-django-avec-pip