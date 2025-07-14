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
poetry run python manage.py runserver
```
Ouvrez http://127.0.0.1:8000/ dans votre navigateur pour vérifier que le site Django fonctionne.
Tapez Ctrl+C pour arrêter le serveur.


## 📄 Aide

- [Poetry le gestionnaire de dépendances Python moderne](https://blog.stephane-robert.info/docs/developper/programmation/python/poetry/)
- [pipx — Install and Run Python Applications in Isolated Environments](https://pipx.pypa.io/stable/)
- [Poetry — Installation](https://python-poetry.org/docs/#installing-with-pipx)