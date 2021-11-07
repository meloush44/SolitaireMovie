unit Lia;

interface

uses Initialisation, Selection, outils;

Type PositionsPossibles = record

	pp : Array[1..7] of Position;
	exists : Boolean;
	nbPos : Integer;
	
end;

Type PlateauPositions = Array [1..7,1..21] of PositionsPossibles;


procedure Ou_Mettre(carte_select : Cartes; pio : Pioche; bloque: Boolean; pl : Plateau; var popo : PositionsPossibles; var joh : Boolean);
Procedure Ensemble_Positions(PiocheOuPlateau : Boolean; pl : Plateau; 	pio : Pioche; var pts : PlateauPositions; var bloque : Boolean; var joh : Boolean);
Procedure Test_Ensemble_Possibilites(bloque : Boolean; var nbTourFinal, nbTour : Integer; var victoire : Boolean; var pl : Plateau; var pio : Pioche; var pts : PlateauPositions);


/////////////////////////////////////////////////////////////////////////////////////
Implementation


procedure Ou_Mettre(carte_select : Cartes; pio : Pioche; bloque: Boolean; pl : Plateau; var popo : PositionsPossibles; var joh : Boolean);
var k, dc : Integer;
	carte_prec : Cartes;
	
	
begin

	popo.nbPos := 0;
	popo.exists := False;
	joh := True;

		
	for k:= 1 to 7 do
		begin
			popo.pp[k].x := 0;
			popo.pp[k].y := 0;
		end;
	
	// Test du plateau dans les cartes du côté
	for k := 1 to 4 do
		begin
			carte_prec := pl[k][1];
			if verif_couleur_haut(carte_prec, carte_select) and verif_valeur_haut(carte_prec, carte_select) then
				begin
					popo.exists := True;
					writeln('coucou');
					popo.nbPos += 1;
					writeln('popo.nbPos : ', popo.nbPos);
					writeln('k : ', k);
					popo.pp[popo.nbPos].x := k;
					writeln('x : ', popo.pp[popo.nbPos].x);
					popo.pp[popo.nbPos].y := 1;
					joh := False;
				end;
		end;
	

	for k := 1 to 7 do
		begin
			if k <> carte_select.pos.x then
				begin
				
				
				// Test du plateau dans le plateau
					dc := Nb_Cartes_Colonne(pl, k);
					carte_prec := pl[k][dc];
					//writeln('carte prec : ', carte_prec.sym);
					
					
					if verif_couleur_jeu(carte_prec, carte_select) and verif_valeur_jeu(carte_prec, carte_select) then
						begin
							popo.exists := True;
							writeln('coucou2');
							popo.nbPos += 1;
							writeln('popo.nbPos : ', popo.nbPos);
							popo.pp[popo.nbPos].x := k;
							writeln('x : ', popo.pp[popo.nbPos].x);
							popo.pp[popo.nbPos].y := dc + 1;
						end;
						
						
				end;
		end;
end;


Procedure Ensemble_Positions(PiocheOuPlateau : Boolean; pl : Plateau; 	pio : Pioche; var pts : PlateauPositions; var bloque : Boolean; var joh : Boolean);

var i,j, CRetourneePio, nbCartesPioche : Integer;
	popo : PositionsPossibles;
	carte_select : Cartes;
	

begin
	bloque := True;
	joh := True;
	if PiocheOuPlateau then
		begin
			for j:= 3 to 21 do
					begin
						for i:= 1 to 7 do
							if pl[i][j].retournee then
								begin
									carte_select := pl[i][j];
									writeln('carte a tester : ', carte_select.valeur, ' ', carte_select.sym);
									writeln('avant ou mettre pour le plateau');
									Ou_Mettre(carte_select, pio, bloque, pl, popo, joh);
									writeln('apres ou mettre pour le plateau');
									pts[i][j] := popo;
									
									if pts[i][j].exists then
										bloque := False;
									writeln('bloque : ', bloque);
								end;
						
					end;
		end
			
	else
		begin
			Trouver_CartePioche(pio, CRetourneePio, nbCartesPioche);
			carte_select := pio[CRetourneePio];
			writeln('avant ou mettre pour la pioche');
			Ou_mettre(carte_select, pio, bloque, pl, popo, joh);
			writeln('apres ou mettre pour la pioche');
			pts[1][1] := popo;
			if pts[1][1].exists then
				bloque := False;
			writeln('bloque : ', bloque);
				
		end	;
			
	
end;


Procedure Test_Ensemble_Possibilites(bloque : Boolean; var nbTourFinal, nbTour : Integer; var victoire : Boolean; var pl : Plateau; var pio : Pioche; var pts : PlateauPositions);

var CRetourneePio, nbCartesPioche, nbTourPioche, i, j, nbCasesExistantes, variable, nbplStock, m, l : Integer;
	PiocheOuPlateau, joh, BooleenVrai, BooleenFaux : Boolean;
	carte_select, carte_prec : Cartes;
	tpl : SauvegardePlateau;
	tpio : SauvegardePioche;
	
	



