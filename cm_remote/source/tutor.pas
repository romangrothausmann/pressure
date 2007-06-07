program Tutor;
{*************************************************************************}
{*************************************************************************}
{                                                                         }
{                        T U T O R . P A S                                }
{                                                                         }
{      Tutor Program to show all the basic Remote Control Functions       }
{                                                                         }
{      (C)  1988  Copyright PHILIPS Export B.V., All Rights Reserved      }
{                                                                         }
{*************************************************************************}
{*************************************************************************}

{$u+} { user interrupt with ^C }
{$r+} { index range check      }

Const
  maxfunctionnumber = 35;

  { Push-button constants: }
  Algn        = 29;
  Autofoc     = 04;
  AutoSgnl    = 53;
  Cross       = 34;
  D           = 03;
  DF          = 28;
  Exposure    = 60;
  ExchMode    = 44;
  Exp1        = 45;
  Exp2        = 46;
  Exp3        = 47;
  ExchSgnl    = 55;
  Fast        = 38;
  Fine        = 62;
  Inverted    = 54;
  Line        = 35;
  Mag         = 42;
  Photo       = 51;
  Reset       = 06;
  Ready       = 07;
  RST         = 61;
  Stig        = 27;
  SGNL        = 41;
  Split       = 43;
  SA          = 33;
  Scanstop    = 36;
  Slow        = 37;
  SetContrast = 52;
  TV          = 39;
  WA          = 32;
  Wbl         = 63;
  Ymode       = 50;
  YZmode      = 49;
  Zmode       = 48;

  { Turn Knob constants: }
  Ratio      = 0;
  Contrast   = 1;
  Brightness = 2;
  Zoom       = 3;
  Magn       = 6;
  Focus      = 7;
  Step       = 8;
  Intens     = 9;
  Shiftx     = 12;
  Shifty     = 13;
  Mfx        = 14;
  Mfy        = 15;
  SpotSize   = 16;
  Filament   = 17;

Type
  PressKindtype = (ON,OFF,PRESS);
  ScreenType = (total, upper, lower);
             { the various parts of the screen. }

  Functionnumbers = 0 .. maxfunctionnumber;

Var
  Kar:    Char;            { used to read one character }
  Stop:   Boolean;         { expresses if program must stop }
  Choice: FunctionNumbers; { expresses which function must be performed }

{***************************************************************************}
Procedure Beep;

{ This procedure sounds a beep }
begin
  sound(500);
  delay(500);
  nosound;
end;


{***************************************************************************}
Procedure NoDriver;

{ This procedure writes a message on the screen indicating there is no driver }

Begin
  Writeln;
  Writeln('ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ');
  Writeln('ณ                                                                            ณ');
  Writeln('ณ   The device driver is not present.                                        ณ');
  Writeln('ณ   In the root directory of the disk you boot from is the file CONFIG.SYS.  ณ');
  Writeln('ณ   This normal ASCII file must contain the following phrase:                ณ');
  Writeln('ณ                                                                            ณ');
  Writeln('ณ                         Device = RCM.SYS                                   ณ');
  Writeln('ณ                                                                            ณ');
  Writeln('ณ   If you do not wish to place the file RCM.SYS in the root directory, but  ณ');
  Writeln('ณ   for example in the directory C:\RemoteCM, then this phrase must be:      ณ');
  Writeln('ณ                                                                            ณ');
  Writeln('ณ                     Device = C:\RemoteCM\RCM.SYS                           ณ');
  Writeln('ณ                                                                            ณ');
  Writeln('ณ   You can change the file config.sys with any normal ASCII text editor.    ณ');
  Writeln('ณ   Please correct this, then boot again.                                    ณ');
  Writeln('ณ                                                                            ณ');
  Writeln('ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู');
  Writeln;
end;

{***************************************************************************}
Procedure Screen(scr: ScreenType);

{ This procedure makes a window of the screen the current one. }

Begin
  case scr of
    upper:  Window(1,1,80,14);
    lower:  Window(1,15,80,25);
  else
    Window(1,1,80,25);
  end;
End;

{ The remote control include files: }
{$iRCM.INC}      { the functions open/close and write to the device driver }
{$iREMOTE.INC}   { the extended control functions }

{***************************************************************************}
Procedure _IOctl;

