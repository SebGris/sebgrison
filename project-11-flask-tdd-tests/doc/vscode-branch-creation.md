# Créer une nouvelle branche dans Visual Studio Code

## 📋 Prérequis
- Visual Studio Code installé
- Un projet Git initialisé
- Le repository cloné localement

## 🔧 Méthodes de création

### Méthode 1 : Via la barre de statut (⭐ Recommandée)

1. **Localiser la branche actuelle**
   - Regardez en bas à gauche de VS Code
   - Vous verrez l'icône Git avec le nom de la branche actuelle (ex: `main`)

2. **Créer la nouvelle branche**
   - Cliquez sur le nom de la branche
   - Un menu déroulant apparaît en haut de l'écran
   - Sélectionnez **"Créer une nouvelle branche..."** ou **"Create new branch..."**

3. **Nommer la branche**
   - Tapez le nom de votre nouvelle branche
   - Appuyez sur `Entrée` pour valider

4. **Résultat**
   - VS Code crée la branche et bascule automatiquement dessus
   - Le nom en bas à gauche affiche maintenant votre nouvelle branche

### Méthode 2 : Via la palette de commandes

1. **Ouvrir la palette de commandes**
   - Windows/Linux : `Ctrl + Shift + P`
   - Mac : `Cmd + Shift + P`

2. **Rechercher la commande**
   - Tapez : `Git: Create Branch`
   - Sélectionnez la commande dans la liste

3. **Nommer et créer**
   - Entrez le nom de votre branche
   - Appuyez sur `Entrée`

### Méthode 3 : Via le panneau Source Control

1. **Ouvrir le panneau Source Control**
   - Cliquez sur l'icône Source Control dans la barre latérale gauche
   - Ou utilisez le raccourci `Ctrl + Shift + G`

2. **Accéder au menu**
   - Cliquez sur les trois points `...` en haut du panneau
   - Naviguez vers : **Branch** → **Create Branch...**

3. **Créer la branche**
   - Nommez votre branche
   - Validez avec `Entrée`

## 📝 Conventions de nommage pour votre projet

Pour le projet OpenClassrooms avec les issues GitHub, utilisez ces conventions :

### Pour les correctifs (bugs)
```
fix/issue-[numéro]
fix/[description-courte]
```
**Exemples :**
- `fix/issue-1`
- `fix/validation-error`

### Pour les nouvelles fonctionnalités
```
feature/[nom-fonctionnalité]
feature/issue-[numéro]
```
**Exemples :**
- `feature/user-authentication`
- `feature/issue-3`

### Pour l'assurance qualité
```
qa/[description]
```
**Exemples :**
- `qa/integration`
- `qa/testing-sprint-1`

## ✅ Vérification

Pour vérifier que vous êtes sur la bonne branche :

1. **Dans VS Code**
   - Regardez en bas à gauche (barre de statut)
   - Le nom de la branche actuelle est affiché

2. **Dans le terminal intégré**
   ```bash
   git branch
   ```
   La branche actuelle aura une étoile `*` devant son nom

## 💡 Conseils pratiques

- **Toujours partir de la bonne branche** : Assurez-vous d'être sur `main` ou `develop` avant de créer une nouvelle branche
- **Noms descriptifs** : Utilisez des noms clairs qui indiquent le but de la branche
- **Pas d'espaces** : Utilisez des tirets `-` ou underscores `_` au lieu d'espaces
- **Minuscules** : Privilégiez les lettres minuscules pour éviter les problèmes de compatibilité

## 🔄 Commandes Git équivalentes

Si vous préférez utiliser le terminal, voici les commandes équivalentes :

```bash
# Créer et basculer sur une nouvelle branche
git checkout -b nom-de-la-branche

# Ou en deux étapes
git branch nom-de-la-branche  # Créer la branche
git checkout nom-de-la-branche # Basculer dessus
```

## ⚠️ Points d'attention

- Une branche est créée à partir de votre position actuelle (HEAD)
- Les modifications non committées seront transportées vers la nouvelle branche
- Pensez à faire un `git pull` régulièrement pour rester à jour avec le repository distant