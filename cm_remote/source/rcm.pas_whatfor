{*************************************************************************}
{*************************************************************************}
{                                                                         }
{                             R C M . P A S                               }
{                                                                         }
{        (C) 1993 Copyright PHILIPS EXPORT B.V., All Rights Reserved      }
{                                                                         }
{*************************************************************************}
{*************************************************************************}

unit RCM;
{$M 40000, 100, 5000} {stack 40000, heapmin 100, heapmax 5000}
{full 8087 emulation:}
{$N+,E+}

{*************************************************************************}
{*************************************************************************}
INTERFACE
{*************************************************************************}
{*************************************************************************}

uses DOS;

Const
  AlignmentsSize = 6000; { length of alignments array          }
  CurrentSize    = 26;   { no. of currents to be retrieved.    }
  ModeSize       = 600;  { length of mode settings array.      }
  PressureSize   = 4;    { no. of pressures to be retrieved.   }
  StigmatorSize  = 2000; { length of stigmator array.          }
  GonNoOfReg     = 25;   { compustage: number of registers     }

  { used in GonGotoPos: }
  Recall = $40; { full 5 axes safe recall }
  XYonly = $C0; { xy recall }
  Xgoto  = $1;
  Ygoto  = $2;
  Zgoto  = $4;
  Agoto  = $8;
  Bgoto  = $10;
  { examples:
    safe goto all axes: use method RECALL;
    direct goto axes Z and B: use method (Zgoto or Bgoto);
  }
Type
  AlignmentsType = Record
    fnid:          Word;
    status:        byte;
    Alignlength:   Word;
    Alignments:    Array [1..AlignmentsSize] of byte;
  end;

  CurrentType  = array[1..CurrentSize] of single;

  InstrModeIdType = 1..8;

  ModeType =       Record
    fnid:          Word;
    status:        byte;
    modelength:    word;
    Mode:          Array [1..ModeSize] of byte;
  end;

  EqAvailType = Record  { the structure of the procedure  Equipment Available }
    fnid:     Word;
    status:   byte;
    Model:    Array [1..6] of char;
    Version:  Array [1..6] of char;
  end;

  OperationIdType = 1..15;

  PbActType = ( On, Off, Press);

  PressureType = array[1..Pressuresize] of single;

  RCMResultType =  ( {1: the values the device driver can return: }
                     Ok, InvalidFunctionId, EquipmentNotAvailable,
                     InvalidData, InvalidMicroscopeStatus, InvalidPCStatus,
                     DelayedExpected, DelayedError, IncorrectDeviceDriver,

                     { 2: The errors as translated by some functions }
                     NotAvailable, CannotPressButton, PressOnly,
                     DeviceDriverNotOpened, NoDeviceDriver,
                     DirectOperationImpossible, NotCalibrated,
                     InvalidPos, InvalidReg, InvPutGet);

  SkIdType = 0..15;

  SRSRegType = 1..99;

  StigType = (ObjStig, CondStig, DifStig);

  StigValuesType = Record
                     fnid:       Word;
                     status:     byte;
                     Stiglength: Word;
                     Stig:       array[1..StigmatorSize] of byte;
                   end;

  CMinfoType = Record
                 fnid:     Word;
                 status:   byte;
                 reserved: byte;
                 lngth:    byte; {length in bytes of following fields}
                 CmType:   byte;   {0..7: cm10/12/20/300/100/120/200/300}
                 ObjLens:  byte;   {0..3: High Contrast/Twin/Supertwin/Ultratwin}
                 DiffLens: byte;   {0..1: normal diffractionlens/special diffraction lens}
                 Gun:      byte;   {0..2: Tungsten/LAB6/FEG}
                 Magn:     single; {the magnification as displayed on data monitor}
                 HolderInserted: Boolean;
                 GonioMeter: byte;  {0..2: manual/compustage/SRS}
                 CompuEnabled: boolean; {true when compustage enabled}
                 Joysticks: byte; {bitwise: ...bazyx; 1 if enabled}
                 AxesAvail: byte; {bitwise: ...bazyx; 1 if available}
               end;

  CMvarType = Record
                fnid:        Word;
                status:      Byte;
                reserved:    Byte;
                lngth:       Byte;  {length in bytes of following fields}
                Page:        Word;
                ButtonState: Word;
                Magn:        single;
                HT:          single;
                D1:          single;
                D2:          single;
                Angle:       single;
                Spotsize:    single;
                Intensity:   single;
                BeamShiftX:  single;
                BeamShiftY:  single;
                ImageShiftX: single;
                ImageShiftY: single;
                MainScrn:    Word;
                DFmode:      Word;
                TVdetPos:    Word;
              end;

  FegDataType = record
                  fnid:   word;
                  status: byte;
                  lngth:  word;
                  state:  byte;
                  time:   byte;
                  disp:   array[1..6] of single;
                end;

  GonPosType = Array [1..5] of longint; {x y z a b}

  GonRegType = Record
                 Filled: Byte; {0: cleared; 1:filled; 2:do not change}
                 Pos:    GonPosType;
               End;

  GonRegistersType = Array [1..GonNoOfReg] of GonRegType;