begin
	
	BooleenVrai := True;
	BooleenFaux := False;
	nbCasesExistantes := 126;
	
	
	
	for j:= 3 to 21 do
		begin
			for i:= 1 to 7 do
				begin
					if not pts[i][j].exists then
						nbCasesExistantes -= 1;
				end;
		end;
	
	
	
	if nbTour > nbTourFinal then
		begin
			writeln('trop de tours');
			exit;
		end;
	
	
	if nbCasesExistantes = 0 then
		begin
			writeln('plus de possibilite');
			halt;
		end;
	
	if Fin_Du_Jeu(pl) then
		begin
			nbTourFinal := nbTour;
			victoire := True;
			writeln('exit fin du jeu');
			exit;
			writeln('finito');
		end
	
	else
		begin
			if bloque then
				begin
				

					
					nbTourPioche := 0;
					Trouver_CartePioche(pio, CRetourneePio, nbCartesPioche);
					PiocheOuPlateau := False;
					repeat
						Retourner_CartePioche(pio);
						Ensemble_Positions(PiocheOuPlateau, pl, pio, pts, bloque, joh);
						//Test_Ensemble_Possibilites(bloque, nbTourFinal, nbTour, victoire, pl, pio, pts);
						nbTourPioche += 1;
					until (not bloque) or (nbTourPioche = nbCartesPioche + 1);
					writeln('ON EST DANS LA PIOCHE');
					
					variable := 0;
					
					if joh then
						variable := 1;
					
					
					Trouver_CartePioche(pio, CRetourneePio, nbCartesPioche);
					carte_select := pio[CRetourneePio];
					carte_prec := pl[pts[1][1].pp[pts[1][1].nbPos].x][pts[1][1].pp[pts[1][1].nbPos].y-variable];
					writeln('carte prec :',  carte_prec.valeur);
					writeln('le truc en x :', pts[1][1].pp[pts[1][1].nbPos].x);
					writeln('le truc en y :', pts[1][1].pp[pts[1][1].nbPos].y-variable);
					writeln('carte select :',  carte_select.valeur);
					writeln('avant deplacement pioche');
					//Deplacer_Carte(carte_prec, carte_select, BooleenVrai, BooleenVrai, BooleenFaux, BooleenVrai, joh, pl, pio);
					
					
					
					
					
					Deplacer_CartePioche(variable, carte_prec, carte_select, pio, pl);
					nbTour += 1;
					writeln('nbtour : ', nbTour);
					pts[1][1].nbPos -= 1;
					
					if pts[1][1].nbPos = 0 then
						pts[1][1].exists := False;
					
					
					writeln('apres deplacement pioche');
					
					
					if nbTourPioche = nbCartesPioche + 1 then
						begin
							victoire := False;
							writeln('exit de la pioche');
							exit;
						end;
						
					PiocheOuPlateau := True;
					
					Test_Ensemble_Possibilites(bloque, nbTourFinal, nbTour, victoire, pl, pio, pts);
						
				end
				
				
			else
				begin
					Ensemble_Positions(PiocheOuPlateau, pl, pio, pts, bloque, joh);
					for j:= 3 to 21 do
						begin
							for i:= 1 to 7 do
								begin
									if pts[i][j].exists then
										begin
																
											variable := 0;
					
											if joh then
												variable := 1;
										
											carte_prec := pl[pts[i][j].pp[pts[i][j].nbPos].x][pts[i][j].pp[pts[i][j].nbPos].y-variable];
											writeln('le truc en x :', pts[i][j].pp[pts[i][j].nbPos].x);
											writeln('le truc en y :', pts[i][j].pp[pts[i][j].nbPos].y-variable);
											carte_select := pl[i][j];
											writeln('carte prec :',  carte_prec.valeur);
											writeln('carte select :',  carte_select.valeur);
											writeln('avant deplacement');
											Deplacer_Carte(carte_prec, carte_select, BooleenVrai, BooleenVrai, joh, BooleenFaux, pl, pio, nbPlStock, tpl, tpio);
											writeln('deplacement effectue');
											nbTour += 1;
											writeln('nb de tours : ', nbTour);
											
											for l:= 1 to 10 do
													begin
														for m:= 1 to 7 do
															begin
															write(pl[m][l].valeur, pl[m][l].sym, '     ');
															end;
														writeln();
													end;
											writeln;
	
	
											pts[i][j].nbPos -= 1;
											if pts[i][j].nbPos = 0 then
												pts[i][j].exists := False;
											
											
											Test_Ensemble_Possibilites(bloque, nbTourFinal, nbTour, victoire, pl, pio, pts);
										end;
								end;
						end;
				end;
											
											
									
				
		end;
		
		
		
		
		
	
end;


end.



{


	
	if bloque then
		begin
			Trouver_CartePioche(pio, CRetourneePio, nbCartesPioche);
			carte_select := pio[CRetourneePio];
		end
	else	
		carte_select := pl[i][j];
		
}






						
						
						
						
						