{ This procedure will set the baudrate and the portno to the desired values.
  The value of the function expresses whether this could be done correctly. }

Var
  Baudrate: integer;
  Portno  : byte;
  InputOK:  boolean;
Begin
    {ask for the desired portno. and the baudrate: }
    Repeat
      Writeln;
      Writeln('ออออออออออออออออออออ IO ctl อออออออออออออออออออออออออออออออออ');
      Write('Desired Baudrate: (150/300/600/1200/2400/4800/9600): ');
      Readln(BaudRate);

      Write('Desired Portno: (1/2): '); Readln(Portno);

      InputOk := ( (Baudrate div 50) in [3,6,12,24,48,96,192])
                   and (Portno in [1,2]);
      if not InputOK
      then Writeln('Incorrect Baudrate or portno; Please re-specify.')
    until InputOK;
    Write ('Setting the new values ... ');
    if IOCtl(Baudrate,Portno) then
      Writeln ('Done. ')
    else begin
      writeln('Error');
      Beep;
    end
end; { of procedure _IOctl }

{***************************************************************************}
Procedure _EquipmentAvailable;

{ This procedure performs the function Are You There. It will ask if the
  equipment is available and if so, it will display the Equipment Model Type
  and the software revision code.
}

Var
  i:          byte;

Begin
    Writeln;
    Writeln('ออออออออออออออออออออ Equipment Available อออออออออออออออออออออออออออ');
    if EquipmentAvailable
    then
      Writeln ('Equipment is available.')
    else
    begin
      Writeln('Equipment is not available.');
      Beep;
    end
End; { of procedure _EquipmentAvailable. }


{***************************************************************************}
Procedure _Pushbutton(presskind: presskindtype);

{ This procedure ask which pushbutton must be pressed and presses it on, or
  off, depending of presskind.
}

Var
  Act_Type,Answer,Id:     byte;
  AnswerOk:               boolean;

Begin
  {ask which pushbutton must be pressed: }
  Writeln('ออออออออออออออออออออ Push Button อออออออออออออออออออออออออออออ');
  Writeln('1 = Algn        10 = Exp2        19 = Photo       28 = Slow');
  Writeln('2 = Autofoc     11 = Exp3        20 = Reset       29 = Set');
  Writeln('3 = AutoSgnl    12 = ExchSgnl    21 = Ready       30 = TV');
  Writeln('4 = Cross       13 = Fast        22 = RST         31 = WA');
  Writeln('5 = D           14 = Fine        23 = Stig        32 = Wbl');
  Writeln('6 = DF                           24 = SGNL        33 = Ymode');
  Writeln('7 = Exposure    16 = Inverted    25 = Split       34 = YZmode');
  Writeln('8 = ExchMode    17 = Line        26 = SA          35 = Zmode');
  Writeln('9 = Exp1        18 = Mag         27 = Scanstop');
  Writeln;

  Repeat
    Write('Select a pushbutton: (1..35) '); Readln(Answer);
    AnswerOk := Answer in [1..14,16..35];
    if not AnswerOk
    then
    begin
      Writeln ('Incorrect pushbutton id; please re-specify.');
      beep;
    end;
  until AnswerOk;

    case presskind of
      on: begin
            Act_Type := 1;
            Write('Pressing the button on ... ');
          end;
      off: begin
             Act_Type := 0;
               Write('Pressing the button off ... ');
           end;
      press: begin
               Act_Type := 2;
               Write('Pressing the button ... ');
             end;
    end;

    case Answer of
      1: Id := Algn;
      2: Id := Autofoc;
      3: Id := AutoSgnl;
      4: Id := Cross;
      5: Id := D;
      6: Id := DF;
      7: Id := Exposure;
      8: Id := ExchMode;
      9: Id := Exp1;
      10: Id := Exp2;
      11: Id := Exp3;
      12: Id := ExchSgnl;
      13: Id := Fast;
      14: Id := Fine;
    { 15: Id := HT;            not remote controllable  }
      16: Id := Inverted;
      17: Id := Line;
      18: Id := Mag;
      19: Id := Photo;
      20: Id := Reset;
      21: Id := Ready;
      22: Id := RST;
      23: Id := Stig;
      24: Id := SGNL;
      25: Id := Split;
      26: Id := SA;
      27: Id := Scanstop;
      28: Id := Slow;
      29: Id := SetContrast;
      30: Id := TV;
      31: Id := WA;
      32: Id := Wbl;
      33: Id := Ymode;
      34: Id := YZmode;
      35: Id := Zmode;
    end; {of case statement }

    { call the device driver and check the returned status }
    if Pushbutton(Id,Act_Type) then
      { function performed correctly. }
      Writeln('Done.')
    else begin
      Writeln('Error');
      Beep;
    end
