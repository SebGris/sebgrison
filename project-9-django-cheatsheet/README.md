# 🌐 Projet 9 Django - Aide-mémoire

## Configuration initiale

### Settings.py
```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'authentication',
    'review',
    'tailwind',
    'theme',
    'django_browser_reload',
]
```

## Models

### User personnalisé
```python
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    follows = models.ManyToManyField(
        'self',
        symmetrical=False,
        verbose_name='suit'
    )
```

### Modèles principaux
```python
class Ticket(models.Model):
    title = models.CharField(max_length=128)
    description = models.TextField(max_length=2048, blank=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    image = models.ImageField(null=True, blank=True)
    time_created = models.DateTimeField(auto_now_add=True)

class Review(models.Model):
    ticket = models.ForeignKey(Ticket, on_delete=models.CASCADE)
    rating = models.PositiveSmallIntegerField()
    headline = models.CharField(max_length=128)
    body = models.TextField(max_length=8192, blank=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    time_created = models.DateTimeField(auto_now_add=True)
```

## Vues importantes

### Authentification
```python
from django.contrib.auth import login, authenticate
from django.contrib.auth.decorators import login_required

@login_required
def feed(request):
    # Logique du fil d'actualité
    pass
```

### Gestion des formulaires
```python
from django.shortcuts import render, redirect

def create_ticket(request):
    if request.method == 'POST':
        form = TicketForm(request.POST, request.FILES)
        if form.is_valid():
            ticket = form.save(commit=False)
            ticket.user = request.user
            ticket.save()
            return redirect('feed')
    else:
        form = TicketForm()
    return render(request, 'reviews/create_ticket.html', {'form': form})
```

## URLs

```python
urlpatterns = [
    path('', views.feed, name='feed'),
    path('login/', views.login_view, name='login'),
    path('signup/', views.signup, name='signup'),
    path('logout/', views.logout_view, name='logout'),
    path('create-ticket/', views.create_ticket, name='create_ticket'),
    path('create-review/', views.create_review, name='create_review'),
]
```

## Templates de base

### Base template
```html
<!DOCTYPE html>
<html>
<head>
    <title>LITRevu</title>
    {% load static %}
    <link rel="stylesheet" type="text/css" href="{% static 'css/style.css' %}">
</head>
<body>
    {% block content %}
    {% endblock %}
</body>
</html>
```

## Commandes utiles

```bash
# Migrations
python manage.py makemigrations
python manage.py migrate

# Créer un superuser
python manage.py createsuperuser

# Lancer le serveur
python manage.py runserver

```

## Bonnes pratiques Django

- Utiliser `login_required` pour protéger les vues
- Valider les données avec les formulaires Django
- Utiliser les templates pour éviter la répétition
- Séparer la logique métier dans les models
- Gérer les médias et fichiers statiques correctement
