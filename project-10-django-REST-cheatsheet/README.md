# 🌐 Projet 10 Django REST - Aide-mémoire

## Installation de Poetry
### **Étape 1 : Installation de pipx**
```bash
python -m pip install --user pipx
```
### **Étape 2 : Ajouter pipx au PATH**
```bash
python -m pipx ensurepath
```
**Pour que les changements prennent effet, vous devez :**

1. **Fermer cette fenêtre de terminal**
2. **Ouvrir un nouveau terminal**
3. **Ou redémarrer VS Code**

Après cela, vous pourrez utiliser directement `pipx` au lieu de `python -m pipx`.

### **Étape 3 : Installation de Poetry**

```bash
pipx install poetry
```

### **Étape 4 : Vérification de l’installation**

```bash
poetry --version
```

## Utilisation de Poetry
### **Étape 1 : Créer un projet**
Poetry configure tout pour vous, générant un fichier `pyproject.toml` pour centraliser la configuration.
```bash
poetry init
```
Vous serez guidé à travers une série de questions interactives :

    Nom du projet
    Version initiale
    Description
    Auteur(s)
    Dépendances et compatibilité Python

Si vous préférez sauter les questions, utilisez l’option `--no-interaction` pour une initialisation rapide avec des valeurs par défaut.
```bash
poetry init --no-interaction
``` 

## 📄 Aide

- [Poetry le gestionnaire de dépendances Python moderne](https://blog.stephane-robert.info/docs/developper/programmation/python/poetry/)
- [pipx — Install and Run Python Applications in Isolated Environments](https://pipx.pypa.io/stable/)
- [Poetry — Installation](https://python-poetry.org/docs/#installing-with-pipx)