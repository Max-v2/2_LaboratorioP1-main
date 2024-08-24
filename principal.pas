program principal;

{ Con esta directiva queda incluido el archivo definiciones.pas }
{$INCLUDE definiciones.pas}

{ Con esta directiva queda incluido el archivo tarea2.pas }
{$INCLUDE tarea2.pas}

var
   opcion     : integer;
   pal,pal2   : Palabra;
   pc,pc2     : PalabraCant;
   pred	      : Predictor;
   pals	      : Ocurrencias;
   txt	      : Texto;
   fn	      : ansistring;
   alts,alts2 : Alternativas;

begin
   pals := NIL;
   alts.tope := 0;
   
   repeat
      writeln('Ingrese Opción');
      writeln('[0=fin, 1=hash, 2=comparaPalabra, 3=mayorPalabraCant, 4=agregarOcurrencia]');
      writeln('[5=inicializarPredictor, 6=entrenarPredictor, 7=insOrdAlternativas, 8=obtenerAlternativas]');
      readln(opcion);
      case opcion of
       1 : begin
	      writeln('hash:Ingrese palabra');
	      leerPalabra(input, pal); 
	      writeln(hash(SEMILLA,PASO,MAXHASH,pal):0)
	   end;
       2 : begin
	      writeln('comparaPalabra:Ingrese dos palabras');
	      leerPalabra(input,pal);
	      leerPalabra(input,pal2);
	      case comparaPalabra(pal,pal2) of
		menor : writeln('Menor');
		igual : writeln('Igual');
		mayor : writeln('Mayor')
	      end
	   end;
       3 : begin
	      writeln('mayorPalabraCant:Ingrese dos pares palabra-cantidad');
	      leerPalabra(input,pc.pal);
	      read(pc.cant);
	      leerPalabra(input,pc2.pal);
	      read(pc2.cant);
	      if mayorPalabraCant(pc,pc2) then
		 writeln('Si')
	      else
		 writeln('No')
	   end;
       4 : begin
	      writeln('agregarOcurrencia:Ingrese palabra');
	      leerPalabra(input,pal);
	      agregarOcurrencia(pal,pals);
	      mostrarOcurrencias(pals)
	   end;
       5 : begin
	      writeln('inicializarPredictor:');
	      inicializarPredictor(pred);
	      writeln('Predictor inicializado');
	      mostrarPredictor(pred)
	   end;
       6 : begin
	      writeln('entrenarPredictor:Ingrese archivo');
	      readln(fn); 
	      txt := leerTexto(fn); 
	      entrenarPredictor(txt,pred);
	      liberarTexto(txt);
	      writeln('Predictor entrenado');
	      mostrarPredictor(pred)
	   end;
       7 : begin
	      writeln('insOrdAlternativas:Ingrese palabra-cantidad');
	      leerPalabra(input,pc.pal);
	      read(pc.cant);
	      insOrdAlternativas(pc,alts);
	      mostrarAlternativas(alts)
	   end;
       8 : begin
	      writeln('obtenerAlternativas:Ingrese palabra');
	      leerPalabra(input,pal);
	      obtenerAlternativas(pal,pred,alts2);
	      mostrarAlternativas(alts2)
	   end;

	0 : ;
	else writeln ('Opción inexistente')
       end
   until opcion = 0
   
end.
