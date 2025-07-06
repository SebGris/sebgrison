# 🌐 Projet 9 Django - Aide-mémoire

**📋 Sommaire**

- [Configuration initiale](#configuration-initiale)
- [Models](#models)
  - [User personnalisé](#user-personnalisé)
  - [Modèles principaux](#modèles-principaux)
- [Code expliqué sur les Vues](#code-expliqué-sur-les-vues)
  - [Authentification](#authentification)
  - [Vue pour modifier un ticket existant](#vue-pour-modifier-un-ticket-existant)
  - [Vue pour créer un nouveau ticket](#vue-pour-créer-un-nouveau-ticket)
  - [Vue pour créer une critique](#vue-pour-créer-une-critique)
  - [Vue principale du flux d'activité](#vue-principale-du-flux-dactivité)
- [Formulaire personnalisé](#formulaire-personalisé)
- [URLs](#urls)
- [Templates de base](#templates-de-base)
- [Commandes utiles](#commandes-utiles)
- [Ressources utiles](#ressources-utiles)
  - [Tutoriels vidéo](#tutoriels-vidéo)
  - [Documentation](#documentation)
- [Bonnes pratiques Django](#bonnes-pratiques-django)

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

## Code expliqué sur les Vues

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

#### Quel est la différence entre `redirect` et `render` ?

##### `render` - Affichage d'une page

###### Utilisation :
```python
return render(request, 'template.html', context={'data': value})
```

###### Ce qui se passe :
1. **Génère une page HTML** à partir d'un template
2. **Renvoie directement** cette page au navigateur
3. **L'URL reste la même** dans la barre d'adresse
4. **Code de statut HTTP : 200** (OK)

###### Exemple dans le code :
```python
return render(request, 'review/create_ticket.html', context={'form': form})
```
→ Affiche le formulaire de création de ticket sur `/ticket/create/`

##### `redirect` - Redirection vers une autre page

###### Utilisation :
```python
return redirect('nom-de-lurl')  # ou redirect('/url/absolue/')
```

###### Ce qui se passe :
1. **N'affiche PAS de contenu**
2. **Indique au navigateur** d'aller vers une autre URL
3. **L'URL change** dans la barre d'adresse
4. **Code de statut HTTP : 302** (Redirection temporaire)
5. **Le navigateur fait une nouvelle requête**

###### Exemple dans le code :
```python
return redirect('flux')
```
→ Redirige vers la page du flux (nouvelle URL : `/flux/`)

##### Comparaison pratique :

###### Cas 1 : Formulaire invalide (affichage)
```python
# GET ou formulaire invalide → AFFICHER la page
return render(request, 'review/create_ticket.html', context={'form': form})
```
- L'utilisateur voit le formulaire (avec erreurs éventuelles)
- URL : `/ticket/create/`

###### Cas 2 : Formulaire valide (redirection)
```python
# POST valide → REDIRIGER vers le flux
messages.success(request, "Ticket créé avec succès !")
return redirect('flux')
```
- L'utilisateur est redirigé vers `/flux/`
- Il voit le message de succès là-bas

##### Pourquoi cette distinction est importante ?

###### **Pattern PRG (Post-Redirect-Get)**
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

###### Avantages du pattern PRG :
1. **Évite la double soumission** si l'utilisateur actualise la page
2. **URL propre** après soumission réussie
3. **Messages temporaires** fonctionnent correctement

##### Résumé des différences :

| Aspect | `render` | `redirect` |
|--------|----------|------------|
| **Action** | Affiche une page | Redirige vers une autre URL |
| **URL** | Reste identique | Change |
| **Template** | Obligatoire | Aucun |
| **Contexte** | Peut passer des données | Aucun (utiliser messages) |
| **Code HTTP** | 200 (OK) | 302 (Redirection) |
| **Usage type** | Affichage de formulaires, listes | Après POST réussi, changement de page |

##### Erreur courante à éviter :

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
    
    # Liste des utilisateurs dont on veut voir le contenu (suivis + soi-même)
    users_to_show = list(followed_users) + [request.user.id]

    # Annoter les tickets pour savoir s'ils ont déjà une critique
    reviews_for_tickets = models.Review.objects.filter(ticket=OuterRef('pk'))
    tickets = models.Ticket.objects.filter(
        user__id__in=users_to_show
    ).annotate(
        post_type=Value('ticket', output_field=CharField()),
        has_review=Exists(reviews_for_tickets)  # Permet de masquer le bouton
    )
    # ...
```

#### Que fait `objects` sur `models.UserFollows` ?

##### Qu'est-ce que `objects` ?

`objects` est un **Manager Django** - c'est l'interface entre votre modèle Python et la base de données. Il fournit tous les méthodes pour effectuer des requêtes SQL.

##### Dans le code :

```python
followed_users = models.UserFollows.objects.filter(
    user=request.user
).values_list('followed_user', flat=True)
```

###### Décomposition :

1. **`models.UserFollows`** = La classe du modèle (table en base)
2. **`.objects`** = Le manager par défaut de Django
3. **`.filter(...)`** = Méthode du manager pour filtrer les résultats
4. **`.values_list(...)`** = Méthode pour récupérer seulement certains champs

##### Équivalent SQL généré :

```sql
SELECT followed_user_id 
FROM review_userfollows 
WHERE user_id = [ID de l'utilisateur connecté];
```

##### Autres exemples d'utilisation d'`objects` :

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

##### Pourquoi `objects` existe-t-il ?

1. **Abstraction** : Vous écrivez du Python au lieu de SQL
2. **Sécurité** : Protection automatique contre les injections SQL
3. **Portabilité** : Fonctionne avec différentes bases de données
4. **Facilité** : Syntaxe Python intuitive pour les requêtes

##### En résumé

`objects` est le **pont automatique** entre votre modèle Python et la base de données - c'est ce qui transforme vos appels de méthodes Python en requêtes SQL optimisées !

#### Qu'est-ce que `OuterRef` ?
`OuterRef` est un concept avancé de Django pour les requêtes imbriquées (subqueries).
`OuterRef('pk')` fait référence au **champ `pk` (primary key) du ticket** dans la requête principale (outer query).

##### Décomposition étape par étape :

###### 1. La requête principale (outer) :
```python
tickets = models.Ticket.objects.filter(user__id__in=users_to_show)
```
Cette requête récupère tous les tickets des utilisateurs suivis.

###### 2. La sous-requête (inner) :
```python
reviews_for_tickets = models.Review.objects.filter(ticket=OuterRef('pk'))
```
Pour **chaque ticket** de la requête principale, cette sous-requête cherche s'il existe des critiques liées à ce ticket.

###### 3. La combinaison avec `Exists` :
```python
has_review=Exists(reviews_for_tickets)
```
`Exists()` retourne `True` si la sous-requête trouve au moins une critique, `False` sinon.

##### Équivalent SQL généré :

```sql
SELECT ticket.*,
       'ticket' AS post_type,
       EXISTS(
           SELECT 1 
           FROM review_review 
           WHERE review_review.ticket_id = ticket.id  -- ← OuterRef('pk')
       ) AS has_review
FROM review_ticket ticket
WHERE ticket.user_id IN (1, 2, 3, ...);
```

##### Analogie simple :

Imaginez que vous avez une liste de livres et vous voulez savoir lesquels ont des critiques :

```python
# Pour chaque livre (requête externe)
for livre in tous_les_livres:
    # Chercher s'il y a des critiques (requête interne)
    a_des_critiques = existe_critique_pour(livre.id)  # ← OuterRef
    livre.has_review = a_des_critiques
```

##### Pourquoi utiliser `OuterRef` ?

###### ❌ Sans `OuterRef` (inefficace) :
```python
# Approche naïve : N+1 requêtes !
for ticket in tickets:
    ticket.has_review = models.Review.objects.filter(ticket=ticket).exists()
```

###### ✅ Avec `OuterRef` (efficace) :
```python
# Une seule requête SQL complexe
tickets = tickets.annotate(
    has_review=Exists(
        models.Review.objects.filter(ticket=OuterRef('pk'))
    )
)
```

##### Autres exemples d'`OuterRef` :

###### Exemple 1 : Dernier commentaire par article
```python
from django.db.models import OuterRef, Subquery

last_comment = Comment.objects.filter(
    article=OuterRef('pk')
).order_by('-created').values('content')[:1]

articles = Article.objects.annotate(
    last_comment_content=Subquery(last_comment)
)
```

###### Exemple 2 : Nombre de critiques par ticket
```python
review_count = models.Review.objects.filter(
    ticket=OuterRef('pk')
).count()

tickets = models.Ticket.objects.annotate(
    review_count=review_count
)
```

##### Dans le template :

Grâce à `has_review`, vous pouvez maintenant faire :

```html
{% if not post.has_review %}
    <a href="{% url 'review-create-for-ticket' post.id %}">
        <button>Créer une critique</button>
    </a>
{% endif %}
```

##### Résumé :

- **`OuterRef`** = Référence à un champ de la requête principale
- **Usage typique** = Vérifier l'existence de relations dans des sous-requêtes
- **Avantage** = Performance (évite les requêtes N+1)
- **Dans votre cas** = Détermine si un ticket a déjà une critique pour masquer/afficher le bouton

#### Qu'est-ce que `annotate` ?

`annotate` **ajoute des champs temporaires** aux objets récupérés de la base de données. Ces champs n'existent pas dans le modèle, mais sont calculés à la volée.

##### Dans le code :

```python
tickets = models.Ticket.objects.filter(
    user__id__in=users_to_show
).annotate(
    post_type=Value('ticket', output_field=CharField()),
    has_review=Exists(reviews_for_tickets)
)
```

##### Décomposition de chaque annotation :

###### 1. `post_type=Value('ticket', output_field=CharField())`

**Ce que ça fait :** Ajoute un champ `post_type` avec la valeur fixe `'ticket'` à chaque objet Ticket.

**Pourquoi ?** Dans votre template, vous voulez traiter les tickets et les critiques de manière uniforme. Vous pouvez donc faire :

```python
{% if post.post_type == 'ticket' %}
    <!-- Affichage spécifique aux tickets -->
{% elif post.post_type == 'review' %}
    <!-- Affichage spécifique aux critiques -->
{% endif %}
```

###### 2. `has_review=Exists(reviews_for_tickets)`

**Ce que ça fait :** Ajoute un champ booléen `has_review` qui indique si le ticket a au moins une critique.

**Utilisation dans le template :**
```python
{% if not post.has_review %}
    <button>Créer une critique</button>
{% endif %}
```

##### Équivalent SQL généré :

```sql
SELECT ticket.*,
       'ticket' AS post_type,                    -- Value()
       EXISTS(SELECT 1 FROM review_review        -- Exists()
              WHERE review_review.ticket_id = ticket.id) AS has_review
FROM review_ticket ticket
WHERE ticket.user_id IN (1, 2, 3, ...);
```

##### Autres exemples d'`annotate` :

###### Exemple 1 : Compter les critiques par ticket
```python
from django.db.models import Count

tickets = models.Ticket.objects.annotate(
    review_count=Count('reviews')  # Compte le nombre de critiques
)

# Dans le template : {{ ticket.review_count }}
```

###### Exemple 2 : Calculer la moyenne des notes
```python
from django.db.models import Avg

tickets = models.Ticket.objects.annotate(
    avg_rating=Avg('reviews__rating')  # Moyenne des notes
)

# Utilisation : {{ ticket.avg_rating|floatformat:1 }}
```

###### Exemple 3 : Concaténer des champs
```python
from django.db.models import Concat, Value

users = User.objects.annotate(
    full_name=Concat('first_name', Value(' '), 'last_name')
)

# Utilisation : {{ user.full_name }}
```

###### Exemple 4 : Calculs arithmétiques
```python
from django.db.models import F

products = Product.objects.annotate(
    total_price=F('price') * F('quantity')  # Prix total
)
```

##### Dans votre template flux.html :

Grâce aux annotations, vous pouvez faire :

```html
{% for post in flux %}
    {% if post.post_type == 'review' %}
        <!-- C'est une critique -->
        <div class="review">
            <h2>{{ post.headline }}</h2>
            <p>{{ post.body }}</p>
        </div>
    {% elif post.post_type == 'ticket' %}
        <!-- C'est un ticket -->
        <div class="ticket">
            <h2>{{ post.title }}</h2>
            <p>{{ post.description }}</p>
            {% if not post.has_review %}
                <button>Créer une critique</button>
            {% endif %}
        </div>
    {% endif %}
{% endfor %}
```

##### Avantages d'`annotate` :

###### ✅ **Performance**
```python
# ❌ MAUVAIS - N+1 requêtes
for ticket in tickets:
    ticket.has_review = ticket.reviews.exists()  # Une requête par ticket

# ✅ BON - Une seule requête
tickets = tickets.annotate(has_review=Exists(...))  # Tout en une fois
```

###### ✅ **Simplification du code**
```python
# ❌ SANS annotate - logique dans le template
{% for ticket in tickets %}
    {% if ticket.reviews.all %}
        <!-- Logique compliquée -->
    {% endif %}
{% endfor %}

# ✅ AVEC annotate - logique dans la vue
{% for ticket in tickets %}
    {% if ticket.has_review %}
        <!-- Simple et clair -->
    {% endif %}
{% endfor %}
```

##### Comparaison avec d'autres méthodes :

| Méthode | Description | Quand utiliser |
|---------|-------------|----------------|
| `filter()` | Filtre les résultats | Réduire le nombre d'objets |
| `annotate()` | Ajoute des champs calculés | Enrichir les objets existants |
| `aggregate()` | Calcule une valeur globale | Statistiques sur tout le QuerySet |
| `values()` | Récupère seulement certains champs | Optimiser les performances |

##### Résumé :

- **`annotate`** = "Ajouter des informations calculées aux objets"
- **Usage typique** = Comptes, moyennes, conditions, champs virtuels
- **Avantage principal** = Performance (calculs en base de données)
- **Dans votre cas** = Uniformiser les types d'objets et précalculer l'existence de critiques

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