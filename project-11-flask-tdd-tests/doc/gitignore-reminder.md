# ⚠️ IMPORTANT - À FAIRE AVANT DE COMMENCER LE PROJET

## 📋 TODO pour le fichier `.gitignore`

### Problème actuel
La ligne `tests/` dans `.gitignore` fait que Git ignore TOUS les fichiers de tests.

### ❌ État actuel (PROBLÉMATIQUE)
```gitignore
tests/      # ← CETTE LIGNE DOIT ÊTRE SUPPRIMÉE
```

### ✅ Ce qu'il faut faire AVANT de commencer le projet

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

### 🔍 Vérification

Après modification, exécuter :
```bash
git status
# Les fichiers tests/ doivent apparaître
git add tests/
git commit -m "Add all tests to repository"
git push
```