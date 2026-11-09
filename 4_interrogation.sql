USE etam_seconde_vie;

-- A. Projections et restrictions

-- A1. Référence, nom, prix et score des produits de score A ou B, triés par prix croissant
SELECT ref_produit, nom_produit, prix_vente, score_environnemental
FROM produit
WHERE score_environnemental IN ('A', 'B')
ORDER BY prix_vente ASC, nom_produit;

-- A2. Référence, nom et prix des produits dont le nom contient « dentelle »
SELECT ref_produit, nom_produit, prix_vente
FROM produit
WHERE nom_produit LIKE '%dentelle%'
ORDER BY nom_produit;

-- A3. Pièces collectées en 2025, de la plus récente à la plus ancienne
SELECT id_collecte, date_depot, etat_piece, destination
FROM collecte
WHERE date_depot BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY date_depot DESC;

-- A4. Pays de confection des produits, sans doublon
SELECT DISTINCT pays_confection
FROM produit
ORDER BY pays_confection;

-- A5. Matières recyclées ou certifiées GOTS, de la plus faible à la plus forte empreinte carbone
SELECT nom_matiere, type_fibre, certification, empreinte_carbone_kg
FROM matiere
WHERE est_recyclee = TRUE OR certification = 'GOTS'
ORDER BY empreinte_carbone_kg;

-- A6. Clientes sans numéro de téléphone
SELECT id_client, prenom, nom, email
FROM client
WHERE telephone IS NULL
ORDER BY nom, prenom;

-- B. Fonctions d'agrégation et données groupées

-- B1. Nombre de pièces collectées, total et moyenne des bons d'achat par destination
SELECT destination, COUNT(*) AS nb_pieces, SUM(montant_bon_achat) AS total_bons, ROUND(AVG(montant_bon_achat), 2) AS bon_moyen
FROM collecte
GROUP BY destination
ORDER BY nb_pieces DESC;

-- B2. Magasins ayant recueilli au moins 5 pièces
SELECT m.nom_magasin, COUNT(c.id_collecte) AS nb_collectes
FROM magasin m
JOIN collecte c ON c.id_magasin = m.id_magasin
GROUP BY m.id_magasin, m.nom_magasin
HAVING COUNT(c.id_collecte) >= 5
ORDER BY nb_collectes DESC;

-- B3. Nombre de commandes et chiffre d'affaires par année et par canal, hors commandes annulées
SELECT YEAR(co.date_commande) AS annee, co.canal, COUNT(DISTINCT co.id_commande) AS nb_commandes, SUM(ct.quantite * ct.prix_unitaire) AS chiffre_affaires
FROM commande co
JOIN contenir ct ON ct.id_commande = co.id_commande
WHERE co.statut <> 'Annulée'
GROUP BY YEAR(co.date_commande), co.canal
ORDER BY annee, co.canal;

-- B4. Produits dont l'empreinte carbone (moyenne des matières pondérée par le pourcentage) dépasse 5 kg CO2e/kg
SELECT p.ref_produit, p.nom_produit, ROUND(SUM(cp.pourcentage / 100 * m.empreinte_carbone_kg), 2) AS empreinte_kg_co2e
FROM produit p
JOIN composer cp ON cp.ref_produit = p.ref_produit
JOIN matiere m ON m.id_matiere = cp.id_matiere
GROUP BY p.ref_produit, p.nom_produit
HAVING SUM(cp.pourcentage / 100 * m.empreinte_carbone_kg) > 5
ORDER BY empreinte_kg_co2e DESC;

-- B5. Nombre de produits, prix moyen, minimum et maximum par score, pour les scores d'au moins 3 produits
SELECT score_environnemental, COUNT(*) AS nb_produits, ROUND(AVG(prix_vente), 2) AS prix_moyen, MIN(prix_vente) AS prix_min, MAX(prix_vente) AS prix_max
FROM produit
GROUP BY score_environnemental
HAVING COUNT(*) >= 3
ORDER BY score_environnemental;

-- B6. Nombre de pièces et bon d'achat moyen par état, pour les états représentés par plus de 10 pièces
SELECT etat_piece, COUNT(*) AS nb_pieces, ROUND(AVG(montant_bon_achat), 2) AS bon_moyen
FROM collecte
GROUP BY etat_piece
HAVING COUNT(*) > 10
ORDER BY nb_pieces DESC;

-- C. Jointures

-- C1. Jointure interne sur 5 tables : clientes, produits, tailles et couleurs des commandes livrées en 2026
SELECT co.id_commande, co.date_commande, cl.prenom, cl.nom, p.nom_produit, v.taille, v.couleur, ct.quantite, ct.prix_unitaire
FROM commande co
INNER JOIN client cl ON cl.id_client = co.id_client
INNER JOIN contenir ct ON ct.id_commande = co.id_commande
INNER JOIN variante v ON v.ref_produit = ct.ref_produit AND v.num_variante = ct.num_variante
INNER JOIN produit p ON p.ref_produit = v.ref_produit
WHERE co.statut = 'Livrée' AND co.date_commande >= '2026-01-01'
ORDER BY co.date_commande, co.id_commande;

