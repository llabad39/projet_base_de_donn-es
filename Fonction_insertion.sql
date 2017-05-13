
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



DROP TRIGGER modif_reservation ON Reservations;
DROP TRIGGER check_on_reserv ON Reservations;
DROP TRIGGER make_a_reserv ON Reservations;

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

/*Quannt on insere une piece dans Pieces_creees on lajouter dans piece */
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
    SELECT  INTO exist *
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

CREATE OR REPLACE FUNCTION buy_representation(t_name varchar(50),t_ville varchar(50),nom_p varchar(50),prix_norm integer,prix_red integer,nb_p integer,prix_ach integer,date_rep date) RETURNS VOID AS $$
DECLARE
  id_p integer;
  id_t integer;
  id_r integer;
  BEGIN
  id_p = ajout_unexisting_piece(nom_p,prix_norm,prix_red);
 INSERT INTO Representations(id_piece,date_representation)
    VALUES (id_p,date_rep) RETURNING id_representation INTO id_r;
  INSERT INTO Representations_exterieures(id_representation,nb_place,nb_places_vendues_tarif_normal,nb_places_vendues_tarif_reduit,nb_places_restantes)
  VALUES(id_r,nb_p,DEFAULT,DEFAULT,nb_p);
  id_t = ajout_unexisting_theatre(t_name,t_ville);
  INSERT INTO Achat(id_representation,id_theatre,date_achat,cout_achat)
  VALUES (id_r,id_t,DEFAULT,prix_ach);
     END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION check_on_reserv() RETURNS TRIGGER AS $$
DECLARE
  restante integer;
BEGIN
  SELECT INTO restante nb_places_restantes FROM Representations_interieures WHERE id_representation=New.id_representation;
  IF(restante>New.nb_places_reservees_tarif_normal+New.nb_places_reservees_tarif_reduit) THEN
    RETURN NEW;
  ELSE
    RETURN NULL;
    END IF;
  END;
 $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION make_a_reserv() RETURNS TRIGGER AS $$
BEGIN
UPDATE Representations_interieures SET nb_places_restantes=nb_places_restantes-NEW.nb_places_reservees_tarif_normal-NEW.nb_places_reservees_tarif_reduit
 WHERE id_representation=New.id_representation;
END;
 $$ LANGUAGE plpgsql;
CREATE TRIGGER check_on_reserv BEFORE INSERT ON Reservations
FOR EACH ROW 
EXECUTE PROCEDURE check_on_reserv();

CREATE TRIGGER make_a_reserv AFTER INSERT ON Reservations
FOR EACH ROW 
EXECUTE PROCEDURE make_a_reserv();
/*Trigger qui increment le nombre de place disponible pour une prepésentation en fonction des Reservations */
CREATE OR REPLACE FUNCTION modif_reser() RETURNS TRIGGER AS $$
DECLARE
 i integer;
BEGIN
  IF(NEW.nb_places_reservees_tarif_normal <> OLD.nb_places_reservees_tarif_normal) THEN
   i = NEW.nb_places_reservees_tarif_normal - OLD.nb_places_reservees_tarif_normal;
   ELSE
     IF(NEW.nb_places_reservees_tarif_reduit <> OLD.nb_places_reservees_tarif_reduit) THEN
      i = NEW.nb_places_reservees_tarif_reduit - OLD.nb_places_reservees_tarif_reduit;
     ELSE
     i = (NEW.nb_places_reservees_tarif_reduit - OLD.nb_places_reservees_tarif_reduit) + (NEW.nb_places_reservees_tarif_normal - OLD.nb_places_reservees_tarif_normal);
     END IF ;
   END IF;
  UPDATE Representations_interieures
  SET nb_places_restantes = nb_places_restantes - i
  WHERE id_representation = NEW.id_representation;
END;
$$ LANGUAGE plpgsql;

/*drop trigger verification_comptes on comptes;*/

CREATE TRIGGER modif_reservation AFTER UPDATE ON Reservations
 FOR EACH ROW
 WHEN (NEW.nb_places_reservees_tarif_normal  <> OLD.nb_places_reservees_tarif_normal OR NEW.nb_places_reservees_tarif_reduit  <> OLD.nb_places_reservees_tarif_reduit  )
EXECUTE PROCEDURE modif_reser();
