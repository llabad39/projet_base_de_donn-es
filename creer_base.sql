DROP TABLE IF EXISTS Organismes;
DROP TABLE IF EXISTS Pieces;
DROP TABLE IF EXISTS Subventions;
DROP TABLE IF EXISTS Pieces_creees;
DROP TABLE IF EXISTS Representations;
DROP TABLE IF EXISTS Representations_exterieures;
DROP TABLE IF EXISTS Representations_interieures;
DROP TABLE IF EXISTS Theatres;
DROP TABLE IF EXISTS Achats;
DROP TABLE IF EXISTS Billets;
DROP TABLE IF EXISTS Clients;

CREATE TABLE Organismes (
    id_organisme serial PRIMARY KEY,
    nom varchar (50) NOT NULL
    /*location varchar(25) check (location in ('north', 'south', 'west', 'east', 'northeast', 'southeast', 'southwest', 'northwest')),
    install_date date*/
);
CREATE TABLE Pieces (
    id_piece serial PRIMARY KEY,
    nom varchar (50) NOT NULL,
    prix_basique integer NOT NULL check(cout_piece >= 0),
    prix_reduction integer  NOT NULL check(cout_piece >= 0)
    /*location varchar(25) check (location in ('north', 'south', 'west', 'east', 'northeast', 'southeast', 'southwest', 'northwest')),
    install_date date*/
);

CREATE TABLE Subventions(
  id_organisme serial REFERENCES Organismes,
  id_piece serial REFERENCES Pieces,
  date_subvention DATE NOT NULL DEFAULT CURRENT_DATE,
  valeur_don integer  NOT NULL check(cout_piece >= 0),
  PRIMARY KEY (id_organisme, id_piece)
/*  CHECK ()*/
);


CREATE TABLE Pieces_creees (
  id_piece serial PRIMARY KEY REFERENCES Pieces,
  cout_piece integer CHECK (cout_piece >= 0),
  nb_acteurs integer CHECK (nb_acteurs >= 0),
  nb_musiciens integer CHECK (nb_acteurs >= 0)
);

CREATE TABLE Couts (
  id_cout serial PRIMARY KEY,
  id_piece serial REFERENCES Pieces_creees,
  prix integer CHECK (cout_piece >= 0),
  date_cout DATE NOT NULL DEFAULT CURRENT_DATE
);


CREATE TABLE Representations (
    id_representation serial PRIMARY KEY,
    id_piece  REFERENCES Pieces,
    date_representation  DATE NOT NULL,
    adresse varchar (100) NOT NULL,
    nb_places integer  NOT NULL check(nb_places >= 0)
);

CREATE TABLE Representations_exterieures (
  id_representation serial PRIMARY KEY REFERENCES Representations
);

CREATE TABLE Representations_interieures (
  id_representation serial PRIMARY KEY REFERENCES Representations,
  id_theatre serial REFERENCES Theatres
);

CREATE TABLE Theatres (
  id_theatre serial PRIMARY KEY ,
  nom varchar (100) NOT NULL,
  adresse varchar (100) NOT NULL,
);

CREATE TABLE Achats(
  id_representation serial REFERENCES Representations_interieures,
  id_theatre serial REFERENCES Theatres,
  date_achat DATE NOT NULL DEFAULT CURRENT_DATE,
  cout_achat integer  NOT NULL check(nb_places >= 0),
  PRIMARY KEY (id_representation, id_theatre)
/*  CHECK ()*/
);

CREATE TABLE Clients (
  id_client serial PRIMARY KEY ,
  nom varchar (100) NOT NULL,
  adresse varchar (100) NOT NULL,
);
CREATE TABLE Billets(
  id_representation serial REFERENCES Representations_interieures
  id_client serial REFERENCES CLients,
  date_achat DATE NOT NULL DEFAULT CURRENT_DATE,
  reduction integer  NOT NULL check(reduction >= 0),
  prix integer  NOT NULL check(prix >= 0),
  PRIMARY KEY (id_representation, id_client)
/*  CHECK ()*/
);
