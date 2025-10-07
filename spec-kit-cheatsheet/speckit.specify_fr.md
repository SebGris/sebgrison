---
description : Créer ou mettre à jour la spécification d'une fonctionnalité à partir d'une description en langage naturel.
---

## Entrée utilisateur

```text
$ARGUMENTS
```

Vous **DEVEZ** tenir compte des données saisies par l'utilisateur avant de continuer (si elles ne sont pas vides).

## Aperçu

Le texte saisi par l'utilisateur après « /speckit.specify » dans le message déclencheur **correspond** à la description de la fonctionnalité. Considérez qu'il est toujours disponible dans cette conversation, même si « $ARGUMENTS » apparaît littéralement ci-dessous. Ne demandez pas à l'utilisateur de le répéter, sauf s'il a fourni une commande vide.

Compte tenu de cette description de la fonctionnalité, procédez comme suit :

1. Exécutez le script `.specify/scripts/powershell/create-new-feature.ps1 -Json "$ARGUMENTS"` à partir de la racine du dépôt et analysez sa sortie JSON pour BRANCH_NAME et SPEC_FILE. Tous les chemins d'accès aux fichiers doivent être absolus.
  **IMPORTANT** Vous ne devez exécuter ce script qu'une seule fois. Le JSON est fourni dans le terminal en tant que sortie. Reportez-vous toujours à celui-ci pour obtenir le contenu réel que vous recherchez.
2. Chargez `.specify/templates/spec-template.md` pour comprendre les sections requises.

3. Suivez ce flux d'exécution :

    1. Analyser la description de l'utilisateur à partir de l'entrée
       Si vide : ERREUR « Aucune description de fonctionnalité fournie »
    2. Extraire les concepts clés de la description
       Identifier : acteurs, actions, données, contraintes
    3. Pour les aspects peu clairs :
       - Faire des suppositions éclairées en fonction du contexte et des normes du secteur
       - Ne marquer avec [À CLARIFIER : question spécifique] que si :
         - Le choix a un impact significatif sur la portée des fonctionnalités ou l'expérience utilisateur
         - Il existe plusieurs interprétations raisonnables avec des implications différentes
         - Il n'existe aucune valeur par défaut raisonnable
       - **LIMITE : 3 marqueurs [À CLARIFIER] au maximum**
       - Classez les clarifications par ordre de priorité en fonction de leur impact : portée > sécurité/confidentialité > expérience utilisateur > détails techniques
    4. Remplissez la section Scénarios d'utilisation et tests
       Si aucun flux utilisateur clair n'est défini : ERREUR « Impossible de déterminer les scénarios utilisateur »
    5. Générer les exigences fonctionnelles
       Chaque exigence doit être testable
       Utilisez des valeurs par défaut raisonnables pour les détails non spécifiés (documentez les hypothèses dans la section Hypothèses)
    6. Définir les critères de réussite
       Créer des résultats mesurables et indépendants de la technologie
       Inclure à la fois des mesures quantitatives (temps, performances, volume) et qualitatives (satisfaction des utilisateurs, achèvement des tâches)
       Chaque critère doit être vérifiable sans détails de mise en œuvre
    7. Identifier les entités clés (si des données sont impliquées)
    8. Résultat : SUCCÈS (spécifications prêtes pour la planification)

4. Écrire la spécification dans SPEC_FILE en utilisant la structure du modèle, en remplaçant les espaces réservés par des détails concrets tirés de la description des fonctionnalités (arguments) tout en conservant l'ordre des sections et les en-têtes.

