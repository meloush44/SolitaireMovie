Unit Selection;


Interface

uses Initialisation, SDL, SDL_image, sysutils, outils;

/////////////////////////////////////////////////////////////////////////////////////////
// Procédures et fonctions

//Procedure Trouver_CartePioche(pio : Pioche; var i, n : Integer);
Procedure TrouverCarte(cst : Constantes; p : Position; var pl : Plateau; var a, b : Integer);
Procedure Clic (cst : Constantes; pl : Plateau; pio : Pioche; var carte_select, carte_prec : Cartes; var piocheouplateau, cliccartepioche, joh1, joh2 : Boolean);
Procedure Verification (cst : Constantes; cp, cs : Cartes; pl : Plateau; pio : Pioche; pClic, ClicUp: Position; var v : Boolean);
Procedure Retourner_CartePioche(var pio : Pioche);
Procedure Deplacer_Carte (carte_prec, carte_select : Cartes; v, cliccartepioche, joh1, joh2 : Boolean; var pl : Plateau; var pio : Pioche; var nbPlStock  : Integer ; var tPl : SauvegardePlateau; var tPio : SauvegardePioche);
Procedure Deplacer_CartePioche(variable : Integer; carte_prec, carte_select : Cartes; var pio : Pioche; var pl : Plateau);


Procedure CliquerCarte(cst : Constantes; pl : Plateau; pio : Pioche; var carte_select : Cartes; var joh1, tupeuxcliquer, clicsimple, fin, retour, aide, clicretournepioche, cliccartepioche : Boolean; var p : Position);
Procedure RelacherCarte(cst : Constantes; pl : Plateau; ClicUp : Position; var carte_prec : Cartes; var joh2, tupeuxrelacher : Boolean);

Function Emplaclicable (pl : PLateau; p : Position; cst : Constantes) : Boolean;
Function Emplarelachable (pl : Plateau; p : Position; cst : Constantes) : Boolean;

Procedure JusteUnClic(choixDiff : Integer; retour, fin, aide, clicretournepioche : Boolean; var pl : Plateau; var pio : Pioche; var nbPlStock  : Integer ; var tPl : SauvegardePlateau; var tPio : SauvegardePioche);


Procedure Dilapider_La_Pioche (var pio : Pioche; var pl : Plateau);
Procedure Fin_Automatique (var pio : Pioche; var pl : Plateau);
Procedure Ou_Mettre(carte_select : Cartes; pio : Pioche; bloque: Boolean; pl : Plateau; var popo : PositionsPossibles; var joh : Boolean);



/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

Implementation


// Retourne la prochaine carte de la pioche
Procedure Retourner_CartePioche(var pio : Pioche);

var i, n : Integer;

begin	
	Trouver_CartePioche(pio, i, n);
	writeln(i);
	if i = 0 then
		begin
			pio[1].retournee := True;
			writeln('i vaut 0');
		end
	else
		begin
			if i = n then
				begin
					writeln('i=n');
					pio[i].retournee := False;
				end
			else
				begin
					writeln('i<>n');
					pio[i].retournee := False;
					pio[i+1].retournee := True;
				end;
		end;
end;
		
	
/////////////////////////////////////////////////////////////////////////////////////////
// Deplace une carte de la pioche dans le plateau ou sur le côté
Procedure Deplacer_CartePioche(variable : Integer; carte_prec, carte_select : Cartes; var pio : Pioche; var pl : Plateau);

var i, j, n : Integer;

begin	
	pl[carte_prec.pos.x][carte_prec.pos.y + variable] := carte_select;
	Trouver_CartePioche(pio, i, n);
	if i > 0 then 
		begin
			pio[i-1].retournee := True;
			pio[i].retournee := False;
			for j:= i to n-1 do
				pio[j] := pio[j+1];
			pio[n].existe := False;
		end;
end;
			

/////////////////////////////////////////////////////////////////////////////////////////
// Donne la position de la carte cliquée dans le tableau
Procedure TrouverCarte(cst : Constantes; p : Position; var pl : Plateau; var a, b : Integer);

var i : Integer;
	joh : Boolean;

