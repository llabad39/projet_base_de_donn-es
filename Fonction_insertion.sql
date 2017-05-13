
/*
INSERT INTO Pieces( nom, prix_normal,prix_reduit)
VALUES
('Mandarine',30,25),
( 'Le Bal des voleurs',40,10)
;

INSERT INTO Pieces_creees(id_piece, nb_acteurs, nb_musiciens)
VALUES
(1, 10,30);
INSERT INTO Pieces( nom, prix_normal,prix_reduit)
VALUES
('La Sauvage',12,6),
( 'Eurydice',60,40)
;
INSERT INTO Pieces_creees(id_piece, nb_acteurs, nb_musiciens)
VALUES
(3, 10,30);*/



/*cette fonction interdit d'ajouter un cout à une piece qu'on a pas nous méme créée*/
CREATE OR REPLACE FUNCTION ajouter_cout( id_p integer,prixx integer, d DATE) RETURNS VOID AS $$
BEGIN
PERFORM * FROM Pieces WHERE id_piece=id_p;
      IF NOT FOUND THEN
              RAISE 'Pièces innexistante % ', id_p USING ERRCODE='20002';
      END IF;
      PERFORM * FROM Pieces_creees WHERE id_piece=id_p;
      IF NOT FOUND THEN
              RAISE 'Impossible d ajouter un cout à une pièce créée à l exterieur % ', id_p USING ERRCODE='20001';
      END IF;
      INSERT INTO Couts(id_piece, prix,  date_cout)
      VALUES
      ( id_p,prixx, d);
END;
$$ LANGUAGE plpgsql;

/*Quannt on insere une piece dans Pieces_creees on lajouter dan piece */
CREATE OR REPLACE FUNCTION ajouter_piece_creee(name varchar(50),p_normal integer,p_reduit integer,  d DATE, nb_act integer , nb_m integer) RETURNS VOID AS $$
BEGIN
      INSERT INTO Pieces(nom,prix_normal,prix_reduit)
      VALUES
      ( name,p_normal,p_reduit);

      INSERT INTO Pieces_creees(date_creation,nb_acteurs,nb_musiciens)
      VALUES
      (d,nb_act,nb_m);
END;
$$ LANGUAGE plpgsql;

/*Subvention : si un organisme a envi de faire un don pour une piece
si la piece n'existe pas ça ne sera pas possible par contre si
l'organisme n'existe pas dans la table Organisme on l'ajoute et on insere dans Subvention

*/
CREATE OR REPLACE FUNCTION  ajouter_subvention(nom_org varchar (50),id_p integer ,date_sub DATE ,val_don integer ) RETURNS VOID AS $$
BEGIN
  INSERT INTO Subventions(nom_organisme,id_piece ,date_subvention  ,valeur_don )
  VALUES
  (nom_org,id_p ,date_sub  ,val_don);
EXCEPTION
  WHEN foreign_key_violation THEN
    DECLARE
      exist integer;
    BEGIN
      SELECT 1 INTO exist
        FROM Organismes
       WHERE nom_organisme = nom_org;
      IF NOT FOUND THEN
      INSERT INTO Organismes(nom_organisme)
      VALUES
      (nom_org);
      INSERT INTO Subventions(nom_organisme,id_piece ,date_subvention  ,valeur_don )
      VALUES
      (nom_org,id_p ,date_sub  ,val_don);
      ELSE
        RAISE 'La piece n existe pas  % ',id_p USING ERRCODE='20000';
      END IF;
   END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ajout_unexisting_theatre(nom_t varchar(50),ville_t varchar(50)) RETURNS integer AS $$
  DECLARE
    exist Theatres%rowtype;
    id integer;
    BEGIN
    SELECT * INTO exist
      FROM Theatres
     WHERE nom = nom_t and  ville = ville_tl;
     IF NOT FOUND THEN
      INSERT INTO Theatres(nom,ville)
      VALUES
       (nom_t,ville_t);
     END IF;
     SELECT id_theatre Into id
     FROM Theatres
     WHERE nom = nom_t and  ville = ville_tl;
     RETURN id;
     END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ajout_unexisting_piece(nom_p varchar(50), prix_norm integer,prix_red integer) RETURNS integer AS $$
  DECLARE
    exist Pieces%rowtype;
    id integer;
    BEGIN
    SELECT * INTO exist
      FROM Pieces
     WHERE nom = nom_p;
     IF NOT FOUND THEN
      INSERT INTO Pieces(nom,prix_reduit,prix_normal)
      VALUES
        (nom_p,prix_red,prix_norm);
      END IF;
       SELECT id_piece Into id
     FROM Pieces
     WHERE nom = nom_p;
     RETURN id;
     END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION buy_representation(t_name varchar(50),t_ville varchar(50),nom_p varchar(50),prix_norm integer,prix_red integer,prix_ach integer,date_rep date) RETURNS VOID AS $$
DECLARE
  id_p integer;
  id_t integer;
  BEGIN
  id_p = ajout_unexisting_theatre(t_name,t_ville);
     END;
$$ LANGUAGE plpgsql;



