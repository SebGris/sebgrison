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

### Un simple champ texte pour saisir l'utilisateur à suivre

```python
class FollowUsersForm(forms.Form):
    username = forms.CharField(
        label="Nom d'utilisateur",
        max_length=150,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'style': 'border:2px solid #333;',
            'placeholder': 'Entrez le nom d\'utilisateur'
        })
    )
```

### Une liste déroulante pour saisir l'utilisateur à suivre

```python
class FollowUsersForm(forms.Form):
    username = forms.ChoiceField(
        label="Nom d'utilisateur",
        choices=[],
        widget=forms.Select(attrs={
            'class': 'form-control',
            'style': 'border:2px solid #333;'
        })
    )

    def __init__(self, *args, **kwargs):
        # Extraire l'utilisateur des kwargs avant d'appeler super()
        current_user = kwargs.pop('user', None)
        super().__init__(*args, **kwargs)
        User = get_user_model()

        # Exclure l'utilisateur courant et ceux déjà suivis
        users_qs = User.objects.all()
        if current_user:
            users_qs = users_qs.exclude(pk=current_user.pk)
            already_followed = UserFollows.objects.filter(
                user=current_user
            ).values_list('followed_user', flat=True)
            users_qs = users_qs.exclude(pk__in=already_followed)
        self.fields['username'].choices = [
            ('', '--- Sélectionnez un utilisateur ---')
        ] + [
            (user.username, user.username) for user in users_qs
        ]
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
Liste des adresses pour test :
http://127.0.0.1:8000/flux/
http://127.0.0.1:8000/posts/
http://127.0.0.1:8000/follow-users/

ticket et review de l'utilisateur TestWireframes :
http://127.0.0.1:8000/ticket/17/edit/
http://127.0.0.1:8000/ticket/17/delete/
http://127.0.0.1:8000/review/12/edit/
http://127.0.0.1:8000/review/12/delete/


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

# Tailwind CSS (développement)
python manage.py tailwind start

# Linting et correction automatique avec Ruff
ruff check . --fix

# Générer le fichier requirements.txt
pip freeze > requirements.txt

```

## Ressources utiles

### Tutoriels vidéo
- [Django : How to Implement a Star Rating & Review Feature | Part 6](https://www.youtube.com/watch?v=AxdEdkeBI0s&ab_channel=ELIE)

### Documentation
- [Django Tailwind Documentation](https://django-tailwind.readthedocs.io/en/latest/index.html)

## Bonnes pratiques Django

- Utiliser `login_required` pour protéger les vues
- Valider les données avec les formulaires Django
- Utiliser les templates pour éviter la répétition
- Séparer la logique métier dans les models
- Gérer les médias et fichiers statiques correctement
