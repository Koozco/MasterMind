program MasterMind;

{$APPTYPE GUI}

uses allegro, SysUtils, windows, Dialogs, dateutils, bot;

const
  ScreenWidth= 500;
  ScreenHeight= 680;

type
  bmp = record
    img : string;
    w, h : integer;
    xp, yp : integer;
  end;

  aspot = record
    x, y : integer;
  end;

  pin = record
     col : integer;
     ex : integer;
  end;

var
  bg, ls, bufor : AL_BITMAPptr;
  now, notnow : TDateTime;
  menu : array[1..10] of bmp;
  pins : array[1..6, 1..4] of pin;
  cols : array[1..6] of string;
  ans : array[1..6] of integer;
  aspots : array[1..4] of aspot;
  sekundy, minuty : string;
  i : integer;
  mx, my, mb : integer;
  arow, apins : integer;
  aimode : integer;
  code, guess, codeShown, human, pre, mcode : integer;
  speed : integer;


procedure IntClock; cdecl;
begin
    inc(speed);
end;

procedure mkMenu;
var
  imgTmp : bmp;
  it : integer;
begin
     it := 1;
     {logo}
     imgTmp.img := 'mm.bmp';
     imgTmp.w := 500;
     imgTmp.h := 400;
     imgTmp.xp := 0;
     imgTmp.yp := 0;
     menu[it] := imgTmp;
     inc(it);
     {menu buttons}
     imgTmp.img := 'start.bmp';
     imgTmp.w := 400;
     imgTmp.h := 80;
     imgTmp.xp := (ScreenWidth-400) div 2;
     imgTmp.yp := ScreenHeight div 2;
     menu[it] := imgTmp;
     inc(it);
     imgTmp.img := 'ai.bmp';
     imgTmp.w := 400;
     imgTmp.h := 80;
     imgTmp.xp := (ScreenWidth-400) div 2;
     imgTmp.yp := ScreenHeight div 2 + 90;
     menu[it] := imgTmp;
     inc(it);
     imgTmp.img := 'exit.bmp';
     imgTmp.w := 400;
     imgTmp.h := 80;
     imgTmp.xp := (ScreenWidth-400) div 2;
     imgTmp.yp := ScreenHeight div 2 + 180;
     menu[it] := imgTmp;
     inc(it);
end;

procedure initPins;
var
  it, it2 : integer;
begin
     for it := 1 to 6 do
         for it2 := 1 to 4 do begin
             pins[it, it2].col := 0;
             pins[it, it2].ex := 0;
         end;
     cols[1] := 'prefabs/pin1.bmp';
     cols[2] := 'prefabs/pin2.bmp';
     cols[3] := 'prefabs/pin3.bmp';
     cols[4] := 'prefabs/pin4.bmp';
     cols[5] := 'prefabs/pin5.bmp';
     cols[6] := 'prefabs/pin6.bmp';
end;

procedure myszka;
begin
     al_poll_mouse;
     if (mb = 1) then
        mb := 0;
     if( mx <> al_mouse_x) OR (my <> al_mouse_y) then
     begin
          mx := al_mouse_x;
          my := al_mouse_y;
          mb := al_mouse_b;
     end;
     if (mb = 1) then begin
          al_rest(250);
     end;
end;

procedure gameDraw;
var
  it, it2, p, c, b, w : integer;
  msg : string;
