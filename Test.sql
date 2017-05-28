\i creer_base.sql;
\i historique.sql;
\i Fonction_insertion.sql;


\echo 'Quand on insert une nouvelle pièce, elle est automatiquement ajoutée à lhistorique des Pieces\n' ;
INSERT INTO Pieces(nom,prix_normal,prix_reduit) VALUES
('rent',10,20),
('Les Femmes savantes',80,70),
('Les Fâcheux',40,35);
SELECT * FROM Pieces ;

\echo 'HISTORIQUE  des depenses et des recettes par Pieces ' ;
SELECT * FROM HISTORIQUE_PIECE ;
Insert Into Organismes(nom_organisme) Values
('mairie de paris'),
('la sacem');
 SELECT * FROM Pieces;
 SELECT * FROM Organismes ;

 Insert Into Representations(id_piece ,date_representation) Values
 (1,CURRENT_DATE);

  SELECT * FROM Pieces;
  SELECT * FROM Organismes ;
  SELECT * FROM Representations ;


\echo 'ajouter un cout à une Pieces créée à l exterieur provoque une exception \n';

Insert Into Couts(id_piece,prix ,date_cout ) Values
(1,100,CURRENT_DATE);

\echo 'ajouter un cout  \n';
INSERT INTO Pieces_creees(id_piece ,date_creation ,nb_acteurs ,nb_musiciens ) VALUES
(3,CURRENT_DATE,12,15);

SELECT * FROM Pieces_creees;

Insert Into Couts(id_piece,prix ,date_cout ) Values
(3,100,CURRENT_DATE);

\echo '\nL ajout d un coût permet de mettre à jour les dépenses de la compagnie pour le mois courantainsi que les dépenses relatives à la pièce concernée.\n';
\echo 'HISTORIQUE  des depenses et des recettes par Pieces  \n';
 SELECT * FROM HISTORIQUE_PIECE ;
 \echo 'HISTORIQUE des depenses et de la recette par moi de la compagnie \n';
 SELECT * FROM HISTORIQUE_DATE;

\echo '\nSubvention : Un organisme fait des dons uniquement aux pièces qui doivent exister dans lensemble des piece de la compagnie, \n et s ajoute dans l ensemble des organisme s il n y est pas deja ' ;
Insert Into Subventions(nom_organisme ,  id_piece ,  date_subvention ,  valeur_don )Values
('mairie FR ',3,'2017/06/12',2500);
\echo 'Subventions :\n';
SELECT * FROM Subventions ;
\echo 'organismes  :\n';
SELECT * FROM organismes;
\echo 'HISTORIQUE_DATE :\n';
SELECT * FROM HISTORIQUE_DATE ;
\echo 'HISTORIQUE_PIECE :\n';
SELECT * FROM HISTORIQUE_PIECE ;

/*\echo '\n Fonction pour l achat d une pièce (Représentation ) : \n - ajouter la Representations aux Representations interieures\n - ajouter le théatre s il n existe pas\n - ajout dans achat la date et le cout de la Representations_interieures\n mise à jour des depenses\n
';*/

\echo '\n Achat d une pièce (Représentation ) : mise à jour automatique des historiques \n ';
Insert Into Representations_interieures(id_representation,nb_places,nb_places_vendues_tarif_normal,nb_places_vendues_tarif_reduit,nb_places_restante,debut_vente) Values
(1,100,DEFAULT,DEFAULT,100,CURRENT_DATE);
Insert Into Theatres(nom ,ville ) Values ('Théâtre Antoine','Paris');

Insert Into  Achats(  id_representation ,  id_theatre ,  date_achat ,  cout_achat) VALUES
(1,1,'2017/05/01',7000);

\echo 'Achats :\n';
SELECT * FROM Achats ;
\echo 'Representations_interieures  :\n';
SELECT * FROM Representations_interieures;
\echo 'HISTORIQUE_DATE :\n';
SELECT * FROM HISTORIQUE_DATE ;
\echo 'HISTORIQUE_PIECE :\n';
SELECT * FROM HISTORIQUE_PIECE ;

\echo '\n Fonction : Verification des disponibilités de place pour effectuer une réservation \n';
\echo '\n  Effectuer une reservation de places fait que le nombre de places libres de la représentation diminut \n';
Insert Into Clients (  nom ,  prenom ,  email ) Values
('Hamaz','belynda','belynda@hotmail.com');

Insert Into  Reservations(id_representation ,  id_client ,  nb_places_reservees ,  date_reservation ,  date_peremption ) Values
(1,1,5, CURRENT_DATE,'2017/06/01')
;
\echo 'Representations interieures  :\n';
SELECT * FROM Representations_interieures ;

\echo 'Une modification d une reservation en une reservation Impossible   :\n';

UPDATE Reservations SET nb_places_reservees = 100  WHERE id_client = 1;
\echo 'Representations interieures  :\n';
SELECT * FROM Representations_interieures ;

\echo 'Achat d une place :\n -On commence par supprimer toutes les reservations expirées\n-Si la représentation est deja passé alors  une exception est declenchée\n Une  verification du nombre de places disponibles par rapport aux nombres de place demandé pour l achat \n'
UPDATE REPRESENTATIONs_Interieures Set nb_places_vendues_tarif_reduit=4 WHERE id_representation = 1 ;
UPDATE REPRESENTATIONs_Interieures Set nb_places_vendues_tarif_normal=10 WHERE id_representation = 1 ;

\echo 'Representations interieures  :\n';
SELECT * FROM Representations_interieures ;
\echo 'HISTORIQUE_DATE :\n';
SELECT * FROM HISTORIQUE_DATE ;
\echo 'HISTORIQUE_PIECE :\n';
SELECT * FROM HISTORIQUE_PIECE ;

\echo 'Vente présentation \n';
Insert Into Representations(id_piece ,date_representation) Values
(2,CURRENT_DATE);
Insert Into Representations_exterieures( id_representation ,  prix ,  date_vente ) Values
(2 , 8000,CURRENT_DATE);
\echo 'Representations exterieurs  :\n';
SELECT * FROM Representations_exterieures;
\echo 'HISTORIQUE_DATE :\n';
SELECT * FROM HISTORIQUE_DATE ;
\echo 'HISTORIQUE_PIECE :\n';
SELECT * FROM HISTORIQUE_PIECE ;



/*
Insert into Pieces_creees(id_piece,date_creation,nb_acteurs,nb_musiciens) Values(1,CURRENT_DATE,4,4);

Insert Into Representations(id_piece,date_representation) Values(1,'2017-08-06');

Insert Into Representations_interieures(id_representation,nb_places,nb_places_vendues_tarif_normal,nb_places_vendues_tarif_reduit,nb_places_restante,debut_vente) Values(1,100,DEFAULT,DEFAULT,100,CURRENT_DATE);

Insert Into Couts(id_piece,prix,date_cout) Values(1,150,DEFAULT);

insert into Subventions(nom_organisme,id_piece,date_subvention,valeur_don) VALUES ('mairie de paris',1,CURRENT_DATE,100);

UPDATE REPRESENTATIONs_Interieures Set nb_places_vendues_tarif_reduit=4;

UPDATE REPRESENTATIONs_Interieures Set nb_places_vendues_tarif_reduit=22;*/
