unit IHM;

Interface

uses Initialisation, Selection, outils, SDL, SDL_image, SDL_ttf, crt, sysutils;

/////////////////////////////////////////////////////////////////////////////////////////
// Procedures et fonctions

Procedure AffichePioche(cst : Constantes; pio : Pioche; images : TableauImages; fenetre : PSDL_Surface);
Procedure AfficheCote(cst : Constantes; pl : Plateau; images : TableauImages; fenetre : PSDL_Surface);

Procedure CreationImage(cst : Constantes; pl : Plateau; pio : Pioche; images : TableauImages; fenetre : PSDL_Surface; var ImageDeFond : PSDL_Surface);
Procedure AffichageDeplacable(cst : Constantes; pl : Plateau; pio : Pioche; ImageDeFond : PSDL_Surface; images : TableauImages; fenetre : PSDL_Surface);
Procedure CreationImagePendantDeplacement(cst : Constantes; cliccartepioche : Boolean; carte_select : Cartes; pl : Plateau; pio : Pioche; images : TableauImages; ImageDeFond : PSDL_Surface; var ImageIntermediaire : PSDL_Surface);

Procedure AffichageComplet (cst : Constantes; pl : Plateau; pio: Pioche; images : TableauImages; fenetre : PSDL_Surface);
Procedure DemandeConfirmation(cst : Constantes; images : TableauImages; fenetre : PSDL_Surface; var reponse : Boolean);

Procedure GlisserCarte(cst : Constantes; pClic : Position; pl: plateau; pio : Pioche; cliccartepioche : Boolean; carte_select : Cartes; images : TableauImages; fenetre: PSDL_Surface; ImageDeFond : PSDL_Surface; var ClicUp : Position);
Procedure NePasRevenirEnArriere (cst : Constantes; images : TableauImages; fenetre : PSDL_Surface);
Procedure AffichageClicBouton (cst : Constantes; Numero : Integer; images : TableauImages; fenetre : PSDL_Surface);
Procedure AffichageConfirmation (cst : Constantes; Numero : Integer; images : TableauImages; fenetre : PSDL_Surface);

Procedure QuitterLaSDL(images : TableauImages);


/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

Implementation


/////////////////////////////////////////////////////////////////////////////////////////
// Affichage du plateau de jeu
Procedure AffichePlateau(cst : Constantes; pl : Plateau; images : TableauImages; var fenetre : PSDL_Surface);

var i, j, k : LongInt;
	destination : TSDL_Rect;
	

begin
	destination.x := 0;
	destination.y := 0;
	sdl_blitsurface(images.fond, nil, fenetre, @destination);

	
	for i:= 1 to 7 do
		begin
			k := Nb_Cartes_Colonne(pl, i);
			for j:= 3 to k do
				begin
					destination.x := cst.Dx + (i-1)*(cst.w + cst.E_cx);
					destination.y := cst.Dy + (j-3)*cst.E_cy;
					if (pl[i][j].retournee) and (pl[i][j].existe) then
						sdl_blitsurface(images.TabIm[pl[i][j].ind], nil, fenetre, @destination)
					else
						if not (pl[i][j].retournee) then
							sdl_blitsurface(images.verso, nil, fenetre, @destination);	
				end;
		end;

end;


/////////////////////////////////////////////////////////////////////////////////////////
// Affiche les cartes face cachées du plateau
Procedure AffichePlateauNonRetourne(cst : Constantes; pl : Plateau; images : TableauImages; var ImageDeFond : PSDL_Surface);

var i, j, k : LongInt;
	destination : TSDL_Rect;
	

begin
	destination.x := 0;
	destination.y := 0;
	sdl_blitsurface(images.fond, nil, ImageDeFond, @destination);

	
	for i:= 1 to 7 do
		begin
			k := Nb_Cartes_Colonne(pl, i);
			for j:= 3 to k do
				begin
					destination.x := cst.Dx + (i-1)*(cst.w + cst.E_cx);
					destination.y := cst.Dy + (j-3)*cst.E_cy;
					if not (pl[i][j].retournee) and (pl[i][j].existe) then
						sdl_blitsurface(images.verso, nil, ImageDeFond, @destination);
				end;
		end;
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Affiche les cartes face visible du plateau
Procedure AffichePlateauRetourne(cst : Constantes; pl : Plateau; images : TableauImages; fenetre : PSDL_Surface);

