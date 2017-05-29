
			/** retourne le date du debut du mois courant   */
CREATE OR REPLACE FUNCTION get_begging_month(d Date) RETURNS DATE AS $$
DECLARE
beg Date;
BEGIN
	SELECT date_trunc('month',d) Into beg;
	RETURN beg;
END;
$$ LANGUAGE plpgsql;

			/** met à jour la recette d'une pièce donnée si elle existe */
CREATE OR REPLACE FUNCTION update_historique_piece_recette(idp integer,nb_red integer,nb_norm integer,price integer) RETURNS VOID AS $$
BEGIN
PERFORM * FROM HISTORIQUE_PIECE WHERE idp = id_piece;
IF NOT FOUND THEN
	  RAISE 'Pièces innexistante % ', idp USING ERRCODE='20002';
ELSE
	UPDATE HISTORIQUE_PIECE SET nb_places_vendues_tarif_reduit = (nb_places_vendues_tarif_reduit+nb_red),nb_places_vendues_tarif_normal=(nb_places_vendues_tarif_normal+nb_norm)
			,recette_piece=(price+recette_piece) WHERE id_piece=idp;
END IF;
END;
$$ LANGUAGE plpgsql;

			/** fonction qui met à jour les depense d'une pièce donnée si elle existe  */

CREATE OR REPLACE FUNCTION update_historique_piece_depense(idp integer,cout integer) RETURNS VOID AS $$
BEGIN
PERFORM * FROM HISTORIQUE_PIECE WHERE idp = id_piece;
IF NOT FOUND THEN
	  RAISE 'Pièces innexistante % ', idp USING ERRCODE='20002';
ELSE
	UPDATE HISTORIQUE_PIECE SET depense_piece = depense_piece+cout  WHERE idp = id_piece;
END IF;
END;
$$ LANGUAGE plpgsql;

			/**  Ajoute la recette "recette" dans la recette du mois courant    */
CREATE OR REPLACE FUNCTION update_historique_date_recette(recette integer,d Date) RETURNS VOID AS $$
DECLARE
cur_month Date;
BEGIN
	cur_month = get_begging_month(d);

	PERFORM * FROM HISTORIQUE_DATE WHERE cur_month = date_historique;

	IF NOT FOUND THEN
		INSERT INTO HISTORIQUE_DATE(date_historique,recette_mois,depense_mois)
			VALUES(cur_month,recette,DEFAULT);
	ELSE
		UPDATE HISTORIQUE_DATE SET recette_mois=(recette+recette_mois)
			WHERE date_historique = cur_month;
	END IF;
END;
$$ LANGUAGE plpgsql;

		/**  met à jour les depenses du mois courant si elle existe sinon on la crée */
CREATE OR REPLACE FUNCTION update_historique_date_depense(depense integer,d Date) RETURNS VOID AS $$
DECLARE
cur_month Date;
BEGIN
	cur_month = get_begging_month(d);

	PERFORM * FROM HISTORIQUE_DATE WHERE cur_month = date_historique;

	IF NOT FOUND THEN
		INSERT INTO HISTORIQUE_DATE(date_historique,recette_mois,depense_mois)
			VALUES(cur_month,DEFAULT,depense);
	ELSE
		UPDATE HISTORIQUE_DATE SET depense_mois=(depense+depense_mois)
			WHERE date_historique = cur_month;
	END IF;
END;
$$ LANGUAGE plpgsql;