begin
	joh := Jeu_ou_Haut(p, cst);
	if joh then
		begin
			a:= trunc((cst.Dx + cst.w - p.x)/(- cst.E_cx - cst.w) + 2);				// a position correspondante du clic dans le tableau (numéro de la colonne)
			
			i := Nb_Cartes_Colonne(pl, a);
			//writeln('nb cartes colonne : ', i);
			if i = 0 then
				b := 2
			else
				begin
					if (p.y >= cst.Dy + (i-3)*cst.E_cy) then
						b := i
					else
						b:= trunc((- p.y + cst.Dy)/(- cst.E_cy) + 3);
				end;
		end
	else
		begin
			//writeln('not joh de trouver');
			b := 1;
			a := trunc((cst.l - p.y + cst.Dyco)/(- cst.l - cst.E_coy) + 2);
		end;
	pl[a][b].pos.x := a;
	pl[a][b].pos.y := b;

	writeln(a, ' ', b);
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Renvoie les deux cartes sélectionnées
Procedure Clic (cst : Constantes; pl : Plateau; pio : Pioche; var carte_select, carte_prec : Cartes; var piocheouplateau, cliccartepioche, joh1, joh2 : Boolean);

var p : Position;
	i, n, a, b, c, d : Integer;

begin
	writeln('debut de clic');
	repeat
		p:= PositionDernierClic
	until p.x <> -1;
	//writeln('1er clic : ', p.x, ' ', p.y);
	
	piocheouplateau := True;
	cliccartepioche := False;
	joh1 := Jeu_ou_Haut(p, cst);
	
	// clic sur la pioche
	if (p.x > cst.Dx) and (p.x < cst.Dx + cst.w) and (p.y > 52) and (p.y < 52 + cst.l) then
		begin
			piocheouplateau := False;
		end;
		
		
	// clic sur les cartes de la pioche
	if (p.x> cst.Dx + cst.w + cst.E_cx) and (p.x < cst.Dx + 2*cst.w + cst.E_cx) and (p.y > 52) and (p.y < 52 + cst.l) then
		begin
			//writeln('clic cartes pioche');
			cliccartepioche := True;
			Trouver_CartePioche(pio, i, n);
			carte_select := pio[i];
			repeat
				p := PositionDernierClic;
				//writeln(p.x);
			until p.x <> -1;
			if Emplaclicable(pl, p, cst) then
				begin
					//writeln('deuxieme clic pioche dans plateau');
					TrouverCarte(cst, p, pl, c, d);
					carte_prec := pl[c][d];
					joh2 := Jeu_ou_Haut(p, cst);
				end;
		end
		
	else	
		begin
	// clic sur le plateau
			if Emplaclicable(pl, p, cst) then
				begin
					//writeln('#1');
					TrouverCarte(cst, p, pl, a, b);
					//writeln(a, ' ', b);
					carte_select := pl[a][b];
					//writeln('carte select : ', carte_select.valeur);
					repeat
						p := PositionDernierClic
					until p.x <> -1;
					//writeln('2eme clic : ', p.x, ' ', p.y);
					if Emplaclicable(pl, p, cst) then
						begin
							//writeln('#2');
							TrouverCarte(cst, p, pl, c, d);
							joh2 := Jeu_ou_Haut(p, cst);
							//writeln(c, ' ', d);
							carte_prec := pl[c][d];
							//writeln('carte prec : ', carte_prec.valeur);
						end;
				end;
		end;
	//writeln('joh1 : ', joh1, ' joh2 : ', joh2);
	writeln('clic fait');
end;


/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure CliquerCarte(cst : Constantes; pl : Plateau; pio : Pioche; var carte_select : Cartes; var joh1, tupeuxcliquer, clicsimple, fin, retour, aide, clicretournepioche, cliccartepioche : Boolean; var p : Position);

var i, n, a, b : Integer;
	