End; { of procedure _Pushbutton}

{***************************************************************************}
Procedure _Softkey;

{ This procedure asks for and presses a softkey. }

VAR
  Id,count:   byte;
  Answerok:   boolean;

Begin
  { ask for the key to press: }
  Answerok := False;
  Writeln('ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ');
  Writeln('ฦอ 0                           8 อต  Select a key to press (0 .. 15): ');
  Writeln('ฦอ 1                           9 อต');
  Writeln('ฦอ 2                          10 อต');
  Writeln('ฦอ 3                          11 อต  No. of Presses:');
  Writeln('ฦอ 4                          12 อต');
  Writeln('ฦอ 5                          13 อต');
  Writeln('ฦอ 6                          14 อต');
  Writeln('ฦอ 7                          15 อต');
  Write  ('ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู');


    Repeat
      GotoXY(71,2);
      Write('        ');
      GotoXY(71,2);
      Readln(Id);
      if Id in [0 .. 15]
      then
      begin
        AnswerOk := True;
        GotoXY(36,3); Write('                                           ');
      end
      else
      begin
        GotoXY(37,3);
        Writeln ('Incorrect Softkey number; please re-specify.');
      end;
    until AnswerOK;

    GotoXY(54,5);
    Readln(Count);
    GotoXY(37,7);
    write('Pressing Softkey ',Id:2,', ',Count:3,' times ... ');

    if Softkey(Id,count) then { function performed correctly. }
      Writeln('Done.')
    else begin
      Writeln('Error.');
      Beep;
    end;
    GotoXY(37,9);
End; { of procedure _Softkey}

{***************************************************************************}
Procedure _Turnknob;

{ This function asks which turn-knob must be turned and tells the microscope
  to turn the knob.
}

Var
  Answer,Id:   byte;
  Count:       integer;
  AnswerOk:    boolean;

Begin
  Writeln;
  Writeln('ออออออออออออออออออออ Turn Knob อออออออออออออออออออออออออออออออออออ');
  Writeln('  1: Ratio               6: Focus           11: Multi Function X');
  Writeln('  2: Contrast            7: Stepsize        12: Multi Function Y');
  Writeln('  3: Brightness          8: Intensity       13: Spotsize');
  Writeln('  4: Zoom                9: Shift X         14: Filament');
  Writeln('  5: Magnification      10: Shift Y');

  { ask which knob must be turned: }
  Repeat
    Write('Select a knob to turn (1 .. 14): '); Readln(Answer);
    AnswerOk := Answer in [1 .. 14];
    if not AnswerOK
    then
    begin
      Writeln ('Invalid knob id; please re-specify.');
      Beep;
    end
  until answerok;

    Case Answer of
      1:  Id := Ratio;
      2:  Id := Contrast;
      3:  Id := Brightness;
      4:  Id := Zoom;
      5:  Id := Magn;
      6:  Id := Focus;
      7:  Id := Step;
      8:  Id := Intens;
      9:  Id := Shiftx;
      10: Id := Shifty;
      11: Id := Mfx;
      12: Id := Mfy;
      13: Id := SpotSize;
      14: Id := Filament;
    end; { of case statement }

    Write('Turn count: '); Readln(Count);
    { call the device driver and check the returned status }
    Write('Performing the function ... ');
    if Turnknob(Id,Count) then { function performed correctly. }
      Writeln('Done.')
    else begin
      Writeln('Error');
      Beep;
    end
End; { of procedure _Turnknob}

{***************************************************************************}
Procedure _InstrumentMode;

Var
  Answer:   byte;
  AnswerOk: boolean;