begin
     if(aimode = 1) then
               code := mcode;
     al_clear_to_color(bufor, al_makecol(255, 0, 255));
     {al_clear_to_color(al_screen, al_makecol(0,0,0));}
     bg := al_load_bmp( 'prefabs/bg.bmp',  @al_default_palette);
     al_blit(bg, bufor, 0, 0, 0, 0, ScreenWidth, ScreenHeight);
     al_destroy_bitmap(bg);
     ls := al_load_bmp( 'prefabs/pat.bmp',  @al_default_palette);
     al_masked_blit(ls, bufor, 0, 0, 0, 0, ScreenWidth, ScreenHeight);
     al_destroy_bitmap(ls);

     {palette}
     if(codeShown = 0) OR (pre = 1) then
     for it := 1 to 6 do begin
         ls := al_load_bmp( cols[it], @al_default_palette);
         al_masked_blit(ls, bufor, 0, 0, 100 + (it-1)*50, 590, 60, 50);
         al_destroy_bitmap(ls);
     end;

     {pins}
     for it := 1 to 6 do
         for it2 := 1 to 4 do
             if( pins[it, it2].ex = 1) then begin
               ls := al_load_bmp( cols[pins[it, it2].col], @al_default_palette);
               al_masked_blit( ls, bufor, 0, 0, 180 + (it2-1)*50, 150 + (it-1)*60, 60, 50);
               al_destroy_bitmap(ls);
             end;

     {ans}
     for it := 1 to 6 do begin
         if( ans[it] = 0) then continue;
         w := ans[it] mod 10;
         b := ans[it] div 10;
         p:=1;
         while(w > 0) do begin
              ls := al_load_bmp('prefabs/spin1.bmp' , @al_default_palette);
              al_masked_blit( ls, bufor, 0, 0, aspots[p].x, aspots[p].y + (it-1)*60, 30, 40);
              if(ls <> NIL) then
              al_destroy_bitmap(ls);
              inc(p);
              dec(w);
         end;
         while(b > 0) do begin
              ls := al_load_bmp('prefabs/spin2.bmp' , @al_default_palette);
              al_masked_blit( ls, bufor, 0, 0, aspots[p].x, aspots[p].y + (it-1)*60, 30, 40);
              al_destroy_bitmap(ls);
              inc(p);
              dec(b);
         end;
     end;

     {ok button}
     if(codeShown = 0) AND NOT(pre = 1) then begin
        ls := al_load_bmp( 'prefabs/vbut.bmp', @al_default_palette);
        al_masked_blit( ls, bufor, 0, 0, 400, 150 + (arow - 1)*60, 50, 50);
        al_destroy_bitmap(ls);
     end;
     if(pre = 1) then begin
        ls := al_load_bmp( 'prefabs/vbut.bmp', @al_default_palette);
        al_masked_blit( ls, bufor, 0, 0, 400, 590, 50, 50);
        al_destroy_bitmap(ls);
     end;

     {menu}
     if NOT(aimode = 1) then begin
       ls := al_load_bmp( 'prefabs/mbut.bmp', @al_default_palette);
       al_masked_blit( ls, bufor, 0, 0, 10, 620, 80, 48);
       al_destroy_bitmap(ls);
     end;

     {code}
     if(codeShown = 1) then begin
                   c := code;
                   for it := 1 to 4 do begin
                       p := c mod 10;
                       c := c div 10;
                       if( p <> 0) then begin
                           ls := al_load_bmp( cols[p], @al_default_palette);
                           al_masked_blit( ls, bufor, 0, 0, 180 + (it-1)*50, 150+6*60, 60, 50);
                           al_destroy_bitmap(ls);
                       end;
                   end;
                   if NOT(pre = 1) AND NOT(aimode =1) then begin
                      if(guess = code) then
                          msg := 'Gratulacje! Ukończyłeś grę w czasie ' + minuty + ':' + sekundy + '.'
                      else
                          msg := 'Niestety, nie tym razem :P';
                      al_textout_ex(bufor, al_font, msg, 100, 600, al_makecol(255,255,255), -1);
                   end;
     end;
     al_masked_blit(bufor, al_screen, 0, 0, 0, 0, ScreenWidth, ScreenHeight);
     al_rest(10);
end;

procedure clearGame;
var
  it, it2 : integer;
begin
     for it := 1 to 6 do
         for it2 := 1 to 4 do
             if( pins[it, it2].ex = 1) then begin
               pins[it, it2].col := 0;
               pins[it, it2].ex := 0;
             end;
     for it := 1 to 6 do
         ans[it] := 0;
     arow := 1;
     apins := 0;
     codeShown := 0;
     guess := 0;
     pre := 0;
end;

procedure acceptGuess;
begin
     ans[arow] := score(guess, code);
    if(arow < 6) then
             inc(arow);
     if(guess = code) then begin
         codeShown := 1;
         now := Time;
         sekundy := intToStr(secondsBetween(now, notnow) mod 60);
         if(secondsBetween(now, notnow) mod 60 < 10) then
             sekundy := '0' + intToStr(secondsBetween(now, notnow) mod 60)
         else
             sekundy := intToStr(secondsBetween(now, notnow) mod 60);

         minuty := intToStr(minutesBetween(now, notnow) mod 60);
     end
     else
         guess := 0;
end;

procedure startFunction;
var
  it, it2 : integer;
  gx : integer;
  w, t : integer;