-- C2. Jointure externe à gauche : toutes les clientes et leur nombre de commandes, y compris 0
SELECT cl.id_client, cl.prenom, cl.nom, COUNT(co.id_commande) AS nb_commandes
FROM client cl
LEFT OUTER JOIN commande co ON co.id_client = cl.id_client
GROUP BY cl.id_client, cl.prenom, cl.nom
ORDER BY nb_commandes, cl.nom;

-- C3. Auto-jointure (association réflexive) : chaque catégorie avec sa catégorie mère
SELECT c1.libelle_categorie AS categorie, c2.libelle_categorie AS categorie_mere
FROM categorie c1
LEFT OUTER JOIN categorie c2 ON c2.id_categorie = c1.id_categorie_parente
ORDER BY categorie_mere, categorie;

-- C4. Jointure externe à droite : magasins n'ayant recueilli aucune pièce
SELECT m.nom_magasin, m.type_magasin
FROM collecte c
RIGHT OUTER JOIN magasin m ON m.id_magasin = c.id_magasin
WHERE c.id_collecte IS NULL;

-- C5. Jointure sur l'association ternaire : matières, fournisseurs et pourcentages du produit « Soutien-gorge push-up Romance »
SELECT p.nom_produit, m.nom_matiere, m.certification, f.raison_sociale, f.pays_fournisseur, cp.pourcentage
FROM produit p
JOIN composer cp ON cp.ref_produit = p.ref_produit
JOIN matiere m ON m.id_matiere = cp.id_matiere
JOIN fournisseur f ON f.id_fournisseur = cp.id_fournisseur
WHERE p.nom_produit = 'Soutien-gorge push-up Romance'
ORDER BY cp.pourcentage DESC;

-- C6. Jointure externe complète (FULL OUTER JOIN n'existe pas en MySQL : UNION d'une jointure externe à gauche et à droite) : matières et fournisseurs liés à aucun produit
SELECT 'Matière' AS type_donnee, m.nom_matiere AS nom
FROM matiere m
LEFT OUTER JOIN composer cp ON cp.id_matiere = m.id_matiere
WHERE cp.ref_produit IS NULL
UNION
SELECT 'Fournisseur', f.raison_sociale
FROM composer cp
RIGHT OUTER JOIN fournisseur f ON f.id_fournisseur = cp.id_fournisseur
WHERE cp.ref_produit IS NULL;

-- D. Sous-requêtes

-- D1. NOT IN : produits jamais commandés
SELECT ref_produit, nom_produit
FROM produit
WHERE ref_produit NOT IN (SELECT ref_produit FROM contenir);

-- D2. EXISTS : clientes ayant à la fois déposé une pièce et passé au moins une commande
SELECT cl.id_client, cl.prenom, cl.nom, cl.email
FROM client cl
WHERE EXISTS (SELECT 1 FROM collecte c WHERE c.id_client = cl.id_client)
AND EXISTS (SELECT 1 FROM commande co WHERE co.id_client = cl.id_client)
ORDER BY cl.nom;

-- D3. NOT EXISTS : matières utilisées dans aucun produit
SELECT m.nom_matiere
FROM matiere m
WHERE NOT EXISTS (SELECT 1 FROM composer cp WHERE cp.id_matiere = m.id_matiere);

-- D4. ALL : produits plus chers que tous les produits de la catégorie Culottes et de ses sous-catégories
SELECT nom_produit, prix_vente
FROM produit
WHERE prix_vente > ALL (SELECT p.prix_vente FROM produit p JOIN categorie c ON c.id_categorie = p.id_categorie WHERE c.id_categorie = 6 OR c.id_categorie_parente = 6)
ORDER BY prix_vente;

-- D5. IN imbriqués : fournisseurs d'au moins une matière recyclée
SELECT raison_sociale, pays_fournisseur
FROM fournisseur
WHERE id_fournisseur IN (SELECT id_fournisseur FROM composer WHERE id_matiere IN (SELECT id_matiere FROM matiere WHERE est_recyclee = TRUE))
ORDER BY raison_sociale;

-- D6. Sous-requête corrélée et ANY : produits plus chers que la moyenne de leur catégorie et déjà collectés
SELECT p.nom_produit, p.prix_vente
FROM produit p
WHERE p.prix_vente > (SELECT AVG(p2.prix_vente) FROM produit p2 WHERE p2.id_categorie = p.id_categorie)
AND p.ref_produit = ANY (SELECT ref_produit FROM collecte)
ORDER BY p.prix_vente DESC;

-- E. Requête étudiée pour l'arbre relationnel et le plan logique

-- E. Nom des produits de score A et date de dépôt de leurs pièces parties en revente
SELECT p.nom_produit, c.date_depot
FROM produit p
JOIN collecte c ON c.ref_produit = p.ref_produit
WHERE p.score_environnemental = 'A' AND c.destination = 'Revente';