Begin
  Writeln;
  Writeln('ออออออออออออออออออออ Instrument Mode ออออออออออออออออออออออออออออ');
  Writeln('1: Micro Probe Scan   4: Post Specimen Scan   7: Tem Low Dose');
  Writeln('2: Nano  Probe Scan   5: Rocking Beam         8: Tem');
  Writeln('3: Nano  Probe        6: Scanning');

  { ask which operations must be executed: }
  Repeat
    Write('Select an Instrument Mode: '); Readln(Answer);
    AnswerOk := Answer in [1 .. 8];
    if not AnswerOk
    then
    begin
      Writeln ('Invalid Instrument Mode; please re-specify.');
      Beep;
    end;
  until answerok;

  if InstrumentMode(Answer) then { function performed correctly. }
      Writeln('Done.')
    else begin
      Writeln('Error');
      Beep;
    end
End; { of procedure _InstrumentMode}

{***************************************************************************}
Procedure _DirectOperations;

Var
  Parameter: integer;
  Answer:   byte;
  AnswerOk: boolean;

Begin
  Writeln('ออออออออออออออออออออ Direct Operations ออออออออออออออออออออออออออออ');
  Writeln(' 1: Switch to D Mode                 9: Set High Tension to Maximum');
  Writeln(' 2: Set Focus Stepsize              10: Beam Blank On');
  Writeln(' 3: Set HM/SA magnification         11: Beam Blank Off');
  Writeln(' 4: Set High Tension Step           12: Edx Protection On');
  Writeln(' 5: Switch to LAD Mode              13: Edx Protection Off');
  Writeln(' 6: Set LM magnification            14: External XY Control On');
  Writeln(' 7: Press Ready                     15: External XY Control Off');
  Writeln(' 8: Set Spotsize');
  Writeln;

  { ask which operations must be executed: }
  Repeat
    Write('Select an operation to execute (1 .. 15): '); Readln(Answer);
    AnswerOk := Answer in [1..15];
    if not AnswerOk
    then
    begin
      Writeln ('Invalid operation id; please re-specify.');
      Beep;
    end;
  until answerok;

  if answer in [1 .. 8] then begin
    Write('Parameter Value: '); Readln(parameter);
  end
  else parameter := 0;

  Write('Performing the function ... ');
  if DirectOperation(Answer,Parameter) then
    Writeln('Done.')
  else
  begin
    Writeln('Error');
    Beep;
  end
End; { of procedure _DirectOperations }

{***************************************************************************}
Procedure _CurrentReadout;
var c:CurrentType;
    i : integer;

Begin
  Writeln;
  Writeln('ออออออออออออออออออออ Current Read-out อออออออออออออออออออออออออออออ');
    if CurrentReadout(c) then begin

       { display the currents: }
       writeln('Currents: [mA]');
       writeln;
       for i := 1 to 9 do
          write(c[i]:8:1);
       writeln;
       for i := 10 to 18 do
          write(c[i]:8:1);
       writeln;
       for i := 19 to Currentsize do
          write(c[i]:8:1);
       Writeln;
  end
End;

{***************************************************************************}
Procedure _PressureReadout;
var p:PressureType;
    pi: array[1..PressureSize] of integer;
    i : integer;
Begin
  Writeln;
  Writeln('ออออออออออออออออออออ Pressure Read-out ออออออออออออออออออออออออออออ');
    if PressureReadout(P) then begin
       for i := 1 to PressureSize do
         pi[i] := Trunc(p[i]);
       writeln('Pressures: ',pi[1]:4,pi[2]:4,pi[3]:4,pi[4]:4)
  end
End;

{***************************************************************************}
Procedure _ScreenCurrent;

var is:real;

Begin
  Writeln;
  Writeln('ออออออออออออออออออออ Screen Current อออออออออออออออออออออออออออออออออ');
  Writeln;
  if ScreenCurrent(is)
  then
  begin
    if is > 1.0E30 then is := 0.0;
    Writeln('The Screen Current is ',is,' A')
  end
  else
    Writeln('Error');
End;

{***************************************************************************}
Procedure _VideoSignal;
var
   bl,br:byte;
   b    :boolean;
Begin
  Writeln;
  Writeln('ออออออออออออออออออออ Video Signal ออออออออออออออออออออออออออออ');
  b := VideoL(bl) and VideoR(br);
  if b then  begin
     Writeln('The Video signals are',bl:4,' and',br:4);
     Writeln('(White = 0, Black = 255)');
  end
End;

{***************************************************************************}
Procedure _EmissionCurrent;

