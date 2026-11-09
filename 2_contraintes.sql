USE etam_seconde_vie;

-- RG06
ALTER TABLE collection ADD CONSTRAINT ck_collection_saison CHECK (saison IN ('Printemps-Été', 'Automne-Hiver'));
ALTER TABLE collection ADD CONSTRAINT ck_collection_annee CHECK (annee BETWEEN 2015 AND 2030);

-- RG07 à RG11
ALTER TABLE produit ADD CONSTRAINT ck_produit_ref CHECK (ref_produit LIKE 'ET______');
ALTER TABLE produit ADD CONSTRAINT ck_produit_prix CHECK (prix_vente > 0 AND prix_vente < 500);
ALTER TABLE produit ADD CONSTRAINT ck_produit_recyclabilite CHECK (taux_recyclabilite BETWEEN 0 AND 100);
ALTER TABLE produit ADD CONSTRAINT ck_produit_score CHECK (score_environnemental IN ('A', 'B', 'C', 'D', 'E'));
ALTER TABLE produit ADD CONSTRAINT ck_produit_date_lancement CHECK (date_lancement >= '2015-01-01');

-- RG13 à RG15
ALTER TABLE variante ADD CONSTRAINT ck_variante_taille CHECK (taille IN ('XS', 'S', 'M', 'L', 'XL', 'XXL', 'TU') OR taille LIKE '70_' OR taille LIKE '75_' OR taille LIKE '80_' OR taille LIKE '85_' OR taille LIKE '90_' OR taille LIKE '95_' OR taille LIKE '100_' OR taille LIKE '105_');
ALTER TABLE variante ADD CONSTRAINT ck_variante_ean CHECK (code_ean LIKE '_____________');
ALTER TABLE variante ADD CONSTRAINT ck_variante_stock CHECK (stock >= 0);
ALTER TABLE variante ADD CONSTRAINT ck_variante_num CHECK (num_variante >= 1);

-- RG17 à RG20
ALTER TABLE matiere ADD CONSTRAINT ck_matiere_type CHECK (type_fibre IN ('Naturelle', 'Synthétique', 'Artificielle'));
ALTER TABLE matiere ADD CONSTRAINT ck_matiere_certification CHECK (certification IS NULL OR certification IN ('GOTS', 'OEKO-TEX', 'GRS', 'RCS', 'FSC'));
ALTER TABLE matiere ADD CONSTRAINT ck_matiere_recyclee CHECK (est_recyclee = FALSE OR certification IN ('GRS', 'RCS'));
ALTER TABLE matiere ADD CONSTRAINT ck_matiere_empreinte CHECK (empreinte_carbone_kg >= 0);

-- RG22
ALTER TABLE fournisseur ADD CONSTRAINT ck_fournisseur_email CHECK (email_fournisseur LIKE '%_@_%._%');

-- RG24
ALTER TABLE composer ADD CONSTRAINT ck_composer_pourcentage CHECK (pourcentage > 0 AND pourcentage <= 100);

-- RG27
ALTER TABLE magasin ADD CONSTRAINT ck_magasin_type CHECK (type_magasin IN ('Boutique', 'Corner', 'Outlet'));

-- RG29 à RG32
ALTER TABLE client ADD CONSTRAINT ck_client_email CHECK (email LIKE '%_@_%._%');
ALTER TABLE client ADD CONSTRAINT ck_client_telephone CHECK (telephone IS NULL OR telephone LIKE '0_________');
ALTER TABLE client ADD CONSTRAINT ck_client_age CHECK (YEAR(date_inscription) - YEAR(date_naissance) >= 15);
ALTER TABLE client ADD CONSTRAINT ck_client_points CHECK (points_fidelite >= 0);

-- RG34
ALTER TABLE commande ADD CONSTRAINT ck_commande_canal CHECK (canal IN ('Web', 'Magasin'));
ALTER TABLE commande ADD CONSTRAINT ck_commande_statut CHECK (statut IN ('En cours', 'Expédiée', 'Livrée', 'Annulée'));

-- RG37
ALTER TABLE contenir ADD CONSTRAINT ck_contenir_quantite CHECK (quantite BETWEEN 1 AND 10);
ALTER TABLE contenir ADD CONSTRAINT ck_contenir_prix CHECK (prix_unitaire > 0);

-- RG40 à RG43
ALTER TABLE collecte ADD CONSTRAINT ck_collecte_etat CHECK (etat_piece IN ('Très bon', 'Bon', 'Usé', 'Abîmé'));
ALTER TABLE collecte ADD CONSTRAINT ck_collecte_destination CHECK (destination IN ('Revente', 'Recyclage', 'Upcycling'));
ALTER TABLE collecte ADD CONSTRAINT ck_collecte_abime CHECK (NOT (etat_piece = 'Abîmé' AND destination = 'Revente'));
ALTER TABLE collecte ADD CONSTRAINT ck_collecte_bon_achat CHECK (montant_bon_achat BETWEEN 0 AND 15);
ALTER TABLE collecte ADD CONSTRAINT ck_collecte_date CHECK (date_depot >= '2021-01-01');