var i, j, k : LongInt;
	destination : TSDL_Rect;
	

begin
	for i:= 1 to 7 do
		begin
			k := Nb_Cartes_Colonne(pl, i);
			for j:= 3 to k do
				begin
					destination.x := cst.Dx + (i-1)*(cst.w + cst.E_cx);
					destination.y := cst.Dy + (j-3)*cst.E_cy;
					if (pl[i][j].retournee) and (pl[i][j].existe) then
						sdl_blitsurface(images.TabIm[pl[i][j].ind], nil, fenetre, @destination)
				end;
		end;
end;

/////////////////////////////////////////////////////////////////////////////////////////
// 
Procedure AffichePiocheEnDessous(cst : Constantes; pio : Pioche; images : TableauImages; var ImageDeFond : PSDL_Surface);

var destination : TSDL_Rect;
	i, n : Integer;

begin
	Trouver_CartePioche(pio, i, n);
	if not pio[n].retournee then
		begin
			destination.x := cst.Dx;
			destination.y := cst.Dypio;
			sdl_blitsurface(images.verso, nil, ImageDeFond, @destination);
		end;
		
	
	destination.x := cst.Dx + cst.w + cst.E_cx;
	destination.y := cst.Dypio;
	
	writeln('i : ', i);
	
	if (i > 1) and pio[i-1].existe then
		begin
		writeln('pioche en dessous');
		sdl_blitsurface(images.TabIm[pio[i-1].ind], nil, ImageDeFond, @destination);
		end;

end;


/////////////////////////////////////////////////////////////////////////////////////////
// 
Procedure AfficheCoteEnDessous(cst : Constantes; pl : Plateau; images : TableauImages; ImageDeFond : PSDL_Surface);

var i : Integer;
	destination : TSDL_Rect;

begin
	for i:= 1 to 4 do
		begin
			if pl[i][1].valeur > 1 then
				begin
					destination.x := cst.Dxco;
					destination.y := cst.Dyco + (i-1)*(cst.l + cst.E_coy);
					sdl_blitsurface(images.TabIm[pl[i][1].ind - 4], nil, ImageDeFond, @destination);
				end;
		end;
end;


/////////////////////////////////////////////////////////////////////////////////////////
// Affiche la pioche
Procedure AffichePioche(cst : Constantes; pio : Pioche; images : TableauImages; fenetre : PSDL_Surface);

var destination : TSDL_Rect;
	i, n : Integer;

begin
	Trouver_CartePioche(pio, i, n);
	destination.x := cst.Dx + cst.w + cst.E_cx;
	destination.y := cst.Dypio;
	if (i <> 0) and pio[i].existe then
		sdl_blitsurface(images.TabIm[pio[i].ind], nil, fenetre, @destination);

end;

/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure CreationImage(cst : Constantes; pl : Plateau; pio : Pioche; images : TableauImages; fenetre : PSDL_Surface; var ImageDeFond : PSDL_Surface);

var destination : TSDL_Rect;

begin
	sdl_getcliprect(fenetre, @destination);
    ImageDeFond := SDL_CreateRGBSurface(0, destination.w, destination.h, 32, 0, 0, 0, 0);
    AffichePlateauNonRetourne(cst, pl, images, ImageDeFond);
    AffichePiocheEnDessous(cst, pio, images, ImageDeFond);
    AfficheCoteEnDessous(cst, pl, images, ImageDeFond);
end;


/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure AffichageDeplacable(cst : Constantes; pl : Plateau; pio : Pioche; ImageDeFond : PSDL_Surface; images : TableauImages; fenetre : PSDL_Surface);

var destination : TSDL_Rect;

begin
	sdl_getcliprect(fenetre, @destination);
	sdl_blitsurface(ImageDeFond, nil, fenetre, @destination);
	AffichePlateauRetourne(cst, pl, images, fenetre);
	AfficheCote(cst, pl, images, fenetre);
	AffichePioche(cst, pio, images, fenetre);