begin
     notnow := Time;
     pre := 0;
     apins := 0;
     while (speed > 0) do begin
         gameDraw;
         al_poll_mouse;
         myszka;
         if( mb = 1) then begin
             {choose color}
             if( mx >= 100) AND (mx <= 400) AND (my >= 590) AND (my <= 650) AND (apins < 4) then begin
               gx := mx;
               gx := (gx - 100) div 50 + 1;
               for it := 1 to 4 do
                 if( pins[arow, it].ex = 0) then begin
                   pins[arow, it].ex := 1;
                   pins[arow, it].col := gx;
                   t := 1;
                   w := it;
                   for it2 := 1 to w-1 do
                   t := t*10;
                   guess := guess + gx*t;
                   inc(apins);
                   break;
               end;
               al_rest(50);
             end;
             {deselct}
             if( mx >= 180) AND (mx <= 380) AND (my >= 150+(arow-1)*60) AND (my <= 210+(arow-1)*60) then begin
                 gx := mx;
                 gx := (gx - 180) div 50 + 1;
                 t := 1;
                 for it := 1 to gx - 1 do begin
                     t := t*10;
                 end;
                 guess := guess - pins[arow, gx].col*t; {zmiana}
                 pins[arow, gx].ex := 0;
                 dec(apins);
             end;

             {accept guess}
             if(mx >= 400) AND (mx <=450) AND (my >= 150+(arow-1)*60) AND (my<=200+(arow-1)*60) AND (apins = 4) then begin
                   if(arow = 6) then begin
                           codeShown := 1;
                   end;
                   acceptguess;
                   apins := 0;
             end;
             {menu}
             if(mx >= 10) AND (mx <= 90) AND (my>=620) AND (my<=668) then begin
               clearGame;
               exit;
             end;
         end;
         if(codeShown = 1) then
              break;
     end;
     gameDraw;
     {wait for exit}
     while 1=1 do begin
         myszka;
         {menu}
         if (mb = 1) AND (mx >= 10) AND (mx <= 90) AND (my>=620) AND (my<=668) then begin
           clearGame;
           exit;
         end;
     end;
end;

procedure wybierz;
var
  it : integer;
  gx : integer;
  p, c, t : integer;
begin
     clearGame;
          codeShown := 1;
          p := 1;
          pre := 1;
          code := 0;
          mb := 0;
          apins := 0;

          gameDraw;
          while(speed > 0) do begin
              al_rest(10);
              al_poll_mouse;
              al_rest(10);
              myszka;

              if( mb = 1) then begin
                  {choose color}
                  if( mx >= 100) AND (mx <= 400) AND (my >= 590) AND (my <= 650) AND (apins < 4) then begin
                      gx := mx;
                      gx := (gx - 100) div 50 + 1;
                      p := 1;
                      c := code;
                      while(c > 0) do begin
                            if( c mod 10 <> 0) then
                               inc(p)
                            else
                                break;
                            c := c div 10;
                      end;
                      t := 1;
                      for it := 1 to p-1 do
                          t := t*10;
                      inc(apins) ;
                      code := code + t*gx;
                  end;
                  {deselct}
                   if( mx >= 180) AND (mx <= 380) AND (my >= 510) AND (my <= 570) then begin
                       gx := mx;
                       gx := (gx - 180) div 50 + 1;
                       t := 1;
                       for it := 1 to gx do
                          t := t*10;
                       c := (code mod t) div (t div 10);
                       code := code - c*(t div 10);
                       dec(apins);
                   end;
                  {menu}
                  if(mx >= 10) AND (mx <= 90) AND (my>=620) AND (my<=668) then begin
                     clearGame;
                     exit;
                   end;
                  {vbut}
                  if(mx >= 400) AND (mx <= 450) AND (my >= 590) AND (my <= 640) AND (apins = 4) then begin
                        pre := 0;
                        codeShown := 0;
                        break;
                  end;
                  gameDraw;
                  al_rest(50);
              end;
       end;
       clearGame;
       startFunction;
end;

procedure menuDraw;
begin
     al_clear_to_color( bufor, al_makecol(0,0,0) );
     bg := al_load_bmp( 'prefabs/bg.bmp',  @al_default_palette);
     al_blit(bg, bufor, 0, 0, 0, 0, ScreenWidth, ScreenHeight);
     al_destroy_bitmap(bg);
     for i:=1 to 4 do begin
         ls := al_load_bmp('prefabs/' + menu[i].img, @al_default_palette);
         al_masked_blit( ls, bufor, 0, 0, menu[i].xp, menu[i].yp, menu[i].w, menu[i].h);
         al_destroy_bitmap(ls);
     end;
     al_masked_blit(bufor, al_screen, 0, 0, 0, 0, ScreenWidth, ScreenHeight);
end;

procedure choose;
var
   msg : string;
   it, t : integer;
