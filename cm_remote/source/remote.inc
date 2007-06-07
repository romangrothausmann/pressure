{*************************************************************************}
{*************************************************************************}
{                                                                         }
{                          R E M O T E . I N C                            }
{                                                                         }
{   Include File for the extended CM microscope Remote Control functions  }
{                                                                         }
{   (C)  1988    Copyright PHILIPS EXPORT B.V., All Rights Reserved       }
{                                                                         }
{*************************************************************************}
{*************************************************************************}

Const

  AlignmentsSize = 5000; { length of alignments array        }
  CurrentSize    = 26;   { no. of currents to be retrieved.  }
  ModeSize       = 250;  { length of mode settings array.    }
  PressureSize   = 4;    { no. of pressures to be retrieved. }
  StigmatorSize  = 1500;  { length of stigmator array.        }

  StringSize =     80;   { length of a work string.          }


Type

  IntelReal = array[0..3] of byte;        { the format of a 8087 real }

  PressureType = array[1..Pressuresize] of real;

  CurrentType  = array[1..CurrentSize] of real;

  AlignmentsType = Record
    fnid:          integer;
    status:        byte;
    Alignlength:   integer;
    Alignments:    Array [1..AlignmentsSize] of byte;
  end;

  ModeType =       Record
    fnid:          integer;
    status:        byte;
    modelength:    byte;
    Mode:          Array [1..ModeSize] of byte;
  end;

  StigType =       Record
    fnid:          integer;
    status:        byte;
    Stiglength:    integer;
    Stig:          array[1..StigmatorSize] of byte;
  end;

  WrkString=       String[StringSize];


Var
  Alignments:      AlignmentsType;
  CurrentRec:      CurrentType;
  ModeRec:         ModeType;
  PressureRec:     PressureType;
  StigRec:         StigType;

{***************************************************************************}
function TurboReal(u:IntelReal):real;

{ This function converts a 4-byte short intel real to the 6-bytes format
  used by Turbo Pascal.

  input:  the 4-byte 'INTEL'-real
 output: the 6-byte 'Turbo Pascal'-real

  The details are:

  INTEL format:

  <---- High Memory                                      Low Memory -->
       Byte 3            Byte 2            Byte 1           Byte 0
  x x x x x x x x | x x x x x x x x | x x x x x x x x | x x x x x x x x
  | +---------------+ +-----------------------------------------------+
  |   Exponent,         MSB            Mantissa                   LSB
  |   bias $7F
  +-- Sign bit

Turbo Pascal Format:

     Byte: 5        4          3          2          1          0
     xxxxxxxx | xxxxxxxx | xxxxxxxx | xxxxxxxx | xxxxxxxx | xxxxxxxx
     |+-------------------------------------------------+   +------+
     |  MSB                Mantissa                  LSB    Exponent
     +- Sign Bit                                            Bias $80
}

var
  v: real;
  vb: array[0..6] of byte absolute v;
begin
  if u[3]=0  then
    TurboReal := 0.0
  else begin
    vb[0] := ((u[3] + 1) and $7F) shl 1;
    if (u[2] and $80) <> 0 then
      vb[0] := vb[0] + 1;
    vb[5] := (u[3] and $80) or (u[2] and $7F);
    vb[4] := u[1];
    vb[3] := u[0];
    vb[2] := 0;
    vb[1] := 0;
    TurboReal := v;
  end
end;


{***************************************************************************}
function CurrentReadout(var c:CurrentType):boolean;
Const
   CurrentId:     array[0..25] of byte = ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,
                                          13,14,15,16,17,18,19,20,21,22,23,24,25);
Type
  CurrentRType =  Record
    fnid:          integer;
    status:        byte;
    number:        byte;
    IDOfs:         integer;
    IdSeg:         integer;
    RCMOfs:        integer;
    RCMSeg:        integer;
  end;
Var
  i           : integer;
  CurrentRRec : CurrentRType;
  CurrentRCM : array[1..CurrentSize] of IntelReal;