end;


/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure CreationImagePendantDeplacement(cst : Constantes; cliccartepioche : Boolean; carte_select : Cartes; pl : Plateau; pio : Pioche; images : TableauImages; ImageDeFond : PSDL_Surface; var ImageIntermediaire : PSDL_Surface);

var destination : TSDL_Rect;
	plIntermediaire : Plateau;

begin
    ImageIntermediaire := SDL_CreateRGBSurface(0, cst.TailleFenetreX, cst.TailleFenetreY, 32, 0, 0, 0, 0);
    
    destination.x := 0;
    destination.y := 0;
    
    sdl_blitsurface(ImageDeFond, nil, ImageIntermediaire, @destination);
    plIntermediaire := pl;


	if cliccartepioche then
		begin
			AffichePlateauRetourne(cst, pl, images, ImageIntermediaire);
			AfficheCote(cst, pl, images, ImageIntermediaire);
		end
	else
		begin
			if carte_select.pos.y = 1 then
				begin
					AffichePlateauRetourne(cst, pl, images, ImageIntermediaire);
					AffichePioche(cst, pio, images, ImageIntermediaire);
				end
			else
				begin
					AfficheCote(cst, pl, images, ImageIntermediaire);
					AffichePioche(cst, pio, images, ImageIntermediaire);
					plIntermediaire[carte_select.pos.x][carte_select.pos.y].existe := False;
					AffichePlateauRetourne(cst, plIntermediaire, images, ImageIntermediaire);
				end;
		end;

end;

/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure AffichageIntermediaire(cst : Constantes; pl : Plateau; pio : Pioche; cliccartepioche : Boolean; carte_select : Cartes; images : TableauImages; fenetre : PSDL_Surface);

var plIntermediaire : Plateau;
	pioIntermediaire : Pioche;
	i, n : Integer;
	destination : TSDL_RECT;
	
begin
	plIntermediaire := pl;
	pioIntermediaire := pio;

	if cliccartepioche then
		begin
			Trouver_CartePioche(pio, i, n);
			pioIntermediaire[i].retournee := False;
			pioIntermediaire[i - 1].retournee := True;
			if i = n then
				begin
					AffichePlateau(cst, pl, images, fenetre);
					destination.x := cst.Dx + cst.w + cst.E_cx;
					destination.y := cst.Dypio;
					if (i <> 0) and pioIntermediaire[i-1].existe then
						sdl_blitsurface(images.TabIm[pioIntermediaire[i-1].ind], nil, fenetre, @destination);
					AfficheCote(cst, pl, images, fenetre);
					exit;
				end;
		end
	else
		begin
			if carte_select.pos.y = 1 then
				plIntermediaire[carte_select.pos.x][carte_select.pos.y].ind -= 4
			else
				plIntermediaire[carte_select.pos.x][carte_select.pos.y].existe := False;
		end;
	AffichageComplet(cst, plIntermediaire, pioIntermediaire, images, fenetre);
	
	//d.x := 0;
	//d.y := 0;
	//sdl_blitsurface(fenetreIntermediaire, nil, fenetre, @d);
	sdl_flip(fenetre);
		
end;


/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure AfficheCote(cst : Constantes; pl : Plateau; images : TableauImages; fenetre : PSDL_Surface);

var i : Integer;
	destination : TSDL_Rect;

begin
	for i:= 1 to 4 do
		begin
			if pl[i][1].valeur <> 0 then
				begin
					destination.x := cst.Dxco;
					destination.y := cst.Dyco + (i-1)*(cst.l + cst.E_coy);
					sdl_blitsurface(images.TabIm[pl[i][1].ind], nil, fenetre, @destination);
				end;
		end;
end;
	


/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure AffichageComplet (cst : Constantes; pl : Plateau; pio: Pioche; images : TableauImages; fenetre : PSDL_Surface);

begin
	AffichePlateau(cst, pl, images, fenetre);
	AffichePioche(cst, pio, images, fenetre);
	AfficheCote(cst, pl, images, fenetre);
end;