5. **Validation de la qualité de la spécification** : après avoir rédigé la spécification initiale, validez-la par rapport aux critères de qualité :

   a. **Créer une liste de contrôle de la qualité des spécifications** : générez un fichier de liste de contrôle dans `FEATURE_DIR/checklists/requirements.md` en utilisant la structure du modèle de liste de contrôle avec les éléments de validation suivants :


   
      ```markdown
      # Liste de contrôle de la qualité des spécifications : [NOM DE LA FONCTIONNALITÉ]


      
      **Objectif** : Valider l'exhaustivité et la qualité des spécifications avant de passer à la planification
      **Créé le** : [DATE]
      **Fonctionnalité** : [Lien vers spec.md]


      
      ## Qualité du contenu


      
      - [ ] Aucun détail de mise en œuvre (langages, frameworks, API)
      - [ ] Axé sur la valeur pour l'utilisateur et les besoins de l'entreprise
      - [ ] Rédigé pour des parties prenantes non techniques
      - [ ] Toutes les sections obligatoires sont remplies


      
      ## Exhaustivité des exigences


      
      - [ ] Aucun marqueur [À CLARIFIER] ne subsiste
      - [ ] Les exigences sont vérifiables et sans ambiguïté
      - [ ] Les critères de réussite sont mesurables
      - [ ] Les critères de réussite sont indépendants de la technologie (pas de détails de mise en œuvre)
      - [ ] Tous les scénarios d'acceptation sont définis
      - [ ] Les cas limites sont identifiés
      - [ ] Le périmètre est clairement délimité
      - [ ] Les dépendances et les hypothèses sont identifiées


      
      ## Préparation des fonctionnalités


      
      - [ ] Toutes les exigences fonctionnelles ont des critères d'acceptation clairs
      - [ ] Les scénarios utilisateur couvrent les flux principaux
      - [ ] La fonctionnalité répond aux résultats mesurables définis dans les critères de réussite
      - [ ] Aucun détail de mise en œuvre ne transparaît dans les spécifications


      
      ## Remarques


      
      - Les éléments marqués comme incomplets nécessitent une mise à jour des spécifications avant `/speckit.clarify` ou `/speckit.plan`
      ```


   
   b. **Exécuter la vérification de validation** : examinez les spécifications par rapport à chaque élément de la liste de contrôle :
      - Pour chaque élément, déterminez s'il est conforme ou non
      - Documentez les problèmes spécifiques détectés (citez les sections pertinentes des spécifications)


   
   c. **Traiter les résultats de la validation** :


      
      - **Si tous les éléments sont conformes** : cochez la liste de contrôle et passez à l'étape 6


      
      - **Si des éléments échouent (à l'exception de [À CLARIFIER])** :
        1. Dressez la liste des éléments non conformes et des problèmes spécifiques
        2. Mettez à jour les spécifications pour résoudre chaque problème
        3. Relancez la validation jusqu'à ce que tous les éléments soient conformes (3 itérations maximum)
        4. Si les éléments échouent toujours après 3 itérations, documentez les problèmes restants dans les notes de la liste de contrôle et avertissez l'utilisateur


      
      - **Si des marqueurs [À CLARIFIER] subsistent** :
        1. Extrayez tous les marqueurs [NEEDS CLARIFICATION: ...] de la spécification
        2. **VÉRIFICATION DES LIMITES** : s'il y a plus de 3 marqueurs, ne conservez que les 3 plus critiques (en termes de portée/sécurité/impact sur l'expérience utilisateur) et faites des suppositions éclairées pour les autres
        3. Pour chaque clarification nécessaire (max. 3), présentez les options à l'utilisateur dans ce format :


        
           ```markdown
           ## Question [N] : [Sujet]


           
           **Contexte** : [Citer la section pertinente des spécifications]


           
           **Ce que nous devons savoir** : [Question spécifique issue du marqueur « À CLARIFIER »]


           
           **Réponses suggérées** :


           
           | Option | Réponse | Implications |
           |--------|--------|--------------|
           | A      | [Première réponse suggérée] | [Ce que cela signifie pour la fonctionnalité] |
           | B      | [Deuxième réponse suggérée] | [Ce que cela signifie pour la fonctionnalité] |
           | C      | [Troisième réponse suggérée] | [Ce que cela signifie pour la fonctionnalité] |
           | Personnalisé | Fournissez votre propre réponse | [Expliquez comment fournir une entrée personnalisée] |


           
           **Votre choix** : _[Attendre la réponse de l'utilisateur]_
           ```


        
        4. **CRITIQUE - Formatage des tableaux** : assurez-vous que les tableaux Markdown sont correctement formatés :
           - Utilisez un espacement cohérent avec des barres verticales alignées
           - Chaque cellule doit comporter des espaces autour du contenu : `| Contenu |` et non `|Contenu|`
           - Le séparateur d'en-tête doit comporter au moins 3 tirets : `|--------|`
           - Vérifiez que le tableau s'affiche correctement dans l'aperçu Markdown
        5. Numérotez les questions de manière séquentielle (Q1, Q2, Q3 - 3 au maximum)
        6. Présentez toutes les questions ensemble avant d'attendre les réponses
        7. Attendez que l'utilisateur réponde en indiquant ses choix pour toutes les questions (par exemple, « Q1 : A, Q2 : Personnalisé - [détails], Q3 : B »)
        8. Mettre à jour le cahier des charges en remplaçant chaque marqueur [À CLARIFIER] par la réponse sélectionnée ou fournie par l'utilisateur
        9. Relancer la validation une fois toutes les clarifications résolues


   
   d. **Mettre à jour la liste de contrôle** : après chaque itération de validation, mettre à jour le fichier de la liste de contrôle avec le statut actuel de réussite/échec.

