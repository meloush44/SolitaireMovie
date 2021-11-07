Program TestFichier;

uses TestSolitaire;



Procedure Test;

var i : Integer;

begin

for i:= 1 to 3 do
		begin
			writeln(i);
			halt;
			writeln('a');
		end;
end;



var n, i : Integer;
	fichier : Text;
	
begin
	n := TrouverNumeroPartie;
	writeln(n);
	
	Test;
	
	writeln('b');
	for i:= 1 to 3 do
		begin
			writeln(i);
			halt;
		end;
	for i:= 1 to 3 do
		begin
			writeln(i);
			exit;
		end;	
	
	OuvrirFichier(n, fichier);
	writeln(fichier, 'bonjour');
	close(fichier);
end.