Const
  PBPressOnlySet: Set of Byte =
                     [6, 7, 33..35, 37..39, 41, 45..49, 54..55, 61];

Var
  RCMResult: RCMResultType;
  EqAvail  : EqAvailType;

{*************************************************************************}
{functions and procedures: }

function  CallRemoteCM(var Instruction): RCMResultType;

procedure CurrentReadout (var Current: CurrentType);
procedure DirectOperation(OperationId: OperationIdType; Param:byte);
function  EmissionCurrent: single;

function  EquipmentAvailable:boolean;
function  CMversion: Integer;
procedure GetAlignments(var Alignments: AlignmentsType);
procedure GetMode(var ModeRec:ModeType);

procedure GetStigmator(var StigValues:StigValuesType);
procedure GetCmInfo (var CmInfo: CmInfoType);
procedure GetCMVar (var CmVar: CmVarType);
procedure GetFegData (var FegData: FegDataType);

procedure InstrumentMode(InstrModeId: InstrModeIdType);
procedure IOctl (Baud: Word; Port, T1, T2, T3, Retries: Byte);

procedure PressureReadout(var Pressure:PressureType);
procedure Pushbutton(PbId: byte; Act: PbActType);
function  RetrEdxProt: boolean;

function  RetrExtXYdefl: boolean;
function  RetrHTcondition: boolean;
procedure SetAlignments(Alignments:AlignmentsType);

procedure SetMode(Mode: ModeType);
procedure SetStigmator(StigValues: StigValuesType; Stig: StigType);
function  ScreenCurrent: single;

procedure Softkey(SKId: SKIdType; NoOfPresses: byte);
procedure StartDisplInfo(Filename:PathStr; appnd: boolean);
procedure StopDisplInfo;

procedure SwitchFreeHt (SwitchOn: Boolean);
procedure ChangeFreeHt (deltaHt: Real);
procedure SetTVdetPos (Pos: Byte);
procedure NormalizeImLenses;

procedure TurnKnob(TKId:byte; TKCount:integer);
function  VideoL: byte;
Function  VideoR: byte;

Procedure SRSCalibrate;
Procedure SRSGotoPos(x, y:longint);
Procedure SRSGotoReg(RegNr:SRSRegType);
Procedure SRSReadPos (var X, Y: longint);
Procedure SRSReadReg(RegNr: SRSRegType; var x, y:longint);
Procedure SRSSelReg (RegNr:SRSRegType);
Procedure SRSSetReg(RegNr:SRSRegType; x,y: longint);

Procedure GonAskPos (Var Pos: GonPosType);
Procedure GonGotoPos (Method:Byte; Pos: GonPosType);
Procedure GonGetRegisters (Var Regs: GonRegistersType);
Procedure GonSetRegisters (GonRegs: GonRegisterstype);

{*************************************************************************}
{*************************************************************************}
IMPLEMENTATION
{*************************************************************************}
{*************************************************************************}

Uses CRT;

Type
    InstructionType = Record    { the standard instruction form. }
      fnid:   word;
      status: byte;
    end;

  RetrBoolType = Record { the structure of the retrieve boolean functions }
    fnid:   Word;
    status: byte;
    value:  byte;
  end;

  SRStype = Record     { The Standard SRS instruction type }
    fnid:     word;
    status:   byte;
    reserve1: word;
    x:        longint;
    y:        longint;
    reserve2: word;
    bool:     byte; { true if odd; false if even }
    byt:      byte;
    wor:      word;
  end;

  VideoType = Record
    fnid:     Word;
    status:   byte;
    value:    byte;
    reserved: array [0..2] of byte;
  end;

  DiropByteType = Record { the structure of the byte Direct Operations }
    fnid:      Word;
    status:    byte;
    parameter: byte;
  end;

  DiropRealType = Record { the structure of the Real Direct Operations }
    fnid:      Word;
    status:    byte;
    parameter: single;
  end;


Const
  RemoteCMHandle: word = $FFFF;
    { contains the handle of the opened REMOTECM device driver; if not
      opened, it contains the value $FFFF}
Var
  StopTime: Word; { used by the CountDown functions }

{*************************************************************************}
function OpenRemoteCM: boolean;
{*************************************************************************}