6. Signalez l'achèvement avec le nom de la branche, le chemin d'accès au fichier de spécifications, les résultats de la liste de contrôle et l'état de préparation pour la phase suivante (`/speckit.clarify` ou `/speckit.plan`).

**REMARQUE :** le script crée et vérifie la nouvelle branche et initialise le fichier de spécifications avant l'écriture.

## Directives générales

## Directives rapides

- Concentrez-vous sur **CE DONT** les utilisateurs ont besoin et **POURQUOI**.
- Évitez les détails techniques (pas de pile technologique, d'API, de structure de code).
- Rédigez pour les parties prenantes commerciales, pas pour les développeurs.
- NE CRÉEZ PAS de listes de contrôle intégrées dans les spécifications. Cela fera l'objet d'une commande distincte.

### Exigences de la section

- **Sections obligatoires** : doivent être remplies pour chaque fonctionnalité
- **Sections facultatives** : à inclure uniquement lorsqu'elles sont pertinentes pour la fonctionnalité
- Lorsqu'une section ne s'applique pas, supprimez-la entièrement (ne la laissez pas en indiquant « N/A »).

### Pour la génération par IA

Lors de la création de cette spécification à partir d'une invite utilisateur :

1. **Faites des suppositions éclairées** : utilisez le contexte, les normes du secteur et les modèles courants pour combler les lacunes
2. **Documentez vos hypothèses** : consignez les valeurs par défaut raisonnables dans la section « Hypothèses ».
3. **Limitez les clarifications** : maximum 3 marqueurs [À CLARIFIER] - à utiliser uniquement pour les décisions critiques qui :
   - ont un impact significatif sur la portée des fonctionnalités ou l'expérience utilisateur
   - ont plusieurs interprétations raisonnables avec des implications différentes
   - ne disposent d'aucune valeur par défaut raisonnable
4. **Hiérarchiser les clarifications** : portée > sécurité/confidentialité > expérience utilisateur > détails techniques
5. **Penser comme un testeur** : toute exigence vague doit échouer au critère « testable et sans ambiguïté » de la liste de contrôle
6. **Domaines courants nécessitant des clarifications** (uniquement s'il n'existe aucune valeur par défaut raisonnable) :
   - Portée et limites des fonctionnalités (inclure/exclure des cas d'utilisation spécifiques)
   - Types d'utilisateurs et autorisations (si plusieurs interprétations contradictoires sont possibles)
   - Exigences en matière de sécurité/conformité (lorsqu'elles sont importantes sur le plan juridique/financier)


   
**Exemples de valeurs par défaut raisonnables** (ne posez pas de questions à ce sujet) :

- Conservation des données : pratiques standard du secteur pour le domaine
- Objectifs de performance : attentes standard pour les applications web/mobiles, sauf indication contraire
- Gestion des erreurs : messages conviviaux avec solutions de secours appropriées
- Méthode d'authentification : standard basée sur la session ou OAuth2 pour les applications web
- Modèles d'intégration : API RESTful, sauf indication contraire

### Critères de réussite - Lignes directrices

Les critères de réussite doivent être les suivants :

1. **Mesurables** : inclure des indicateurs spécifiques (temps, pourcentage, nombre, taux)
2. **Indépendants de la technologie** : aucune mention des frameworks, langages, bases de données ou outils
3. **Axés sur l'utilisateur** : décrire les résultats du point de vue de l'utilisateur/de l'entreprise, et non du fonctionnement interne du système
4. **Vérifiable** : peut être testé/validé sans connaître les détails de la mise en œuvre

**Bons exemples** :

- « Les utilisateurs peuvent finaliser leur commande en moins de 3 minutes »
- « Le système prend en charge 10 000 utilisateurs simultanés »
- « 95 % des recherches donnent des résultats en moins d'une seconde »
- « Le taux d'achèvement des tâches s'améliore de 40 % »

**Mauvais exemples** (axés sur la mise en œuvre) :

- « Le temps de réponse de l'API est inférieur à 200 ms » (trop technique, utilisez plutôt « Les utilisateurs voient les résultats instantanément »)
- « La base de données peut traiter 1 000 TPS » (détail de mise en œuvre, utilisez une métrique orientée utilisateur)
- « Les composants React s'affichent efficacement » (spécifique au framework)
- « Taux de réussite du cache Redis supérieur à 80 % » (spécifique à la technologie)
