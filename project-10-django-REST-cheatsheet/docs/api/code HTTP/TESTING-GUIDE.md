# 🧪 Guide de Test - API SoftDesk Support

## 🎯 Objectif

Ce guide vous permet de tester systématiquement tous les endpoints de l'API SoftDesk Support avec Postman pour valider tous les codes de réponse HTTP possibles.

---

## 🚀 Préparation de l'Environnement

### 1. **Démarrer le serveur Django**
```bash
# Dans le terminal, depuis le répertoire du projet
python manage.py runserver
```
Vérifiez que le serveur fonctionne sur `http://127.0.0.1:8000`

### 2. **Importer la collection Postman**
1. Ouvrez Postman
2. Cliquez sur **Import**
3. Sélectionnez le fichier `postman-collection-softdesk.json`
4. La collection "SoftDesk Support API - Test Complet des Codes HTTP" apparaît

### 3. **Configurer les variables d'environnement**
Créez un environnement Postman avec ces variables :

| Variable | Valeur | Description |
|----------|--------|-------------|
| `base_url` | `http://127.0.0.1:8000` | URL de base de l'API |
| `test_username` | `auteur_principal` | Nom d'utilisateur de test |
| `test_password` | `motdepasse123` | Mot de passe de test |

### 4. **Créer les données de test**
Exécutez le script de configuration :
- **Windows** : `setup-test-environment.bat`
- **Linux/Mac** : `bash setup-test-environment.sh`

---

## 📋 Plan de Test Systématique

### **Phase 1 : Authentification JWT** 🔐

#### Tests à effectuer :
1. **Obtenir Token JWT - 200 OK**
   - Vérifiez que le token est stocké automatiquement
   - Validez la présence des champs `access` et `refresh`

2. **Token invalide - 401 Unauthorized**
   - Testez avec des identifiants incorrects
   - Vérifiez le message d'erreur approprié

3. **Rafraîchir Token - 200 OK**
   - Utilisez le token de rafraîchissement
   - Vérifiez qu'un nouveau token d'accès est généré

4. **Données manquantes - 400 Bad Request**
   - Testez avec des champs vides
   - Validez les erreurs de validation

#### ✅ Critères de validation :
- [ ] Token JWT obtenu avec succès (200)
- [ ] Gestion correcte des identifiants invalides (401)
- [ ] Rafraîchissement de token fonctionnel (200)
- [ ] Validation des données d'entrée (400)

---

### **Phase 2 : Gestion des Utilisateurs** 👥

#### Tests à effectuer :
1. **Créer un utilisateur - 201 Created**
   - Validez la création avec toutes les données requises
   - Vérifiez que l'ID utilisateur est stocké

2. **Lister les utilisateurs - 200 OK**
   - Testez avec authentification valide
   - Vérifiez le format de la réponse (array)

3. **Obtenir un utilisateur par ID - 200 OK**
   - Utilisez l'ID stocké depuis la création
   - Validez les détails complets de l'utilisateur

4. **Accès non autorisé - 401 Unauthorized**
   - Testez sans token d'authentification
   - Vérifiez le message d'erreur

5. **Utilisateur inexistant - 404 Not Found**
   - Utilisez un ID inexistant (99999)
   - Validez la réponse d'erreur

6. **Données invalides - 400 Bad Request**
   - Testez avec email invalide, âge négatif, etc.
   - Vérifiez toutes les erreurs de validation

#### ✅ Critères de validation :
- [ ] Création d'utilisateur réussie (201)
- [ ] Liste des utilisateurs accessible (200)
- [ ] Détails utilisateur récupérés (200)
- [ ] Protection contre accès non autorisé (401)
- [ ] Gestion des utilisateurs inexistants (404)
- [ ] Validation des données (400)

---

### **Phase 3 : Gestion des Projets** 📋

