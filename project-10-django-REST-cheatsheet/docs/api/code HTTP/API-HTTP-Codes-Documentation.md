# 📊 Documentation des Codes de Réponse HTTP - API SoftDesk Support

## 🎯 Vue d'ensemble

Cette documentation présente tous les types de points de terminaison de l'API SoftDesk Support avec leurs codes de réponse HTTP respectifs. L'API utilise Django REST Framework avec authentification JWT et suit les principes REST avec des routes imbriquées.

## 🔗 Architecture des Endpoints

### URL de base : `http://127.0.0.1:8000`

```
/api/
├── token/                          # Authentification JWT
├── users/                          # Gestion des utilisateurs
├── projects/                       # Gestion des projets
│   └── {id}/contributors/          # Contributeurs par projet
│   └── {id}/issues/                # Issues par projet
│       └── {id}/comments/          # Commentaires par issue
└── admin/                          # Interface d'administration
```

---

## 🔐 Authentification JWT

### `POST /api/token/` - Obtenir un token d'accès

**Succès :**
- **200 OK** : Token généré avec succès
  ```json
  {
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }
  ```

**Erreurs :**
- **400 Bad Request** : Données manquantes ou malformées
  ```json
  {
    "username": ["Ce champ est obligatoire."],
    "password": ["Ce champ est obligatoire."]
  }
  ```
- **401 Unauthorized** : Identifiants incorrects
  ```json
  {
    "detail": "No active account found with the given credentials"
  }
  ```

---

### `POST /api/token/refresh/` - Rafraîchir le token

**Succès :**
- **200 OK** : Token rafraîchi avec succès
  ```json
  {
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }
  ```

**Erreurs :**
- **401 Unauthorized** : Token de rafraîchissement invalide ou expiré

---

## 👥 Gestion des Utilisateurs

### `POST /api/users/` - Créer un utilisateur

**Succès :**
- **201 Created** : Utilisateur créé avec succès
  ```json
  {
    "id": 1,
    "username": "nouvel_utilisateur",
    "email": "nouveau@example.com",
    "age": 25,
    "can_be_contacted": true,
    "can_data_be_shared": false,
    "date_joined": "2024-01-15T12:00:00Z"
  }
  ```

**Erreurs :**
- **400 Bad Request** : Données de validation échouées
  ```json
  {
    "username": ["Un utilisateur avec ce nom existe déjà."],
    "email": ["Saisissez une adresse de courriel valide."],
    "age": ["L'âge doit être supérieur à 15 ans."],
    "password": ["Les mots de passe ne correspondent pas."]
  }
  ```

---

### `GET /api/users/` - Lister tous les utilisateurs

**Succès :**
- **200 OK** : Liste des utilisateurs (format résumé)
  ```json
  [
    {
      "id": 1,
      "username": "utilisateur1",
      "email": "user1@example.com"
    },
    {
      "id": 2,
      "username": "utilisateur2", 
      "email": "user2@example.com"
    }
  ]
  ```

**Erreurs :**
- **401 Unauthorized** : Token manquant ou invalide
  ```json
  {
    "detail": "Authentication credentials were not provided."
  }
  ```

---

### `GET /api/users/{id}/` - Obtenir un utilisateur spécifique

**Succès :**
- **200 OK** : Détails complets de l'utilisateur
  ```json
  {
    "id": 1,
    "username": "utilisateur1",
    "email": "user1@example.com",
    "age": 30,
    "can_be_contacted": true,
    "can_data_be_shared": false,
    "date_joined": "2024-01-15T12:00:00Z"
  }
  ```

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **404 Not Found** : Utilisateur inexistant
  ```json
  {
    "detail": "Not found."
  }
  ```

---

### `PUT/PATCH /api/users/{id}/` - Modifier un utilisateur

**Succès :**
- **200 OK** : Utilisateur modifié avec succès (même format que GET)

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas le propriétaire du compte
  ```json
  {
    "detail": "You do not have permission to perform this action."
  }
  ```
- **404 Not Found** : Utilisateur inexistant
- **400 Bad Request** : Données invalides

---

### `DELETE /api/users/{id}/` - Supprimer un utilisateur

**Succès :**
- **204 No Content** : Utilisateur supprimé (pas de contenu retourné)

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas le propriétaire du compte
- **404 Not Found** : Utilisateur inexistant

