
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
DROP TRIGGER buy_places ON Representations_interieures;
DROP TRIGGER ajouter_piece ON Pieces;
DROP TRIGGER before_add_subvention ON subventions;
DROP TRIGGER after_add_subvention ON subventions;
DROP TRIGGER after_cout ON couts;
DROP TRIGGER after_selling ON Representations_exterieures;

/*fonction et trigger pour les couts des pièces*/
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

CREATE OR REPLACE FUNCTION after_cout_fun() RETURNS TRIGGER AS $$
BEGIN
EXECUTE update_historique_piece_depense(New.id_piece,New.prix);
EXECUTE update_historique_date_depense(New.prix);
RETURN New;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_cout AFTER INSERT ON Couts
FOR EACH ROW
EXECUTE PROCEDURE after_cout_fun();



/*Quand on insert une nouvelle pièce on l'ajoute à l'historique*/
CREATE OR REPLACE FUNCTION ajouter_piece_fun() RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO HISTORIQUE_PIECE(id_piece,nom,nb_places_vendues_tarif_reduit,nb_places_vendues_tarif_normal,recette_piece,depense_piece)
		VALUES(New.id_piece,New.nom,DEFAULT,DEFAULT,DEFAULT,DEFAULT);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ajouter_piece AFTER INSERT ON Pieces
FOR EACH ROW
	EXECUTE PROCEDURE ajouter_piece_fun();



/*Subvention : si un organisme a envi de faire un don pour une piece
si la piece n'existe pas ça ne sera pas possible par contre si
l'organisme n'existe pas dans la table Organisme on l'ajoute et on insere dans Subvention
*/
CREATE OR REPLACE FUNCTION  before_add_subvention_fun() RETURNS TRIGGER AS $$
BEGIN
     PERFORM * FROM Pieces WHERE id_piece = New.id_piece;
     IF NOT FOUND THEN
     	RETURN NULL;
     END IF;
     PERFORM * FROM Organismes WHERE nom_organisme = New.nom_organisme;
     IF NOT FOUND THEN
     	INSERT INTO Organismes(nom_organisme)
     		VALUES(New.nom_organisme);
     END IF;
     RETURN New;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION after_add_subvention_fun() RETURNS TRIGGER AS $$
BEGIN
	EXECUTE update_historique_piece_recette(New.id_piece,0,0,New.valeur_don);
	EXECUTE update_historique_date_recette(New.valeur_don);

	RETURN New;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_add_subvention AFTER INSERT ON Subventions
FOR EACH ROW
EXECUTE PROCEDURE after_add_subvention_fun();

CREATE TRIGGER before_add_subvention BEFORE INSERT ON Subventions
FOR EACH ROW
EXECUTE PROCEDURE before_add_subvention_fun();

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
    id integer;
BEGIN
    PERFORM * FROM Pieces
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
/*fonction et trigger d'achat d'une pièce*/

CREATE OR REPLACE FUNCTION buy_representation(t_name varchar(50),t_ville varchar(50),nom_p varchar(50),prix_norm integer,prix_red integer,nb_p integer,prix_ach integer,date_rep date) RETURNS VOID AS $$
DECLARE
  id_p integer;
  id_t integer;
  id_r integer;
  BEGIN
  id_p = ajout_unexisting_piece(nom_p,prix_norm,prix_red);
 INSERT INTO Representations(id_piece,date_representation)
    VALUES (id_p,date_rep) RETURNING id_representation INTO id_r;
  INSERT INTO Representations_interieures(id_representation,nb_place,nb_places_vendues_tarif_normal,nb_places_vendues_tarif_reduit,nb_places_restantes,debut_vente)
  VALUES(id_r,nb_p,DEFAULT,DEFAULT,nb_p,DEFAULT);
  id_t = ajout_unexisting_theatre(t_name,t_ville);
  INSERT INTO Achat(id_representation,id_theatre,date_achat,cout_achat)
  VALUES (id_r,id_t,DEFAULT,prix_ach);
     END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION after_buy_representation_fun() RETURNS TRIGGER AS $$
DECLARE
id_p integer;
BEGIN
	SELECT id_piece Into id_p FROM Representations WHERE id_representation = New.id_representation;
	IF NOT FOUND THEN
		RETURN NULL;
	ELSE
 		EXECUTE update_historique_piece_depense(id_p,New.prix);
 		EXECUTE update_historique_date_depense(New.prix);
 		RETURN NEW;
 	END IF;
END;
$$ LANGUAGE plpgsql;

/*fonction de réservation*/
CREATE OR REPLACE FUNCTION check_on_reserv() RETURNS TRIGGER AS $$
DECLARE
  restante integer;
