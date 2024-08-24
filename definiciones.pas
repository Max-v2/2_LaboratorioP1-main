
{ constantes }
{ --------------------------------------------------- }
const

   SEMILLA = 53;      { semilla para función de hash }
   PASO	   = 3;       { paso para función de hash }
   MAXHASH = 1000000; { cota de la función de hash }
   MAXPAL  = 30;      { cota de la palabra }
   MAXALTS = 3;       { cota de alternativas }


{ tipos }
{ --------------------------------------------------- }

type
   
   { tipo de los naturales }
   Natural	= QWord;

   { arreglo con tope de letras, que representa a una palabra }
   Letra        = 'a' .. 'z';
   Palabra	= record
		     cadena : array [1 .. MAXPAL] of Letra;
		     tope   : 0 .. MAXPAL
		  end;

   { enumerado para indicar el resultado de una comparación entre palabras }
   Comparacion	= (menor, igual, mayor);

   { lista de palabras, que representa a un texto }
   Texto	= ^NodoPal; 
   NodoPal	= record  
		     info : Palabra;
		     sig  : Texto
		  end;

   { registro para indicar la cantidad de veces que ocurre una palabra }
   PalabraCant	= record
		     pal  : Palabra;
		     cant : integer
		  end;

   { lista de ocurrencias de palabras }
   Ocurrencias	= ^Nodo;
   Nodo		= record  
		     palc : PalabraCant;
		     sig  : Ocurrencias
		  end;

   { arreglo indexado por los códigos de hash de las distintas palabras
     y que para cada palabra contiene la lista de palabras que suelen 
     aparecer a continuación y la cantidad de veces que ocurrieron 
     en los textos de entrenamiento }
   Predictor  = array [1 .. MAXHASH] of Ocurrencias;


   { arreglo con tope para retornar hasta MAXALT alternativas de palabras
     que pueden continuar }
   Alternativas	= record  
		     pals : array [1..MAXALTS] of PalabraCant;
		     tope : 0 .. MAXALTS
		  end;	  




{ subprogramas }
{ --------------------------------------------------- }


procedure mostrarPalabra (p : Palabra);
{ Muestra la palabra p }
var k : 1..MAXPAL;
begin
   with p do
      for k := 1 to tope do write (cadena[k])
end;

procedure mostrarOcurrencias (pals : Ocurrencias);
{ Muestra la lista de ocurrencias pals }
var piter : Ocurrencias; 
begin
   piter := pals;
   while piter <> NIL do
   begin
      write('-(');
      mostrarPalabra(piter^.palc.pal);
      write(',',piter^.palc.cant:0,')');
      piter := piter^.sig
   end;
   writeln
end;

procedure mostrarPredictor (pred : Predictor );
{ Muestra el predictor pred }
var k : 1..MAXHASH;
begin
   for k := 1 to MAXHASH do
      if pred[k] <> NIL then
      begin
	 write (k, ': ');    
	 mostrarOcurrencias(pred[k])
      end
end;

procedure mostrarAlternativas (alts : Alternativas );
{ Muestra las alternativas alts }
var k : 0..MAXALTS;
begin
   with alts do
      for k := 1 to tope do
      begin
	 write('-(');
	 mostrarPalabra (pals[k].pal);
	 write(',',pals[k].cant:0,')')
      end;
   writeln
end;

procedure leerMinuscula (var f : text; var c: char);
{ Lee un caracter de la entrada, y lo transforma en minúscula de ser necesario }
{ El argumento f indica o un archivo o la entrada estándar desde el teclado }
begin
   read (f, c);
   if c in ['A'..'Z'] then c := chr (ord ('a') - ord ('A') + ord(c))   
end;

procedure leerPalabra (var f : text; var p :Palabra );
{ Lee una palabra usando un autómata con tres estados }
type TEstado =  (START, s, STOP);
const carValidos =  ['a'..'z'];   { Caracteres válidos para una palabra }
var c	 : char;                  
   estado : TEstado;              
begin
   with p do
   begin
      { Inicialización de la palabra y del estado }
      tope := 0;
      estado := START;
      { Se itera hasta que se llega al estado final STOP }
      while estado <> STOP do
	 case estado of { Análisis del estado en que me encuentro }
	   { Estado START: consumo saltos de línea y caracteres que no son
	   aceptables para una palabra, y eventualmente el primer caracter
	   de una palabra }
	   START : if eof (f) then estado := STOP
		      { Cuando se acaba el archivo (eof) paso al estado final }
		   else if eoln (f) then readln (f)
		      { Cuando encuentro un salto de línea (eoln) lo consumo }
		   else
		   begin
		      { Leo un caracter }
		      leerMinuscula (f, c);
		      if c in carValidos then
			 { Guardo el primer caracter en p,
			 y paso al estado S para consumir
			 el resto de la palabra }
		      begin tope := 1; cadena[1] := c; estado := s end
		   end;
	   { Estado S: lee el resto de la palabra y la guarda en p }
	   s     : if eof (f) or eoln (f) then estado := STOP
		      { Cuando se acaba el archivo o se encuentra un salto de
		      línea, paso al estado final }
		   else
		   begin
		      { Leo un caracter }
		      leerMinuscula (f, c);
		      if c in carValidos then
			 { Guardo un nuevo caracter en p }
		      begin tope := 1 + tope; cadena[tope] := c end
		      else
			 { El caracter leído no es válido; la palabra ha sido
			 leída y paso al estado final }
			 estado := STOP
		   end
	 end;
   end
end;

function leerTexto (fn : ansistring): Texto;
   procedure nuevoNodo(p : Palabra; var nodo: Texto);
   begin
      new(nodo);
      nodo^.info  := p
   end;
var l, it: Texto; p: Palabra; f:text;
begin
   assign (f, fn);     { Vincula el archivo físico fn con el archivo lógico f }
   reset (f);          { Abre el archivo f para leer }
   leerPalabra (f, p); { Lee una palabra de f        }
   if p.tope = 0
      then l := nil { Si el archivo es vacío devuelve la lista vacía }
   else
   begin
      { p es la palabra a guardar en la lista }
      nuevoNodo (p, l); it := l;   { guarda p en la lista }
      leerPalabra (f, p);          { lee la palabra p }
      while p.tope <> 0 do         { mientras puede leer palabras (no vacías) } 
      begin
	 nuevoNodo (p, it^.sig); it := it^.sig;  { guarda p en la lista }
	 leerPalabra (f, p)            { lee la palabra p }
      end;
      it^.sig := nil               { termina la lista }
   end;
   close (f);
   leerTexto := l
end;

procedure liberarTexto( var txt : Texto );
{ libera la memoria reservada para un texto }
var p, q : Texto;
begin
   p := txt;
   while p <> NIL do
   begin
      q := p;
      p := p^.sig;
      dispose (q)
   end
end;
