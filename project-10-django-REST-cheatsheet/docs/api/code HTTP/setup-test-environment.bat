@echo off
REM Script de configuration automatique de l'environnement de test pour SoftDesk Support API
REM Ce script crée les utilisateurs et données de base nécessaires pour les tests

echo 🚀 Configuration de l'environnement de test SoftDesk Support...
echo.

REM Vérifier si le serveur Django est accessible
curl -s http://127.0.0.1:8000 >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ⚠️  Le serveur Django n'est pas accessible.
    echo    Veuillez démarrer le serveur avec : python manage.py runserver
    pause
    exit /b 1
)

echo ✅ Serveur Django détecté sur http://127.0.0.1:8000
echo.

echo 👥 Création des utilisateurs de test...

REM Utilisateur 1 - Auteur principal
curl -X POST http://127.0.0.1:8000/api/users/ ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"auteur_principal\", \"email\": \"auteur@example.com\", \"password\": \"motdepasse123\", \"password_confirm\": \"motdepasse123\", \"age\": 30, \"can_be_contacted\": true, \"can_data_be_shared\": false}" ^
  --silent >nul 2>&1

REM Utilisateur 2 - Contributeur
curl -X POST http://127.0.0.1:8000/api/users/ ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"contributeur_test\", \"email\": \"contributeur@example.com\", \"password\": \"motdepasse123\", \"password_confirm\": \"motdepasse123\", \"age\": 25, \"can_be_contacted\": true, \"can_data_be_shared\": true}" ^
  --silent >nul 2>&1

REM Utilisateur 3 - Utilisateur simple
curl -X POST http://127.0.0.1:8000/api/users/ ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"utilisateur_simple\", \"email\": \"simple@example.com\", \"password\": \"motdepasse123\", \"password_confirm\": \"motdepasse123\", \"age\": 22, \"can_be_contacted\": false, \"can_data_be_shared\": false}" ^
  --silent >nul 2>&1

echo ✅ Utilisateurs de test créés :
echo    - auteur_principal / motdepasse123
echo    - contributeur_test / motdepasse123
echo    - utilisateur_simple / motdepasse123
echo.

echo 🔐 Obtention du token JWT pour l'auteur principal...

REM Créer un fichier temporaire pour stocker la réponse
set TEMP_FILE=%TEMP%\token_response.json

curl -X POST http://127.0.0.1:8000/api/token/ ^
  -H "Content-Type: application/json" ^
  -d "{\"username\": \"auteur_principal\", \"password\": \"motdepasse123\"}" ^
  --silent -o "%TEMP_FILE%"

REM Vérifier si le fichier de réponse existe et contient des données
if not exist "%TEMP_FILE%" (
    echo ❌ Impossible d'obtenir le token. Vérifiez que les utilisateurs ont été créés correctement.
    pause
    exit /b 1
)

REM Lire le token depuis le fichier (méthode simplifiée)
for /f "tokens=2 delims=:" %%a in ('findstr "access" "%TEMP_FILE%"') do (
    set TOKEN_PART=%%a
)

if "%TOKEN_PART%"=="" (
    echo ❌ Token non trouvé dans la réponse. Vérifiez les identifiants.
    del "%TEMP_FILE%" 2>nul
    pause
    exit /b 1
)

REM Extraire le token (enlever les guillemets et caractères indésirables)
for /f "tokens=1 delims=," %%b in ("%TOKEN_PART%") do (
    set ACCESS_TOKEN=%%b
)
set ACCESS_TOKEN=%ACCESS_TOKEN:"=%
set ACCESS_TOKEN=%ACCESS_TOKEN: =%

echo ✅ Token obtenu pour auteur_principal
echo.

echo 📋 Création d'un projet de test...

REM Créer un projet de test
curl -X POST http://127.0.0.1:8000/api/projects/ ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer %ACCESS_TOKEN%" ^
  -d "{\"name\": \"Projet de Test API\", \"description\": \"Projet créé automatiquement pour tester tous les endpoints de l API\", \"type\": \"back-end\"}" ^
  --silent -o "%TEMP%\project_response.json"