---

## 📋 Gestion des Projets

### `POST /api/projects/` - Créer un projet

**Succès :**
- **201 Created** : Projet créé avec l'utilisateur comme auteur
  ```json
  {
    "id": 1,
    "name": "Mon Projet",
    "description": "Description du projet",
    "type": "back-end",
    "author": {
      "id": 1,
      "username": "auteur_principal"
    },
    "created_time": "2024-01-15T12:00:00Z"
  }
  ```

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **400 Bad Request** : Données invalides
  ```json
  {
    "name": ["Ce champ est obligatoire."],
    "type": ["Choisissez un type valide."]
  }
  ```

---

### `GET /api/projects/` - Lister les projets

**Succès :**
- **200 OK** : Projets où l'utilisateur est contributeur
  ```json
  [
    {
      "id": 1,
      "name": "Projet 1",
      "type": "back-end",
      "author": "auteur_principal"
    }
  ]
  ```

**Erreurs :**
- **401 Unauthorized** : Non authentifié

---

### `GET /api/projects/{id}/` - Obtenir un projet spécifique

**Succès :**
- **200 OK** : Détails complets du projet

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas contributeur du projet
- **404 Not Found** : Projet inexistant

---

### `PUT/PATCH /api/projects/{id}/` - Modifier un projet

**Succès :**
- **200 OK** : Projet modifié avec succès

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas l'auteur du projet
- **404 Not Found** : Projet inexistant
- **400 Bad Request** : Données invalides

---

### `DELETE /api/projects/{id}/` - Supprimer un projet

**Succès :**
- **204 No Content** : Projet supprimé

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas l'auteur du projet
- **404 Not Found** : Projet inexistant

---

## 🤝 Gestion des Contributeurs

### `POST /api/projects/{project_id}/contributors/` - Ajouter un contributeur

**Succès :**
- **201 Created** : Contributeur ajouté au projet
  ```json
  {
    "id": 1,
    "user": {
      "id": 2,
      "username": "contributeur"
    },
    "project": 1
  }
  ```

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas l'auteur du projet
- **404 Not Found** : Projet ou utilisateur inexistant
- **400 Bad Request** : Contributeur déjà ajouté ou données invalides

---

### `GET /api/projects/{project_id}/contributors/` - Lister les contributeurs

**Succès :**
- **200 OK** : Liste des contributeurs du projet

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas contributeur du projet
- **404 Not Found** : Projet inexistant

---

### `DELETE /api/projects/{project_id}/contributors/{id}/` - Supprimer un contributeur

**Succès :**
- **204 No Content** : Contributeur supprimé

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas l'auteur du projet
- **404 Not Found** : Projet ou contributeur inexistant

---

## 🐛 Gestion des Issues

### `POST /api/projects/{project_id}/issues/` - Créer une issue

**Succès :**
- **201 Created** : Issue créée dans le projet
  ```json
  {
    "id": 1,
    "title": "Bug à corriger",
    "description": "Description détaillée",
    "tag": "BUG",
    "priority": "HIGH",
    "status": "TODO",
    "author": {
      "id": 1,
      "username": "auteur_principal"
    },
    "project": 1,
    "created_time": "2024-01-15T12:00:00Z"
  }
  ```

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas contributeur du projet
- **404 Not Found** : Projet inexistant
- **400 Bad Request** : Données invalides

---

### `GET /api/projects/{project_id}/issues/` - Lister les issues

**Succès :**
- **200 OK** : Issues du projet (format résumé)

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas contributeur du projet
- **404 Not Found** : Projet inexistant

---

### `GET /api/projects/{project_id}/issues/{id}/` - Obtenir une issue

**Succès :**
- **200 OK** : Détails complets de l'issue

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas contributeur du projet
- **404 Not Found** : Projet ou issue inexistant

---

### `PUT/PATCH /api/projects/{project_id}/issues/{id}/` - Modifier une issue

**Succès :**
- **200 OK** : Issue modifiée avec succès

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas l'auteur de l'issue ou l'auteur du projet
- **404 Not Found** : Projet ou issue inexistant
- **400 Bad Request** : Données invalides

---

### `DELETE /api/projects/{project_id}/issues/{id}/` - Supprimer une issue

**Succès :**
- **204 No Content** : Issue supprimée

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas l'auteur de l'issue ou l'auteur du projet
- **404 Not Found** : Projet ou issue inexistant