#### Tests à effectuer :
1. **Créer un projet - 201 Created**
   - Créez avec l'utilisateur authentifié
   - Vérifiez que l'ID projet est stocké

2. **Lister les projets - 200 OK**
   - Vérifiez que seuls les projets accessibles sont retournés
   - Validez le format de réponse

3. **Obtenir un projet par ID - 200 OK**
   - Utilisez l'ID du projet créé
   - Vérifiez les détails complets

4. **Modifier un projet - 200 OK**
   - Testez la mise à jour des informations
   - Validez les modifications

5. **Projet inexistant - 404 Not Found**
   - Testez avec un ID invalide
   - Vérifiez la gestion d'erreur

6. **Méthode non autorisée - 405 Method Not Allowed**
   - Testez une méthode HTTP non supportée
   - Validez la réponse d'erreur

#### ✅ Critères de validation :
- [ ] Création de projet réussie (201)
- [ ] Liste des projets accessible (200)
- [ ] Détails projet récupérés (200)
- [ ] Modification de projet fonctionnelle (200)
- [ ] Gestion des projets inexistants (404)
- [ ] Gestion des méthodes non autorisées (405)

---

### **Phase 4 : Gestion des Contributeurs** 🤝

#### Tests à effectuer :
1. **Ajouter un contributeur - 201 Created**
   - Ajoutez un utilisateur au projet
   - Vérifiez que l'ID contributeur est stocké

2. **Lister les contributeurs - 200 OK**
   - Vérifiez la liste des contributeurs du projet
   - Validez le format de réponse

3. **Supprimer un contributeur - 204 No Content**
   - Testez la suppression
   - Vérifiez l'absence de contenu de réponse

4. **Accès refusé - 403 Forbidden**
   - Testez avec un utilisateur non autorisé
   - Validez la protection des permissions

#### ✅ Critères de validation :
- [ ] Ajout de contributeur réussi (201)
- [ ] Liste des contributeurs accessible (200)
- [ ] Suppression de contributeur réussie (204)
- [ ] Protection des permissions (403)

---

### **Phase 5 : Gestion des Issues** 🐛

#### Tests à effectuer :
1. **Créer une issue - 201 Created**
   - Créez dans un projet existant
   - Vérifiez que l'ID issue est stocké

2. **Lister les issues - 200 OK**
   - Vérifiez la liste des issues du projet
   - Validez le format résumé

3. **Obtenir une issue par ID - 200 OK**
   - Récupérez les détails complets
   - Validez toutes les informations

4. **Modifier une issue - 200 OK**
   - Testez la mise à jour du statut
   - Vérifiez les modifications

5. **Supprimer une issue - 204 No Content**
   - Testez la suppression
   - Vérifiez l'absence de contenu

#### ✅ Critères de validation :
- [ ] Création d'issue réussie (201)
- [ ] Liste des issues accessible (200)
- [ ] Détails issue récupérés (200)
- [ ] Modification d'issue fonctionnelle (200)
- [ ] Suppression d'issue réussie (204)

---

### **Phase 6 : Gestion des Commentaires** 💬

#### Tests à effectuer :
1. **Créer un commentaire - 201 Created**
   - Ajoutez sur une issue existante
   - Vérifiez que l'ID commentaire est stocké

2. **Lister les commentaires - 200 OK**
   - Vérifiez tous les commentaires de l'issue
   - Validez le format de réponse

3. **Obtenir un commentaire par ID - 200 OK**
   - Récupérez les détails complets
   - Validez les informations

4. **Modifier un commentaire - 200 OK**
   - Testez la mise à jour du contenu
   - Vérifiez les modifications

5. **Supprimer un commentaire - 204 No Content**
   - Testez la suppression
   - Vérifiez l'absence de contenu

#### ✅ Critères de validation :
- [ ] Création de commentaire réussie (201)
- [ ] Liste des commentaires accessible (200)
- [ ] Détails commentaire récupérés (200)
- [ ] Modification de commentaire fonctionnelle (200)
- [ ] Suppression de commentaire réussie (204)

