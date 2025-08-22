# project-11-flask-tdd-tests

## 📌 Description
Ce projet a été réalisé dans le cadre de la formation **Développeur d’application – Python** sur OpenClassrooms.  
L’objectif est d’**améliorer une application web Flask** en optimisant la qualité du code par :  
- La mise en place de **tests unitaires et fonctionnels**  
- L’utilisation de la méthode **TDD (Test-Driven Development)**  
- Le **débogage** et la gestion des erreurs/exceptions  
- Des **tests automatisés** avec **pytest** et **Selenium**

Repo GitHub : [OpenClassrooms-Student-Center_Python_Testing](https://github.com/OpenClassrooms-Student-Center/Python_Testing)

## 🐞 Issues
### BUG : les clubs ne devraient pas pouvoir réserver plus de places que celles disponibles pour la compétition.
Quand :
Une secrétaire réserve plus de places que celles disponibles pour le concours, ce qui la mettrait dans le négatif.
Ensuite :
Elle reçoit un message de confirmation.
Attendu :
Ils ne devraient pas pouvoir réserver plus que les places disponibles pour la compétition.
Les places pour la compétition devraient être correctement déduites du total.
### FONCTIONNALITÉ : Tableau d'affichage des points mis en œuvre
Quand :
Une secrétaire se connecte à l'application
Ensuite :
Elle devrait pouvoir voir la liste des clubs et leur solde de points actuel
### BUG : les mises à jour des points ne sont pas prises en compte
Données :
Le secrétaire d'un club souhaite échanger des points contre une place dans une compétition.
Quand :
Le nombre de places est confirmé.
Alors :
Le nombre de points disponibles pour le club reste inchangé.
Résultat attendu :
Le nombre de points utilisés doit être déduit du solde du club.
### BUG : Réservation de places dans les compétitions passées
Données :
Une secrétaire souhaite réserver plusieurs places pour un concours.
Quand :
Elle réserve plusieurs places pour un concours qui a déjà eu lieu.
Alors :
Elle reçoit un message de confirmation.
Attendu :
Elle ne devrait pas pouvoir réserver de place pour un concours passé (mais les concours passés devraient être visibles). 
La page booking.html devrait s'afficher pour un concours valide.
Un message d'erreur s'affiche lorsqu'un concours n'est pas valide et un message de confirmation s'affiche lorsqu'un concours est valide.
### BUG : les clubs ne devraient pas pouvoir réserver plus de 12 places par compétition.
Quand :
Une secrétaire tente de réserver plus de 12 places pour une même compétition.
Ensuite :
Ces places sont confirmées.
Attendu :
Elle ne devrait pas pouvoir réserver plus de 12 places.
L'interface utilisateur devrait l'empêcher de réserver plus de 12 places.
Les places sont correctement déduites de la compétition.
### BUG : Les clubs ne devraient pas pouvoir utiliser plus de points que leur quota autorisé.
Quand :
Un secrétaire échange plus de points qu'il n'en a à sa disposition, ce qui le mettrait dans le rouge.
Ensuite :
Il reçoit un message de confirmation.
Attendu :
Il ne devrait pas pouvoir échanger plus de points qu'il n'en a à sa disposition ; cela devrait être fait dans l'interface utilisateur. 
Les points échangés devraient être correctement déduits du total du club.
### ERREUR : La saisie d'une adresse e-mail inconnue provoque le plantage de l'application.
Quand :
Un utilisateur saisit une adresse e-mail qui n'existe pas dans le système.
Ensuite :
L'application plante.
Attendu :
Le code doit être écrit de manière à garantir que si quelque chose ne fonctionne pas (par exemple, si l'adresse e-mail est introuvable), l'erreur est détectée et traitée. Affichez un message d'erreur tel que « Désolé, cette adresse e-mail est introuvable. » 
Le résumé doit s'afficher à l'utilisateur lorsqu'une adresse e-mail correcte est saisie.

[Issues · OpenClassrooms-Student-Center_Python_Testing](https://github.com/OpenClassrooms-Student-Center/Python_Testing/issues)

## 🛠️ Technologies utilisées
- **Python 3**
- **Flask**
- **pytest-flask**
- **Selenium**
- **HTML/CSS**

## 🚀 Fonctionnalités principales
- Écriture et exécution de tests automatisés
- Gestion et capture des exceptions
- Validation de la couverture de code
- Application de la méthodologie TDD

## 📂 Installation et exécution de flask
1. Cloner ce dépôt  
   ```bash
   git clone https://github.com/OpenClassrooms-Student-Center/Python_Testing.git
   cd Python_Testing
   ```
2. Créer et activer un environnement virtuel  
   ```bash
   python -m venv venv
   source venv/bin/activate   # macOS / Linux
   venv\Scripts\activate      # Windows
   ```
3. Installer les dépendances  
   ```bash
   pip install -r requirements.txt
   ```
4. Mettre Flask à jour avec pip
   ```bash
   pip install --upgrade flask
   ```
5. Lancer l’application  
   ```bash
   python -m flask --app server run
   ```

## 📂 Installation de Coverage, Locust et Pytest
```bash
pip install coverage
pip install locust
pip install -U pytest
```

## Aide

### Erreur "Could not locate a Flask application"
Error: Could not locate a Flask application. You did not provide the "FLASK_APP" environment variable, and a "wsgi.py" or "app.py" module was not found in the current directory.
### Solution
Depuis Flask 2.2, il est recommandé d’utiliser l’option --app pour préciser le module de l’application.
Activer l'environnement virtuel, puis tapez :

```bash
python -m flask --app server run
```
### Adresse
http://127.0.0.1:5000/

## ⚠️ Licence et utilisation

Copyright (c) 2025 Sébastien Grison  
Tous droits réservés.

Ce code est fourni uniquement à titre éducatif dans le cadre d’un projet OpenClassrooms, formation « Développeur d'application Python ».  
Toute reproduction, modification, redistribution ou utilisation de ce code, totale ou partielle, à des fins autres que personnelles et éducatives, est strictement interdite sans autorisation écrite préalable de l’auteur.