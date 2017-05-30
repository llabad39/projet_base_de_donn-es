CREATE OR REPLACE FUNCTION payer_reservation(p_norm integer,p_red integer,id_cl integer,id_rep integer) RETURNS BOOLEAN AS $$
DECLARE
pl_reserv integer;
nb_norm integer;
nb_red integer;
BEGIN
PERFORM * FROM Reservations Where id_client=id_cl AND id_representation=id_rep;
IF NOT FOUND THEN
	Raise 'vous nous avez pas reserve' Using ERRCODE='20002';
	RETURN FALSE;
END IF;


SELECT nb_places_reservees INTO pl_reserv FROM Reservations Where id_client=id_cl AND id_representation=id_rep;
IF pl_reserv=p_norm + p_red THEN
UPDATE Representations_interieures SET nb_places_restante = nb_places_restante+p_norm+p_red;
UPDATE Representations_interieures SET nb_places_vendues_tarif_normal=p_norm+nb_places_vendues_tarif_normal Where id_representation =id_rep;
UPDATE Representations_interieures SET nb_places_vendues_tarif_reduit=p_red+nb_places_vendues_tarif_reduit Where id_representation =id_rep;
DELETE FROM Reservations Where id_client=id_cl AND id_representation=id_rep;
RETURN TRUE;
ELSE
	Raise 'Ce n est pas le nombre de place que vous avez reservé' Using ERRCODE='20003';
	RETURN FALSE;
END IF;
END;
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getDate() RETURNS DATE AS $$
DECLARE
cur_d DATE;
BEGIN
  SELECT * Into cur_d FROM DATE_COURANTE;
  RETURN cur_d;
 END;
$$ LANGUAGE plpgsql ;