/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure GlisserCarte(cst : Constantes; pClic : Position; pl: plateau; pio : Pioche; cliccartepioche : Boolean; carte_select : Cartes; images : TableauImages; fenetre: PSDL_Surface; ImageDeFond : PSDL_Surface; var ClicUp : Position);

var destintermediaire, destination, destlight : TSDL_Rect;
	p : Position;
	i, nb, DistanceCarteSourisX, DistanceCarteSourisY : Integer;
	ImageIntermediaire : PSDL_Surface;


begin
	writeln('debut de glissercarte');

	destintermediaire.x := 0;
	destintermediaire.y := 0;
	
	CreationImagePendantDeplacement(cst, cliccartepioche, carte_select, pl, pio, images, ImageDeFond, ImageIntermediaire);
	sdl_blitsurface(ImageIntermediaire, nil, fenetre, @destintermediaire);
	sdl_flip(fenetre);
	
	repeat
		SDL_getmousestate(p.x, p.y);
		sdl_blitsurface(ImageIntermediaire, nil, fenetre, @destintermediaire);
		sdl_flip(fenetre);
		
		if not cliccartepioche then
			begin
				if carte_select.pos.y = 1 then 								// cartes sur le côté
					begin
						DistanceCarteSourisX := pClic.x - cst.Dxco;
						DistanceCarteSourisY := pClic.y - (cst.Dyco + (carte_select.pos.x - 1) * (cst.l + cst.E_coy));
						
						destination.x := p.x - DistanceCarteSourisX;
						destination.y := p.y - DistanceCarteSourisY;
						sdl_blitsurface(images.TabIm[carte_select.ind], nil, fenetre, @destination);
						sdl_blitsurface(images.TabHighlight[1], nil, fenetre, @destination);
					end
				else														// sur le plateau
					begin
						nb := Nb_Cartes_Colonne(pl, carte_select.pos.x);
						DistanceCarteSourisX := pClic.x - (cst.Dx + (carte_select.pos.x - 1) * (cst.E_cx + cst.w));
						DistanceCarteSourisY := pClic.y - (cst.Dy + (carte_select.pos.y - 3) * cst.E_cy);
						for i:= 0 to nb - carte_select.pos.y do
							begin
								destination.x := p.x - DistanceCarteSourisX;
								destination.y := p.y - DistanceCarteSourisY + i*cst.E_cy;
								if pl[carte_select.pos.x][carte_select.pos.y + i].retournee then
									sdl_blitsurface(images.TabIm[pl[carte_select.pos.x][carte_select.pos.y + i].ind], nil, fenetre, @destination);
							end;
						destlight.x := destination.x;
						destlight.y := destination.y - cst.E_cy*(nb - carte_select.pos.y);
						sdl_blitsurface(images.TabHighlight[nb - carte_select.pos.y + 1], nil, fenetre, @destlight);
					end;

			end
		else																// carte de la pioche
			begin
				destination.x := p.x - (pClic.x - (cst.Dx + cst.w + cst.E_cx));
				destination.y := p.y - (pClic.y - cst.Dypio);
				sdl_blitsurface(images.TabIm[carte_select.ind], nil, fenetre, @destination);
				sdl_blitsurface(images.TabHighlight[1], nil, fenetre, @destination);
			end;
			
		sdl_flip(fenetre);
		sdl_delay(30);
	
	until PositionRelacheClic.x <> -1;
	
	sdl_freesurface(ImageIntermediaire);	
	ClicUp := PositionRelacheClic;
	writeln('ClicUp : ', ClicUp.x, ' ', ClicUp.y);
	
	writeln('fin de glisser carte');
		
end;

/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure NePasRevenirEnArriere (cst : Constantes; images : TableauImages; fenetre : PSDL_Surface);

var destination : TSDL_Rect;

begin
	destination.x := cst.TailleFenetreX - (3*cst.TailleFenetreX) div 2;
	destination.y := cst.TailleFenetreY - (2*cst.TailleFenetreY) div 3;
	
	sdl_blitsurface(images.RetourArriere, nil, fenetre, @destination);
end;


/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure AffichageClicBouton (cst : Constantes; Numero : Integer; images : TableauImages; fenetre : PSDL_Surface);