var ie:real;
Begin
  Writeln;
  Writeln('ออออออออออออออออออออ Emission Current อออออออออออออออออออออออออออออออออ');
  if EmissionCurrent(ie)  then
    if ie < 1.0E31 then
      Writeln('The Emission Current is ',ie,' A')
    else
      Writeln('Emission Current is out of range');
End;

{***************************************************************************}
Procedure _GetMode;

{ This function asks for a filename to store the mode in; gets it and saves
  it in this file.
}

Var
  ModeFile: File of ModeType;
  Filename: String[20];

Begin
  Writeln;
  Writeln('ออออออออออออออออออออ Get Mode อออออออออออออออออออออออออออออออออออ');
  write('Give filename to save the mode in: '); readln(filename);
    Write('trying to get the mode ... ');

    { call the device driver and check the returned status }
    if GetMode(ModeRec)
    then { function performed correctly. }
    begin
      write('Saving the mode ... ');
      assign(modefile, Filename );
      rewrite(modefile);
      write(modefile, ModeRec);
      close(modefile);
    end
    else begin
      Writeln('Error');
      Beep
    end
End; { of procedure _GetMode }

{***************************************************************************}
Procedure _SetMode;

{ This function asks for a filename to retrieve the mode off and restores it }

Var
  ModeFile: File of ModeType;
  Filename: String[20];

Begin
  Writeln;
  Writeln('อออออออออออออออออออออ Set Mode ออออออออออออออออออออออออออออออออออ');
  write('Give filename to retrieve mode of: '); readln(filename);

  assign(Modefile,Filename );
  reset(Modefile);
  read(Modefile, ModeRec);
  close(modefile);

    write('Setting the Mode ... ');
    if SetMode(ModeRec) then { function performed correctly. }
      Writeln('Done.')
    else begin
      Writeln('Error');
      Beep;
    end
End; { of procedure _SetMode }

{***************************************************************************}
Procedure _GetStigmator;

{ This function asks for a filename to store the Stigmators in; gets them
  and saves them in this file. }

Var
  StigFile: File of StigType;
  Filename: String[20];

Begin
  Writeln;
  Writeln('อออออออออออออออออออออ Get Stigmator Settings ออออออออออออออออออออ');
  write('Give filename to save the stigmator settings in: ');readln(filename);
    Write('trying to get the stigmator ... ');

    if GetStigmator(StigRec) then { function performed correctly. } begin
      write('Saving the stigmator settings ... ');
      assign(Stigfile, Filename );
      rewrite(Stigfile);
      write(Stigfile, StigRec);
      close(Stigfile);
      writeln('Done.');
    end
    else begin
      Writeln('Error');
      Beep;
    end
End; { of procedure _GetStigmator }

{***************************************************************************}
Procedure _SetStigmator;

{ This function asks for a filename to retrieve the Stigmator settings of,
  a stigmator which should be restored and restores it. }

Var
  StigNr  :  byte;
  StigFile:  File of StigType;
  Filename:  String[20];
  Stigmator: Char;
  Error:     Boolean;
  AnswerOk: boolean;

Begin
  Writeln;
  Writeln('อออออออออออออออออออออ Set Stigmator Settings ออออออออออออออออออออ');
  write('Give filename to retrieve Stig of: '); readln(filename);

  assign(Stigfile,Filename );
  reset(Stigfile);
  read(Stigfile, StigRec);
  close(Stigfile);

  Writeln('Wich Stigmator setting must be reset;');
  Repeat
    Writeln('the Objective, the Condensor, or the Diffraction stigamtor (O/C/D)? ');
    Readln(Stigmator);
    AnswerOK := Stigmator in ['o','O','c','C','d','D'];
    if not AnswerOk
    then
    begin
      writeln('Incorrect answer; please re-specify which Stigmator must be reset;');
      beep;
    end;
  until AnswerOk;

  Case Upcase(Stigmator) of
    'C': StigNr := 0;
    'O': StigNr := 1;
    'D': StigNr := 2;
  end; { of case statement }

    if not error then begin
      write('Setting the Stig ... ');

      { call the device driver and check the returned status }
      if SetStigmator(StigRec,StigNr) then { function performed correctly. }
        Writeln('Done.')
      else begin
        Writeln('Error');
        Beep;
      end
    end { of if not error statement }
End; { of procedure SetStig }

{***************************************************************************}
Procedure _GetAlignments;