---

## 💬 Gestion des Commentaires

### `POST /api/projects/{project_id}/issues/{issue_id}/comments/` - Créer un commentaire

**Succès :**
- **201 Created** : Commentaire créé sur l'issue
  ```json
  {
    "id": 1,
    "content": "Contenu du commentaire",
    "author": {
      "id": 1,
      "username": "auteur_principal"
    },
    "issue": 1,
    "created_time": "2024-01-15T12:00:00Z"
  }
  ```

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas contributeur du projet
- **404 Not Found** : Projet ou issue inexistant
- **400 Bad Request** : Contenu manquant ou invalide

---

### `GET /api/projects/{project_id}/issues/{issue_id}/comments/` - Lister les commentaires

**Succès :**
- **200 OK** : Commentaires de l'issue

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas contributeur du projet
- **404 Not Found** : Projet ou issue inexistant

---

### `GET /api/projects/{project_id}/issues/{issue_id}/comments/{id}/` - Obtenir un commentaire

**Succès :**
- **200 OK** : Détails du commentaire

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas contributeur du projet
- **404 Not Found** : Projet, issue ou commentaire inexistant

---

### `PUT/PATCH /api/projects/{project_id}/issues/{issue_id}/comments/{id}/` - Modifier un commentaire

**Succès :**
- **200 OK** : Commentaire modifié avec succès

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas l'auteur du commentaire
- **404 Not Found** : Projet, issue ou commentaire inexistant
- **400 Bad Request** : Données invalides

---

### `DELETE /api/projects/{project_id}/issues/{issue_id}/comments/{id}/` - Supprimer un commentaire

**Succès :**
- **204 No Content** : Commentaire supprimé

**Erreurs :**
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Pas l'auteur du commentaire
- **404 Not Found** : Projet, issue ou commentaire inexistant

---

## ❌ Scénarios d'Erreur Globaux

### **400 Bad Request**
- Données JSON malformées
- Champs requis manquants
- Valeurs invalides (email, âge, etc.)
- Contraintes de validation non respectées

### **401 Unauthorized**
- Token JWT manquant
- Token JWT invalide ou expiré
- Identifiants de connexion incorrects

### **403 Forbidden**
- Permissions insuffisantes
- Tentative d'accès à une ressource non autorisée
- Modification de ressources d'autres utilisateurs

### **404 Not Found**
- Endpoint inexistant
- Ressource demandée introuvable
- ID invalide dans l'URL

### **405 Method Not Allowed**
- Méthode HTTP non supportée sur l'endpoint
- Exemple : PATCH sur `/api/projects/` (seul POST/GET autorisés)

### **500 Internal Server Error**
- Erreur côté serveur
- Exception non gérée dans le code
- Problème de base de données

---

## 🔧 Configuration et Tests

### Variables d'environnement Postman recommandées :
```
base_url: http://127.0.0.1:8000
test_username: auteur_principal
test_password: motdepasse123
```

### Headers requis :
```
Content-Type: application/json
Authorization: Bearer {access_token}
```

### Ordre de test recommandé :
1. **Authentification** : Obtenir le token JWT
2. **Utilisateurs** : Créer/lister/consulter les utilisateurs
3. **Projets** : Créer et gérer les projets
4. **Contributeurs** : Ajouter des contributeurs aux projets
5. **Issues** : Créer et gérer les issues
6. **Commentaires** : Ajouter des commentaires aux issues
7. **Scénarios d'erreur** : Tester tous les cas d'erreur

---

## 📈 Résumé des Codes HTTP Utilisés

| Code | Signification | Usage dans l'API |
|------|---------------|------------------|
| **200** | OK | Récupération et modification réussies |
| **201** | Created | Création de ressources réussie |
| **204** | No Content | Suppression réussie |
| **400** | Bad Request | Données invalides ou malformées |
| **401** | Unauthorized | Authentification requise |
| **403** | Forbidden | Permissions insuffisantes |
| **404** | Not Found | Ressource inexistante |
| **405** | Method Not Allowed | Méthode HTTP non supportée |
| **500** | Internal Server Error | Erreur serveur |

Cette documentation couvre tous les endpoints de l'API SoftDesk Support avec leurs codes de réponse HTTP respectifs, permettant un test complet de tous les scénarios possibles.
