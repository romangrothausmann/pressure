program current;

{
This programme reads the pressure values and writes them to a file.
The name is put together by date and time at start.
It is written for rcm.pas (the newer version of the cm_remote software)
which (replaces rcm.inc) is a unit with a different api than discribed
in the manual for rcm.inc!
}

{full 8087 emulation: }
{$N+,E+}
{$R+}
Uses CRT, DOS, RCM, Drivers;

function LeadingZero(w : Word) : String;
var s : String;

begin
     Str(w:0,s);
     if Length(s) = 1 then
     s := '0' + s;
     LeadingZero := s;
end;


{Main programm}

var p:PressureType;
    c:CurrentType;
    pi: array[1..PressureSize] of integer;
    i, code : integer;
    dt: Word;
    f: text;
    y, mo, d, dow : Word;
    h, m, s, hund : Word;
    fname: String;
    b: boolean;

Begin
     if ParamCount < 1 then
        Begin
        WriteLn('No delay time specified, using 60,000 ms!');
        dt:= 60000;
        End
     else
        Begin
        Val(ParamStr(1), dt, code);
        if code <> 0 then
           Begin
           WriteLn('Error at position: ', code);
           exit;
           end
        else
           WriteLN('Using delay: ', dt, ' ms');
        End;
     GetDate(y,mo,d,dow);
     GetTime(h,m,s,hund);
     fname:= LeadingZero(d) + LeadingZero(mo) + LeadingZero(h)
             + LeadingZero(m) + '.cur';
     WriteLn('Writing currents to file ', fname );
     WriteLn('Abort with any key and wait a period!');
     Assign(f, fname);
     rewrite(f);   {Append(f);}
     WriteLn(f,'# CM30 current values from ', d:0, '/', mo:0, '/', y:0);
     WriteLn(f,'#', chr(9), 'time C1 C2 Twin Obj Dif Int P1 P2 ',
               'G-UX G-UY G-LX G-LY B-UX B-UY B-LX B-LY ',
               'I-UX I-UY I-LX I-LY C2-A C2-B Obj-A Obj-B Dif-A Dif-B');
     close(f);{we do this because flush doesn't work}
     while true do
           begin
           append(f); {we do this because flush doesn't work!}
           GetTime(h,m,s,hund);
           if EquipmentAvailable then
              begin
                   CurrentReadout(c);
                   write(LeadingZero(h),':', LeadingZero(m),':',LeadingZero(s));
                   write(f, LeadingZero(h),':', LeadingZero(m),':',LeadingZero(s));
                   for i := 1 to Currentsize do
                       begin
                       write(' ', c[i]:8:2);
                       if (i = 8) or (i = 12) or (i = 16) or (i = 20) then
                          writeln('');
                       write(f, ' ', c[i]:0:2);
                       end;
                   writeln('');
                   writeln(f,'');
              end
           else
               begin
               Writeln('Equipment not available! ',
                        LeadingZero(h),':', LeadingZero(m),':',LeadingZero(s));
               Writeln(f, '#Equipment not available! ',
                        LeadingZero(h),':', LeadingZero(m),':',LeadingZero(s));
               end;
           {flush(f); {ment, if not aborted by ^C, doesn't help :-(}
           close(f); {so we use close and append...}
           delay(dt);
           if KeyPressed then
              Begin
              Writeln('Programme end.');
              {close(f);}
              exit;
              end;

     end;
End.


