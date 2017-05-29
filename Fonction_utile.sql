CREATE OR REPLACE FUNCTION reservation(p_norm integer,p_red integer,id_cl integer,id_rep integer) RETURN BOOLEAN AS $$
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
SELECT nb_places_vendues_tarif_reduit INTO nb_red FROM Representations_Interieures where id_representation =id_rep;
SELECT nb_places_vendues_tarif_normal INTO nb_norm FROM Representations_Interieures where id_representation =id_rep;

SELECT nb_places_reservees INTO pl_reserv FROM Reservations Where id_client=id_cl AND id_representation=id_rep;
IF pl_reserv=p_norm + p_red THEN
UPDATE Representation_interieures SET nb_places_vendues_tarif_normal=p_norm+nb_norm Where id_representation =id_rep;
UPDATE Representation_interieures SET nb_vendues_tarif_reduit=p_red+nb_red Where id_representation =id_rep;
DELETE Reservations Where id_client=id_cl AND id_representation=id_rep;
RETURN TRUE;
ELSE
	Raise 'Ce n est pas le nombre de place que vous avez reservé' Using ERRCODE='20003';
	RETURN FALSE;
END IF;
END;
  $$ LANGUAGE plpgsql;
