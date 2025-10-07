---
Description : Créez ou mettez à jour la constitution du projet à partir d'entrées interactives ou fournies, en veillant à ce que tous les modèles dépendants restent synchronisés.
---

## Entrées utilisateur

```text
$ARGUMENTS
```

Vous **DEVEZ** tenir compte des données saisies par l'utilisateur avant de continuer (si elles ne sont pas vides).

## Aperçu

Vous mettez à jour la constitution du projet dans `.specify/memory/constitution.md`. Ce fichier est un MODÈLE contenant des jetons de remplacement entre crochets (par exemple `[PROJECT_NAME]`, `[PRINCIPLE_1_NAME]`). Votre travail consiste à (a) collecter/déduire des valeurs concrètes, (b) remplir le modèle avec précision et (c) propager toute modification dans les artefacts dépendants.

Suivez ce flux d'exécution :

1. Chargez le modèle de constitution existant à l'adresse `.specify/memory/constitution.md`.
   - Identifiez tous les jetons de remplacement sous la forme `[ALL_CAPS_IDENTIFIER]`.
   **IMPORTANT** : l'utilisateur peut avoir besoin de plus ou moins de principes que ceux utilisés dans le modèle. Si un nombre est spécifié, respectez-le et suivez le modèle général. Vous mettrez à jour le document en conséquence.

2. Collectez/déduisez les valeurs des espaces réservés :
   - Si l'entrée utilisateur (conversation) fournit une valeur, utilisez-la.
   - Sinon, déduisez-la du contexte du dépôt existant (README, documents, versions antérieures de la constitution si elles sont intégrées).
   - Pour les dates de gouvernance : `RATIFICATION_DATE` est la date d'adoption initiale (si elle est inconnue, demandez-la ou marquez-la comme TODO), `LAST_AMENDED_DATE` est la date du jour si des modifications ont été apportées, sinon conservez la date précédente.
   - `CONSTITUTION_VERSION` doit être incrémentée selon les règles de versionnement sémantique :
     * MAJOR : Suppressions ou redéfinitions de gouvernance/principes incompatibles avec les versions antérieures.
     * MINOR : ajout d'un nouveau principe/d'une nouvelle section ou extension significative des directives.
     * PATCH : clarifications, formulations, corrections de fautes de frappe, améliorations non sémantiques.
   - Si le type de modification de version est ambigu, proposez un raisonnement avant de finaliser.

3. Rédiger le contenu de la constitution mise à jour :
   - Remplacer chaque espace réservé par un texte concret (ne laisser aucun token entre crochets, sauf les emplacements de modèle intentionnellement conservés que le projet a choisi de ne pas encore définir — justifier explicitement tout emplacement restant).
   - Conservez la hiérarchie des titres et supprimez les commentaires une fois qu'ils ont été remplacés, sauf s'ils apportent des précisions utiles.
   - Veiller à ce que chaque section « Principes » comporte : un titre succinct, un paragraphe (ou une liste à puces) reprenant les règles non négociables, une justification explicite si cela n'est pas évident.
   - Veiller à ce que la section Gouvernance énumère la procédure de modification, la politique de gestion des versions et les attentes en matière d'examen de conformité.

4. Liste de contrôle de propagation de la cohérence (convertir la liste de contrôle précédente en validations actives) :
   - Lisez `.specify/templates/plan-template.md` et assurez-vous que tous les « contrôles de constitution » ou règles sont conformes aux principes mis à jour.
   - Lisez `.specify/templates/spec-template.md` pour vérifier l'alignement de la portée/des exigences — mettez à jour si la constitution ajoute/supprime des sections obligatoires ou des contraintes.
   - Lisez `.specify/templates/tasks-template.md` et assurez-vous que la catégorisation des tâches reflète les types de tâches nouveaux ou supprimés basés sur les principes (par exemple, observabilité, gestion des versions, discipline de test).
   - Lisez chaque fichier de commande dans `.specify/templates/commands/*.md` (y compris celui-ci) pour vérifier qu'il ne reste aucune référence obsolète (noms spécifiques à l'agent comme CLAUDE uniquement) lorsqu'une orientation générique est requise.
   - Lisez tous les documents d'orientation sur l'exécution (par exemple, `README.md`, `docs/quickstart.md` ou les fichiers d'orientation spécifiques à l'agent, le cas échéant). Mettez à jour les références aux principes modifiés.

5. Produisez un rapport d'impact de synchronisation (à ajouter en tant que commentaire HTML en haut du fichier de constitution après la mise à jour) :
   - Changement de version : ancien → nouveau
   - Liste des principes modifiés (ancien titre → nouveau titre s'il a été renommé)
   - Sections ajoutées
   - Sections supprimées
   - Modèles nécessitant des mises à jour (✅ mis à jour / ⚠ en attente) avec chemins d'accès aux fichiers
   - Suivi des tâches à effectuer si des espaces réservés ont été intentionnellement reportés.

6. Validation avant la sortie finale :
   - Aucun jeton de parenthèse inexpliqué restant.
   - La ligne de version correspond au rapport.
   - Dates au format ISO AAAA-MM-JJ.
   - Les principes sont déclaratifs, vérifiables et exempts de langage vague (« devrait » → remplacer par « DOIT/DEVRAIT » lorsque cela est approprié).

7. Écrivez la constitution complète dans `.specify/memory/constitution.md` (écraser).

8. Envoyez un résumé final à l'utilisateur avec :
   - Nouvelle version et justification de la mise à jour.
   - Tous les fichiers signalés pour un suivi manuel.
   - Message de validation suggéré (par exemple, « docs : modification de la constitution vers vX.Y.Z (ajouts de principes + mise à jour de la gouvernance) »).

Exigences en matière de formatage et de style :
- Utilisez les en-têtes Markdown exactement comme dans le modèle (ne réduisez/augmentez pas les niveaux).
- Enveloppez les longues lignes de justification pour conserver la lisibilité (idéalement moins de 100 caractères), mais n'imposez pas de coupures artificielles.
- Conservez une seule ligne vide entre les sections.
- Évitez les espaces blancs à la fin des lignes.

Si l'utilisateur fournit des mises à jour partielles (par exemple, une seule révision de principe), procédez tout de même aux étapes de validation et de décision de version.

Si des informations essentielles manquent (par exemple, la date de ratification est vraiment inconnue), insérez « TODO(<FIELD_NAME>) : explication » et incluez-la dans le rapport d'impact de la synchronisation sous les éléments différés.

Ne créez pas de nouveau modèle ; utilisez toujours le fichier « .specify/memory/constitution.md » existant.
