Unit Initialisation;



Interface

// variables, types et structures

uses SDL, SDL_image, crt, sysutils;

Type Symbole = (coeur, carreau, pique, trefle);

Type Position = Record
	x : LongInt ;
	y : LongInt ;
end;

Type Indice = 1..52;


// Structure définie pour les cartes
Type Cartes = Record
	retournee : Boolean ;
	valeur : Integer ;
	couleur : Boolean ;
	sym : Symbole ;
	pos : Position ;
	ind : Indice;
	existe : Boolean;			// certaines cartes n'existent pas et sont là juste pour remplir le tableau
end;


Type Cartes_Restantes = set of Indice;

Type Pioche = Array[1..24] of Cartes;
Type Plateau = Array[1..7,1..21] of Cartes;

// Tableaux permettant de stocker l'état du jeu pour un tour donné pour le retour en arrière
Type SauvegardePlateau = Array[1..6] of Plateau;
Type SauvegardePioche = Array[1..6] of Pioche;


// Structure nécessaire pour l'interface graphique
Type TableauImages = Record
	Verso : PSDL_surface;
	Fond :PSDL_surface;
	RetourArriere : PSDL_surface;
	TabIm : Array[1..52] of PSDL_surface;
	TabBouton : Array[1..3] of PSDL_Surface;
	TabConfirmation : Array[1..3] of PSDL_Surface;
	TabHighlight : Array[1..13] of PSDL_Surface;
end;


// Structure qui permet de changer les constantes afin de les adapter à la résolution de l'écran
Type Constantes = Record
	E_cx, E_cy, Dx, Dy, Dyco, Dxco, Dypio, E_coy, w, l : Integer;
	TailleFenetreX, TailleFenetreY : Integer;
	Dxb, Dyb, E_b, TailleBoutonX, TailleBoutonY : Integer;
	ConfX, ConfY, ConfOui, ConfBoutonY, ConfTailleBoutonX, ConfTailleBoutonY, ConfEspaceBouton : Integer;
end;


// Structure utilisée pour stocker tous les coups possible pour une carte
Type PositionsPossibles = record
	pp : Array[1..7] of Position;
	exists : Boolean;
	nbPos : Integer;
end;



/////////////////////////////////////////////////////////////////////////////////////////
// Procédures et fonctions

Procedure initialiser_tout(var pl : Plateau; var pio : Pioche; var fenetre, ImageDeFond : PSDL_Surface; var images : TableauImages; var cst : Constantes);

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

Implementation

// Permet de connaître la definition de l'écran
Procedure TrouverDefinition (var fenetre : PSDL_Surface; var TailleEcran : TSDL_Rect);

begin
	SDL_Init(SDL_INIT_VIDEO);
	fenetre := SDL_SetVideoMode(0, 0, 32, SDL_FULLSCREEN);
	sdl_getcliprect(fenetre, @TailleEcran);
end;

/////////////////////////////////////////////////////////////////////////////////////////
//
Function Load(TailleEcran : TSDL_Rect; str : String) : PSDL_Surface;

var chemin : String;
	pchemin : pchar;
begin
	if TailleEcran.w > 1400 then
		begin
		chemin := 'Ressources/1080p/' + str + '.png';
		pchemin := StrAlloc(length(chemin) + 1);
		strPCopy(pchemin, chemin);
		end
	else
		begin
		chemin := 'Ressources/720p/' + str + '.png';
		pchemin := StrAlloc(length(chemin) + 1);
		strPCopy(pchemin, chemin);
		end;
	
	Load := IMG_Load(pchemin);
end;

/////////////////////////////////////////////////////////////////////////////////////////
// Iitialisation de la SDL
Procedure Lancement (TailleEcran : TSDL_Rect; var images : TableauImages);

var str, chemin : String;
	pimage : pchar;
	i : Integer;
	