begin
     al_clear_to_color(bufor, al_makecol(255, 0, 255));
     bg := al_load_bmp( 'prefabs/bg.bmp',  @al_default_palette);
     al_blit(bg, bufor, 0, 0, 0, 0, ScreenWidth, ScreenHeight);
     al_destroy_bitmap(bg);
     msg := 'Ułóż kod.';
     al_textout_centre_ex(bufor, al_font, msg, ScreenWidth div 2, 200, al_makecol(255,255,255), -1);
     ls := al_load_bmp( 'prefabs/vbut.bmp', @al_default_palette);
     al_masked_blit( ls, bufor, 0, 0, ScreenWidth div 2 -25, 215, 50, 50);
     al_destroy_bitmap(ls);
     msg :='Generuj losowo.';
     al_textout_centre_ex(bufor, al_font, msg, ScreenWidth div 2, 300, al_makecol(255,255,255), -1);
     ls := al_load_bmp( 'prefabs/vbut.bmp', @al_default_palette);
     al_masked_blit( ls, bufor, 0, 0, ScreenWidth div 2 -25, 315, 50, 50);
     al_destroy_bitmap(ls);
     al_masked_blit( bufor, al_screen, 0, 0, 0, 0, ScreenWidth, ScreenHeight);
     while(speed > 0) do begin
          myszka;
          if(mb = 1) then begin
           if(mx >= ScreenWidth div 2 -25) AND (mx <= ScreenWidth div 2 +25) AND (my >=215) AND (my <= 265) then begin
                 human := 1;
                 mb := 0;
                 break;
           end;
           if(mx >= ScreenWidth div 2 -25) AND (mx <= ScreenWidth div 2 +25) AND (my >=315) AND (my <= 365) then begin
                 t := 1;
                 code := 0;
                 for it := 1 to 4 do begin
                      code := code + (random(4)+1)*t;
                      t := t*10;
                 end;
                 human := 0;
                 break;
           end;
           end;
     end;
     if(human = 1) then
        wybierz
     else
         startfunction;
end;

procedure aifunction;
var
   t, it, r, c : integer;
begin
     clearGame;
     aimode := 1;
     t := 1;
     mcode := 0;
     for it := 1 to 4 do begin
          mcode := mcode + (random(4)+1)*t;
          t := t*10;
     end;
     codeShown := 1;
     gameDraw;
     al_rest(200);
     generateB();
     guess := 1122;
     r := 1;
     while(speed > 0) AND (r <= 6) do begin
          gameDraw;
          c := guess;
          t := 1;
          while ( c > 0) do begin
               pins[r, t].col := c mod 10;
               pins[r, t].ex := 1;
               inc(t);
               c := c div 10;
               al_rest(300);
               gameDraw;
          end;
          playBot(guess, mcode);

          ans[r] := score(guess,mcode);
          gameDraw;
          if(ans[r] = 40) then
                    break;

          if(BSize > 1) then
              guess := minimax()
          else
              guess := BListBeg^.code;

         inc(r);
     end;

     ls := al_load_bmp( 'prefabs/mbut.bmp', @al_default_palette);
     al_masked_blit( ls, al_screen, 0, 0, 10, 620, 80, 48);
     al_destroy_bitmap(ls);

     while(1=1) do begin
         myszka;
         if(mb = 1) AND (mx >= 10) AND (mx <= 90) AND (my>=620) AND (my<=668) then begin
           clearGame;
           break;
         end;
     end;
     byeByeB;
     clearGame;
     aimode := 0;
end;

procedure menuFunction;
begin
     menuDraw;
     while (speed > 0) do begin
           if(mb <> 0) then
           if ((mx >= menu[2].xp) AND (mx <= menu[2].xp + menu[2].w)) then begin
             if (my >= menu[2].yp) AND (my <= menu[2].yp + menu[2].h) then begin
               al_rest(60);
                choose;
                menuDraw;
                continue;
             end;
             if (my >= menu[3].yp) AND (my <= menu[3].yp + menu[3].h) then begin
                aiFunction;
                menuDraw;
                continue;
             end;
             if (my >= menu[4].yp) AND (my <= menu[4].yp + menu[4].h) then begin
                al_rest(100);
                exit();
             end;
           end;
           myszka;
           al_rest(10);
     end;
end;

procedure inicjalizacja;
begin
     randomize;
     bot_init;
     al_init;
     al_install_keyboard;
     al_install_timer;
     al_install_sound(AL_DIGI_AUTODETECT, AL_MIDI_AUTODETECT);
     al_set_color_depth(32);
     al_set_gfx_mode(Al_GFX_AUTODETECT_WINDOWED,ScreenWidth,ScreenHeight,0,0);
     al_set_window_title('MasterMind');
     mx := 0;
     my := 0;
     mb := 0;
     arow := 1;
     guess := 0;
     human := 0;
     speed := 0;
     pre := 0;
     aimode := 0;
     al_install_int_ex (@IntClock,  AL_BPS_TO_TIMER(60));
     apins := 0;
     codeShown := 0;
     al_install_mouse();
     al_show_mouse(al_screen);
     al_unscare_mouse();
     bufor := al_create_bitmap(ScreenWidth, ScreenHeight);
     mkMenu;
     initPins;
     aspots[1].y := 150;
     aspots[2].y := 150;
     aspots[3].y := 180;
     aspots[4].y := 180;
     aspots[1].x := 100;
     aspots[2].x := 140;
     aspots[3].x := 100;
     aspots[4].x := 140;
end;


begin
  inicjalizacja;
  menuFunction();
  al_exit;
end.

