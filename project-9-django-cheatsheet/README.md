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
def signup_page(request):
    form = forms.SignupForm()
    if request.method == 'POST':
        form = forms.SignupForm(request.POST)
        if form.is_valid():
            user = form.save()
            # auto-login user
            login(request, user)
            return redirect(settings.LOGIN_REDIRECT_URL)
    context = {'form': form}
    return render(request, 'authentication/signup.html', context=context)
```

Quel est la différence entre `redirect` et `render` ?

## `render` - Affichage d'une page

### Utilisation :
```python
return render(request, 'template.html', context={'data': value})
```

### Ce qui se passe :
1. **Génère une page HTML** à partir d'un template
2. **Renvoie directement** cette page au navigateur
3. **L'URL reste la même** dans la barre d'adresse
4. **Code de statut HTTP : 200** (OK)

### Exemple dans votre code :
```python
return render(request, 'review/create_ticket.html', context={'form': form})
```
→ Affiche le formulaire de création de ticket sur `/ticket/create/`

## `redirect` - Redirection vers une autre page

### Utilisation :
```python
return redirect('nom-de-lurl')  # ou redirect('/url/absolue/')
```

### Ce qui se passe :
1. **N'affiche PAS de contenu**
2. **Indique au navigateur** d'aller vers une autre URL
3. **L'URL change** dans la barre d'adresse
4. **Code de statut HTTP : 302** (Redirection temporaire)
5. **Le navigateur fait une nouvelle requête**

### Exemple dans votre code :
```python
return redirect('flux')
```
→ Redirige vers la page du flux (nouvelle URL : `/flux/`)

## Comparaison pratique avec vos exemples :

### Cas 1 : Formulaire invalide (affichage)
```python
# GET ou formulaire invalide → AFFICHER la page
return render(request, 'review/create_ticket.html', context={'form': form})
```
- L'utilisateur voit le formulaire (avec erreurs éventuelles)
- URL : `/ticket/create/`

### Cas 2 : Formulaire valide (redirection)
```python
# POST valide → REDIRIGER vers le flux
messages.success(request, "Ticket créé avec succès !")
return redirect('flux')
```
- L'utilisateur est redirigé vers `/flux/`
- Il voit le message de succès là-bas

## Pourquoi cette distinction est importante ?

### **Pattern PRG (Post-Redirect-Get)**
```python
if request.method == 'POST':
    if form.is_valid():
        # Traitement des données
        return redirect('success-page')  # ← REDIRECTION après POST
    else:
        # Erreurs dans le formulaire
        return render(request, 'form.html', {'form': form})  # ← AFFICHAGE
else:
    # GET initial
    return render(request, 'form.html', {'form': form})  # ← AFFICHAGE
```

### Avantages du pattern PRG :
1. **Évite la double soumission** si l'utilisateur actualise la page
2. **URL propre** après soumission réussie
3. **Messages temporaires** fonctionnent correctement

## Résumé des différences :

| Aspect | `render` | `redirect` |
|--------|----------|------------|
| **Action** | Affiche une page | Redirige vers une autre URL |
| **URL** | Reste identique | Change |
| **Template** | Obligatoire | Aucun |
| **Contexte** | Peut passer des données | Aucun (utiliser messages) |
| **Code HTTP** | 200 (OK) | 302 (Redirection) |
| **Usage type** | Affichage de formulaires, listes | Après POST réussi, changement de page |

## Erreur courante à éviter :

```python
# ❌ MAUVAIS - render après POST réussi
if form.is_valid():
    form.save()
    return render(request, 'success.html')  # URL reste sur /create/

# ✅ BON - redirect après POST réussi  
if form.is_valid():
    form.save()
    return redirect('success-page')  # URL change vers /success/
