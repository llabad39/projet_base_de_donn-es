\i creer_base.sql;
\i historique.sql;
\i Fonction_insertion.sql;

INSERT INTO PIECES(nom,prix_normal,prix_reduit) VALUES ('rent',10,20);

Insert Into Organismes(nom_organisme) Values('mairie de paris');

Insert into Pieces_creees(id_piece,date_creation,nb_acteurs,nb_musiciens) Values(1,CURRENT_DATE,4,4);

Insert Into Representations(id_piece,date_representation) Values(1,'2017-08-06');

Insert Into Representations_interieures(id_representation,nb_places,nb_places_vendues_tarif_normal,nb_places_vendues_tarif_reduit,nb_places_restante,debut_vente) Values(1,100,DEFAULT,DEFAULT,100,CURRENT_DATE);

Insert Into Couts(id_piece,prix,date_cout) Values(1,150,DEFAULT);

insert into Subventions(nom_organisme,id_piece,date_subvention,valeur_don) VALUES ('mairie de paris',1,CURRENT_DATE,100);

UPDATE REPRESENTATIONs_Interieures Set nb_places_vendues_tarif_reduit=4;

UPDATE REPRESENTATIONs_Interieures Set nb_places_vendues_tarif_reduit=22;
