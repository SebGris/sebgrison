# Guide Flask : Paramètres d'URL vs Données de Formulaire

## 📚 Introduction

Dans Flask, il existe plusieurs façons de récupérer des données envoyées par le client. Ce guide explique les différences entre les paramètres d'URL et les données de formulaire, et quand utiliser chaque méthode.

## 🔍 Les Trois Types de Données

### 1. **Paramètres d'URL (Route Parameters)**

Les paramètres directement intégrés dans l'URL de la route.

```python
@app.route('/book/<competition>/<club>')
def book(competition, club):
    # 'competition' et 'club' sont automatiquement extraits de l'URL
    # URL exemple : /book/Spring%20Festival/Simply%20Lift
    print(f"Competition: {competition}")
    print(f"Club: {club}")
```

**Caractéristiques :**
- 📍 Définis dans la route avec `<nom_param>`
- 🔄 Passés automatiquement comme arguments de fonction
- 🌐 Visibles dans l'URL
- 📤 Utilisés généralement avec GET

**Exemple d'URL :**
```
http://localhost:5000/book/Spring Festival/Simply Lift
                           ↑              ↑
                      competition        club
```

### 2. **Données de Formulaire (Form Data)**

Les données envoyées via un formulaire HTML avec la méthode POST.

```python
@app.route('/purchasePlaces', methods=['POST'])
def purchasePlaces():
    # Les données viennent du corps de la requête POST
    competition_name = request.form.get('competition')
    club_name = request.form.get('club')
    places = request.form.get('places')
```

**Caractéristiques :**
- 📝 Envoyées dans le corps de la requête
- 🔒 Non visibles dans l'URL
- 📥 Accessibles via `request.form`
- 📤 Utilisées avec POST (parfois PUT/PATCH)

**Formulaire HTML correspondant :**
```html
<form action="/purchasePlaces" method="post">
    <input type="hidden" name="competition" value="Spring Festival">
    <input type="hidden" name="club" value="Simply Lift">
    <input type="number" name="places" placeholder="Nombre de places">
    <button type="submit">Réserver</button>
</form>
```

### 3. **Paramètres de Requête (Query Parameters)**

Les paramètres ajoutés après `?` dans l'URL.

```python
@app.route('/search')
def search():
    # URL : /search?q=flask&category=web
    query = request.args.get('q')        # 'flask'
    category = request.args.get('category')  # 'web'
```

**Caractéristiques :**
- ❓ Ajoutés après `?` dans l'URL
- 🔍 Utilisés pour filtres et recherches
- 📥 Accessibles via `request.args`
- 📤 Utilisés avec GET

**Exemple d'URL :**
```
http://localhost:5000/search?q=flask&category=web
                            ↑        ↑
                         query    category
```

## 📊 Tableau Comparatif

| Aspect | Paramètres d'URL | Données de Formulaire | Query Parameters |
|--------|------------------|----------------------|------------------|
| **Syntaxe Route** | `/route/<param>` | `/route` | `/route` |
| **Accès Python** | Arguments de fonction | `request.form.get()` | `request.args.get()` |
| **Méthode HTTP** | GET (généralement) | POST/PUT/PATCH | GET |
| **Visible dans URL** | ✅ Oui | ❌ Non | ✅ Oui |
| **Taille limite** | ~2000 caractères | Plusieurs MB | ~2000 caractères |
| **Cas d'usage** | Identifiants, navigation | Soumission de données | Filtres, recherche |

## 💡 Exemples Pratiques

### Exemple 1 : Navigation vers une page de réservation

```python
# Route avec paramètres d'URL
@app.route('/book/<competition_name>/<club_name>')
def book(competition_name, club_name):
    # Recherche des entités
    club = next((c for c in clubs if c['name'] == club_name), None)
    competition = next((c for c in competitions if c['name'] == competition_name), None)
    
    if not club or not competition:
        flash("Données introuvables")
        return redirect(url_for('index'))
    
    return render_template('booking.html', club=club, competition=competition)
```

**Utilisation :**
```html
<!-- Lien pour accéder à la page -->
<a href="{{ url_for('book', competition_name='Spring Festival', club_name='Simply Lift') }}">
    Réserver
</a>
```

### Exemple 2 : Soumission d'un formulaire

```python
# Route acceptant des données POST
@app.route('/purchasePlaces', methods=['POST'])
def purchasePlaces():
    # Récupération sécurisée avec valeurs par défaut
    competition = request.form.get('competition', '')
    club = request.form.get('club', '')
    places = request.form.get('places', 0, type=int)
    
    # Validation
    if not competition or not club:
        flash("Données manquantes")
        return redirect(url_for('index'))
    
    # Traitement...
    return render_template('confirmation.html')
```

### Exemple 3 : Recherche avec filtres

```python
# Route avec query parameters
@app.route('/competitions')
def list_competitions():
    # URL exemple : /competitions?status=future&limit=10
    status = request.args.get('status', 'all')
    limit = request.args.get('limit', 20, type=int)
    
    # Filtrage selon les paramètres
    filtered_competitions = filter_by_status(competitions, status)
    
    return render_template('competitions.html', 
                         competitions=filtered_competitions[:limit])
```

## 🎯 Bonnes Pratiques

### 1. **Utiliser les paramètres d'URL pour :**
- ✅ Les identifiants de ressources (`/user/123`)
- ✅ La navigation (`/book/competition/club`)
- ✅ Les chemins RESTful (`/api/users/123/posts`)

### 2. **Utiliser les données de formulaire pour :**
- ✅ Création de ressources (nouveau compte, nouvelle réservation)
- ✅ Modification de données sensibles (mot de passe)
- ✅ Upload de fichiers
- ✅ Données complexes ou volumineuses

### 3. **Utiliser les query parameters pour :**
- ✅ Recherche et filtres (`?search=term`)
- ✅ Pagination (`?page=2&limit=20`)
- ✅ Options d'affichage (`?sort=date&order=desc`)

## 🔒 Sécurité

### Validation des Paramètres d'URL
```python
@app.route('/user/<int:user_id>')  # Force un entier
def user_profile(user_id):
    # user_id est garanti d'être un int
    pass
```

### Validation des Données de Formulaire
```python
# Utiliser .get() avec valeurs par défaut
places = request.form.get('places', 0, type=int)

# Ou avec try/except
try:
    places = int(request.form['places'])
except (KeyError, ValueError):
    places = 0
```

### Protection CSRF pour les Formulaires
```python
# Utiliser Flask-WTF pour la protection CSRF
from flask_wtf import FlaskForm
from wtforms import IntegerField
from wtforms.validators import Required, NumberRange

class BookingForm(FlaskForm):
    places = IntegerField('Places', 
                         validators=[Required(), 
                                   NumberRange(min=1, max=12)])
```

## 📖 Résumé

- **Paramètres d'URL** (`/route/<param>`) → Pour identifier des ressources
- **Données POST** (`request.form`) → Pour soumettre des données
- **Query strings** (`request.args`) → Pour filtrer et rechercher

Choisissez la méthode appropriée selon :
1. Le type de données (identifiant vs contenu)
2. La sensibilité des données
3. La méthode HTTP utilisée
4. L'expérience utilisateur souhaitée

## 🔗 Ressources

- [Documentation Flask - Quickstart](https://flask.palletsprojects.com/quickstart/)
- [Documentation Flask - Request Object](https://flask.palletsprojects.com/api/#flask.Request)
- [Flask Patterns](https://flask.palletsprojects.com/patterns/)