begin
	images.RetourArriere := Load(TailleEcran, 'RetourArriere');

	images.fond := Load(TailleEcran, 'Fond');
	
	images.verso := Load(TailleEcran, 'Verso');
	
	images.TabBouton[1] := Load(TailleEcran, 'RetourClic');
	images.TabBouton[2] := Load(TailleEcran, 'AideClic');
	images.TabBouton[3] := Load(TailleEcran, 'MenuClic');
	
	
	images.TabConfirmation[1] := Load(TailleEcran, 'Confirmation');
	images.TabConfirmation[2] := Load(TailleEcran, 'ConfirmationOui');
	images.TabConfirmation[3] := Load(TailleEcran, 'ConfirmationNon');

	if TailleEcran.w > 1400 then
		chemin := 'Ressources/1080p/'
	else
		chemin := 'Ressources/720p/';
	
	for i:= 1 to 52 do
		begin
			str := chemin + 'Carte_' + IntToStr(i) + '.png';
			pimage := StrAlloc(length(str) + 1);
			strPCopy(pimage, str);
			images.TabIm[i] := IMG_Load(pimage);
		end;
		
	
	for i:= 1 to 13 do
		begin
			str := chemin + 'Highlight' + IntToStr(i) + '.png';
			pimage := StrAlloc(length(str) + 1);
			strPCopy(pimage, str);
			images.TabHighlight[i] := IMG_Load(pimage);
		end;
	
end;	

// Créée les cartes et leur assigne un nombre entre 1 et 52

Function FabriquerCartes(ind : Integer) : Cartes;

begin
	FabriquerCartes.retournee := False;
	FabriquerCartes.pos.x := 1;
	FabriquerCartes.pos.y := 1;	
	FabriquerCartes.ind := ind;
	FabriquerCartes.existe := True;
	if ind MOD 2 = 0
		then
			FabriquerCartes.couleur := True
		else
			FabriquerCartes.couleur := False;
	FabriquerCartes.valeur := (1*(ind- ind MOD 4 + 1)  + 3) MOD 4;
	case (ind MOD 4) of
		1 : begin
				FabriquerCartes.sym := pique;
				FabriquerCartes.valeur := trunc((ind + 3)/4);
			end;
		2 : begin
				FabriquerCartes.sym := coeur;
				FabriquerCartes.valeur := trunc((ind + 2)/4);
			end;
		3 : begin
				FabriquerCartes.sym := trefle;
				FabriquerCartes.valeur := trunc((ind + 1)/4);
			end;
		0 : begin
				FabriquerCartes.sym := carreau;
				FabriquerCartes.valeur := trunc(ind/4);
			end;
	end;
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Remplit le tableau qui correspond au plateau de jeu (= distribue les cartes)

Procedure RemplirTableau(var pl : Plateau; var pio : Cartes_Restantes);

var i, j : Integer;
	ind : Indice;

begin
	for j:= 1 to 21 do							// chaque case du tableau ne comporte pas carte
		begin
			for i:= 1 to 7 do
				pl[i][j].existe := False;
		end;
	
	for i:= 1 to 4 do							// 1ère ligne = les cartes "0" pour mettre avant les AS du haut
		begin
			pl[i][1].valeur := 0;
			pl[i][1].pos.x := i;
			pl[i][1].pos.y := 1;
			if (i MOD 2) = 1 then
				pl[i][1].couleur := false
			else
				pl[i][1].couleur := true;
			case (i MOD 4) of
				1 : pl[i][1].sym := pique;
				2 : pl[i][1].sym := coeur;
				3 : pl[i][1].sym := trefle;
				0 : pl[i][1].sym := carreau;
			end;
		end;
		
	for i:= 1 to 7 do							// ligne 2 : carte de valeur "14" pour pouvoir ensuite placer un roi en dessous
		begin
			pl[i][2].valeur := 14;
			pl[i][2].pos.x := i;
			pl[i][2].pos.y := 2;	
			pl[i][2].retournee := true;
		end;
		
		
			
			
	i:=0;
	repeat
		i := i + 1;
		Include(pio, i);
	until i = 52;
	randomize;
		for j:= 3 to 9 do
			begin
				for i:=(j-2) to 7 do
					begin
						repeat
							ind := random(52) + 1;
						until ind in pio;
						Exclude(pio, ind);
						pl[i][j] := FabriquerCartes(ind);
						pl[i][j].pos.x := i;
						pl[i][j].pos.y := j;
						if i = j-2 then
							pl[i][j].retournee := True;
					end;
			end;
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Crée un tableau avec la pioche

Procedure FabriquePioche(pio : Cartes_Restantes; var tpio : Pioche);

var a, i : Integer;
	ind : set of 1..24;

begin
	for i:= 1 to 24 do
		Include(ind, i);
	
	randomize;
	for i:= 1 to 52 do
		begin
			if i in pio then
				begin
					repeat
						a := random(24) + 1;
					until a in ind;
					tpio[a] := FabriquerCartes(i);
					Exclude(ind, a);
				end;
		end;
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Initialise la partie