begin
	tupeuxcliquer := False;
	
	repeat
		p:= PositionDernierClic
	until p.x <> -1;
	
	
	if Emplaclicable(pl, p, cst) then
		begin
			tupeuxcliquer := True;
		end
	else
		exit;
		
		
	clicsimple := False;
	fin := False;
	retour := False;
	aide := False;
	clicretournepioche := False;
	cliccartepioche := False;
	
	joh1 := Jeu_ou_Haut(p, cst);

	//clic sur quitter
	if (p.x >= cst.Dxb + 2*(cst.TailleBoutonX + cst.E_b)) and (p.x <= cst.Dxb + 2*cst.E_b + 3*cst.TailleBoutonX) and (p.y >= cst.Dyb) and (p.y <= cst.Dyb + cst.TailleBoutonY) then
		begin
			fin := True;
			clicsimple := True;
			exit;
		end;
		
	//clic sur retour arrière
	if (p.x >= cst.Dxb) and (p.x <= cst.Dxb + cst.TailleBoutonX) and (p.y >= cst.Dyb) and (p.y <= cst.Dyb + cst.TailleBoutonY) then
		begin
			retour := True;
			clicsimple := True;
			exit;
		end;
	
	// clic sur aide	
	if (p.x >= cst.Dxb + (cst.TailleBoutonX + cst.E_b)) and (p.x <= cst.Dxb + cst.E_b + 2*cst.TailleBoutonX) and (p.y >= cst.Dyb) and (p.y <= cst.Dyb + cst.TailleBoutonY) then
		begin
			aide := True;
			clicsimple := True;
			exit;
		end;
	
	// clic sur le dos de la pioche
	if (p.x >= cst.Dx) and (p.x <= cst.Dx + cst.w) and (p.y >= cst.Dypio) and (p.y <= cst.Dypio + cst.l) then
		begin
			clicretournepioche := True;
			clicsimple := True;
			exit;
		end;

	// clic sur les cartes de la pioche
	if (p.x >= cst.Dx + cst.w + cst.E_cx) and (p.x <= cst.Dx + 2*cst.w + cst.E_cx) and (p.y >= cst.Dypio) and (p.y <= cst.Dypio + cst.l) then
		begin
			cliccartepioche := True;
			Trouver_CartePioche(pio, i, n);
			if (i <> 0) and (n <> 0) then
				carte_select := pio[i]
			else
				tupeuxcliquer := False;
		end
	else
		begin
	// clic sur le plateau ou le côté
			TrouverCarte(cst, p, pl, a, b);
			carte_select := pl[a][b];
			
			if (carte_select.pos.y = 1) and (carte_select.valeur = 0) then		// clic sur le côté alors qu'il n'y a aucune carte
				tupeuxcliquer := False;
			
			if not carte_select.retournee then
				tupeuxcliquer := False;
				
		end;
end;


/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure RelacherCarte(cst : Constantes; pl : Plateau; ClicUp : Position; var carte_prec : Cartes; var joh2, tupeuxrelacher : Boolean);

var c, d : Integer;

begin
	tupeuxrelacher := False;

	if Emplarelachable(pl, ClicUp, cst) then
		begin
			tupeuxrelacher := True;
			TrouverCarte(cst, ClicUp, pl, c, d);
			carte_prec := pl[c][d];
				if (carte_prec.pos.y <> 1) and not carte_prec.retournee then
					begin
						tupeuxrelacher := False;
						exit;
					end;
			joh2 := Jeu_ou_Haut(ClicUp, cst);
		end;
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Vérifie si la carte peut être déplacée
Procedure Verification (cst : Constantes; cp, cs : Cartes; pl : Plateau; pio : Pioche; pClic, ClicUp: Position; var v : Boolean);

var	joh, joh1 : Boolean;
	
begin
	v := False;
	
	joh := Jeu_ou_Haut(ClicUp, cst);
	writeln('joh : ', joh);
	
	joh1 := Jeu_ou_Haut(pClic, cst);
	writeln('joh1 : ', joh1);
	
	if not joh1 and not joh then			// Du côté au côté
		exit;

	if not joh then
		begin 
			if verif_couleur_haut(cp, cs) and verif_valeur_haut(cp, cs) then
				v := True
		end
	else 
		begin
			if cs.valeur = 13 then
				begin
					if verif_valeur_jeu(cp, cs) then
						begin
							v := True;
						end;
				end
			else
				begin
					if verif_couleur_jeu(cp, cs) and verif_valeur_jeu(cp, cs) then
						begin
							v := True;
						end;
				end;
		end;
	writeln('v : ', v);
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Vérifie si le joueur est sur un emplacement cliquable
Function Emplaclicable (pl : PLateau; p : Position; cst : Constantes) : Boolean;