---

### **Phase 7 : Scénarios d'Erreur** ❌

#### Tests à effectuer :
1. **Endpoint inexistant - 404 Not Found**
   - Testez une URL qui n'existe pas
   - Validez la réponse 404

2. **JSON malformé - 400 Bad Request**
   - Envoyez du JSON invalide
   - Vérifiez la gestion d'erreur

3. **Token expiré - 401 Unauthorized**
   - Utilisez un token invalide
   - Validez le message d'erreur

4. **Test erreur serveur - 500 Internal Server Error**
   - Testez des scénarios qui pourraient causer une erreur serveur
   - Vérifiez la robustesse de l'API

#### ✅ Critères de validation :
- [ ] Gestion des endpoints inexistants (404)
- [ ] Validation du JSON (400)
- [ ] Gestion des tokens expirés (401)
- [ ] Robustesse générale de l'API

---

## 🔧 Utilisation Avancée

### **Exécution automatisée**
1. Sélectionnez la collection complète
2. Cliquez sur "Run"
3. Configurez l'ordre d'exécution :
   - Authentification en premier
   - Tests de ressources ensuite
   - Scénarios d'erreur en dernier

### **Variables automatiques**
La collection utilise des scripts qui stockent automatiquement :
- `access_token` et `refresh_token`
- `project_id`, `issue_id`, `comment_id`
- `new_user_id`, `contributor_id`

### **Tests personnalisés**
Chaque requête contient des scripts de test qui valident :
- Le code de statut HTTP
- La structure de la réponse JSON
- La présence des champs requis
- Les temps de réponse

---

## 🐛 Dépannage

### **Problème : Serveur Django non accessible**
- Vérifiez que `python manage.py runserver` fonctionne
- Confirmez l'URL `http://127.0.0.1:8000`

### **Problème : Erreurs d'authentification**
- Vérifiez que les utilisateurs de test existent
- Exécutez le script de configuration des données
- Confirmez que le token est bien stocké

### **Problème : Tests échouent en cascade**
- Exécutez les tests dans l'ordre recommandé
- Vérifiez que les variables sont bien définies
- Relancez depuis l'authentification

### **Problème : Données de test manquantes**
- Exécutez le script `setup-test-environment`
- Vérifiez la base de données Django
- Créez manuellement les utilisateurs si nécessaire

---

## 📊 Rapport de Test

### **Tableau de suivi**
| Phase | Endpoint | Code HTTP | Status | Notes |
|-------|----------|-----------|--------|-------|
| Auth | POST /api/token/ | 200 | ✅/❌ | |
| Auth | POST /api/token/ | 401 | ✅/❌ | |
| Users | POST /api/users/ | 201 | ✅/❌ | |
| Users | GET /api/users/ | 200 | ✅/❌ | |
| ... | ... | ... | ... | |

### **Métriques de réussite**
- **Codes 2xx** : ___/25 réussis
- **Codes 4xx** : ___/15 réussis  
- **Codes 5xx** : ___/1 réussis
- **Total** : ___/41 tests réussis

---

## 🎉 Validation Finale

### **Checklist complète**
- [ ] Tous les endpoints testés avec succès
- [ ] Tous les codes HTTP validés
- [ ] Aucune régression détectée
- [ ] Documentation à jour
- [ ] Tests reproductibles

### **Critères de validation globaux**
- ✅ **API Fonctionnelle** : Tous les endpoints répondent correctement
- ✅ **Sécurité** : Authentification et autorisations fonctionnent
- ✅ **Robustesse** : Gestion d'erreurs appropriée
- ✅ **Performance** : Temps de réponse acceptables (<1000ms)
- ✅ **Conformité REST** : Codes HTTP appropriés

---

**🚀 Votre API SoftDesk Support est prête pour la production !**