VAR
  AlignmentsFile: File of AlignmentsType;
  Filename:       String[20];
  Status:         byte;

Begin
  Writeln;
  Writeln('อออออออออออออออออออออ Get Alignments ออออออออออออออออออออออออออออ');
  Write('Filename to store the alignments in: '); Readln(Filename);

  write('Retrieving Alignments ... ');
  if GetAlignments(Alignments) then begin
    write('Saving the Alignments ... ');
    assign(Alignmentsfile, filename );
    rewrite(Alignmentsfile);
    write(Alignmentsfile, Alignments);
    writeln('done.');
    close(Alignmentsfile);
  end
  else begin
    Writeln('Error');
    Beep;
  end
End;

{***************************************************************************}
Procedure _SetAlignments;

{ this function ask for a file to retrieve the alignments out of and restores
  them.  }

VAR
  AlignmentsFile: File of AlignmentsType;
  Filename:       String[20];
  Status:         byte;

Begin
  Writeln;
  Writeln('อออออออออออออออออออออ Set Alignments ออออออออออออออออออออออออออออ');
  Write('  Filename to retrieve the alignments out of: '); Readln(Filename);

  assign(Alignmentsfile, Filename );
  reset(Alignmentsfile);
  read(Alignmentsfile, Alignments);
  close(Alignmentsfile);

  if SetAlignments(Alignments) then
    writeln('Alignments set from: ',filename)
  else begin
    Writeln('Error');
    Beep
  end
End;

{***************************************************************************}
Procedure _RetrHTCondition;

{ This procedure retrieves and displays the boolean value of the HT condition }
Var HT : boolean;
Begin
  Writeln;
  Writeln('อออออออออออออออออออออ HT Condition ออออออออออออออออออออออออออออออ');

    Write('Retrieving the HT condition ... ');
    if RetrHTcondition(HT) then
    Begin
      if ht then
        writeln('The HT may be switched on')
      else
        writeln('The HT may not be switched on')
    End
    else begin
      Writeln('Error');
      Beep;
    end
End; { of procedure _RetrHTCondition. }

{***************************************************************************}
Procedure _RetrEDXprot;

{ This procedure retrieves and displays whether the Edx protection is on. }

Var Edxprt : boolean;

Begin
  Writeln;
  Writeln('อออออออออออออออออออออ Edx Protection ออออออออออออออออออออออออออออ');

    if RetrEdxProt(EdxPRt)
    then { function performed correctly. }
      if EdxPrt
      then
        writeln('The Edx Protection is on')
      else
        writeln('The Edx Protection is off')
    else begin
      writeln('Error');
      Beep;
    end
End; { of procedure _RetrEDXprot. }

{***************************************************************************}
Procedure _RetrEXTXYDefl;

{ This procedure retrieves and displays the boolean value of the Ext. XY Defl }

Var  x : boolean;

Begin
  Writeln;
  Writeln('อออออออออออออออออออออ Ext. XY Defl ออออออออออออออออออออออออออออออ');
  Write(' Retrieving the Ext. XY Control ... ');
    if RetrExtXYDefl(x) then  { function performed correctly. }
      if x then
        writeln('The Ext. XY Control is on')
      else
        writeln('The Ext. XY Contol is off')
    else begin
      Writeln('Error');
      Beep
    end
End; { of procedure ExtXYDefl. }

{**************************************************************************}
procedure _StartDisplayInfo;

Var
  Filename: WrkString;
  Answer: char;
  Append: boolean;

Begin
  Writeln;
  Writeln('อออออออออออออออออ Start Display Info ออออออออออออออออออออออออออออ');
  Writeln;
  Write('Filename to save display information in: '); Readln(Filename);
  Write('Append this information to the (maybe) already existing one (Y/N) ');
  Readln(Answer);
  Append := ( Answer in ['Y','y'] );

  if  StartDisplInfo(filename, append) then
    Writeln('Beginning to store Display Info in file ', Filename);
end;


{**************************************************************************}
procedure _StopDisplayInfo;
Begin
  Writeln;
  Writeln('อออออออออออออออออ Stop Display Info ออออออออออออออออออออออออออออ');
  Writeln;
  if  StopDisplInfo then
    Writeln('Stopping to store Display Info');
end;

