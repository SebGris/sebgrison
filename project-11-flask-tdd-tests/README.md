# project-11-flask-tdd-tests

## 📌 Description
Ce projet a été réalisé dans le cadre de la formation **Développeur d'application – Python** sur OpenClassrooms.  
L'objectif est d'**améliorer une application web Flask** en optimisant la qualité du code par :  
- La mise en place de **tests unitaires et fonctionnels**  
- L'utilisation de la méthode **TDD (Test-Driven Development)**  
- Le **débogage** et la gestion des erreurs/exceptions  
- Des **tests automatisés** avec **pytest** et **Selenium**

Repo GitHub : [OpenClassrooms-Student-Center_Python_Testing](https://github.com/OpenClassrooms-Student-Center/Python_Testing)

## 🐞 Issues

### Issue #1 - ERREUR : La saisie d'une adresse e-mail inconnue provoque le plantage de l'application
**Quand :**  
Un utilisateur saisit une adresse e-mail qui n'existe pas dans le système.

**Ensuite :**  
L'application plante.

**Attendu :**  
Le code doit être écrit de manière à garantir que si quelque chose ne fonctionne pas (par exemple, si l'adresse e-mail est introuvable), l'erreur est détectée et traitée. Affichez un message d'erreur tel que « Désolé, cette adresse e-mail est introuvable. »  
Le résumé doit s'afficher à l'utilisateur lorsqu'une adresse e-mail correcte est saisie.

### Issue #2 - BUG : Les clubs ne devraient pas pouvoir réserver plus de places que celles disponibles pour la compétition
**Quand :**  
Une secrétaire réserve plus de places que celles disponibles pour le concours, ce qui la mettrait dans le négatif.

**Ensuite :**  
Elle reçoit un message de confirmation.

**Attendu :**  
Ils ne devraient pas pouvoir réserver plus que les places disponibles pour la compétition.  
Les places pour la compétition devraient être correctement déduites du total.

### Issue #3 - FONCTIONNALITÉ : Tableau d'affichage des points mis en œuvre
**Quand :**  
Une secrétaire se connecte à l'application

**Ensuite :**  
Elle devrait pouvoir voir la liste des clubs et leur solde de points actuel

### Issue #4 - BUG : Les mises à jour des points ne sont pas prises en compte
**Données :**  
Le secrétaire d'un club souhaite échanger des points contre une place dans une compétition.

**Quand :**  
Le nombre de places est confirmé.

**Alors :**  
Le nombre de points disponibles pour le club reste inchangé.

**Résultat attendu :**  
Le nombre de points utilisés doit être déduit du solde du club.

### Issue #5 - BUG : Réservation de places dans les compétitions passées
**Données :**  
Une secrétaire souhaite réserver plusieurs places pour un concours.

**Quand :**  
Elle réserve plusieurs places pour un concours qui a déjà eu lieu.

**Alors :**  
Elle reçoit un message de confirmation.

**Attendu :**  
Elle ne devrait pas pouvoir réserver de place pour un concours passé (mais les concours passés devraient être visibles).  
La page booking.html devrait s'afficher pour un concours valide.  
Un message d'erreur s'affiche lorsqu'un concours n'est pas valide et un message de confirmation s'affiche lorsqu'un concours est valide.

### Issue #6 - BUG : Les clubs ne devraient pas pouvoir réserver plus de 12 places par compétition
**Quand :**  
Une secrétaire tente de réserver plus de 12 places pour une même compétition.

**Ensuite :**  
Ces places sont confirmées.

**Attendu :**  
Elle ne devrait pas pouvoir réserver plus de 12 places.  
L'interface utilisateur devrait l'empêcher de réserver plus de 12 places.  
Les places sont correctement déduites de la compétition.

### Issue #7 - BUG : Les clubs ne devraient pas pouvoir utiliser plus de points que leur quota autorisé
**Quand :**  
Un secrétaire échange plus de points qu'il n'en a à sa disposition, ce qui le mettrait dans le rouge.

**Ensuite :**  
Il reçoit un message de confirmation.

**Attendu :**  
Il ne devrait pas pouvoir échanger plus de points qu'il n'en a à sa disposition ; cela devrait être fait dans l'interface utilisateur.  
Les points échangés devraient être correctement déduits du total du club.

[Issues · OpenClassrooms-Student-Center_Python_Testing](https://github.com/OpenClassrooms-Student-Center/Python_Testing/issues)

## 🛠️ Technologies utilisées
- **Python 3**
- **Flask**
- **pytest**
- **pytest-flask**
- **Selenium**
- **Coverage**
- **Locust**
- **HTML/CSS**

## 🚀 Fonctionnalités principales
- Écriture et exécution de tests automatisés
- Gestion et capture des exceptions
- Validation de la couverture de code
- Application de la méthodologie TDD
- Tests de performance avec Locust

## 📂 Installation et exécution

### 1. Fork du dépôt original

Ce projet est un fork du repository OpenClassrooms original.

**Repository original :** [OpenClassrooms-Student-Center/Python_Testing](https://github.com/OpenClassrooms-Student-Center/Python_Testing)

**Pour créer votre propre fork :**
- Rendez-vous sur le [repository original](https://github.com/OpenClassrooms-Student-Center/Python_Testing)
- Cliquez sur le bouton **Fork** en haut à droite
- Le fork sera créé dans votre compte GitHub
- Vous pourrez ensuite cloner votre fork localement pour travailler dessus

### 2. Créer et activer un environnement virtuel
```bash
python -m venv venv

# Activation sur macOS / Linux
source venv/bin/activate

# Activation sur Windows
venv\Scripts\activate
```

### 3. Installer les dépendances
```bash
pip install -r requirements.txt
```

### 4. Mettre Flask à jour
```bash
pip install --upgrade flask
```

### 5. Lancer l'application
```bash
python -m flask --app server run
```

L'application sera accessible à l'adresse : http://127.0.0.1:5000/

## 🧪 Installation des outils de test

### Tests de base
```bash
# Framework de test
pip install -U pytest
pip install pytest-flask # pour écrire moins de code

# Couverture de code
pip install coverage
pip install pytest-cov

# Tests de performance
pip install locust
```

### Tests d'interface avec Selenium
```bash
# Bibliothèque Selenium
pip install selenium

# Gestionnaire de drivers (recommandé)
pip install webdriver-manager

# Ou télécharger manuellement le driver pour votre navigateur :
# - Chrome: https://chromedriver.chromium.org/
# - Firefox: https://github.com/mozilla/geckodriver/releases
```

### 📋 TODO pour le fichier `.gitignore`

La ligne `tests/` dans `.gitignore` fait que Git ignore TOUS les fichiers de tests.

#### ❌ État actuel (PROBLÉMATIQUE)
```gitignore
tests/      # ← CETTE LIGNE DOIT ÊTRE SUPPRIMÉE
```

#### ✅ Ce qu'il faut faire AVANT de commencer le projet

1. **Ouvrir `.gitignore`**
2. **SUPPRIMER la ligne `tests/`**
3. **Garder ces lignes** :
   ```gitignore
   venv/
   .venv/
   __pycache__/
   *.pyc
   .pytest_cache/
   htmlcov/
   .coverage
   ```

## 📝 Exécution des tests

### Tests unitaires et fonctionnels
```bash
# Lancer tous les tests
python -m pytest tests/

# Lancer avec détails
pytest -v

# Lancer un fichier de test spécifique
pytest tests/test_email_validation.py
```

### Couverture de code
```bash
# Générer un rapport de couverture
coverage run -m pytest
coverage report
coverage html  # Génère un rapport HTML dans htmlcov/
```

### Tests de performance
```bash
# Lancer Locust
locust -f locustfile.py --host=http://127.0.0.1:5000
```

## 🆘 Aide et dépannage

### Erreur "Could not locate a Flask application"
**Problème :**  
Error: Could not locate a Flask application. You did not provide the "FLASK_APP" environment variable, and a "wsgi.py" or "app.py" module was not found in the current directory.

**Solution :**  
Depuis Flask 2.2, il est recommandé d'utiliser l'option `--app` pour préciser le module de l'application.  
Assurez-vous d'avoir activé l'environnement virtuel, puis tapez :

```bash
python -m flask --app server run
```

## 📝 Aide-mémoire pour la soutenance

Voici deux commandes indispensables pour lancer et tester l'application :

- Démarrer le serveur Flask :
  ```bash
  python -m flask --app server run
  ```
- Lancer les tests avec pytest :
  ```bash
  python -m pytest tests/
  ```
- Générer le rapport HTML :
  ```bash
  pytest --cov=server --cov-report=html
  ```
- Ouvrir le rapport :
  ```bash
  start htmlcov/index.html
  ```

### Lancer les tests de performance

```bash
python -m flask --app server run
locust -f locustfile.py --host=http://localhost:5000 --users=6 --spawn-rate=1 --run-time=60s
```
Allez sur http://localhost:8089

## ⚖️ Licence et utilisation

Copyright (c) 2025 Sébastien Grison  
Tous droits réservés.

Ce code est fourni uniquement à titre éducatif dans le cadre d'un projet OpenClassrooms, formation « Développeur d'application Python ».  
Toute reproduction, modification, redistribution ou utilisation de ce code, totale ou partielle, à des fins autres que personnelles et éducatives, est strictement interdite sans autorisation écrite préalable de l'auteur.