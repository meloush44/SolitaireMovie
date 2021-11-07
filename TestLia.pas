Program TestLia;

uses Lia, Initialisation, Selection, Verif;


var pl : Plateau;
	pio : Pioche;
	i, j : Integer;
	//popo : PositionsPossibles;
	pts : PlateauPositions;
	bloque,PiocheOuPlateau, joh,victoire : Boolean;
	nbTourFinal, nbTour : Integer;
	
begin
	Init(pl, pio);
	writeln('Plateau : ');

	for j:= 1 to 10 do
			begin
				for i:= 1 to 7 do
					begin
					write(pl[i][j].valeur, pl[i][j].sym, '     ');
					end;
				writeln();
			end;
	writeln;		
	//writeln('Popo : ');
	
{
	Ensemble_Positions(pl,pio, pts, bloque);
	for j:= 1 to 21 do
		begin
			for i:= 1 to 7 do
				begin
					if pts[i][j].exists then 
						begin
							for k:= 1 to 7 do
							write(pts[i][j].pp[k].x, ' ', pts[i][j].pp[k].y, '   ');
						end;
				end;
			writeln;
		end;
}

	
	
	
	nbTourFinal := 100;
	nbTour := 0;
	victoire := False;
	PiocheOuPlateau := True;
	
	Ensemble_Positions(PiocheOuPlateau, pl, pio, pts, bloque, joh);


	Test_Ensemble_Possibilites(bloque, nbTourFinal, nbTour, victoire, pl, pio, pts);
	
	writeln('c''est fini programme principal');			
			
{
				if pl[i][j].retournee then
					begin
						

						for k:= 1 to 7 do
							begin
								write(popo.pp[k].x, ' ', popo.pp[k].y, '   ');
								//write(popo.exists, ' ');
							end;
						writeln;

					end;
			
}
		

		
{
	for j:= 1 to 21 do
		begin
			for i:= 1 to 7 do
				write(pl[i][j].retournee, ' ');
			writeln;
		end;
}
		
{
		
	Ou_Mettre(6, 8, pl, popo);	
	for i:= 1 to 7 do
		write(popo.pp[i].x, ' ', popo.pp[i].y, '   ');
}
end.

