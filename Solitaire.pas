program Solitaire;

uses Selection, Initialisation, outils, ihm, SDL, SDL_image, crt, sysutils;



Procedure Partie ;

var pl : Plateau;
	pio : Pioche;
	cp, cs : Cartes;
	images : TableauImages;
	fenetre, ImageDeFond : PSDL_Surface;
	v, clicretournepioche, cliccartepioche, joh1, joh2, tupeuxcliquer, tupeuxrelacher, clicsimple, fin, retour, aide, reponse : Boolean;
	ClicUp, pClic : Position;
	tPl : SauvegardePlateau;
	tPio : SauvegardePioche;
	nbPlStock, Numero, choixDiff : Integer;
	cst : Constantes;


begin

initialiser_tout(pl, pio, fenetre, ImageDeFond, images, cst);

	CreationImage(cst, pl, pio, images, fenetre, ImageDeFond);
	AffichageDeplacable(cst, pl, pio, ImageDeFond, images, fenetre);
	SDL_flip(fenetre);
	
	fin := False;
	nbPlStock := 0;
	choixDiff := 2;
			
	Stockage(pl, pio, tPl, tPio, nbPlStock);


	repeat
		CreationImage(cst, pl, pio, images, fenetre, ImageDeFond);
		AffichageDeplacable(cst, pl, pio, ImageDeFond, images, fenetre);
		SDL_flip(fenetre);
		CliquerCarte(cst, pl, pio, cs, joh1, tupeuxcliquer, clicsimple, fin, retour, aide, clicretournepioche, cliccartepioche, pClic);
		
		if tupeuxcliquer then
			begin
				if clicsimple then
					JusteUnClic(choixDiff, retour, fin, aide, clicretournepioche, pl, pio, nbPlStock, tPl, tPio)
				else
					begin
						GlisserCarte(cst, pClic, pl, pio, cliccartepioche, cs, images, fenetre, ImageDeFond, ClicUp);
						RelacherCarte(cst, pl, ClicUp, cp, joh2, tupeuxrelacher);
						if tupeuxrelacher then
							begin
								Verification(cst, cp, cs, pl, pio, pClic, ClicUp, v);
								Deplacer_Carte(cp, cs, v, cliccartepioche, joh1, joh2, pl, pio, nbPlStock, tPl, tPio);
							end;
					end;
			end;
		
			
		sdl_flip(fenetre);

		QuelBouton(retour, aide, fin, Numero);
		if Numero <> 0 then
			begin
				AffichageClicBouton(cst, Numero, images, fenetre);
				SDL_flip(fenetre);
				delay(100);
				AffichageDeplacable(cst, pl, pio, ImageDeFond, images, fenetre);
				SDL_flip(fenetre);
				if fin then	
					DemandeConfirmation(cst, images, fenetre, reponse);
					if not reponse then
						begin
							AffichageDeplacable(cst, pl, pio, ImageDeFond, images, fenetre);
							SDL_flip(fenetre);
						end;		
			end;
		sdl_freesurface(ImageDeFond);
	until Fin_Du_Jeu(pl);

end;


var	images : TableauImages;

begin
	writeln('debut du programme');
	Partie;
	
	writeln('Bravo, tu as gagne !');
	
	QuitterLaSDL(images);

	
end.