var i, j : Integer;

begin	
	Emplaclicable := False;
	for i := 1 to 7 do
		begin									
			j := Nb_Cartes_Colonne(pl, i);
			if (p.x >= cst.Dx + (i-1)*(cst.w + cst.E_cx)) and (p.x <= cst.Dx + i*cst.w + (i-1)*cst.E_cx) and (p.y <= cst.Dy + (j-3)*cst.E_cy + cst.l) and (p.y >= cst.Dy) then
				begin
				Emplaclicable := True;			// Plateau
				end;
		end;
		
	for i:= 0 to 3 do
		begin
			if (p.x >= cst.Dxco) and (p.x <= cst.Dxco + cst.w) and (p.y >= cst.Dyco + i*(cst.l + cst.E_coy)) and (p.y <= cst.Dyco + (i + 1)*cst.l + i*cst.E_coy) then
				begin
				Emplaclicable := True;			// Cartes du côté
				end;
		end;
							

	if (((p.x >= cst.Dx) and (p.x <= cst.Dx + cst.w)) or ((p.x >= cst.Dx + cst.w + cst.E_cx) and (p.x <= cst.Dx + 2*cst.w + cst.E_cx))) and (p.y >= cst.Dypio) and (p.y <= cst.Dypio + cst.l) then
		begin
		Emplaclicable := True;					// Pioche
		end;
		
	for i:= 1 to 3 do
		begin
			if (p.x >= cst.Dxb + (i-1)*(cst.TailleBoutonX + cst.E_b)) and (p.x <= cst.Dxb + (i-1)*cst.E_b + i*cst.Dxb) and (p.y >= cst.Dyb) and (p.y <= cst.Dyb + cst.TailleBoutonY) then
				Emplaclicable := True;			// Menu
		end;

end;


/////////////////////////////////////////////////////////////////////////////////////////
// Vérifie si le joueur peut relâcher la carte à cet endroit
Function Emplarelachable (pl : Plateau; p : Position; cst : Constantes) : Boolean;

var i, j : Integer;


begin
	Emplarelachable := False;
	for i := 1 to 7 do
		begin									
			j := Nb_Cartes_Colonne(pl, i);
			if (p.x >= cst.Dx + (i-1)*(cst.w + cst.E_cx)) and (p.x <= cst.Dx + i*cst.w + (i-1)*cst.E_cx) and (p.y <= cst.Dy + (j-3)*cst.E_cy + cst.l) and (p.y >= cst.Dy) then
				Emplarelachable := True;			// Plateau
		end;
		
	for i:= 0 to 3 do
		begin
			if (p.x >= cst.Dxco) and (p.x <= cst.Dxco + cst.w) and (p.y >= cst.Dyco + i*(cst.l + cst.E_coy)) and (p.y <= cst.Dyco + (i + 1)*cst.l + i*cst.E_coy) then
				Emplarelachable := True;			// Cartes du côté
		end;

end;


/////////////////////////////////////////////////////////////////////////////////////////
// 
Procedure JusteUnClic(choixDiff : Integer; retour, fin, aide, clicretournepioche : Boolean; var pl : Plateau; var pio : Pioche; var nbPlStock  : Integer ; var tPl : SauvegardePlateau; var tPio : SauvegardePioche);

begin
	if retour then
		begin
			Annuler_Coup(nbPlStock, tPl, tPio, pl, pio);
			exit;
		end;
		
	if aide then
		exit;
		
	if clicretournepioche then
		begin
			Retourner_CartePioche(pio);
			Stockage(pl, pio, tPl, tPio, nbPlStock);
		end;

end;


/////////////////////////////////////////////////////////////////////////////////////////
// Deplace la carte dans le tableau
Procedure Deplacer_Carte (carte_prec, carte_select : Cartes; v, cliccartepioche, joh1, joh2 : Boolean; var pl : Plateau; var pio : Pioche; var nbPlStock  : Integer ; var tPl : SauvegardePlateau; var tPio : SauvegardePioche);