REM Extraire l'ID du projet (méthode simplifiée)
for /f "tokens=2 delims=:" %%c in ('findstr "\"id\"" "%TEMP%\project_response.json"') do (
    set PROJECT_ID_PART=%%c
)

if "%PROJECT_ID_PART%"=="" (
    echo ❌ Impossible de créer le projet de test.
    del "%TEMP_FILE%" 2>nul
    del "%TEMP%\project_response.json" 2>nul
    pause
    exit /b 1
)

REM Extraire l'ID du projet
for /f "tokens=1 delims=," %%d in ("%PROJECT_ID_PART%") do (
    set PROJECT_ID=%%d
)
set PROJECT_ID=%PROJECT_ID: =%

echo ✅ Projet de test créé (ID: %PROJECT_ID%)
echo.

echo 🐛 Création d'une issue de test...

REM Créer une issue de test
curl -X POST http://127.0.0.1:8000/api/projects/%PROJECT_ID%/issues/ ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer %ACCESS_TOKEN%" ^
  -d "{\"title\": \"Bug de test pour API\", \"description\": \"Issue créée automatiquement pour tester les endpoints de commentaires\", \"tag\": \"BUG\", \"priority\": \"HIGH\", \"status\": \"TODO\"}" ^
  --silent -o "%TEMP%\issue_response.json"

REM Extraire l'ID de l'issue
for /f "tokens=2 delims=:" %%e in ('findstr "\"id\"" "%TEMP%\issue_response.json"') do (
    set ISSUE_ID_PART=%%e
)

if "%ISSUE_ID_PART%"=="" (
    echo ❌ Impossible de créer l'issue de test.
    del "%TEMP_FILE%" 2>nul
    del "%TEMP%\project_response.json" 2>nul
    del "%TEMP%\issue_response.json" 2>nul
    pause
    exit /b 1
)

for /f "tokens=1 delims=," %%f in ("%ISSUE_ID_PART%") do (
    set ISSUE_ID=%%f
)
set ISSUE_ID=%ISSUE_ID: =%

echo ✅ Issue de test créée (ID: %ISSUE_ID%)
echo.

echo 💬 Création d'un commentaire de test...

REM Créer un commentaire de test
curl -X POST http://127.0.0.1:8000/api/projects/%PROJECT_ID%/issues/%ISSUE_ID%/comments/ ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer %ACCESS_TOKEN%" ^
  -d "{\"content\": \"Commentaire de test créé automatiquement pour valider l API des commentaires.\"}" ^
  --silent >nul

echo ✅ Commentaire de test créé
echo.

REM Nettoyage des fichiers temporaires
del "%TEMP_FILE%" 2>nul
del "%TEMP%\project_response.json" 2>nul
del "%TEMP%\issue_response.json" 2>nul

echo 🎉 Environnement de test prêt !
echo.
echo 📊 Données créées :
echo    - 3 utilisateurs de test
echo    - 1 projet de test (ID: %PROJECT_ID%)
echo    - 1 issue de test (ID: %ISSUE_ID%)
echo    - 1 commentaire de test
echo.
echo 🔗 Endpoints de base disponibles :
echo    - API Base URL: http://127.0.0.1:8000
echo    - Admin: http://127.0.0.1:8000/admin/
echo    - API Auth: http://127.0.0.1:8000/api-auth/
echo.
echo 📋 Variables Postman suggérées :
echo    - base_url: http://127.0.0.1:8000
echo    - project_id: %PROJECT_ID%
echo    - issue_id: %ISSUE_ID%
echo.
echo 🔐 Pour obtenir un token JWT dans Postman :
echo    POST /api/token/
echo    Body: {"username": "auteur_principal", "password": "motdepasse123"}
echo.
echo 📚 Documentation complète disponible dans :
echo    - API-HTTP-Codes-Documentation.md
echo    - postman-collection-softdesk.json
echo    - TESTING-GUIDE.md
echo.
echo ✨ Vous pouvez maintenant importer la collection Postman et commencer les tests !
echo.
pause
