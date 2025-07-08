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