Begin
  with CurrentRRec do  begin
    fnid  := $C445;
    number:= 26;
    IDSeg := Seg(CurrentID);
    IDOfs := Ofs(CurrentID);
    RCMSeg:= Seg(CurrentRCM);
    RCMOfs:= Ofs(CurrentRCM);
    CurrentReadout := CallRemoteCM(CurrentRRec) = 0;
    for i := 1 to CurrentSize do
      c[i] := TurboReal(CurrentRCM[i]);
  end {with }
End;

{***************************************************************************}
function DirectOperation(DO_Id,Param:byte):boolean;
Type
  DiropType = Record { the structure of the function DirectOperations }
    fnid:      integer;
    status:    byte;
    parameter: byte;
  end;
Var
  DiropRec: DiropType;

Begin
  With DiropRec do begin
    case DO_Id of
      1: fnid := $C741;
      2: fnid := $C743;
      3: fnid := $C745;
      4: fnid := $C747;
      5: fnid := $C749;
      6: fnid := $C74B;
      7: fnid := $C74D;
      8: fnid := $C74F;
      9: fnid := $C781;
      10: fnid := $C793;
      11: fnid := $C795;
      12: fnid := $C797;
      13: fnid := $C799;
      14: fnid := $C79B;
      15: fnid := $C79D;
      else
      begin
        DirectOperation := False;
        Exit
      end
    End; { of case statement }
    parameter := Param;
    DirectOperation := CallRemoteCM(DiropRec) = 0
  End { of with statement }
End; { of procedure DirectOperations }


{***************************************************************************}
function EmissionCurrent(var ie:real):boolean;
type
  RetrRealType = Record
    fnid: integer;
    status: byte;
    rvalue: IntelReal;
  end;
var RetrRealRec : RetrRealType;

Begin
  with RetrRealRec do begin
    fnid := $C44F;
    EmissionCurrent := CallRemoteCM(RetrRealRec) = 0;
    ie := TurboReal(rvalue);
  end { with }
End;


{***************************************************************************}
function EquipmentAvailable:boolean;

{ This procedure performs the function Are You There. The value of the
  function expresses whether the equipment is available or not.
}

Type
  EqAvailType = Record  { the structure of the function  Equipment Available }
    fnid:     integer;
    status:   byte;
    Model:    Array [1..6] of char;
    Version:  Array [1..6] of char;
  end;

Var
  EqavailRec: Eqavailtype;
  i:          byte;

Begin
  With EqavailRec do
  Begin
    fnid := $8101;
    { call the device driver and check the returned status }
    EquipmentAvailable := CallRemoteCM(EqAvailRec) =  0
  End { of with statement }
End; { of procedure EquipmentAvailable. }

{***************************************************************************}
function GetAlignments(var Alignments: AlignmentsType):boolean;

Begin
  Alignments.fnid := $C54D;
  GetAlignments :=  CallRemoteCM(Alignments) = 0
End;

{***************************************************************************}
Function GetMode(var ModeRec:ModeType):boolean;

{ This function retrieves the mode setting and stores it in a given record }

Begin
  ModeRec.fnid  := $C541;
  GetMode :=  CallRemoteCM(ModeRec) = 0
End; { of procedure GetMode }

{***************************************************************************}
function GetStigmator(var StigRec:StigType):boolean;

{ This function retrieves the stigmator settings }

Begin
  StigRec.fnid := $C545;
  GetStigmator := CallRemoteCM(StigRec) = 0;
End; { of procedure GetStigmator }


{***************************************************************************}
Function InstrumentMode(Mode_Id:byte):boolean;

Type
  InstrModeType = Record
    fnid:   integer;
    status: byte;
  end;

Var
  InstrModeRec: InstrModeType;

Begin
  with InstrModeRec do begin
    if Mode_Id in [1..8] then
      fnid := $C781+ 2 * Mode_Id
    else begin
      InstrumentMode := False;
      Exit
    end;
    InstrumentMode :=  CallRemoteCM(InstrModeRec) = 0
  End { of with statement }
End; { of procedure InstrumentMode}

{***************************************************************************}
function IOctl(Baud,Port:integer):boolean;

{ This procedure will set the baudrate and the portno to the desired values.
  The value of the function expresses whether this could be done correctly.
}

