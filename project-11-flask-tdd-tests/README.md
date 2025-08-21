# project-11-flask-tdd-tests

## 📌 Description
Ce projet a été réalisé dans le cadre de la formation **Développeur d’application – Python** sur OpenClassrooms.  
L’objectif est d’**améliorer une application web Flask** en optimisant la qualité du code par :  
- La mise en place de **tests unitaires et fonctionnels**  
- L’utilisation de la méthode **TDD (Test-Driven Development)**  
- Le **débogage** et la gestion des erreurs/exceptions  
- Des **tests automatisés** avec **pytest** et **Selenium**  

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

## 📂 Installation de Coverage.py
```bash
pip install coverage
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