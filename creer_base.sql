DROP TABLE IF EXISTS Organismes CASCADE ;
DROP TABLE IF EXISTS Pieces CASCADE;
DROP TABLE IF EXISTS Couts CASCADE;
DROP TABLE IF EXISTS Subventions CASCADE;
DROP TABLE IF EXISTS Pieces_creees CASCADE;
DROP TABLE IF EXISTS Representations CASCADE;
DROP TABLE IF EXISTS Representations_exterieures CASCADE;
DROP TABLE IF EXISTS Representations_interieures CASCADE;
DROP TABLE IF EXISTS Theatres CASCADE;
DROP TABLE IF EXISTS Achats CASCADE;
DROP TABLE IF EXISTS Reservations CASCADE;
DROP TABLE IF EXISTS Clients CASCADE;
DROP TABLE IF EXISTS HISTORIQUE_PIECE CASCADE;
DROP TABLE IF EXISTS HISTORIQUE_DATE CASCADE;
DROP TABLE IF EXISTS DATE_COURANTE;

CREATE TABLE Organismes (
    nom_organisme varchar (50) PRIMARY KEY
);

CREATE TABLE Pieces (
    id_piece serial  PRIMARY KEY,
    nom varchar (50) NOT NULL,
    prix_normal integer NOT NULL check(prix_normal >= 0),
    prix_reduit integer  NOT NULL check(prix_normal >= 0)
);

CREATE TABLE Subventions(
  nom_organisme varchar (50) REFERENCES Organismes (nom_organisme),
  id_piece integer REFERENCES Pieces (id_piece),
  date_subvention DATE NOT NULL DEFAULT CURRENT_DATE,
  valeur_don integer  NOT NULL check(valeur_don >= 0),
  PRIMARY KEY (nom_organisme, id_piece)
);


CREATE TABLE Pieces_creees(
  id_piece integer PRIMARY KEY REFERENCES Pieces (id_piece),
  date_creation DATE ,
  nb_acteurs integer CHECK (nb_acteurs >= 0),
  nb_musiciens integer CHECK (nb_acteurs >= 0)
);

CREATE TABLE Couts (
  id_cout serial PRIMARY KEY,
  id_piece integer REFERENCES Pieces_creees (id_piece),
  prix integer CHECK (prix >= 0),
  date_cout DATE NOT NULL DEFAULT CURRENT_DATE
);


CREATE TABLE Representations (
    id_representation serial PRIMARY KEY,
    id_piece integer REFERENCES Pieces (id_piece),
    date_representation  DATE NOT NULL
);



CREATE TABLE Theatres (
  id_theatre serial PRIMARY KEY ,
  nom varchar (100) NOT NULL,
  ville varchar (100) NOT NULL
);
CREATE TABLE Representations_exterieures (
  id_representation integer PRIMARY KEY REFERENCES Representations (id_representation),
  id_theatre integer REFERENCES Theatres (id_theatre),
  prix integer NOT NULL,
  date_vente  DATE NOT NULL DEFAULT CURRENT_DATE
);
CREATE TABLE Representations_interieures (
  id_representation integer PRIMARY KEY REFERENCES Representations (id_representation),
  nb_places integer  NOT NULL check(nb_places >= 0),
  nb_places_vendues_tarif_normal integer  NOT NULL DEFAULT 0 check(nb_places_vendues_tarif_normal >= 0 and nb_places_vendues_tarif_normal < nb_places ),
  nb_places_vendues_tarif_reduit integer  NOT NULL DEFAULT 0 check(nb_places_vendues_tarif_reduit >= 0  and nb_places_vendues_tarif_reduit < nb_places ),
  nb_places_restante integer  NOT NULL check(nb_places_restante >= 0 and nb_places_restante <= nb_places),
  debut_vente DATE NOT NULL DEFAULT CURRENT_DATE
);



CREATE TABLE Achats(
  id_representation integer REFERENCES Representations_interieures (id_representation),
  id_theatre integer REFERENCES Theatres (id_theatre),
  date_achat DATE NOT NULL DEFAULT CURRENT_DATE,
  cout_achat integer  NOT NULL check(cout_achat >= 0),
  PRIMARY KEY (id_representation, id_theatre)
);

CREATE TABLE Clients (
  id_client serial PRIMARY KEY ,
  nom varchar (100) NOT NULL,
  prenom varchar (100) NOT NULL,
  email varchar (50) NOT NULL
);
CREATE TABLE Reservations(
  id_representation integer REFERENCES Representations_interieures (id_representation),
  id_client integer REFERENCES Clients (id_client),
  nb_places_reservees integer NOT NULL check(nb_places_reservees > 0),
  date_reservation DATE ,
  date_peremption DATE check(date_peremption>= date_reservation),
  PRIMARY KEY (id_representation, id_client)
);
CREATE TABLE HISTORIQUE_PIECE(id_piece integer PRIMARY KEY,
  nom varchar(100) NOT NULL,
  nb_places_vendues_tarif_reduit integer NOT NULL DEFAULT 0,
  nb_places_vendues_tarif_normal integer NOT NULL DEFAULT 0,
  recette_piece integer NOT NULL DEFAULT 0,
  depense_piece integer NOT NULL DEFAULT 0);

CREATE TABLE HISTORIQUE_DATE(date_historique DATE PRIMARY KEY,
  recette_mois integer NOT NULL DEFAULT 0,
  depense_mois integer NOT NULL DEFAULT 0);

CREATE TABLE DATE_COURANTE(my_date date);

INSERT INTO DATE_COURANTE(my_date) VALUES (CURRENT_DATE);