Procedure Init(var pl : Plateau; var tpio : Pioche);

var pio : Cartes_Restantes;

begin
	RemplirTableau(pl, pio);
	FabriquePioche(pio, tpio);
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Définit les constantes en fonction de la taille de l'écran

Procedure InitConstantes(TailleEcran : TSDL_Rect; var cst : Constantes);

begin
	if TailleEcran.w > 1400 then
		begin
			cst.E_cx := 38;		//Espacement en pixels entre 2 colonne de cartes
			cst.E_cy := 30;		//Espacement en pixels entre 2 cartes l'une sur l'autre
			cst.Dx := 78; 		//Espacement en pixels entre le bord et la première colonne (x)
			cst.Dy := 346;		//Espacement en pixels entre le bord et la première colonne (y)
			cst.Dyco := 108; 	//Espacement en pixels entre le bord et la première carte sur le côté (y)
			cst.Dxco := 1544; 	//Espacement en pixels entre le bord et les cartes sur le côté (x)
			cst.Dypio := 52; 	//Espacement en pixels entre le bord et la pioche (y)
			cst.E_coy := 20; 	//Espacement en pixels entre 2 cartes sur le côté
			cst.w := 154; 		// Largeur d'une carte en pixels
			cst.l := 202; 		// Longueur d'une carte en pixels

			cst.Dxb := 1011;		//Espacement en pixels entre le bord et le bouton retour (x)
			cst.Dyb := 132;		//Espacement en pixels entre le bord et les boutons (y) 
			cst.E_b := 20;		//Espacement en pixels entre 2 boutons (x)
			cst.TailleBoutonX := 82;
			cst.TailleBoutonY := 60;

			cst.TailleFenetreX := 1920;
			cst.TailleFenetreY := 1080;

			cst.ConfX := 594;
			cst.ConfY := 203;
			cst.ConfOui := 196;
			cst.ConfBoutonY := 109;
			cst.ConfTailleBoutonX := 74;
			cst.ConfTailleBoutonY := 38;
			cst.ConfEspaceBouton := 48;
		end
	else
		begin
			cst.E_cx := 25;		//Espacement en pixels entre 2 colonne de cartes
			cst.E_cy := 20;		//Espacement en pixels entre 2 cartes l'une sur l'autre
			cst.Dx := 52; 		//Espacement en pixels entre le bord et la première colonne (x)
			cst.Dy := 230;		//Espacement en pixels entre le bord et la première colonne (y)
			cst.Dyco := 72; 	//Espacement en pixels entre le bord et la première carte sur le côté (y)
			cst.Dxco := 1029; 	//Espacement en pixels entre le bord et les cartes sur le côté (x)
			cst.Dypio := 34; 	//Espacement en pixels entre le bord et la pioche (y)
			cst.E_coy := 13; 	//Espacement en pixels entre 2 cartes sur le côté
			cst.w := 102; 		// Largeur d'une carte en pixels
			cst.l := 134; 		// Longueur d'une carte en pixels

			cst.Dxb := 674;		//Espacement en pixels entre le bord et le bouton retour (x)
			cst.Dyb := 88;		//Espacement en pixels entre le bord et les boutons (y) 
			cst.E_b := 13;		//Espacement en pixels entre 2 boutons (x)
			cst.TailleBoutonX := 54;
			cst.TailleBoutonY := 40;

			cst.TailleFenetreX := 1280;
			cst.TailleFenetreY := 720;

			cst.ConfX := 396;
			cst.ConfY := 135;
			cst.ConfOui := 130;
			cst.ConfBoutonY := 72;
			cst.ConfTailleBoutonX := 49;
			cst.ConfTailleBoutonY := 25;
			cst.ConfEspaceBouton := 32;
		end;
end;

/////////////////////////////////////////////////////////////////////////////////////////
// initialise tout
Procedure initialiser_tout(var pl : Plateau; var pio : Pioche; var fenetre, ImageDeFond : PSDL_Surface; var images : TableauImages; var cst : Constantes);
 var TailleEcran : TSDL_Rect;
begin
	Init(pl, pio);
	TrouverDefinition(fenetre, TailleEcran);
	writeln('TailleEcran : ', TailleEcran.w, TailleEcran.h);
	InitConstantes(TailleEcran, cst);
	Lancement(TailleEcran, images);
	writeln('lancement de la sdl');

end;

end.
		
	






