DROP DATABASE IF EXISTS etam_seconde_vie;
CREATE DATABASE etam_seconde_vie;
USE etam_seconde_vie;

CREATE TABLE categorie (
id_categorie INT NOT NULL,
libelle_categorie VARCHAR(50) NOT NULL,
id_categorie_parente INT NULL,
CONSTRAINT pk_categorie PRIMARY KEY (id_categorie),
CONSTRAINT uq_categorie_libelle UNIQUE (libelle_categorie),
CONSTRAINT fk_categorie_parente FOREIGN KEY (id_categorie_parente) REFERENCES categorie (id_categorie) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE collection (
id_collection INT NOT NULL,
nom_collection VARCHAR(50) NOT NULL,
saison VARCHAR(20) NOT NULL,
annee INT NOT NULL,
eco_concue BOOLEAN NOT NULL DEFAULT FALSE,
CONSTRAINT pk_collection PRIMARY KEY (id_collection)
);

CREATE TABLE produit (
ref_produit CHAR(8) NOT NULL,
nom_produit VARCHAR(80) NOT NULL,
prix_vente DECIMAL(6,2) NOT NULL,
date_lancement DATE NOT NULL,
pays_confection VARCHAR(50) NOT NULL,
taux_recyclabilite INT NOT NULL,
score_environnemental CHAR(1) NOT NULL,
id_categorie INT NOT NULL,
id_collection INT NOT NULL,
CONSTRAINT pk_produit PRIMARY KEY (ref_produit),
CONSTRAINT fk_produit_categorie FOREIGN KEY (id_categorie) REFERENCES categorie (id_categorie) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_produit_collection FOREIGN KEY (id_collection) REFERENCES collection (id_collection) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE variante (
ref_produit CHAR(8) NOT NULL,
num_variante INT NOT NULL,
taille VARCHAR(5) NOT NULL,
couleur VARCHAR(30) NOT NULL,
code_ean CHAR(13) NOT NULL,
stock INT NOT NULL DEFAULT 0,
CONSTRAINT pk_variante PRIMARY KEY (ref_produit, num_variante),
CONSTRAINT uq_variante_ean UNIQUE (code_ean),
CONSTRAINT fk_variante_produit FOREIGN KEY (ref_produit) REFERENCES produit (ref_produit) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE matiere (
id_matiere INT NOT NULL,
nom_matiere VARCHAR(50) NOT NULL,
type_fibre VARCHAR(15) NOT NULL,
est_recyclee BOOLEAN NOT NULL DEFAULT FALSE,
certification VARCHAR(10) NULL,
empreinte_carbone_kg DECIMAL(5,2) NOT NULL,
CONSTRAINT pk_matiere PRIMARY KEY (id_matiere),
CONSTRAINT uq_matiere_nom UNIQUE (nom_matiere)
);

CREATE TABLE fournisseur (
id_fournisseur INT NOT NULL,
raison_sociale VARCHAR(80) NOT NULL,
pays_fournisseur VARCHAR(50) NOT NULL,
email_fournisseur VARCHAR(100) NOT NULL,
date_debut_partenariat DATE NOT NULL,
CONSTRAINT pk_fournisseur PRIMARY KEY (id_fournisseur),
CONSTRAINT uq_fournisseur_email UNIQUE (email_fournisseur)
);

CREATE TABLE composer (
ref_produit CHAR(8) NOT NULL,
id_matiere INT NOT NULL,
id_fournisseur INT NOT NULL,
pourcentage DECIMAL(5,2) NOT NULL,
CONSTRAINT pk_composer PRIMARY KEY (ref_produit, id_matiere, id_fournisseur),
CONSTRAINT fk_composer_produit FOREIGN KEY (ref_produit) REFERENCES produit (ref_produit) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_composer_matiere FOREIGN KEY (id_matiere) REFERENCES matiere (id_matiere) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_composer_fournisseur FOREIGN KEY (id_fournisseur) REFERENCES fournisseur (id_fournisseur) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE magasin (
id_magasin INT NOT NULL,
nom_magasin VARCHAR(80) NOT NULL,
ville_magasin VARCHAR(50) NOT NULL,
type_magasin VARCHAR(10) NOT NULL,
date_ouverture DATE NOT NULL,
CONSTRAINT pk_magasin PRIMARY KEY (id_magasin)
);

CREATE TABLE client (
id_client INT NOT NULL,
nom VARCHAR(50) NOT NULL,
prenom VARCHAR(50) NOT NULL,
email VARCHAR(100) NOT NULL,
telephone CHAR(10) NULL,
date_naissance DATE NOT NULL,
ville VARCHAR(50) NOT NULL,
date_inscription DATE NOT NULL,
points_fidelite INT NOT NULL DEFAULT 0,
CONSTRAINT pk_client PRIMARY KEY (id_client),
CONSTRAINT uq_client_email UNIQUE (email)
);

CREATE TABLE commande (
id_commande INT NOT NULL,
date_commande DATE NOT NULL,
canal VARCHAR(7) NOT NULL,
statut VARCHAR(10) NOT NULL DEFAULT 'En cours',
id_client INT NOT NULL,
id_magasin INT NULL,
CONSTRAINT pk_commande PRIMARY KEY (id_commande),
CONSTRAINT fk_commande_client FOREIGN KEY (id_client) REFERENCES client (id_client) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_commande_magasin FOREIGN KEY (id_magasin) REFERENCES magasin (id_magasin) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE contenir (
id_commande INT NOT NULL,
ref_produit CHAR(8) NOT NULL,
num_variante INT NOT NULL,
quantite INT NOT NULL,
prix_unitaire DECIMAL(6,2) NOT NULL,
CONSTRAINT pk_contenir PRIMARY KEY (id_commande, ref_produit, num_variante),
CONSTRAINT fk_contenir_commande FOREIGN KEY (id_commande) REFERENCES commande (id_commande) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_contenir_variante FOREIGN KEY (ref_produit, num_variante) REFERENCES variante (ref_produit, num_variante) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE collecte (
id_collecte INT NOT NULL,
date_depot DATE NOT NULL,
etat_piece VARCHAR(10) NOT NULL,
destination VARCHAR(10) NOT NULL,
montant_bon_achat DECIMAL(4,2) NOT NULL DEFAULT 0,
id_client INT NOT NULL,
id_magasin INT NOT NULL,
ref_produit CHAR(8) NOT NULL,
CONSTRAINT pk_collecte PRIMARY KEY (id_collecte),
CONSTRAINT fk_collecte_client FOREIGN KEY (id_client) REFERENCES client (id_client) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_collecte_magasin FOREIGN KEY (id_magasin) REFERENCES magasin (id_magasin) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_collecte_produit FOREIGN KEY (ref_produit) REFERENCES produit (ref_produit) ON DELETE CASCADE ON UPDATE CASCADE
);