Type
  IOctlType = record
    fnid:     integer;
    status:   byte;
    PortNo:   byte;
    Baudrate: integer;
    T1:       byte;
    T2:       byte;
    T3:       byte;
    RTY:      byte;
    Slave:    byte;
  end;

Var
  IOctlRec: IOctlType;        { the structure of the function }

Begin
  with IOctlRec do  begin
    BaudRate := Baud;
    Portno := Port;
    fnid     := 0;
    T1       := $FF;
    T2       := $FF;
    T3       := $FF;
    Rty      := $FF;
    Slave    := $FF;
    IOCtl :=  CallRemotecm(IOctlRec) = 0
  end
end; { IOCtl }

{***************************************************************************}
function PressureReadout(var p:PressureType):boolean;

Const
   PressureId: array[1..PressureSize] of byte = (1,2,3,4);

Type
  PressureRType =  Record
    fnid:          integer;
    status:        byte;
    number:        byte;
    IDOfs:         integer;
    IdSeg:         integer;
    RCMOfs:        integer;
    RCMSeg:        integer;
  end;

Var
  i           : integer;
  PressureRec : PressureRType;
  PressureRCM : array[0..3] of IntelReal;

Begin
  with PressureRec do  begin
    fnid  := $C447;
    number:= 4;
    IDSeg := Seg(PressureID);
    IDOfs := Ofs(PressureID);
    RCMSeg:= Seg(PressureRCM);
    RCMOfs:= Ofs(PressureRCM);
    PressureReadout := CallRemoteCM(PressureRec) = 0;
    for i := 1 to PressureSize do
      p[i] := TurboReal(PressureRCM[i-1]);
  end {with }
End;

{***************************************************************************}
Function Pushbutton(Pb_Id,Act_Type:byte):boolean;

{ This function presses a pushbutton on or off, depending of Act_Type }

Type
  PushbuttonType = Record
    fnid:   integer;
    status: byte;
    Id:     byte;
  end;
Var
  PushbuttonRec: PushbuttonType;

Begin
  With PushbuttonRec do
  begin
    Id := Pb_Id;
    case Act_Type of
      1: fnid := $C041;
      0: fnid := $C043;
      2: fnid := $C045;
      else begin
        Pushbutton := False;
        Exit
      end
    end;
    Pushbutton := CallRemoteCM(PushButtonRec) = 0
  End { of with statement }
End; { of procedure Pushbutton}

{***************************************************************************}
function RetrEdxProt(var p:boolean):boolean;

{ This procedure retrieves the Edx protection  }

Type
  RetrBoolType = Record { the structure of the retrieve boolean functions }
    fnid:   integer;
    status: byte;
    value:  byte;
  end;
Var
  EdxProtRec: RetrBoolType;
Begin
  EdxProtRec.fnid := $C345;
  RetrEDXprot := CallRemoteCM(EdxProtRec) = 0;
  p := EdxProtRec.value<>0;
End; { of procedure RetrEdxProt. }

{***************************************************************************}
function RetrExtXYdefl(var x:boolean):boolean;

{ This procedure retrieves the boolean value of the Ext XY Defl }
Type
  RetrBoolType = Record { the structure of the retrieve boolean functions }
    fnid:   integer;
    status: byte;
    value:  byte;
  end;
Var
  ExtXYDeflRec: RetrBoolType;

Begin
  ExtXYDeflRec.fnid := $C347;
  RetrExtXYdefl := CallRemoteCM(ExtXYDeflRec) = 0;
  x := ExtXYDeflRec.value<>0;
End;

{***************************************************************************}
function RetrHTcondition(var h:boolean):boolean;

{ This procedure retrieves  the boolean value of the HT condition }

Type
  RetrBoolType = Record { the structure of the retrieve boolean functions }
    fnid:   integer;
    status: byte;
    value:  byte;
  end;
Var
  HTCondRec: RetrBoolType;
Begin
  HTCondRec.fnid := $C343;
  RetrHTcondition := CallRemoteCM(HTCondRec) = 0;
  h := HTCondRec.value<>0;
End;

{***************************************************************************}
function ScreenCurrent(var is:real):boolean;
type
  RetrRealType = Record
    fnid: integer;
    status: byte;
    rvalue: IntelReal;
  end;
var
  RetrRealRec : RetrRealType;
  i:byte;

