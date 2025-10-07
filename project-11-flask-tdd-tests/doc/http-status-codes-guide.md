# Guide des codes de statut HTTP dans les tests

## 📋 Introduction

Lors des tests d'applications web, les codes de statut HTTP nous indiquent comment l'application réagit aux requêtes. Un code 500 signifie que l'application a planté, ce qui est exactement ce qu'on veut éviter.

## 🎯 L'assertion expliquée

```python
assert response.status_code in [200, 400, 302]  # Pas de 500!
```

Cette ligne vérifie que l'application **gère l'erreur proprement** au lieu de **planter**.

## 📊 Les codes de statut HTTP courants

### ✅ Codes de succès (2xx)

| Code | Nom | Signification | Utilisation dans les tests |
|------|-----|---------------|----------------------------|
| **200** | OK | La requête a réussi | Page affichée correctement, même avec un message d'erreur |
| **201** | Created | Ressource créée | Après création d'un club/compétition |
| **204** | No Content | Succès sans contenu | Après suppression réussie |

### 🔄 Codes de redirection (3xx)

| Code | Nom | Signification | Utilisation dans les tests |
|------|-----|---------------|----------------------------|
| **301** | Moved Permanently | Redirection permanente | URL changée définitivement |
| **302** | Found | Redirection temporaire | Après login, logout, erreur gérée |
| **303** | See Other | Voir autre ressource | Après POST réussi |
| **304** | Not Modified | Pas modifié | Cache valide |

### ⚠️ Codes d'erreur client (4xx)

| Code | Nom | Signification | Utilisation dans les tests |
|------|-----|---------------|----------------------------|
| **400** | Bad Request | Requête invalide | Données manquantes ou malformées |
| **401** | Unauthorized | Non autorisé | Authentification requise |
| **403** | Forbidden | Interdit | Pas les permissions |
| **404** | Not Found | Non trouvé | Page/ressource inexistante |
| **422** | Unprocessable Entity | Entité non traitable | Validation échouée |

### 🚨 Codes d'erreur serveur (5xx) - À ÉVITER !

| Code | Nom | Signification | Ce que ça indique |
|------|-----|---------------|-------------------|
| **500** | Internal Server Error | Erreur serveur | ⚠️ **L'APPLICATION A PLANTÉ** |
| **502** | Bad Gateway | Passerelle incorrecte | Problème de proxy |
| **503** | Service Unavailable | Service indisponible | Maintenance ou surcharge |

## 🔍 Exemple concret : Test de paramètre manquant

### Situation de test
```python
def test_missing_email_parameter(self, client):
    """Test : que se passe-t-il si on oublie l'email ?"""
    response = client.post('/showSummary', 
                          data={},  # ← Pas d'email !
                          follow_redirects=True)
```

### ❌ Code bugué (actuel)
```python
def show_summary():
    # Tente d'accéder directement à request.form['email']
    club = [c for c in clubs if c['email'] == request.form['email']][0]
    # Si 'email' n'existe pas → KeyError → Code 500 !
```

**Résultat :** 
- Python lève une `KeyError`
- Flask retourne un code **500**
- Le test **ÉCHOUE** (c'est voulu en TDD !)

### ✅ Code corrigé
```python
def show_summary():
    # Utilise .get() qui retourne None si absent
    email = request.form.get('email')
    
    if not email:
        flash("L'adresse email est requise")
        return redirect(url_for('index'))  # Code 302
    
    # Suite du traitement...
```

**Résultat :**
- Pas d'exception Python
- Retourne un code **302** (redirection)
- Le test **PASSE** ✅

## 📈 Stratégie de test par code de statut

### Tests de succès
```python
# L'utilisateur fait tout correctement
assert response.status_code == 200  # Page affichée
```

### Tests d'erreurs gérées
```python
# L'utilisateur fait une erreur, mais l'app la gère
assert response.status_code in [200, 302, 400]  # Erreur gérée proprement
```

### Tests de robustesse
```python
# On envoie n'importe quoi pour voir si ça plante
assert response.status_code != 500  # L'app ne doit JAMAIS planter
```

## 💡 Bonnes pratiques

### 1. Toujours tester les cas limites
```python
def test_edge_cases(self, client):
    # Email vide
    response = client.post('/login', data={'email': ''})
    assert response.status_code != 500
    
    # Email null/None
    response = client.post('/login', data={'email': None})
    assert response.status_code != 500
    
    # Paramètre manquant
    response = client.post('/login', data={})
    assert response.status_code != 500
```

### 2. Messages d'erreur explicites dans les assertions
```python
# ❌ Pas clair
assert response.status_code in [200, 302, 400]

# ✅ Plus explicite
assert response.status_code in [200, 302, 400], \
    f"L'app a planté avec code {response.status_code}, probablement une exception non gérée"
```

### 3. Tester spécifiquement le code 500
```python
def test_no_server_errors(self, client):
    """S'assurer que l'application ne plante jamais"""
    test_cases = [
        {'email': ''},           # Vide
        {'email': None},         # Null
        {},                      # Manquant
        {'email': 'a' * 1000},   # Très long
        {'email': '🦄@test.com'} # Caractères Unicode
    ]
    
    for data in test_cases:
        response = client.post('/showSummary', data=data)
        assert response.status_code < 500, \
            f"Erreur serveur avec data={data}"
```

## 📚 Résumé

- **2xx** = Succès ✅
- **3xx** = Redirection 🔄
- **4xx** = Erreur client (leur faute) ⚠️
- **5xx** = Erreur serveur (NOTRE faute) 🚨

**Règle d'or :** Une application robuste ne retourne JAMAIS de code 5xx. Toutes les erreurs doivent être anticipées et gérées proprement avec des codes 2xx, 3xx ou 4xx.

## 🎯 Pour votre projet

L'issue #1 dit : "L'application plante" = Code 500

Votre mission : Faire en sorte que tous les tests passent avec des codes < 500, prouvant que l'application gère toutes les erreurs gracieusement.