var destination : TSDL_Rect;

begin
	destination.x := cst.Dxb + (Numero-1)*(cst.TailleBoutonX + cst.E_b);
	destination.y := cst.Dyb;
	
	SDL_BlitSurface(images.TabBouton[Numero], nil, fenetre, @destination);
end;


/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure AffichageConfirmation (cst : Constantes; Numero : Integer; images : TableauImages; fenetre : PSDL_Surface);

var destination : TSDL_Rect;

begin
	destination.x := (cst.TailleFenetreX - cst.ConfX) div 2;
	destination.y := (cst.TailleFenetreY - cst.ConfY) div 2;
	
	SDL_BlitSurface(images.TabConfirmation[Numero], nil, fenetre, @destination);
end;

/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure DemandeConfirmation(cst : Constantes; images : TableauImages; fenetre : PSDL_Surface; var reponse : Boolean);

var  p : Position;
	clicdanscadre : Boolean;
	pConfx, pConfy : Integer;

begin
	clicdanscadre := False;
	reponse := False;
	AffichageConfirmation(cst, 1, images, fenetre);
	sdl_flip(fenetre);
	
	repeat
		p := PositionDernierClic;
		pConfx := (cst.TailleFenetreX - cst.ConfX) div 2;
		pConfy := (cst.TailleFenetreY - cst.ConfY) div 2;
		if (((p.x >= pConfX + cst.ConfOui) and (p.x <= pConfx + cst.ConfOui + cst.ConfTailleBoutonX)) or ((p.x >= pConfx + cst.ConfOui + cst.ConfTailleBoutonX + cst.ConfEspaceBouton) and (p.x <= pConfx + cst.ConfOui + 2*cst.ConfTailleBoutonX + cst.ConfEspaceBouton))) and ((p.y >= pConfy + cst.ConfBoutonY) and (p.y <= pConfy + cst.ConfBoutonY + cst.ConfTailleBoutonY)) then
			clicdanscadre := True;
	until clicdanscadre;
	if (p.x >= pConfX + cst.ConfOui) and (p.x <= pConfx + cst.ConfOui + cst.ConfTailleBoutonX) then
		reponse := True;
		
	if reponse then
		begin
			AffichageConfirmation(cst, 2, images, fenetre);
			sdl_flip(fenetre);
			Delay(100);
			QuitterLaSDL(images);
			halt;
		end
	else
		begin
			AffichageConfirmation(cst, 3, images, fenetre);
			sdl_flip(fenetre);
			Delay(100);
		end
end;

/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure Timer(images : TableauImages; fenetre : PSDL_Surface);

var temps : Real;
	time : String;
	texte : PSDL_Surface;
	police : PTTF_Font;
	couleur : TSDL_color;
	destination : TSDL_Rect;

begin
	TTF_Init;
	police := TTF_OPENFONT('Ressources/Vogue.ttf', 20);
	couleur.r := 0;
	couleur.g := 0;
	couleur.b := 0;
	temps := SDL_GetTicks;
	time := FormatFloat('0.####', temps);
	writeln(time);
	texte := TTF_RenderText_Blended(police, 'time', couleur);
	writeln(temps);
	destination.x := 671;
	destination.y := 123;
	sdl_blitsurface(texte, nil, fenetre, @destination);
end;

/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure AnimationGagner;

begin

end;


/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure DeplacementAutomatique(carte_depart, carte_arrivee : Cartes);

begin

end;


/////////////////////////////////////////////////////////////////////////////////////////
//
Procedure QuitterLaSDL(images : TableauImages);

var i: Integer;

begin
	for i := 1 to 52 do
		sdl_freesurface(images.TabIm[i]);
		
	for i := 1 to 3 do
		begin
			sdl_freesurface(images.TabBouton[i]);
			sdl_freesurface(images.TabConfirmation[i]);
		end;
	
	for i := 1 to 13 do
		sdl_freesurface(images.TabHighlight[i]);
			
	sdl_freesurface(images.verso);
	sdl_freesurface(images.fond);
	sdl_freesurface(images.RetourArriere);
	
	SDL_quit;
end;


end.