BEGIN
  SELECT nb_places_restantes INTO restante  FROM Representations_interieures WHERE id_representation=New.id_representation;
  IF (restante>New.nb_places_reservees) THEN
    RETURN NEW;
  ELSE
    RETURN NULL;
    END IF;
  END;
 $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION make_a_reserv() RETURNS TRIGGER AS $$
BEGIN
UPDATE Representations_interieures SET nb_places_restantes=nb_places_restantes-NEW.nb_places_reservees
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
 nb_places_libres integer;
BEGIN
	
 	 Select nb_places_restantes FROM Representations_interieures WHERE New.id_piece=id_piece;
  	IF (nb_places_libres-i) >=0 THEN
  		UPDATE Representations_interieures
  			SET nb_places_restantes = nb_places_restantes - i
  			WHERE id_representation = NEW.id_representation;
  		RETURN NEW;
  	ELSE
  		RETURN NULL;
  	END IF;
	END;
$$ LANGUAGE plpgsql;

/*drop trigger verification_comptes on comptes;*/

CREATE TRIGGER modif_reservation AFTER UPDATE ON Reservations
 FOR EACH ROW
 WHEN (NEW.nb_places_reservees  <> OLD.nb_places_reservees)
EXECUTE PROCEDURE modif_reser();

CREATE OR REPLACE FUNCTION delet_reserv_perim() RETURNS VOID AS $$
DECLARE
perim Reservations%rowtype;
BEGIN
	FOR perim in SELECT * from Reservations
	 WHERE date_peremption < CURRENT_DATE
    LOOP
    	UPDATE Representations_interieures SET  
    		nb_places_restantes = (nb_places_restantes+r.nb_places_reservees);
    END LOOP;
    DELETE FROM Reservations WHERE date_peremption < CURRENT_DATE;
END;    
$$ LANGUAGE plpgsql;


/* fonction d'achat */
CREATE OR REPLACE FUNCTION buy_place() RETURNS TRIGGER AS $$
DECLARE
	prix_red integer;
	prix_norm integer;
	nb_place_red integer;
	nb_place_norm integer;
	recette integer;
	idp integer;
	date_rep DATE;
	cur_month DATE;
BEGIN
	EXECUTE delet_reserv_perim();
	SELECT date_representation INTO date_rep FROM Representations WHERE id_representation=New.id_representation;

	IF date_rep < CURRENT_DATE THEN
		RETURN NULL;
	END IF;
	IF OLD.nb_places_vendues_tarif_reduit > NEW.nb_places_vendues_tarif_reduit OR OLD.nb_places_vendues_tarif_normal > NEW.nb_places_vendues_tarif_normal THEN
		RETURN NULL;
	END IF;

	nb_place_red = NEW.nb_places_vendues_tarif_reduit-OLD.nb_places_vendues_tarif_reduit;
		RAISE  notice 'red % ',nb_place_red;

	nb_place_norm=NEW.nb_places_vendues_tarif_normal-OLD.nb_places_vendues_tarif_normal;
	IF (New.nb_places_restante < (nb_place_red+nb_place_norm)) THEN
		RETURN NULL;
	END IF;
	Select id_piece Into idp  From Representations WHERE id_representation=New.id_representation;
	SELECT prix_reduit,prix_normal  INTO prix_norm,prix_red FROM Pieces WHERE id_piece =idp;
	recette = ((nb_place_red*prix_red)+(nb_place_norm*prix_norm));
	RAISE  notice 'recette % ',recette;
					RAISE  notice 'prix % ',prix_red;

	IF (New.nb_places_restante<5) THEN
			SELECT (recette*1.5) INTO recette ;
	ELSIF (CURRENT_DATE-NEW.debut_vente) < 3 THEN
		SELECT recette*(80/100) INTO recette ;
						RAISE  notice 'prix2 % ',recette;

	ELSIF (date_rep-CURRENT_DATE)<2 THEN
		SELECT recette*(70/100) INTO recette ;
	
	END IF;
	EXECUTE update_historique_piece_recette(idp,nb_place_red,nb_place_norm,recette);

	EXECUTE update_historique_date_recette(recette);
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER buy_places BEFORE UPDATE ON Representations_interieures
	FOR EACH ROW
		WHEN (NEW.nb_places_vendues_tarif_normal > OLD.nb_places_vendues_tarif_normal OR NEW.nb_places_vendues_tarif_reduit > OLD.nb_places_vendues_tarif_reduit)
		EXECUTE Procedure buy_place();

/* fonction de vente de représentations */
CREATE OR REPLACE FUNCTION after_selling_fun() RETURNS TRIGGER AS $$
BEGIN
EXECUTE update_historique_piece_recette(id_piece,0,0,New.prix);
EXECUTE update_historique_date_recette(New.prix);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_selling AFTER INSERT ON Representations_exterieures
FOR EACH ROW
	EXECUTE Procedure after_selling_fun();