var k, i, variable : Integer;
	cas : String;


begin	
	if cliccartepioche and joh2 then
		cas := 'de la pioche au plateau';
	
	if cliccartepioche and not joh2 then
		cas := 'de la pioche au cote';
	
	if joh1 and not cliccartepioche and joh2 then
		cas := 'du plateau au plateau';
		
	if joh1 and not cliccartepioche and not joh2 then
		cas := 'du plateau au cote';
		
	if not joh1 and joh2 then
		cas := 'du cote au plateau';
	
	
	
	if v then
		begin
			case cas of
				'de la pioche au plateau' : begin
												writeln('de la pioche au plateau');
												variable := 1;
												Deplacer_CartePioche(variable, carte_prec, carte_select, pio, pl);
											end;
											
				'de la pioche au cote' : 	begin
												writeln('de la pioche au cote');
												variable := 0;
												Deplacer_CartePioche(variable, carte_prec, carte_select, pio, pl);
											end;
										 
				'du plateau au plateau' : 	begin
												writeln('du plateau au plateau');
												k := Nb_Cartes_Colonne(pl, carte_select.pos.x);
												pl[carte_select.pos.x][carte_select.pos.y-1].retournee := True;
												for i:= 0 to (k - carte_select.pos.y) do
													begin
														writeln(i);
														pl[carte_prec.pos.x][carte_prec.pos.y + i + 1] := pl[carte_select.pos.x][carte_select.pos.y + i];
														pl[carte_select.pos.x][carte_select.pos.y + i].valeur := 0;											
														pl[carte_select.pos.x][carte_select.pos.y + i].existe := False;
														writeln(pl[carte_prec.pos.x][carte_prec.pos.y + i + 1].valeur);
													end;
											end;
											
				'du plateau au cote' : 		begin
												writeln('du plateau au cote');
												pl[carte_select.pos.x][carte_select.pos.y-1].retournee := True;
												pl [carte_prec.pos.x][carte_prec.pos.y] := carte_select;
												pl[carte_select.pos.x][carte_select.pos.y].valeur := 0;
												pl[carte_select.pos.x][carte_select.pos.y].existe := False;
											end;
											
				'du cote au plateau' : 		begin
												writeln('du cote au plateau');
												pl[carte_prec.pos.x][carte_prec.pos.y + 1] := pl[carte_select.pos.x][carte_select.pos.y];
												pl[carte_select.pos.x][carte_select.pos.y].valeur := pl[carte_select.pos.x][carte_select.pos.y].valeur - 1;
												pl[carte_select.pos.x][carte_select.pos.y].ind := pl[carte_select.pos.x][carte_select.pos.y].ind - 4;	
											end;
			end;	
		end;
		
		
		
		
	Stockage(pl, pio, tPl, tPio, nbPlStock);
end;

/////////////////////////////////////////////////////////////////////////////////////////
// Permet de déplacer automatiquement une carte quand on double clique dessus
Procedure Deplacement_Auto (carte_select : Cartes; pl : Plateau; pio : Pioche; var carte_prec : Cartes; var bloque : Boolean);
var BooleenFaux, joh : Boolean;
	popo : PositionsPossibles;
	nbAlea, a, b : Integer;
begin
	
	BooleenFaux := False;
	bloque := True;
	Randomize;
	
	Ou_Mettre(carte_select, pio, BooleenFaux, pl, popo, joh);
	
	if popo.nbPos > 0 then
		begin
			bloque := False;
			if not joh then
				begin
					a := popo.pp[1].x;
					b := popo.pp[1].y;
					carte_prec := pl[a][b];
				end
					
			else
				begin
					nbAlea := Random(popo.nbPos) + 1;
					a := popo.pp[nbAlea].x;
					b := popo.pp[nbAlea].y;
					carte_prec := pl[a][b];
				end;
		end;
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Permet de déplacer automatiquement une carte quand on double clique dessus
procedure Aide (pl : Plateau; pio : Pioche; var carte_prec, carte_select : Cartes; var PasDeSolution : Boolean);

