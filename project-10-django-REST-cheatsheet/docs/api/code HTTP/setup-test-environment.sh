#!/bin/bash

# Script de démarrage pour les tests API SoftDesk Support
# Ce script prépare l'environnement de test avec des données de base

echo "🚀 Démarrage de l'API SoftDesk Support pour les tests..."

# Vérifier si le serveur Django est en cours d'exécution
if ! curl -s http://127.0.0.1:8000 > /dev/null; then
    echo "⚠️  Le serveur Django n'est pas en cours d'exécution."
    echo "   Veuillez démarrer le serveur avec : python manage.py runserver"
    exit 1
fi

echo "✅ Serveur Django détecté sur http://127.0.0.1:8000"

# Créer des utilisateurs de test
echo "👥 Création des utilisateurs de test..."

# Utilisateur 1 - Auteur principal
curl -X POST http://127.0.0.1:8000/api/users/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "auteur_principal",
    "email": "auteur@example.com",
    "password": "motdepasse123",
    "password_confirm": "motdepasse123",
    "age": 30,
    "can_be_contacted": true,
    "can_data_be_shared": false
  }' \
  --silent --output /dev/null

# Utilisateur 2 - Contributeur
curl -X POST http://127.0.0.1:8000/api/users/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "contributeur_test",
    "email": "contributeur@example.com",
    "password": "motdepasse123",
    "password_confirm": "motdepasse123",
    "age": 25,
    "can_be_contacted": true,
    "can_data_be_shared": true
  }' \
  --silent --output /dev/null

# Utilisateur 3 - Utilisateur simple
curl -X POST http://127.0.0.1:8000/api/users/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "utilisateur_simple",
    "email": "simple@example.com",
    "password": "motdepasse123",
    "password_confirm": "motdepasse123",
    "age": 22,
    "can_be_contacted": false,
    "can_data_be_shared": false
  }' \
  --silent --output /dev/null

echo "✅ Utilisateurs de test créés :"
echo "   - auteur_principal / motdepasse123"
echo "   - contributeur_test / motdepasse123"
echo "   - utilisateur_simple / motdepasse123"

# Obtenir un token pour l'auteur principal
echo "🔐 Obtention du token JWT pour l'auteur principal..."
TOKEN_RESPONSE=$(curl -X POST http://127.0.0.1:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "auteur_principal",
    "password": "motdepasse123"
  }' \
  --silent)

ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['access'])" 2>/dev/null)

if [ -z "$ACCESS_TOKEN" ]; then
    echo "❌ Impossible d'obtenir le token. Vérifiez que les utilisateurs ont été créés correctement."
    exit 1
fi

echo "✅ Token obtenu pour auteur_principal"

# Créer un projet de test
echo "📋 Création d'un projet de test..."
PROJECT_RESPONSE=$(curl -X POST http://127.0.0.1:8000/api/projects/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "name": "Projet de Test API",
    "description": "Projet créé automatiquement pour tester tous les endpoints de l API",
    "type": "back-end"
  }' \
  --silent)

PROJECT_ID=$(echo $PROJECT_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    echo "❌ Impossible de créer le projet de test."
    exit 1
fi

echo "✅ Projet de test créé (ID: $PROJECT_ID)"

# Créer une issue de test
echo "🐛 Création d'une issue de test..."
ISSUE_RESPONSE=$(curl -X POST http://127.0.0.1:8000/api/projects/$PROJECT_ID/issues/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "title": "Bug de test pour API",
    "description": "Issue créée automatiquement pour tester les endpoints de commentaires",
    "tag": "BUG",
    "priority": "HIGH",
    "status": "TODO"
  }' \
  --silent)

ISSUE_ID=$(echo $ISSUE_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])" 2>/dev/null)

if [ -z "$ISSUE_ID" ]; then
    echo "❌ Impossible de créer l'issue de test."
    exit 1
fi

echo "✅ Issue de test créée (ID: $ISSUE_ID)"

# Créer un commentaire de test
echo "💬 Création d'un commentaire de test..."
curl -X POST http://127.0.0.1:8000/api/projects/$PROJECT_ID/issues/$ISSUE_ID/comments/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "content": "Commentaire de test créé automatiquement pour valider l API des commentaires."
  }' \
  --silent --output /dev/null

echo "✅ Commentaire de test créé"

# Résumé
echo ""
echo "🎉 Environnement de test prêt !"
echo ""
echo "📊 Données créées :"
echo "   - 3 utilisateurs de test"
echo "   - 1 projet de test (ID: $PROJECT_ID)"
echo "   - 1 issue de test (ID: $ISSUE_ID)"
echo "   - 1 commentaire de test"
echo ""
echo "🔗 Endpoints de base disponibles :"
echo "   - API Base URL: http://127.0.0.1:8000"
echo "   - Admin: http://127.0.0.1:8000/admin/"
echo "   - API Auth: http://127.0.0.1:8000/api-auth/"
echo ""
echo "📋 Variables Postman suggérées :"
echo "   - base_url: http://127.0.0.1:8000"
echo "   - project_id: $PROJECT_ID"
echo "   - issue_id: $ISSUE_ID"
echo ""
echo "🔐 Pour obtenir un token JWT dans Postman :"
echo "   POST /api/token/"
echo "   Body: {\"username\": \"auteur_principal\", \"password\": \"motdepasse123\"}"
echo ""
echo "📚 Documentation complète disponible dans :"
echo "   - API-HTTP-Codes-Documentation.md"
echo "   - postman-collection-softdesk.json"
echo "   - TESTING-GUIDE.md"
echo ""
echo "✨ Vous pouvez maintenant importer la collection Postman et commencer les tests !"