{***************************************************************************}
{**                                                                       **}
{**                   The Test Program functions.                         **}
{**                                                                       **}
{***************************************************************************}

{**************************************************************************}
Procedure InitScreen;

{ This procedure displays all the functions on the screen }

Begin
  Screen(total);
  Clrscr;

  Writeln('ษอออออออออออออออออออออัออออออต0: Stopฦออออออออัออออออออออออออออออออออป');
  Writeln('บ 1 IO ctl            ณ   HRDS Commands:      ณ Status Information:  บ');
  Writeln('วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด  9 Current Read-out   ณ  17 Get Mode         บ');
  Writeln('บ 2 Are You There     ณ 10 Pressure Read-out  ณ  18 Set Mode         บ');
  Writeln('วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด 11 Screen Current     ณ  19 Get Stigmator    บ');
  Writeln('บ Panel Functions:    ณ 12 Video Signal       ณ  20 Set Stigmator    บ');
  Writeln('บ 3 Pushbutton On     ณ 13 Emission Current   ณ  21 Get Alignments   บ');
  Writeln('บ 4 Pushbutton Off    รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด  22 Set Alignments   บ');
  Writeln('บ 5 Press Pushbutton  ณ Display Information:  รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ');
  Writeln('บ 6 Press Softkey     ณ 14 Start Display Info ณ  Retrieve Info       บ');
  Writeln('บ 7 Turn Knob.        ณ 15 Stop  Display Info ณ  23 HT Condition     บ');
  Writeln('วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด  24 EDX Protection   บ');
  Writeln('บ 8 Direct Operations ณ 16 Instrument Mode    ณ  25 EXT. XY Defl     บ');
  Writeln('ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ');

  Screen(lower);
End;

{**************************************************************************}
Function AskFunction: FunctionNumbers;

{ This procedure asks which function must be performed and returns the code. }

Var
  Answer:         String [5];
  NewChoice:      Integer;
  Code:           Integer;
  AnswerFormatOK: Boolean;

Begin
  ClrScr;
  Repeat
    Write  ('Make a choice <', Choice, '>: ');
    Read(Answer);
    if answer = ''
    then
    begin
      NewChoice := Choice;
      AnswerFormatOk := true
    end
    else { not carriage return but new number; check the format }
    begin
      Val(Answer, NewChoice, Code);
      AnswerFormatOK :=  ( Code = 0 )
                     and ( 0 <= NewChoice )
                     and ( NewChoice <= MaxFunctionNumber);
      if not answerFormatOk then Write('Incorrect Function number. ');
    end;
  until AnswerFormatOk;
  AskFunction := NewChoice;
End;



{**************************************************************************}
{**                                                                      **}
{**            T h e   M a i n   P r o g r a m.                          **}
{**                                                                      **}
{**************************************************************************}

BEGIN
  Choice := 0;
  Stop := not OpenRemoteCM;
  { if device driver could not be opened, then stop: }
  { write a message on the screen indicating the driver is not present: }
  if Stop
  then Nodriver
  else {device driver is open now: }
    begin
      InitScreen;
      Repeat
        Choice := AskFunction;
        Screen(lower);
        ClrScr;
        Case Choice of
          0: Stop := True;
          1: _IOctl;
          2: _EquipmentAvailable;
          3: _Pushbutton(ON);
          4: _Pushbutton(Off);
          5: _Pushbutton(Press);
          6: _Softkey;
          7: _Turnknob;
          8: _DirectOperations;
          9: _CurrentReadout;
          10: _PressureReadout;
          11: _ScreenCurrent;
          12: _VideoSignal;
          13: _EmissionCurrent;
          14: _StartDisplayInfo;
          15: _StopDisplayInfo;
          16: _InstrumentMode;
          17: _GetMode;
          18: _SetMode;
          19: _GetStigmator;
          20: _SetStigmator;
          21: _GetAlignments;
          22: _SetAlignments;
          23: _RetrHTCondition;
          24: _RetrEDXprot;
          25: _RetrEXTXYDefl;
        end; { of case statement }

        { wait until any key pressed: }
        if not Stop
        then
        begin
          Write('Press Any key to continue ... ');
          Readln(kar);
        end;

      until stop;

      {close the device driver: }
      CloseRemoteCM;

    end; { of if stop statement }
  Writeln('Stop Program.');
end.