{ This function tries to open the REMOTECM device driver. The value of the
  function expresses whether this could be done or not.
}
CONST
  Remotecm: Array [0..8] of char = ('R','E','M','O','T','E','C','M',#0);

var
  result : boolean;
  regs : Registers;

begin

  with regs do
  begin
    ax := $3D01;
    ds := seg(RemoteCM);
    dx := ofs(RemoteCM);
    msdos(regs);
    result := (flags and Fcarry) = 0;
  if result
  then
    RemoteCMHandle := ax
  else
    RemoteCMHandle := $FFFF; { not opened }

  OpenRemoteCM := result;
  end; {with statement }

end; { of procedure openremotecm }

{*************************************************************************}
procedure CloseRemoteCM;
{*************************************************************************}

{ this procedure closes the device remotecmhandle refers to. }

var
  regs: Registers;

Begin
  with regs do
  begin
    ax := $3E00;
    BX := RemoteCMHandle;
    msdos(regs);
  end;
  RemoteCMHandle := $FFFF; { closed }
end;

{*************************************************************************}
function CallRemoteCM(var Instruction): RCMResultType;
{*************************************************************************}

{ This procedure calls the RemoteCm device driver (which must already be
  opened) with a reference to the formal parameter 'Instruction' and
  returns the status.
}
Var
  Instr: InstructionType absolute Instruction;
  regs: Registers;

begin
  if Not OpenRemoteCM
  then
    CallRemoteCM := NoDeviceDriver
  else
  begin
    with regs do
    begin
      { fill the registers: }
      ax := $4000;
      bx := RemoteCMHandle;
      ds := seg(Instr);
      dx := ofs(Instr);
      cx := 1;

      { call msdos: }
      msdos(Regs);

      { evaluate the answer: }
      if (flags and Fcarry) = 0
      then { message is written to device driver; return status: }
        case Instr.Status of
           0: CallRemoteCM := Ok;
           1: CallRemoteCM := InvalidFunctionId;
           3: CallRemoteCM := EquipmentNotAvailable;
           5: CallRemoteCM := InvalidData;
           7: CallRemoteCM := InvalidMicroscopeStatus;
           9: CallRemoteCM := InvalidPCStatus;
          11: CallRemoteCM := DelayedExpected;
          13: CallRemoteCM := DelayedError;
          else
            CallRemoteCM := IncorrectDeviceDriver;
        end {case}
      else { device driver is not open. }
        CallRemoteCM := DeviceDriverNotOpened;
    end; { with statement }

    CloseRemoteCm;
  end;
end; {of procedure callremotecm }

{**************************************************************************}
procedure CurrentReadout (var Current: CurrentType);
{*************************************************************************}

Const
   CurrentId: array[1..26] of byte =
     ( 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12,
      13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25);
Type
  CurrentRType =  Record
    fnid:          Word;
    status:        byte;
    number:        byte;
    IDOfs:         Word;
    IdSeg:         Word;
    RCMOfs:        Word;
    RCMSeg:        Word;
  end;

Var
  CurrentR : CurrentRType;
  i: byte;

Begin
  with CurrentR do  begin
    fnid  := $C445;
    number:= 26;
    IDSeg := Seg(CurrentID);
    IDOfs := Ofs(CurrentID);
    RCMSeg:= Seg(Current);
    RCMOfs:= Ofs(Current);

    RCMResult := CallRemoteCM(CurrentR);
    For i:=1 to SizeOf (CurrentId) do
      if CurrentId [i] >1.0E+32
      then
        Current[i] := 0.0;
 end {with}
End;

{*************************************************************************}
procedure DirectOperation(OperationId: OperationIdType; Param:byte);
{*************************************************************************}

Var
  Dirop: DiropByteType;

Begin
  With Dirop do begin
    case OperationId of
      1:  fnid := $C741;
      2:  fnid := $C743;
      3:  fnid := $C745;
      4:  fnid := $C747;
      5:  fnid := $C749;
      6:  fnid := $C74B;
      7:  fnid := $C74D;
      8:  fnid := $C74F;
      9: fnid  := $C781;
      10: fnid := $C793;
      11: fnid := $C795;
      12: fnid := $C797;
      13: fnid := $C799;
      14: fnid := $C79B;
      15: fnid := $C79D;
      16: fnid := $C79F;
    End; { of case statement }

    parameter := Param;
    RCMResult := CallRemoteCM(Dirop);
    if RCMResult = InvalidMicroscopeStatus
    then
      RCMResult := DirectOperationImpossible;

  End { of with statement }
End; { of procedure DirectOperation }

{*************************************************************************}
procedure SetTVdetPos (Pos: Byte);
{*************************************************************************}
{ This function sets the TV detector in position Pos: 0: central,
  1: near-axis, 2: off-axis, 3 no change  }
Var
  SwitchHT: DiropByteType;
Begin
  With SwitchHT do
  Begin
    fnid      := $C751;
    parameter := Pos;
    RCMResult := CallRemoteCM(SwitchHT);

    if RCMResult = InvalidMicroscopeStatus
    then
      RCMResult := DirectOperationImpossible;
  End;
End;

{*************************************************************************}
procedure SwitchFreeHt (SwitchOn: Boolean);
{*************************************************************************}
{ This function switches free HT control on/off }
Var
  SwitchHT: DiropByteType;

Begin
  With SwitchHT do
  Begin
    fnid      := $C753;
    parameter := Byte(SwitchOn);
    RCMResult := CallRemoteCM(SwitchHT);

    if RCMResult = InvalidMicroscopeStatus
    then
      RCMResult := DirectOperationImpossible;
  End;
End;

{*************************************************************************}
procedure ChangeFreeHt (deltaHt: Real);
{*************************************************************************}
Var
  ChangeHT: DiropRealType;

Begin
  With ChangeHT do
  Begin
    fnid      := $C755;
    parameter := deltaHT;
    RCMResult := CallRemoteCM (ChangeHT);

    if RCMResult = InvalidMicroscopeStatus
    then
      RCMResult := DirectOperationImpossible;
  End;
End;

{*************************************************************************}
procedure NormalizeImLenses;
{*************************************************************************}
{ This function normalizes the imaging lenses }
Var
  NormLens: DiropByteType;

Begin
  NormLens.fnid      := $C79F;
  RCMResult := CallRemoteCM(NormLens);
End;

{*************************************************************************}
function  EmissionCurrent: single;
{*************************************************************************}

type
  EmissionType = Record
    fnid: Word;
    status: byte;
    current: single;
  end;

var Emission: EmissionType;

Begin
  with Emission do begin
    fnid := $C44F;
    RCMResult:= CallRemoteCM(Emission);
    if Current > 1.0E32
    then
      EmissionCurrent := 0.0
    else
      EmissionCurrent := current;

  end { with }
End;


{*************************************************************************}
function EquipmentAvailable:boolean;
{*************************************************************************}

{ This procedure performs the procedure Are You There. The value of the
  function expresses whether the equipment is available or not.
}

Begin
  With Eqavail do
  Begin
    fnid := $8101;
    { call the device driver and check the returned status }
    RCMResult := CallRemoteCM(EqAvail);
    EquipmentAvailable := RCMResult = Ok;
  End { of with statement }
End; { of procedure EquipmentAvailable. }

{*************************************************************************}
function  CMversion: Integer;
{*************************************************************************}
{ This procedure performs the procedure Are You There.
  If communication is possible then the return value is the
  version number (*10).
  If communication is not possible then the return value is -1
}

Var
  versionstr: String[5];
  version: integer;
  result:  integer;
Begin
  Eqavail.fnid := $8101;
  RCMResult := OK {CallRemoteCM(EqAvail)};
  If RcmResult = Ok
  Then
  Begin
    move (Eqavail.Version, versionstr[1], 5);
    versionstr[0] := char(5);
    val (versionstr, version, result);
    if result = 0
    then
      CMversion := version
    else
      CMversion := -1;
  End
  Else
    CMversion := -1;
End;

{*************************************************************************}
procedure GetAlignments(var Alignments: AlignmentsType);
{*************************************************************************}

Begin
  Alignments.fnid := $C54D;
  RCMResult :=  CallRemoteCM(Alignments);
End;

{*************************************************************************}
procedure GetMode(var ModeRec:ModeType);
{*************************************************************************}

{ This procedure retrieves the mode setting and stores it in a given record }

Begin
  ModeRec.fnid  := $C541;
  RCMResult :=  CallRemoteCM(ModeRec);
End; { of procedure GetMode }

{*************************************************************************}
procedure GetStigmator(var StigValues:StigValuesType);
{*************************************************************************}

{ This procedure retrieves the StigValuesmator settings }

Begin
  StigValues.fnid := $C545;
  RCMResult := CallRemoteCM(StigValues);
End; { of procedure GetStigmator }

{*************************************************************************}
procedure GetCMinfo(var CmInfo: CmInfoType);
{*************************************************************************}

{ This procedure retrieves various CM variables }
Begin
  CMinfo.fnid := $C551;
  RCMResult := CallRemoteCM(CmInfo);
End; { of procedure GetCmInfo }

{*************************************************************************}
procedure GetCMVar(var CmVar: CmVarType);
{*************************************************************************}

{ This procedure retrieves various CM variables }
Begin
  CMVar.fnid := $C553;
  RCMResult := CallRemoteCM(CmVar);
End; { of procedure GetCmVar }

{*************************************************************************}
procedure GetFegData (var FegData: FegDataType);
{*************************************************************************}

{ This procedure retrieves various FEG variables}
Begin
  FegData.fnid := $C34D;
  RCMResult := CallRemoteCM(FegData);
End; { of procedure GetCmVar }

{*************************************************************************}
procedure InstrumentMode(InstrModeId: InstrModeIdType);
{*************************************************************************}

Type
  InstrModeType = Record
    fnid:   Word;
    status: byte;
  end;

Var
  InstrMode: InstrModeType;

Begin
  InstrMode.fnid := $C781+ 2 * InstrModeId;
  RCMResult :=  CallRemoteCM(InstrMode);
  if RCMResult = InvalidMicroscopeStatus
  then
    RCMResult := NotAvailable;
End; { of procedure InstrumentMode}

{*************************************************************************}
procedure IOctl (Baud: Word; Port, T1, T2, T3, Retries: Byte);
{*************************************************************************}

{ This procedure will set the baudrate and the portno to the desired values.
  The value of the function expresses whether this could be done correctly.
}

Type
  IOcntrlType = record
                  fnid:     Word;
                  status:   byte;
                  PortNo:   byte;
                  Baudrate: Word;
                  T1:       byte;
                  T2:       byte;
                  T3:       byte;
                  RTY:      byte;
                  Slave:    byte;
                end;

Var
  IOcntrl: IOcntrlType;

Begin
  IOcntrl.BaudRate := Baud;
  IOcntrl.Portno   := Port;
  IOcntrl.fnid     := 0;
  IOcntrl.T1       := T1;
  IOcntrl.T2       := T2;
  IOcntrl.T3       := T3;
  IOcntrl.Rty      := Retries;
  RCMResult        := CallRemotecm(IOcntrl);
end; { IOCtl }

{*************************************************************************}
procedure PressureReadout(var Pressure:PressureType);
{*************************************************************************}

Const
   PressureId: array[1..PressureSize] of byte = (1,2,3,4);

Type
  PressType =  Record
    fnid:   Word;
    status: byte;
    number: byte;
    IDOfs:  Word;
    IdSeg:  Word;
    RCMOfs: Word;
    RCMSeg: Word;
  end;

Var
  Press: PressType;
  i: byte;

Begin
  with Press do  begin
    fnid  := $C447;
    number:= 4;
    IDSeg := Seg(PressureID);
    IDOfs := Ofs(PressureID);
    RCMSeg:= Seg(Pressure);
    RCMOfs:= Ofs(Pressure);
    RCMResult := CallRemoteCM(Press);
    For i:=1 to SizeOf (PressureId) do
      if PressureId [i] >1.0E+32
      then
        Pressure[i] := 0.0;
  end {with }
End;

{*************************************************************************}
procedure Pushbutton(PbId: byte; Act: PbActType);
{*************************************************************************}

{ This procedure presses a pushbutton on or off, depending of Act_Type }

Type
  PushbuttonType = Record
    fnid:   Word;
    status: byte;
    Id:     byte;
  end;

Var
  Pushbtn: PushbuttonType;
  Error:   Boolean;

Begin

  Error := False;

  Error := (Act <> Press) and (PbId in PBPressOnlySet);
  if Error
  then
    {Button is a press-only button and a press on/off action is requested }
    RCMResult := PressOnly

  else
  begin
    With Pushbtn do
    begin
      Id := PbId;

      case Act of
        On:    fnid := $C041;
        Off:   fnid := $C043;
        Press: fnid := $C045;
      end;
    End; { of with statement }

    RCMResult := CallRemoteCM(PushBtn);
    If RCMResult = InvalidData
    then
      RCMResult := CannotPressButton;
  end;
End; { of procedure Pushbutton}

{*************************************************************************}
Function RetrEdxProt: boolean;
{*************************************************************************}

{ The value of the function expresses whether the Edx protection is on.}

Var
  EdxProt: RetrBoolType;

Begin
  EdxProt.fnid := $C345;
  RCMResult := CallRemoteCM(EdxProt);

  RetrEdxProt := (EdxProt.value mod 2) <> 0;
End; { of procedure RetrEdxProt. }

{*************************************************************************}
function RetrExtXYdefl: boolean;
{*************************************************************************}

{ The value of this function expresses whether the Ext XY Defl is on.}

Var
  ExtXYDefl: RetrBoolType;

Begin
  ExtXYDefl.fnid := $C347;
  RCMResult := CallRemoteCM(ExtXYDefl);
  RetrExtXYDefl := (ExtXYDefl.value Mod 2) <> 0;
End;

{*************************************************************************}
function RetrHTcondition: boolean;
{*************************************************************************}

{ The value of this function expresses whether the HT may be switched on.}

Var
  HTCond: RetrBoolType;

Begin
  HTCond.fnid := $C343;
  RCMResult := CallRemoteCM(HTCond);
  RetrHTcondition := (HTCond.value mod 2) <> 0;
End;

{*************************************************************************}
function ScreenCurrent: single;
{*************************************************************************}

{ The value of this function is the Screen Current }

type
  ScreenCurrentType = Record
    fnid: Word;
    status: byte;
    current: single;
  end;
var
  ScrnCurrent : ScreenCurrentType;

Begin
  with ScrnCurrent do begin
    fnid := $C449;
    RCMResult := CallRemoteCM(ScrnCurrent);
    if Current >1.0E+32
    then
      ScreenCurrent := 0.0
    else
      ScreenCurrent := current;
  end { with }
End;

{*************************************************************************}
procedure SetAlignments(Alignments:AlignmentsType);
{*************************************************************************}

{ this procedure restores the alignment settings }

Begin
  Alignments.fnid := $C54F;
  RCMResult :=  CallRemoteCM(Alignments);
End;

{*************************************************************************}
procedure SetMode(Mode: ModeType);
{*************************************************************************}

{ This procedure restores a retrieved mode setting }

Begin
  Mode.fnid := $C543;
  RCMResult :=  CallRemoteCM(Mode);
End;

{*************************************************************************}
procedure SetStigmator(StigValues: StigValuesType; Stig: StigType);
{*************************************************************************}

{ This procedure restores the setting of a chosen stigmator }

Begin
  Case Stig of
    ObjStig:  StigValues.fnid := $C547;
    CondStig: StigValues.fnid := $C549;
    DifStig:  StigValues.fnid := $C54B;
  end;

  RCMResult :=  CallRemoteCM(StigValues);
End; { of procedure SetStig }


{*************************************************************************}
procedure Softkey(SKId: SKIdType; NoOfPresses: byte);
{*************************************************************************}

{ This procedure presses the desired softkey the desired nr of times }

Var
  Sftkey: Record
            fnid:   Word;
            status: byte;
            Id:     byte;
            Count:  byte;
         end;
Begin
  Sftkey.Id := SKId;
  Sftkey.Count := NoOfPresses;
  Sftkey.fnid := $C141;
  RCMResult :=  CallRemoteCM(Sftkey);
  
End; { of procedure Softkey}

{*************************************************************************}
procedure StartDisplInfo(Filename:PathStr; appnd: boolean);
{*************************************************************************}

Var
  i : Byte;
  display : record
              fnid : Word;
              status : byte;
              append : byte;
              filename : PathStr;
            end;
Begin
  display.fnid := $C641;
  if appnd
  then display.append := $FF
  else display.append := $00;

  { copy filename; terminate with zero: }
  for i := 1 to length(Filename) do
    display.filename[i-1] := filename[i];

  display.filename[i] := chr(0);

  RCMResult := CallRemoteCM(display);
End;

{*************************************************************************}
procedure StopDisplInfo;
{*************************************************************************}

var
   display : record
     fnid : Word;
     status : byte;
   end;

begin
  with display do begin
    fnid := $C643;
    RCMResult := CallRemoteCM(display)
  end;
end;


{*************************************************************************}
procedure TurnKnob(TKId:byte; TKCount:integer);
{*************************************************************************}

{ This procedure tells the microscope to turn the knob. }
Var
  TurnKnb: record
             fnid:   Word;
             status: byte;
             Id:     byte;
             Count:  integer;
           end;
Begin
  TurnKnb.fnid := $C241;
  TurnKnb.Id := TKId;
  TurnKnb.Count := TKCount;
  RCMResult := CallRemoteCM(TurnKnb);
End;

{*************************************************************************}
Function VideoL: byte;
{*************************************************************************}

{ The value of the function expresses the video left signal }

Var
  Video: VideoType;

Begin
  Video.fnid := $C44B;
  RCMResult := CallRemoteCM(Video);
  VideoL := Video.value;
End;

{*************************************************************************}
Function VideoR: byte;
{*************************************************************************}

Var
  Video: VideoType;

Begin
  Video.fnid := $C44D;
  RCMResult := CallRemoteCM(Video);
  VideoR := Video.value;
End;

{*************************************************************************}
{*************************************************************************}
{**                                                                     **}
{**    The SRS functions                                                **}
{**                                                                     **}
{*************************************************************************}
{*************************************************************************}

{*************************************************************************}
function StartTimer (time: word): word;
{*************************************************************************}

{ This function will initialize the timer. Time is the nr of ticks to
  be waited for by the function TimePassed. There are 18.2 ticks in a second
  ($FFFF in a hour). The value of the function is the parameter Counter
  used by the function TimePassed.
}

var
  Regs: registers;

begin
  Regs.ah := 0;
  Intr($1a, Regs);
  StartTimer := $0100 * Regs.cx + Regs.dx + time;
end;

{*************************************************************************}
function TimePassed (Counter: word): boolean;
{*************************************************************************}

{ This function will get the computertime and compare it with the variable
  counter as initialized with StartTimer. The value of the function is
  true if either the time has passed Counter or if a new day has begun.
}

var
  Regs: registers;

begin
  Regs.ah := 0;
  Intr($1a, Regs);
  if Regs.al = 0
  then
    TimePassed := ( ($100 * Regs.cx + Regs.dx) >= Counter)
  else
    TimePassed := True;
End;

{*************************************************************************}
Function CallSRS (var SRS: SRSType): RCMResultType;
{*************************************************************************}

{ This function calls the device driver via the CallRemoteCM function with
  SRSRec as parameter. Afterwards it checks the status and translates it into
  a SRSReturntype.
}

Var
  Hulp: RCMResultType;

Begin
  Hulp := CallRemoteCM (SRS);
  case Hulp of
    InvalidData:              CallSRS := InvalidPos;
    InvalidMicroscopeStatus:  CallSRS := NotCalibrated;
  else
    CallSRS := Hulp;
  end;
End;

{*************************************************************************}
Function SRSWaitUntilReady (var SRSinstr: SRStype): RCMResultType;
{*************************************************************************}

{ This function waits until the delayed SRS function has completed or until
  no SRSmessage is to be expected.
  It does this by asking the device driver for a number of times whether the
  completion message from the microscope is still to be expected.

  The function returns as soon as:
  - The completion message is received, or
  - an error occurred or
  - one minute has passed

  input:
    none.
  output:
    SRSinstr: the result the function is waiting for.
    FunctionValue: OK (delayed received) / EquipmentNotAvailable /
                   DelayedError / IncorrectDeviceDriver;

}
Var
  Ready: RCMResultType;
  Minute: Word;

Begin
  Minute := StartTimer (18 * 60); {about a minute }
  Ready := DelayedExpected;

  While (Ready = DelayedExpected) and not TimePassed (Minute)  do
  Begin
    SRSinstr.Fnid := $C943;
    Ready := CallRemoteCM (SRSinstr);
  end;

  if Ready = DelayedExpected
  then
    SRSWaitUntilReady := DelayedError;
    SRSWaitUntilReady := Ready;
End;

{*************************************************************************}
Procedure SRSCalibrate;
{*************************************************************************}

{ This function will calibrate the specimen holder of the SRS and will
  wait for completion.
}

Var
  SRS: SRStype;
  twominutes: word;
  x, y: longint;

Begin
  SRS.fnid := $C88B;
  RCMResult := CallSRS (SRS);
  if RCMResult = Ok
  then
  begin
    { wait until ready: }
    twominutes := StartTimer (2 * 60 * 18); {about two minutes}

    repeat
      { ask every second whether SRS is calibrated: }
      Delay (1000);
      SRSReadPos (x,y);
    until (RCMResult <> NotCalibrated) and not TimePassed (twominutes);
  end

End;

{*************************************************************************}
Procedure SRSReadPos (var X, Y: longint);
{*************************************************************************}

Var
  SRS: SRStype;

Begin
  SRS.fnid  := $C84F;
  RCMResult := CallSRS (SRS);
  x         := SRS.x;
  y         := SRS.y;
End;

{*************************************************************************}
Procedure SRSGotoPos(x,y:longint);
{*************************************************************************}

Var
  SRS: SRStype;

Begin
  SRS.fnid  := $C844;
  SRS.x     := x;
  SRS.y     := y;
  RCMResult := CallSRS (SRS);

  if RCMResult = Ok
  then
    RCMResult := SRSWaitUntilReady (SRS);
End;

{*************************************************************************}
Procedure SRSGotoReg(RegNr:SRSRegType);
{*************************************************************************}

Var
  SRS: SRStype;

Begin
  SRS.fnid := $C842;
  SRS.Byt  := RegNr;

  RCMResult := CallSRS (SRS);

  if RCMResult = Ok
  then
    RCMResult := SRSWaitUntilReady (SRS)
  else
    if RCMResult = InvalidPos
    then
      RCMResult := InvalidReg;
End;

{*************************************************************************}
Procedure SRSSetReg (RegNr:SRSRegType; x, y: longint);
{*************************************************************************}

Var
  SRS: SRStype;

Begin
  if (abs (x) < 1000000) and (abs (y) < 1000000)
  then
  begin
   SRS.fnid  := $C847;
   SRS.byt   := byte (Regnr);
   SRS.x     := x;
   SRS.y     := y;
   RCMResult := CallSRS (SRS);
  end
  else
    RCMResult := InvalidPos;
End;

{*************************************************************************}
Procedure SRSReadReg(RegNr: SRSRegType; var x, y:longint);
{*************************************************************************}

Var
  SRS: SRStype;

Begin
  SRS.fnid  := $C849;
  SRS.byt   := byte (Regnr);
  RCMResult := CallSRS (SRS);
  if (RCMResult = Ok)
  and (abs (SRS.x+1) < 1000000)
  and (abs (SRS.y+1) < 1000000)
  then
  begin
    x         := SRS.x;
    y         := SRS.y;
  end
  else
    RCMResult := InvalidReg;
End;

{*************************************************************************}
Procedure SRSSelReg (RegNr:SRSRegType);
{*************************************************************************}

Var
  SRS: SRStype;

Begin
  SRS.fnid  := $C865;
  SRS.byt   := byte (Regnr);
  RCMResult := CallSRS (SRS);
End;

{*************************************************************************}
{*************************************************************************}
{**                                                                     **}
{**    The CompuStage functions                                         **}
{**                                                                     **}
{*************************************************************************}
{*************************************************************************}

{*************************************************************************}
Procedure GonAskPos (Var Pos: GonPosType);
{*************************************************************************}
{ This function returns the current position of the compustage }
Var
  AskPos: record
            fnid:     Word;
            status:   byte;
            reserved: word;
            Pos:      GonPosType;
          end;
Begin
  AskPos.fnid := $CB41;
  RcmResult := CallRemoteCm (AskPos);
  Pos := AskPos.Pos;
End;

{*************************************************************************}
Procedure GonGotoPos (Method:Byte; Pos: GonPosType);
{*************************************************************************}
{ This function performs a goto to position, depending on the Method.
  Method has 8 bits, counting from 0(lsb) to 7(msb). They have the following
  meaning:
  bits 7&6:
       11: perform a XY only recall;
       01: perform a full safe recall
       00: goto directly, using the axes as given in bits 0..4
           (bit 0 axe x; bit 1 axe y etc.)
  bit 5 must be 0!
  bits 0..4 only have meaning when bits 7&6 are both 0. It is a mask of the
       axes to use when going to: 0..4 = xyzab.
  Pos is the position to go to in nm and 1/1000 of degrees.
  Only the axes to use are regarded.

  for convenience use the constants: RECALL, XYONLY, Xgoto, Ygoto, Zgoto,
  Agoto, Bgoto.

  Examples:
  Current Position is (0,0,0,0,0)
  GonGotoPos (RECALL, 10, 20, 30, 40, 50);
  a full (safe) recall to (10,20,30,40,50) is performed
  safe means here that before moving the xyz axes AB are set to 0

  Current Position is (10,20,30,40,50)
  GonGotoPos (XYONLY, 60, 70, 80, 90, 100);
  a xy only (safe) recall to (60,70,30,40,50) is performed

  Current Position is (60,70,30,40,50)
  GonGotopos (Zgoto or Bgoto, 110, 120, 130, 140, 150)
  a direct goto using only axes Z and B to (60,70,120,40,150) is performed
}
Var
  GotoPos: record
             fnid:     Word;
             status:   byte;
             reserved: word;
             method:   byte;
             Pos:      GonPosType;
          end;
Begin
  GotoPos.fnid := $CB43;
  GotoPos.method := method;
  GotoPos.Pos    := Pos;
  RcmResult := CallRemoteCm (GotoPos);
End;

{*************************************************************************}
Procedure GonGetRegisters (Var Regs: GonRegistersType);
{*************************************************************************}
{ This function returns the current contents of the registers on the CM }
Var
  GetReg: record
            fnid:      Word;
            status:    byte;
            reserved:  array[1..3] of byte;
            Registers: GonRegistersType;
          end;
Begin
  GetReg.fnid := $CB45;
  RcmResult := CallRemoteCm (GetReg);
  Regs := GetReg.Registers;
End;

{*************************************************************************}
Procedure GonSetRegisters (GonRegs: GonRegisterstype);
{*************************************************************************}
{ This function will set the registers on the CM to the value of GonRegs }
Var
  SetReg: record
            fnid:     Word;
            status:   byte;
            reserved:  array[1..3] of byte;
            Registers: GonRegistersType;
          end;
Begin
  SetReg.Fnid := $CB47;
  SetReg.Registers := GonRegs;
  RcmResult := CallRemoteCm (SetReg);
End;

end. {of unit}
