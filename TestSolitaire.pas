Unit TestSolitaire;



Interface

uses Initialisation, sysutils;

Function test(pl : Plateau) : Boolean;
Function TrouverNumeroPartie : Integer;
Procedure OuvrirFichier(NumeroPartie : Integer; var fichier : Text);
Procedure UpdateNumeroPartie(NumeroPartie : Integer);
Procedure Ecrire(TrucAEcrire : String);
Procedure Ecrir(TrucAEcrire : String);



Implementation


Function test(pl : Plateau) : Boolean;

var i, j : Integer;

begin
	test := False;
	for j:= 2 to 20 do
		begin
			for i:= 1 to 7 do
				begin
					if pl[i][j].valeur = 0 then
						if pl[i][j+1].valeur <> 0 then
							begin
								test := True;
								writeln(i, ' ',j, ' ', pl[i][j+1].valeur);
								writeln('probleme : ', test);
							end;
				end;
		end;
end;



Function TrouverNumeroPartie : Integer;

var fichier : Text;
	n : String;

begin
	assign(fichier, 'Parties/NumeroDeLaPartie.txt');
	reset(fichier);
	while not (eof(fichier)) do
		begin
			readln(fichier, n);
			TrouverNumeroPartie := StrToInt(n);
		end;
	close(fichier);
end;


Procedure OuvrirFichier(NumeroPartie : Integer; var fichier : Text);

var numero : String;

begin
	numero := IntToStr(NumeroPartie);
	assign(fichier, 'Parties/Partie' + numero + '.txt');
	if not (FileExists('Parties/Partie' + numero + '.txt')) then
		begin
		rewrite(fichier);
		end
	else
		append(fichier);
end;



Procedure UpdateNumeroPartie(NumeroPartie : Integer);

var fichier : Text;
	n : String;

begin
	assign(fichier, 'Parties/NumeroDeLaPartie.txt');
	rewrite(fichier);
	n := IntToStr(NumeroPartie);
	write(fichier, n);
	close(fichier);
end;


Procedure Ecrire(TrucAEcrire : String);

var NumeroPartie : Integer;
	fichier : Text;
	
begin
	NumeroPartie := TrouverNumeroPartie;
	OuvrirFichier(NumeroPartie, fichier);
	writeln(fichier, TrucAEcrire);
	close(fichier);
end;

Procedure Ecrir(TrucAEcrire : String);

var NumeroPartie : Integer;
	fichier : Text;
	
begin
	NumeroPartie := TrouverNumeroPartie;
	OuvrirFichier(NumeroPartie, fichier);
	write(fichier, TrucAEcrire);
	close(fichier);
end;
	

end.
