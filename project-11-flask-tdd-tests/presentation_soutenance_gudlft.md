# Présentation Soutenance - Projet GUDLFT
## Débuggez et testez un système de gestion de tournois

---
## 1. Introduction (2 minute)
Bonjour Sam
Suite au succès de notre plateforme nationale, nous développons une version régionale simplifiée.
Les secrétaires de clubs pourront y réserver des places pour leurs athlètes en échangeant des points contre des inscriptions aux compétitions.
En tant que nouveau développeur dans l'équipe, j'ai été chargé de corriger les bugs identifiés dans le prototype et d'implémenter une suite de tests complète pour garantir la qualité du code.
## 2. Workflow Git et Branches (2 minutes)
### Structure des branches créées
```
master                      # Code stable final (91% couverture)
├── qa                      # Tests et validation
├── fix/past-competitions   # Bug #1 - Réservations passées
├── fix/booking-validation  # Bug #2 et #3 - Limite 12 places
├── fix/email              # Bug #4 - Validation email
└── test/performance-locust # Tests de performance
```
```bash
git branch
```
### Respect du guide de développement
- ✅ Une branche par bug/fonctionnalité
- ✅ Tests avant merge dans master
- ✅ Commits descriptifs (fix:, test:, feat:)

---
## 3. Bugs Corrigés depuis GitHub Issues (5 minutes)

### Issue #1 : Réservations sur compétitions passées
**GitHub Issue :** "Users can book places on past competitions"  
**Problème :** Les secrétaires pouvaient réserver sur des compétitions terminées

**Solution (server.py, ligne 191) : n°1**
```python
competition_date = datetime.strptime(competition['date'], "%Y-%m-%d %H:%M:%S")
if competition_date < datetime.now():
    return "Cannot book places for past competitions."
```
**Test associé :** `test_past_competition()` ✅

### Issue #2 : Points négatifs possibles
**GitHub Issue :** "Club points can go negative"  
**Problème :** Les clubs pouvaient avoir un solde de points négatif après réservation

**Solution (server.py, ligne 203) : n°3**
```python
if places_required > int(club['points']):
    return f"Not enough points. You have {club['points']} points available"
```
**Test associé :** `test_points_validation()` avec 4 scénarios ✅

### Issue #3 : Limite de 12 places non appliquée
**GitHub Issue :** "Clubs can book more than 12 places per competition"  
**Problème :** Pas de vérification de la limite réglementaire

**Solution (server.py, lignes 217-221) : n°5**
```python
# Validation par réservation unique
if places_required > MAX_PLACES:
    return f"Cannot book more than {MAX_PLACES} places at once"

# Validation cumulative (avec bookings.json)
if total_would_be > MAX_PLACES:
    return f"Cannot book more than {MAX_PLACES} places in total"
```
**Tests associés :** `test_more_than_twelve()` et `test_cumulative_booking_limit()` ✅

### Issue #4 : Réservation au-delà des places disponibles
**GitHub Issue :** "Can book more places than available"  
**Problème :** Possibilité de surréservation d'une compétition

**Solution (server.py, ligne 207) : n°4**
```python
if places_required > int(competition['numberOfPlaces']):
    places_left = competition['numberOfPlaces']
    return f"Not enough places available. Only {places_left} places left"
```
**Test associé :** `test_more_than_available()` ✅

### Issue #5 : Validation email manquante
**GitHub Issue :** "No proper email validation"  
**Problème :** Messages d'erreur insuffisants pour emails invalides

**Solution (server.py, lignes 93-97) :**
```python
if not club:
    flash("Sorry, that email wasn't found.")
    return redirect(url_for('index'))
```
**Test associé :** `test_invalid_email_shows_flash_message()` ✅

### Amélioration Bonus : Persistance des réservations
**Problème identifié :** Les réservations n'étaient pas persistantes entre les sessions  
**Solution :** Création du système `bookings.json` pour tracker les réservations cumulées

