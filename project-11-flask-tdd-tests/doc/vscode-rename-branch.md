# Renommer une branche Git dans Visual Studio Code

## 📋 Prérequis
- Visual Studio Code installé
- Un projet Git initialisé
- Une branche existante à renommer

## 🔄 Cas 1 : Renommer une branche locale (non publiée)

### Méthode A : Via la palette de commandes ⭐

1. **Ouvrir la palette de commandes**
   - Windows/Linux : `Ctrl + Shift + P`
   - Mac : `Cmd + Shift + P`

2. **Rechercher la commande**
   - Tapez : `Git: Rename Branch`
   - Sélectionnez la commande dans la liste

3. **Entrer le nouveau nom**
   - Tapez le nouveau nom de branche (ex: `bug/email-validation-error`)
   - Appuyez sur `Entrée`

### Méthode B : Via le terminal intégré

1. **Ouvrir le terminal**
   - Raccourci : `Ctrl + ù` (ou `Ctrl + \``)
   - Ou menu : `View` → `Terminal`

2. **Vérifier la branche actuelle**
   ```bash
   git branch
   ```
   L'astérisque (*) indique la branche actuelle

3. **Renommer la branche actuelle**
   ```bash
   git branch -m nouveau-nom-de-branche
   ```

4. **Ou renommer une autre branche**
   ```bash
   git branch -m ancien-nom nouveau-nom
   ```

## 🌐 Cas 2 : Renommer une branche déjà publiée

Si la branche existe déjà sur GitHub/GitLab, suivez ces étapes :

### Étape 1 : Renommer localement
```bash
# Si vous êtes sur la branche
git branch -m nouveau-nom

# Si vous êtes sur une autre branche
git branch -m ancien-nom nouveau-nom
```

### Étape 2 : Supprimer l'ancienne branche distante
```bash
git push origin --delete ancien-nom
```

### Étape 3 : Publier la branche renommée
```bash
git push origin nouveau-nom
```

### Étape 4 : Réinitialiser le tracking
```bash
git push --set-upstream origin nouveau-nom
```

## ✅ Vérification du renommage

### Dans VS Code
- **Barre de statut** : Vérifiez en bas à gauche que le nom a changé
- **Source Control** : Le panneau affiche le nouveau nom

### Dans le terminal
```bash
# Lister toutes les branches locales
git branch

# Lister les branches locales et distantes
git branch -a
```

## 🎯 Exemples concrets

### Exemple 1 : Corriger une faute de frappe
```bash
# Renommer "featrue" en "feature"
git branch -m featrue/login feature/login
```

### Exemple 2 : Changer de convention
```bash
# Passer de "fix/" à "bug/"
git branch -m fix/email-validation bug/email-validation
```

### Exemple 3 : Simplifier un nom
```bash
# Raccourcir un nom trop long
git branch -m feature/implement-user-authentication-system feature/auth
```

## ⚠️ Points d'attention

### Branche principale
- **Évitez** de renommer `main` ou `master` sans coordination avec l'équipe
- Ces branches sont souvent protégées et référencées dans les CI/CD

### Branches partagées
- Si d'autres développeurs travaillent sur la branche, **communiquez** avant de renommer
- Ils devront mettre à jour leurs références locales :
  ```bash
  git fetch origin
  git branch -u origin/nouveau-nom nouveau-nom
  ```

### Pull Requests en cours
- Si une PR est ouverte avec l'ancienne branche, elle devra être mise à jour
- GitHub met généralement à jour automatiquement si vous suivez la procédure complète

## 💡 Bonnes pratiques

### Conventions de nommage cohérentes
```
✅ Bon :
- feature/user-auth
- bug/email-validation
- hotfix/critical-error
- chore/update-deps

❌ À éviter :
- ma_branche
- test123
- nouvelle-fonctionnalité (espaces/accents)
```

### Quand renommer
- **Immédiatement** si vous remarquez une erreur avant de publier
- **Avec précaution** si la branche est déjà publiée
- **Jamais** pendant un merge ou rebase en cours

## 🆘 Résolution de problèmes

### Erreur : "Branch already exists"
```bash
# Supprimer d'abord l'ancienne branche si elle existe
git branch -D ancien-nom
# Puis renommer
git branch -m nouveau-nom
```

### Erreur : "Cannot rename the current branch"
```bash
# Basculer sur une autre branche d'abord
git checkout main
# Puis renommer
git branch -m ancien-nom nouveau-nom
```

### Synchronisation perdue avec remote
```bash
# Réinitialiser le tracking
git branch --unset-upstream
git push --set-upstream origin nouveau-nom
```

## 📚 Commandes utiles supplémentaires

```bash
# Voir toutes les branches avec leurs remotes
git branch -vv

# Nettoyer les références aux branches supprimées
git remote prune origin

# Voir la configuration de tracking
git config --get-regexp branch\..*\.remote
```