```

Cette distinction est fondamentale pour une bonne architecture web Django !

### Vue pour modifier un ticket existant.
```python
@login_required
def edit_ticket(request, ticket_id):
    ticket = get_object_or_404(models.Ticket, id=ticket_id)
    # Vérifier que l'utilisateur est bien le propriétaire
    if ticket.user != request.user:
        return HttpResponseForbidden("Vous n'êtes pas autorisé à modifier ce ticket.")
    # ...
```

#### 1. `@login_required` - Vérification d'**authentification**

```python
@login_required
def edit_ticket(request, ticket_id):
```

Ce décorateur s'assure que l'utilisateur est **connecté** (authentifié). Si l'utilisateur n'est pas connecté :
- Il est redirigé vers la page de connexion
- La vue n'est jamais exécutée
- `request.user` serait un objet `AnonymousUser`

#### 2. `if ticket.user != request.user:` - Vérification d'**autorisation**

```python
if ticket.user != request.user:
    return HttpResponseForbidden(
        "Vous n'êtes pas autorisé à modifier ce ticket."
    )
```

Cette vérification s'assure que l'utilisateur connecté est **autorisé** à modifier ce ticket spécifique. Sans cette vérification :
- N'importe quel utilisateur connecté pourrait modifier n'importe quel ticket
- Il suffirait de connaître l'ID d'un ticket pour le modifier

#### En résumé

- **`@login_required`** = "Es-tu connecté ?" (Authentification)
- **`if ticket.user != request.user:`** = "Es-tu le propriétaire ?" (Autorisation)

### Vue pour créer un nouveau ticket
```python
@login_required
def create_ticket(request):
    form = forms.TicketForm()
    if request.method == 'POST':
        form = forms.TicketForm(request.POST, request.FILES)
        if form.is_valid():
            # Associer le ticket à l'utilisateur connecté
            ticket = form.save(commit=False)
            ticket.user = request.user
            ticket.save()
            messages.success(request, "Ticket créé avec succès !")
            return redirect('flux')
    return render(request, 'review/create_ticket.html', context={'form': form})
```

### Vue pour créer une critique
```python
@login_required
def create_review(request, ticket_id=None):
    if ticket_id:
        # Cas 1: Critique en réponse à un ticket existant
        ticket = get_object_or_404(models.Ticket, id=ticket_id)

        # Vérifier qu'aucune critique n'existe déjà pour ce ticket
        if ticket.reviews.exists():
            messages.error(
                request,
                "Une critique a déjà été publiée pour ce ticket."
            )
            return redirect('flux')
    # ...
```

Je ne trouve pas la fonction `ticket.reviews.exists()` dans mon code ?

La méthode `ticket.reviews.exists()` n'est pas définie explicitement dans votre code, car elle provient d'une **relation Django automatique**.

#### 🔍 **Explication :**

##### 📋 **Dans votre modèle Review :**
```python
class Review(models.Model):
    # ...
    ticket = models.ForeignKey(Ticket, on_delete=models.CASCADE)
    # ...
```

##### 🔄 **Django crée automatiquement la relation inverse :**

Quand vous définissez une `ForeignKey` dans Review vers `Ticket`, Django crée **automatiquement** :
- `review.ticket` (relation directe)
- `ticket.reviews` (relation inverse - **manager automatique**)

##### 🎯 **La relation `ticket.reviews` :**

```python
# Django crée automatiquement cette relation :
# ticket.reviews -> RelatedManager pour Review
```

Par défaut, Django nomme la relation inverse : `<nom_du_modèle_en_minuscule>_set` ou juste `<nom_du_modèle_en_minuscule>s`.

##### 📖 **Méthodes disponibles sur `ticket.reviews` :**

```python
ticket.reviews.all()         # Toutes les critiques du ticket
ticket.reviews.exists()      # True si au moins une critique existe
ticket.reviews.count()       # Nombre de critiques
ticket.reviews.filter(...)   # Filtrer les critiques
ticket.reviews.create(...)   # Créer une nouvelle critique
```

##### 🔧 **Si vous voulez personnaliser le nom :**

```python
class Review(models.Model):
    ticket = models.ForeignKey(
        Ticket, 
        on_delete=models.CASCADE,
        related_name='critiques'  # Personnaliser le nom
    )
