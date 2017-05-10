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

CREATE TABLE Organismes (
    nom_organisme varchar (50) PRIMARY KEY
);

CREATE TABLE Pieces (
    id_piece serial PRIMARY KEY,
    nom varchar (50) NOT NULL,
    prix_normal integer NOT NULL check(prix_normal >= 0),
    prix_reduit integer  NOT NULL
);

CREATE TABLE Subventions(
  nom_organisme varchar (50) REFERENCES Organismes (nom_organisme),
  id_piece serial REFERENCES Pieces (id_piece),
  date_subvention DATE NOT NULL DEFAULT CURRENT_DATE,
  valeur_don integer  NOT NULL check(valeur_don >= 0),
  PRIMARY KEY (nom_organisme, id_piece)
);


CREATE TABLE Pieces_creees(
  id_piece serial PRIMARY KEY REFERENCES Pieces (id_piece),
  date_creation DATE ,
  nb_acteurs integer CHECK (nb_acteurs >= 0),
  nb_musiciens integer CHECK (nb_acteurs >= 0)
);

CREATE TABLE Couts (
  id_cout serial PRIMARY KEY,
  id_piece serial REFERENCES Pieces_creees (id_piece),
  prix integer CHECK (prix >= 0),
  date_cout DATE NOT NULL DEFAULT CURRENT_DATE
);


CREATE TABLE Representations (
    id_representation serial PRIMARY KEY,
    id_piece serial  REFERENCES Pieces (id_piece),
    date_representation  DATE NOT NULL
);

CREATE TABLE Representations_exterieures (
  id_representation serial PRIMARY KEY REFERENCES Representations (id_representation),
  prix integer NOT NULL,
  date_vente  DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE Theatres (
  id_theatre serial PRIMARY KEY ,
  nom varchar (100) NOT NULL,
  adresse varchar (100) NOT NULL
);

CREATE TABLE Representations_interieures (
  id_representation serial PRIMARY KEY REFERENCES Representations (id_representation),
  id_theatre serial REFERENCES Theatres (id_theatre),
  nb_places integer  NOT NULL check(nb_places >= 0),
  nb_places_vendues_tarif_normal integer  NOT NULL check(nb_places_vendues_tarif_normal >= 0 and nb_places_vendues_tarif_normal < nb_places ),
  nb_places_vendues_tarif_reduit integer  NOT NULL check(nb_places_vendues_tarif_reduit >= 0  and nb_places_vendues_tarif_reduit < nb_places ),
  nb_places_restantes integer  NOT NULL check(nb_places_restantes >= 0 and nb_places_restantes < nb_places)

);



CREATE TABLE Achats(
  id_representation serial REFERENCES Representations_interieures (id_representation),
  id_theatre serial REFERENCES Theatres (id_theatre),
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
  id_representation serial REFERENCES Representations_interieures (id_representation),
  id_client serial REFERENCES Clients (id_client),
  nb_places_reservees_tarif_normal integer NOT NULL check(nb_places_reservees_tarif_normal >= 0),
  nb_places_reservees_tarif_reduit integer NOT NULL check(nb_places_reservees_tarif_reduit >= 0),
  date_reservation DATE  check(date_reservation =  CURRENT_DATE),
  PRIMARY KEY (id_representation, id_client)
);
/*---------------------------------------------------  -avant  -----------------------------*/
/*DROP TABLE IF EXISTS Organismes CASCADE ;
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

CREATE TABLE Organismes (
    id_organisme serial PRIMARY KEY,
    nom varchar (50) NOT NULL

);
CREATE TABLE Pieces (
    id_piece serial PRIMARY KEY,
    nom varchar (50) NOT NULL,
    prix_basique integer NOT NULL check(prix_basique >= 0),
    prix_reduction integer  NOT NULL

);

CREATE TABLE Subventions(
  id_organisme serial REFERENCES Organismes (id_organisme),
  id_piece serial REFERENCES Pieces (id_piece),
  date_subvention DATE NOT NULL DEFAULT CURRENT_DATE,
  valeur_don integer  NOT NULL check(valeur_don >= 0),
  PRIMARY KEY (id_organisme, id_piece)
);


CREATE TABLE Pieces_creees (
  id_piece serial PRIMARY KEY REFERENCES Pieces (id_piece),
  cout_piece integer CHECK (cout_piece >= 0),
  nb_acteurs integer CHECK (nb_acteurs >= 0),
  nb_musiciens integer CHECK (nb_acteurs >= 0)
);

CREATE TABLE Couts (
  id_cout serial PRIMARY KEY,
  id_piece serial REFERENCES Pieces_creees (id_piece),
  prix integer CHECK (prix >= 0),
  date_cout DATE NOT NULL DEFAULT CURRENT_DATE
);


CREATE TABLE Representations (
    id_representation serial PRIMARY KEY,
    id_piece serial  REFERENCES Pieces (id_piece),
    date_representation  DATE NOT NULL
);

CREATE TABLE Representations_exterieures (
  id_representation serial PRIMARY KEY REFERENCES Representations (id_representation),
  prix integer NOT NULL
);

CREATE TABLE Theatres (
  id_theatre serial PRIMARY KEY ,
  nom varchar (100) NOT NULL,
  adresse varchar (100) NOT NULL
);

CREATE TABLE Representations_interieures (
  id_representation serial PRIMARY KEY REFERENCES Representations (id_representation),
  id_theatre serial REFERENCES Theatres (id_theatre),
  nb_places integer  NOT NULL check(nb_places >= 0)

);



CREATE TABLE Achats(
  id_representation serial REFERENCES Representations_interieures (id_representation),
  id_theatre serial REFERENCES Theatres (id_theatre),
  date_achat DATE NOT NULL DEFAULT CURRENT_DATE,
  cout_achat integer  NOT NULL check(cout_achat >= 0),
  PRIMARY KEY (id_representation, id_theatre)
);

CREATE TABLE Clients (
  id_client serial PRIMARY KEY ,
  nom varchar (100) NOT NULL,
  adresse varchar (100) NOT NULL
);
CREATE TABLE Reservations(
  id_representation serial REFERENCES Representations_interieures (id_representation),
  id_client serial REFERENCES Clients (id_client),
  date_achat DATE NOT NULL DEFAULT CURRENT_DATE,
  reduction integer  NOT NULL check(reduction >= 0),
  prix integer  NOT NULL check(prix >= 0),
  status varchar(50) NOT NULL check (status in ('en cours', 'payer') ),
  PRIMARY KEY (id_representation, id_client)
);
*/