var bloque, joh : Boolean;
	i, j, nbSolutions, a, b, Hasard, Solution, CRetourneePio, nbCartesPioche : Integer;
	popo : PositionsPossibles;
	tabPosPos : Array[1..20] of PositionsPossibles;
begin
bloque := True;
nbSolutions := 0;
PasDeSolution := False;

	for j:= 3 to 21 do
		begin
			for i:= 1 to 7 do
				begin
					if pl[i][j].retournee and pl[i][j].existe then
						begin
							carte_select := pl[i][j];
							Ou_Mettre(carte_select, pio, bloque, pl, popo, joh);
							if popo.nbPos > 0 then 
								begin
									nbSolutions += 1;
									tabPosPos[nbSolutions] := popo;
								end;
							popo.pp[popo.nbPos + 1].x := i;				// On stocke la position de la carte select dans la dernière case de popo
							popo.pp[popo.nbPos + 1].y := j;
						end;
				end;
		end;
		
		if nbSolutions = 0 then
			begin
				PasDeSolution := True;
				Trouver_CartePioche(pio, CRetourneePio, nbCartesPioche);
				carte_select := pio[CRetourneePio];
				Ou_mettre(carte_select, pio, bloque, pl, popo, joh);
				if popo.exists then
					begin
						PasDeSolution := False;
						
						Hasard := Random(popo.nbPos) + 1;
				
						a := popo.pp[Hasard].x;
						b := popo.pp[Hasard].y - 1;
						carte_prec := pl[a][b];
					end;
			end
		else
			begin
				Randomize;
				
				Solution := Random(nbSolutions) + 1;
				
				a := tabPosPos[Solution].pp[popo.nbPos + 1].x;
				b := tabPosPos[Solution].pp[popo.nbPos + 1].y;
				carte_select := pl[a][b];
				
				Hasard := Random(tabPosPos[Solution].nbPos) + 1;
				
				a := tabPosPos[Solution].pp[Hasard].x;
				b := tabPosPos[Solution].pp[Hasard].y - 1;
				carte_prec := pl[a][b];
			end;
		

end;


/////////////////////////////////////////////////////////////////////////////////////////
// Quand la fin est possible, place les cartes de la pioche dans le plateau
Procedure Dilapider_La_Pioche (var pio : Pioche; var pl : Plateau);
var cartePioVisible, nbCartesPio, dc, k, variable : Integer;
	carte_prec, carte_select : Cartes;
begin

variable := 0;

repeat
	Trouver_CartePioche(pio, cartePioVisible, nbCartesPio);
		
		if cartePioVisible = 0 then
			cartePioVisible := 1;

	carte_select := pio[cartePioVisible];

	for k := 1 to 7 do
			begin

						dc := Nb_Cartes_Colonne(pl, k);
						carte_prec := pl[k][dc];
						
						if verif_couleur_jeu(carte_prec, carte_select) and verif_valeur_jeu(carte_prec, carte_select) then
							begin
								Deplacer_CartePioche(variable, carte_prec, carte_select, pio, pl);
							end;
			end;
			
until nbCartesPio = 0;

end;


/////////////////////////////////////////////////////////////////////////////////////////
// Quand la fin est possible, finir automatiquement
Procedure Fin_Automatique (var pio : Pioche; var pl : Plateau);
var carte_select : Cartes;
		dc, i : Integer;
begin
if Fin_Possible(pl) then
	begin	
		Dilapider_La_Pioche(pio, pl);
		repeat
			for i := 1 to 7 do
				begin

							dc := Nb_Cartes_Colonne(pl, i);
							
							if dc > 0 then
								begin
									carte_select := pl[i][dc];
									Fin_Auto_Une_Carte(carte_select, pl);
								end;
				end;
		until Fin_Du_Jeu(pl);
	end;
end;


/////////////////////////////////////////////////////////////////////////////////////////
// 
Procedure Ou_Mettre(carte_select : Cartes; pio : Pioche; bloque: Boolean; pl : Plateau; var popo : PositionsPossibles; var joh : Boolean);
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
			


			
end.