```

Alors vous pourriez utiliser `ticket.critiques.exists()` au lieu de `ticket.reviews.exists()`.

**C'est la magie des relations Django !** 🪄 La relation inverse est créée automatiquement sans que vous ayez besoin de l'écrire explicitement.

### Vue principale du flux d'activité.
```python
@login_required
def flux(request):
    # Récupérer les utilisateurs suivis par l'utilisateur connecté
    followed_users = models.UserFollows.objects.filter(
        user=request.user
    ).values_list('followed_user', flat=True)
    # ...
```

Que fait objects sur `models.UserFollows` ?

#### Qu'est-ce que `objects` ?

`objects` est un **Manager Django** - c'est l'interface entre votre modèle Python et la base de données. Il fournit tous les méthodes pour effectuer des requêtes SQL.

#### Dans votre code ligne 219 :

```python
followed_users = models.UserFollows.objects.filter(
    user=request.user
).values_list('followed_user', flat=True)
```

##### Décomposition :

1. **`models.UserFollows`** = La classe du modèle (table en base)
2. **`.objects`** = Le manager par défaut de Django
3. **`.filter(...)`** = Méthode du manager pour filtrer les résultats
4. **`.values_list(...)`** = Méthode pour récupérer seulement certains champs

#### Équivalent SQL généré :

```sql
SELECT followed_user_id 
FROM review_userfollows 
WHERE user_id = [ID de l'utilisateur connecté];
```

#### Autres exemples d'utilisation d'`objects` :

```python
# Récupérer tous les objets
models.UserFollows.objects.all()

# Créer un nouvel objet
models.UserFollows.objects.create(
    user=request.user,
    followed_user=user_to_follow
)

# Filtrer avec conditions
models.UserFollows.objects.filter(
    user=request.user,
    followed_user=user_to_follow
).exists()

# Récupérer un objet unique
get_object_or_404(UserFollows, user=request.user, followed_user__id=user_id)
```

#### Pourquoi `objects` existe-t-il ?

1. **Abstraction** : Vous écrivez du Python au lieu de SQL
2. **Sécurité** : Protection automatique contre les injections SQL
3. **Portabilité** : Fonctionne avec différentes bases de données
4. **Facilité** : Syntaxe Python intuitive pour les requêtes

#### Manager personnalisé (optionnel)

Vous pourriez même créer votre propre manager :

```python
class UserFollowsManager(models.Manager):
    def following_count(self, user):
        return self.filter(user=user).count()
    
    def followers_count(self, user):
        return self.filter(followed_user=user).count()

class UserFollows(models.Model):
    # ...vos champs...
    objects = UserFollowsManager()  # Manager personnalisé
```

Puis l'utiliser ainsi :
```python
following_count = models.UserFollows.objects.following_count(request.user)
```

#### En résumé

`objects` est le **pont automatique** entre votre modèle Python et la base de données - c'est ce qui transforme vos appels de méthodes Python en requêtes SQL optimisées !

## Formulaire personalisé

### Un champ texte pour saisir l'utilisateur à suivre

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

### Ou une liste déroulante pour sélectionner l'utilisateur à suivre

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
- http://127.0.0.1:8000/signup/
- http://127.0.0.1:8000/flux/
- http://127.0.0.1:8000/posts/
- http://127.0.0.1:8000/follow-users/

Ticket et review de l'utilisateur TestWireframes :
- http://127.0.0.1:8000/ticket/17/edit/
- http://127.0.0.1:8000/ticket/17/delete/
- http://127.0.0.1:8000/review/12/edit/
- http://127.0.0.1:8000/review/12/delete/


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

https://github.com/SebGris/sebgrison/tree/main/project-9-django-cheatsheet