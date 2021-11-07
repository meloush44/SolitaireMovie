Unit Outils;

Interface

uses Initialisation, sysutils, SDL, SDL_image;

// Fonctions et procédures

Function verif_couleur_jeu (carte_prec, carte_select : Cartes): Boolean;
Function verif_valeur_jeu (carte_prec, carte_select : Cartes): Boolean;
Function verif_couleur_haut (carte_prec, carte_select : Cartes): Boolean;
Function verif_valeur_haut (carte_prec, carte_select : Cartes): Boolean;
Function Nb_Cartes_Colonne(pl : Plateau; colonne : Integer) : Integer;
Function Jeu_ou_Haut (p : Position; cst : Constantes) : Boolean;

Procedure Trouver_CartePioche(pio : Pioche; var i, n : Integer);
Function PositionDernierClic : Position;
Function PositionRelacheClic : Position;
Procedure QuelBouton (retour, aide, fin : Boolean; var Numero : Integer);

Procedure Stockage (pl : Plateau; pio : Pioche ; var tPl : SauvegardePlateau; var tPio : SauvegardePioche; var nbPlStock : Integer);
Procedure Annuler_Coup(var nbPlStock  : Integer ; var tPl : SauvegardePlateau; var tPio : SauvegardePioche; var pl : Plateau; var pio : Pioche);

Function Fin_Possible (pl : Plateau) : Boolean;
Procedure Fin_Auto_Une_Carte (carte_select : Cartes; var pl : plateau);

Function Fin_Du_Jeu(pl : Plateau) : Boolean;
/////////////////////////////////////////////////////////////////////////////////////////
Implementation

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
// compte le nombre de cartes présentes dans la pioche (n) et la position de la carte retournée (i)	
Procedure Trouver_CartePioche(pio : Pioche; var i, n : Integer);

var j : Integer;

begin
	i := 0;
	n := 0;
	for j := 1 to 24 do 
		begin
			if pio[j].existe then
				n += 1;
			if pio[j].retournee then
				i := j
		end;
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Renvoie la position du dernier clic
Function PositionDernierClic : Position;
var event : TSDL_event;
	
begin
	PositionDernierClic.x := -1;
	PositionDernierClic.y := -1;
	sdl_pollEvent(@event);
	if event.type_ = SDL_mouseButtonDown then 
		sdl_getMouseState(PositionDernierClic.x, PositionDernierClic.y);
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Renvoie la position à laquelle le joueur a relâché la souris
Function PositionRelacheClic : Position;
var event : TSDL_event;

begin
	PositionRelacheClic.x := -1;
	PositionRelacheClic.y := -1;
	sdl_pollEvent(@event);
	if event.type_ = SDL_mouseButtonUp then 
		sdl_getMouseState(PositionRelacheClic.x, PositionRelacheClic.y);
end;


/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure QuelBouton (retour, aide, fin : Boolean; var Numero : Integer);

begin
	Numero := 0;
	if retour then
		Numero := 1;
	if aide then
		Numero := 2;
	if fin then
		Numero := 3;
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Stock l'état du plateau et de la pioche afin de pouvoir revenir en arrière
Procedure Stockage (pl : Plateau; pio : Pioche ; var tPl : SauvegardePlateau; var tPio : SauvegardePioche; var nbPlStock : Integer);
var i : Integer;
begin

	if nbPlStock <= 5 then 					//On a choisi de pouvoir retourner seulement 5 tours en arrière 
		begin
			nbPlStock += 1;
			tPl[nbPlStock] := pl;
			tPio[nbPlStock] := pio;
			
		end
	else 
		begin
			for i := 1 to 5 do
				begin
					tPl[i] := tPl[i + 1];
					tPio[i] := tPio[i + 1];
				end;
			tPl[6] := pl;
			tPio[6] := pio;
			nbPlStock := 6;
		end;

end;


/////////////////////////////////////////////////////////////////////////////////////////
// Permet de retourner en arrière
Procedure Annuler_Coup(var nbPlStock  : Integer ; var tPl : SauvegardePlateau; var tPio : SauvegardePioche; var pl : Plateau; var pio : Pioche);

begin
	if (nbPlStock > 1) and (nbPlStock <= 6) then
		begin
			nbPlStock -= 1;
			pl := tPl[nbPlStock];
			pio := tPio[nbPlStock];
		end;
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

/////////////////////////////////////////////////////////////////////////////////////////
// Permet de déplacer automatiquement une carte vers le côté

Procedure Fin_Auto_Une_Carte (carte_select : Cartes; var pl : plateau);
var k : Integer;
	carte_prec : Cartes;
begin
	for k := 1 to 4 do
		begin
			carte_prec := pl[k][1];
			if verif_couleur_haut(carte_prec, carte_select) and verif_valeur_haut(carte_prec, carte_select) then
				begin
					pl[k][1] := carte_select;
					pl[carte_select.pos.x][carte_select.pos.y].existe := False;
				end;
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
	






	
END.

