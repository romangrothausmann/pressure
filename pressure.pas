program pressure;

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
Uses CRT, DOS, RCM;

function LeadingZero(w : Word) : String;
var s : String;

begin
     Str(w:0,s);
     if Length(s) = 1 then
     s := '0' + s;
     LeadingZero := s;
end;

function power(base, exponent:extended): extended;
begin
power:= exp(exponent * ln(base));
end;


function igp2pa(igp: integer) : extended;
Begin
igp2pa:= 7e-6 * power(power(20000 / 7, 1 / 90), igp);
End;

function ext2str(x: extended; precission: integer) : string;
var s,s1: string [40];
begin
str(x,s);
s1:= copy(s,pos('E',s),99);
ext2str := copy(s,1,precission+3) + s1;
end;

{Main programm}

var p:PressureType;
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
             + LeadingZero(m) + '.pre';
     WriteLn('Writing pressures to file ', fname );
     WriteLn('Abort with any key and wait a period!');
     WriteLn('CM30 Pressure values from ', d:0, '/', mo:0, '/', y:0);
     WriteLn('    time  P1  P2  P3 IGP IGP2Pa');

     Assign(f, fname);
     rewrite(f);   {Append(f);}
     WriteLn(f,'# CM30 Pressure values from ', d:0, '/', mo:0, '/', y:0);
     WriteLn(f,'#   time  P1  P2  P3 IGP IGP2Pa');
     close(f);{we do this because flush doesn't work}
     while true do
           begin
           append(f); {we do this because flush doesn't work!}
           GetTime(h,m,s,hund);
           if EquipmentAvailable then
              begin
                   PressureReadout(P);
                   for i := 1 to PressureSize do
                       pi[i] := Trunc(p[i]);
                   writeln(LeadingZero(h),':', LeadingZero(m),':',LeadingZero(s),
                           pi[1]:4,pi[2]:4,pi[3]:4,pi[4]:4,ext2str(igp2pa(pi[4]),3));
                   writeln(f, LeadingZero(h),':', LeadingZero(m),':',LeadingZero(s),
                           pi[1]:4,pi[2]:4,pi[3]:4,pi[4]:4,igp2pa(pi[4]));
              end
           else
               begin
               Writeln('Equipment not available! ',
                        LeadingZero(h),':', LeadingZero(m),':',LeadingZero(s));
               Writeln(f, '#Equipment not available! ',
                        LeadingZero(h),':', LeadingZero(m),':',LeadingZero(s));
               end;
           flush(f); {ment, if not aborted by ^C, doesn't help :-(}
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


