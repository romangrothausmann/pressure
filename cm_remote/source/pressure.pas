program pressure;

{full 8087 emulation: }
{$N+,E+}
{$R+}
Uses CRT, DOS, RCM;


{Main programm}

var p:PressureType;
    pi: array[1..PressureSize] of integer;
    i, code : integer;
    dt: Word;
    f: text;
    y, mo, d, dow : Word;
    h, m, s, hund : Word;
    fname: String;


function LeadingZero(w : Word) : String;
var s : String;

begin
     Str(w:0,s);
     if Length(s) = 1 then
     s := '0' + s;
     LeadingZero := s;
end;

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
     Assign(f, fname);
     rewrite(f);   {Append(f);}
     WriteLn(f,'# CM30 Pressure values from ', d:0, '/', mo:0, '/', y:0);
     WriteLn(f,'#   time  P1  P2  P3 IGP');
     while true do
           begin
           PressureReadout(P);
           for i := 1 to PressureSize do
               pi[i] := Trunc(p[i]);
           GetTime(h,m,s,hund);
           writeln(LeadingZero(h),':', LeadingZero(m),':',LeadingZero(s),
                      pi[1]:4,pi[2]:4,pi[3]:4,pi[4]:4);
           writeln(f, LeadingZero(h),':', LeadingZero(m),':',LeadingZero(s),
                      pi[1]:4,pi[2]:4,pi[3]:4,pi[4]:4);
           delay(dt);
           end;
     Close(f);
End.


