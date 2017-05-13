
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

/* !! pas encore finie ----Fonction d'insertion dans représentation */
CREATE OR REPLACE FUNCTION  ajouter_representation(id_rep integer, id_p integer,date_rep DATE ) RETURNS VOID AS $$
BEGIN
  INSERT INTO Representations(id_representation , id_piece ,date_representation )
  VALUES
  (id_rep,id_p ,date_rep);
EXCEPTION
  WHEN foreign_key_violation THEN
    DECLARE
      exist integer;
    BEGIN
      SELECT 1 INTO exist
        FROM Pieces
       WHERE id_piece = id_p;
      IF NOT FOUND THEN
      INSERT INTO Pieces(id_piece, nom, prix_normal, prix_reduit)
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