Begin
  with RetrRealRec do begin
    fnid := $C449;
    ScreenCurrent := CallRemoteCM(RetrRealRec) = 0;
    is := TurboReal(rvalue);
  end { with }
End;

{***************************************************************************}
function SetAlignments(Alignments:AlignmentsType):boolean;

{ this function restores the alignment settings }

Begin
  Alignments.fnid := $C54F;
  SetAlignments :=  CallRemoteCM(Alignments) = 0
End;

{***************************************************************************}
Function SetMode(ModeRec:ModeType):boolean;

{ This function restores a retrieved mode setting }

Begin
  ModeRec.fnid := $C543;
  SetMode :=  CallRemoteCM(ModeRec) = 0
End;

{***************************************************************************}
Function SetStigmator(StigRec:StigType;StigNr:byte):boolean;

{ This function restores the setting of a chosen stigmator }

Begin
  Case StigNr of
    0: StigRec.fnid := $C549;
    1: StigRec.fnid := $C547;
    2: StigRec.fnid := $C54B;
    else begin
      SetStigmator := False;
      Exit
    end
  end; { of case statement }
  SetStigmator :=  CallRemoteCM(StigRec) = 0;
End; { of procedure SetStig }


{***************************************************************************}
function Softkey(SK_Id,No_of_presses:byte):boolean;

{ This procedure presses the desired softkey. }

Var
  SoftkeyRec: Record
    fnid:   integer;
    status: byte;
    Id:     byte;
    Count:  byte;
  end;
Begin
  SoftkeyRec.Id := SK_Id;
  SoftkeyRec.Count := No_of_presses;
  SoftkeyRec.fnid := $C141;
  Softkey :=  CallRemoteCM(SoftkeyRec) = 0
End; { of procedure Softkey}

{***************************************************************************}
function StartDisplInfo(Filenam:WrkString; appnd: boolean): boolean;
{***************************************************************************}

Var
  i : integer;
  displayrec : record
    fnid : integer;
    status : byte;
    append : byte;
    filename : array [0..20] of char;
  end;
Begin
  With displayrec do begin
    fnid := $C641;
    if appnd
    then append := $FF
    else append := $00;

    { copy filename; terminate with zero: }
    for i := 1 to length(Filenam) do filename[i-1] := filenam[i];
    filename[i] := chr(0);

    StartDisplInfo := CallRemoteCM(displayrec) = 0
  End;
End;

{***************************************************************************}
function StopDisplInfo:boolean;
var
   displayrec : record
     fnid : integer;
     status : byte;
   end;
begin
  with displayrec do begin
    fnid := $C643;
    StopDisplInfo := CallRemoteCM(displayrec) = 0
  end;
end;


{***************************************************************************}
function TurnKnob(TK_Id:byte;TK_Count:integer):boolean;

{ This function tells the microscope to turn the knob. }
Var
  TurnKnobRec: record { the structure of the function turn knob. }
    fnid:   integer;
    status: byte;
    Id:     byte;
    Count:  integer;
  end;
Begin
  TurnKnobRec.fnid := $C241;
  TurnKnobRec.Id := TK_Id;
  TurnKnobRec.Count := TK_Count;
  TurnKnob := CallRemoteCM(TurnKnobRec) = 0
End;

{***************************************************************************}
Function VideoL(var v:byte):boolean;
Type
  RetrByteType = Record { the structure of the retrieve byte functions }
    fnid:   integer;
    status: byte;
    value:  byte;
    dummy:  array[0..2] of byte;
  end;
Var
  VideoRec: RetrByteType;
Begin
  VideoRec.fnid := $C44B;
  VideoL := CallRemoteCM(VideoRec) = 0;
  v := VideoRec.value;
End;

{***************************************************************************}
Function VideoR(var v:byte):boolean;

Type
  RetrByteType = Record { the structure of the retrieve byte functions }
    fnid:   integer;
    status: byte;
    value:  byte;
    dummy:  array[0..2] of byte;
  end;
Var
  VideoRec: RetrByteType;
Begin
  VideoRec.fnid := $C44D;
  VideoR := CallRemoteCM(VideoRec) = 0;
  v := VideoRec.value;
End;
