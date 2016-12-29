unit bot;

interface

TYPE
  listPtr = ^list;
  list = record
       nxt, prv : listPtr;
       code, nr : integer;
       used : boolean;
  end;

VAR
  AListBeg, AListEnd, tmp : listPtr;
  BListBeg, BListEnd : listPtr;
  ptr : listPtr;
  ASize, BSize : integer;

function min(a, b : integer) : integer;
procedure prepareLists();
procedure insert(code, numer : integer; var listBeg, listEnd : listPtr; var size : integer);
procedure delete(var listBeg, listEnd, aktualny : listPtr; var size : integer);
procedure generateList(d, c : integer; var listBeg, listEnd : listPtr; var size : integer);
function score(guess, code : integer) : integer;
function minimax() : integer;
procedure playBot(guess, code : integer);
procedure bot_init();
procedure generateB();
procedure byebyeB();

implementation

var
  int: integer;

function min(a, b : integer) : integer;
begin
     if( a > b) then
         min := b
     else
         min := a;
end;

{ #1   funkcje do obslugi list }

{inicjalizacja globalnych zmiennych}
procedure prepareLists();
begin
    AListBeg := NIL;
    AListEnd := NIL;
    BListBeg := NIL;
    BListEnd := NIL;
    ASize := 0;
    BSize := 0;
end;


{ wstawianie kodu na koniec listy}
procedure insert(code, numer : integer; var listBeg, listEnd : listPtr; var size : integer);
begin
     size := size+1;
     New(tmp);
     tmp^.code := code;
     tmp^.used := false;
     tmp^.nr := numer;
     tmp^.nxt := NIL;

     if(listEnd = NIL) then
     begin
          listBeg := tmp;
          listEnd := tmp;
     end
     else
     begin
          listEnd^.nxt := tmp;
          tmp^.prv :=  listEnd;
          listEnd := tmp;
     end;
end;

{ usuwanie kodu z listy na który wskazuje iterator(aktualny) }
procedure delete(var listBeg, listEnd, aktualny : listPtr; var size : integer);
begin
     tmp := aktualny;

     if ( size = 1) then begin
          listEnd := NIL;
          listBeg := NIL;
     end;

     if( size <> 1) then begin
         if( aktualny = listEnd ) then
             listEnd := aktualny^.prv;
         if( aktualny = listBeg ) then
             listBeg := aktualny^.nxt;
     end;

     if(aktualny^.nxt <> NIL) then
          aktualny^.nxt^.prv := aktualny^.prv;
     if(aktualny^.prv <> NIL) then
          aktualny^.prv^.nxt := aktualny^.nxt;

     if(tmp^.nxt <> NIL) then
          aktualny := tmp^.nxt
     else
     if(tmp^.prv <> NIL) then
          aktualny := tmp^.prv
     else
         aktualny := NIL;
     Dispose(tmp);
     size := size - 1;
end;

{rekurencyjne generowanie listy wszystkich możliwych kodów}
procedure generateList(d, c : integer; var listBeg, listEnd : listPtr; var size : integer);
var it : integer;
begin
     if (d = 5) then
     begin
          insert(c, int, listBeg, listEnd, size);
          int := int+1;
     end
     else
     begin
          for it := 1 to 6 do
              generateList(d+1, c*10+it, listBeg, listEnd, size);
     end;
end;

procedure byebyeB;
begin
     while(BListEnd <> NIL) AND (Bsize > 1) do begin
          delete( BListEnd, BListEnd, BListEnd, Bsize);
     end;

end;

{ #2 funkcje do obslugi mechaniki gry }

{ocena poprawnosci kodu - zwraca integer - liczba dziesiatek : liczba bialych pinow; liczba jednosci : liczba czarnych pinow}
function score(guess, code : integer) : integer;
var
  b, w, it, p, q : integer;
  G : array[1..6] of integer;
  C : array[1..6] of integer;
begin
     b := 0;
     w := 0;
     for it := 1 to 6 do begin
         G[it] := 0;
         C[it] := 0;
     end;
     for it := 1 to 4 do begin
         p := guess mod 10;
         q := code mod 10;
         if ( p = q ) then
            b := b+1
         else begin
             G[p] := G[p]+1;
             C[q] := C[q]+1;
         end;
         guess := guess div 10;
         code := code div 10;
     end;
     for it := 1 to 6 do
         w := w + min(G[it], C[it]);
     score := b*10 + w;
end;

{ #3 funkcje do obslugi AI }

{ minimax - maxymalizuje minimalna liczbe wyeliminowanych kodow}
function minimax() : integer;

var
  m, g, ma, i, j, e, w : integer;
  it, it2 : listPtr;

begin
     m := -1;
     g := -1;
     it := AListBeg;
     while (it <> NIL) do begin
           if ( it^.used = true ) then begin
               it := it^.nxt;
               continue;
           end;
           ma := maxint;
           for i := 0 to 4 do begin
               for j := 0 to 4 do begin
                   if ( NOT( (i=3) AND (j=1) ) AND (i+j <= 4) ) then begin
                       e := 0;
                       it2 := BListBeg;
                       while (it2 <> NIL) do begin
                           w := score(it2^.code, it^.code);
                           if( w <> i*10+j) then
                               e := e+1;
                           it2 := it2^.nxt;
                       end;
                       ma := min(ma, e);
                   end;
               end;
           end;
           if ( ma > m ) then begin
               m := ma;
               g := it^.code;
           end;
           it := it^.nxt;
     end;
     minimax := g;
end;

{wykonanie ruchu z zadanym trafem i redukcja pozostalych mozliwosci}
procedure playBot(guess, code : integer);
var
  i, s, z : integer;
  it, it2 : listPtr;
begin
     it := AListBeg;
     while ( it <> NIL ) do begin
         if ( it^.code = guess ) then
            it^.used := true;
         break;
         it := it^.nxt;
     end;
     s := score( guess, code );
     it2 := BListBeg;
     while (it2 <> NIL) do begin
         z := score(it2^.code, guess);
         if NOT( z = s) then begin
            delete(BListBeg, BListEnd, it2, BSize);
         end
         else
             it2 := it2^.nxt;
     end;
end;

procedure bot_init();
begin
   int := 1;
   prepareLists();
   generateList(1, 0, AListBeg, AListEnd, ASize);

end;

procedure generateB();
begin
   int := 1;
   BListBeg := NIL;
   BListEnd := NIL;
   BSize := 0;
   generateList(1, 0, BListBeg, BListEnd, BSize);
end;

begin
end.
