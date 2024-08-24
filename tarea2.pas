function hash ( semilla, paso, N : Natural; p : Palabra ) : Natural;
  var 
    i : Integer ; Codigo: Natural; {Delcaramos variables que vamos a utilizar}
  begin
    Codigo := semilla;
    for i := 1 to p.tope do {Recorremos hasta el tope de la palabra}
      begin
        Codigo := (Codigo * paso + Ord(p.cadena[i])) mod N {Los mismos paso que tarea1, agragandole p.cadena y el indice}
      end;
    hash := Codigo; {Retornamos codigo en la funcion de hash}
  end;

function comparaPalabra(p1, p2: Palabra): Comparacion;
  var
    i : Integer;
  begin { Compara las letras de las palabras en orden lexicográfico }
    i := 1;
    while (i <= p1.tope) and (i <= p2.tope) and (p1.cadena[i] = p2.cadena[i]) do
      i := i+1; {lo estaba pensando con el for asi puede avanzar, pero no terminaba el bucle, entonces probe con while}
    if (i > p1.tope) and (i > p2.tope) then
      comparaPalabra := igual {Si ambas palabras son idénticas hasta el final, la función devuelve (Igual).}
    else if (i > p1.tope) or ((i <= p2.tope) and (p1.cadena[i] < p2.cadena[i])) then
      comparaPalabra := menor {Si p1 es menor que p2 (en orden lexicográfico), la función devuelve (Menor)}
    else
      comparaPalabra := mayor; {y mayor en caso contrario}
  end;

  function mayorPalabraCant(pc1, pc2: PalabraCant): Boolean;
  begin
    mayorPalabraCant := (pc1.cant > pc2.cant) or ((pc1.cant = pc2.cant) and (comparaPalabra(pc1.pal, pc2.pal) = mayor));
    {Realice toda las condiciones en una linea como retorna la funcion en booleana usando comparaPalabra, seria lo mejor opcion antes que un if}
  end;

procedure agregarOcurrencia(p: Palabra; var pals: Ocurrencias);
  var 
    Primero, Previo: Ocurrencias;  
  begin
    Primero := pals;  {Inicializamos el puntero Primero al comienzo de la lista}
    Previo := nil;     {Inicializamos el puntero previo como nil (ninguno al principio)}
    while (Primero <> nil) and (comparaPalabra(Primero^.palc.pal, p) <> igual) do {Recorremos la lista mientras no lleguemos al final y las palabras no sean iguales}
    begin   
      Previo := Primero; {Guardamos el nodo Primero }
      Primero := Primero^.sig; {Avanzamos al siguiente nodo en la lista}
    end;
    if Primero <> nil then {Si encontramos la misma palabra en la lista}
      Primero^.palc.cant := Primero^.palc.cant + 1  {Incrementamos la cantidad de ocurrencias}
    else
    begin 
      new(Primero);  {Si la palabra no está en la lista, creamos un nuevo nodo para la palabra p}
      Primero^.palc.pal := p;
      Primero^.palc.cant := 1;
      Primero^.sig := nil;  {El siguiente nodo es nil, ya que será el último de la lista}
      if Previo <> nil then    {Insertamos el nuevo nodo al final de la lista}
        Previo^.sig := Primero  {Si hay un nodo previo, actualizamos su puntero siguiente}
      else
        pals := Primero;  {Si no hay nodo previo, actualizamos el inicio de la lista}
    end;
  end;

procedure inicializarPredictor (var pred: Predictor);
  var
    i: Integer;
  begin
    for i := 1 to MAXHASH do
      begin
        pred[i] := nil; { Inicializa cada elemento del predictor como una lista vacía }
      end;
  end;
    
procedure entrenarPredictor(txt: Texto; var pred: Predictor);
  var
    p1, p2: Palabra;
  begin
    while (txt <> nil) and (txt^.sig <> nil) do
    begin
      p1 := txt^.info;
      p2 := txt^.sig^.info;
      agregarOcurrencia(p2, pred[hash(SEMILLA, PASO, MAXHASH, p1)]); {Agrega p2 como una ocurrencia en la lista correspondiente}
      txt := txt^.sig;
    end;
end;

procedure insOrdAlternativas(pc: PalabraCant; var alts: Alternativas);
  var
    i: Integer;
  begin
    if alts.tope < MAXALTS then {Si hay espacio en alts, inserta pc en la posición correcta}
    begin
      i := alts.tope;
      while (i > 0) and mayorPalabraCant(pc, alts.pals[i]) do {Desplaza las palabras a la derecha para hacer espacio para pc}
      begin
        alts.pals[i + 1] := alts.pals[i];
        i := i - 1;
      end;
      alts.pals[i + 1] := pc; {Inserta pc en la posición adecuada y actualiza el tope}
      alts.tope := alts.tope + 1;
  end
  else if mayorPalabraCant(pc, alts.pals[MAXALTS]) then {Si alts está lleno y pc es mayor que el menor elemento, realiza la inserción}
  begin
    i := MAXALTS;
    while (i > 1) and mayorPalabraCant(pc, alts.pals[i - 1]) do {Desplaza las palabras a la derecha hasta encontrar la posición adecuada para pc}
    begin
      alts.pals[i] := alts.pals[i - 1];
      i := i - 1;
    end;
    alts.pals[i] := pc; {Inserta pc en la posición adecuada}
  end;
end;

procedure obtenerAlternativas (p : Palabra; pred : Predictor; var alts: Alternativas);
  var
    primero: Ocurrencias;
    pc: PalabraCant;
  begin
    alts.tope := 0; {Inicializa el tope de alternativas}
    primero := pred[hash(SEMILLA, PASO, MAXHASH, p)]; {Recorre la lista de ocurrencias correspondiente al código de hash}
  while (primero <> nil) do
  begin
    pc := primero^.palc;
    insOrdAlternativas(pc, alts);
    primero := primero^.sig;
  end;
end;