```python
def load_bookings() / save_bookings()  # Lignes 22-62
# Permet de maintenir la limite de 12 places même après redémarrage
```
**Impact :** La limite de 12 places est maintenant appliquée de manière persistante ✅

---

## 4. Tests Implémentés (4 minutes)

### Couverture atteinte : 91%

**Commande de génération du rapport :**
```bash
pytest --cov=server --cov-report=term-missing
```

**Résultat :**
```
Name        Stmts   Miss  Cover   Missing
-----------------------------------------
server.py     131     12    91%   32, 36-37, 42-43, 48-49, 54-64
-----------------------------------------
TOTAL         131     12    91%
```

### Structure des tests

#### Tests unitaires (`tests/unit/`)
- `test_purchasePlaces.py` : 14 tests de réservation
- `test_email_validation.py` : 5 tests de connexion
- `test_book.py` : 3 tests de routing
- `test_points_display.py` : 2 tests d'affichage

#### Tests d'intégration (`tests/integration/`)
- Parcours utilisateur complet
- Validation des limites métier
- Test du tableau public

#### Tests de performance (`locustfile.py`)
- 6 utilisateurs simultanés
- Validation < 5s lecture
- Validation < 2s écriture

### Rapport HTML détaillé
```bash
pytest --cov=server --cov-report=html
# Ouvrir htmlcov/index.html dans le navigateur
```

---

## 5. Démonstration Live (3 minutes)

### Test d'une correction spécifique
```bash
# Test du bug des compétitions passées
pytest tests/unit/test_purchasePlaces.py::TestBookingValidations::test_past_competition -v

# Résultat attendu : PASSED
```

### Lancement de l'application
```bash
flask run
# http://localhost:5000

# Parcours de démonstration :
1. Connexion : john@simplylift.co
2. Tentative réservation Spring Festival (passée) → Erreur ✓
3. Réservation Test Future Competition → Succès ✓
4. Tentative > 12 places → Erreur ✓
```

### Tests de performance
```bash
locust -f locustfile.py --host=http://localhost:5000 --users=6 --spawn-rate=1 --run-time=60s --headless

# Résultats :
- View Competitions : 99e percentile = 4.1s < 5s ✓
- Book Places : 99e percentile = 1.8s < 2s ✓
- Taux d'échec : 0% ✓
```

---

## Questions Anticipées

### Q : "Comment le rapport de couverture prouve que le code fonctionne sans bugs ?"
**R :** Le rapport montre 91% de couverture avec des tests qui valident spécifiquement chaque correction de bug. Chaque bug corrigé a au moins un test dédié qui échouerait si le bug réapparaissait.

### Q : "Pourquoi pas 100% de couverture ?"
**R :** Les 9% non couverts (lignes 54-64) sont les fonctions `save_bookings()` qui écrivent dans les fichiers JSON. Elles sont testées indirectement par les tests d'intégration mais mockées dans les tests unitaires pour éviter les I/O.

### Q : "Comment avez-vous priorisé les corrections ?"
**R :** 
1. Bugs critiques bloquants (compétitions passées)
2. Bugs de validation métier (limite 12 places, points négatifs)
3. Amélioration UX (messages d'erreur)
4. Performance et tests

### Q : "Le code est-il prêt pour la production ?"
**R :** Oui, avec :
- 91% de couverture (objectif 60% dépassé)
- 0% d'échecs en tests de charge
- Performances < seuils définis
- Tous les bugs critiques corrigés

---

## Métriques Finales

| Métrique | Objectif | Atteint |
|----------|----------|---------|
| Couverture de tests | 60% | **91%** ✅ |
| Temps lecture | < 5s | **4.1s** ✅ |
| Temps écriture | < 2s | **1.8s** ✅ |
| Tests unitaires | ✓ | **24 tests** ✅ |
| Tests intégration | ✓ | **7 tests** ✅ |
| Tests performance | ✓ | **Locust 6 users** ✅ |
| Bugs corrigés | 4 | **4/4** ✅ |
