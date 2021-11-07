Unit verif;

Interface

uses Initialisation, sysutils;

/////////////////////////////////////////////////////////////////////////////////////////
// Fonctions et procédures

Function verif_couleur_jeu (carte_prec, carte_select : Cartes): Boolean;
Function verif_valeur_jeu (carte_prec, carte_select : Cartes): Boolean;
Function verif_couleur_haut (carte_prec, carte_select : Cartes): Boolean;
Function verif_valeur_haut (carte_prec, carte_select : Cartes): Boolean;
Function Nb_Cartes_Colonne(pl : Plateau; colonne : Integer) : Integer;
Function Jeu_ou_Haut (p : Position; cst : Constantes) : Boolean;
Function Emplaclicable (pl : PLateau; p : Position; cst : Constantes) : Boolean;
Function Emplarelachable (pl : PLateau; p : Position; cst : Constantes) : Boolean;
Function Fin_Du_Jeu(pl : Plateau) : Boolean;
Function Fin_Possible (pl : Plateau) : Boolean;

Implementation

/////////////////////////////////////////////////////////////////////////////////////////
// Fonctions de vérification

Function verif_couleur_jeu (carte_prec, carte_select : Cartes): Boolean;
	begin
		verif_couleur_jeu := True;
		if carte_prec.couleur = carte_select.couleur then
			verif_couleur_jeu := False	
	end;
	
Function verif_valeur_jeu (carte_prec, carte_select : Cartes): Boolean;
	begin
		verif_valeur_jeu := False;
		if carte_prec.valeur = carte_select.valeur + 1 then
			verif_valeur_jeu := True	
	end;
	
Function verif_couleur_haut (carte_prec, carte_select : Cartes): Boolean;
	begin
		verif_couleur_haut := False;
		if carte_prec.sym = carte_select.sym then
			verif_couleur_haut := True	
	end;

Function verif_valeur_haut (carte_prec, carte_select : Cartes): Boolean;
	begin
		verif_valeur_haut := False;
		if carte_prec.valeur = carte_select.valeur -1 then
			verif_valeur_haut := True
	end;	


/////////////////////////////////////////////////////////////////////////////////////////
// Renvoie le nombre de cartes d'une colonne

Function Nb_Cartes_Colonne(pl : Plateau; colonne : Integer) : Integer;

var i : Integer;

begin
	i:= 2;
		repeat
			i:= i + 1;
		until not (pl[colonne][i].existe);
		Nb_Cartes_Colonne := i-1; 										// i numéro de ligne de la dernière carte de la colonne
end;



/////////////////////////////////////////////////////////////////////////////////////////
// Vérifie si le joueur clique dans la partie jeu ou à côté

Function Jeu_ou_Haut (p : Position; cst : Constantes) : Boolean;			// Jeu ou haut est faux pour les cartes du cote (vrai pour le plateau)

begin
	Jeu_ou_Haut := True;
	if p.x > cst.Dxco then
		Jeu_ou_Haut := False;
		
	if p.y = 1 then
		begin
		Jeu_ou_Haut := False;
		end;

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
// Vérifie si le joueur a fini le jeu

Function Fin_Du_Jeu(pl : Plateau) : Boolean;

var i, fin : Integer;

begin
	Fin_Du_Jeu := False;
	fin := 0;
	for i:= 1 to 4 do
		begin
			if (pl[i][1].valeur = 13) then
				fin += 1;
		end;
	if fin = 4 then
		Fin_Du_Jeu := True;
end;
			
/////////////////////////////////////////////////////////////////////////////////////////
// Vérifie si toutes les cartes sont retournées

Function Fin_Possible (pl : Plateau) : Boolean;
var i,j : Integer;
begin
Fin_Possible := True;

	for i := 1 to 7 do
		begin
			for j := 1 to i do 
				begin
					if not pl[i][j].retournee then
						Fin_Possible := False;
				end;
		end;

end;
	

end.
