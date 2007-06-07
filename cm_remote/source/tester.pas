Program TESTER;

{ (C)  1988  Copyright PHILIPS EXPORT B.V., All Rights Reserved.

  This program will test whether the remote control link works or not.
  If not, it will perform the following checks to see why.

  - 1. Is the device driver loaded?
       If not, adjust config.sys and try again.
  - 2. Is the interrupt vector used by another program or hardware card?
       If so, try the other serial port, or disable the program/hardware card.
  - 3. Does the communication equipment use the right port addresses
       (3F8H for port 1; 2F8H for port 2)?
  - 4. Is the communication cable connected to the right serial port?
       If not, correct this.
  - 5. Is it possible to send and receive one single character?
       If not, check the following:
       - a. Is the baudrate ok?
            If not, adjust the value on the CM to the right value.
       - b. Is the remote control switch on the CM switched on?
            If not, switch it on.
       - c. Are both the PC and the CM configured as a DTE?
            If not adjust the switches.
}

{$U+} { enable user interrupt with ^C }

{$ircm.inc} {the functions openremotecm, callremotecm and closeremotecm}

Type
  DriverNameType = String[8];
  String4 = String[4];
  HexadigitType = $0..$15;
  UsePortType = (none, one, two, both);

Var
  Ok: Boolean;
  Portno: byte;
  Baudrate: integer;
  Address1, Address2: integer;

{****************************************************************************}
Function Exist(Filename: DriverNameType) : boolean;
{****************************************************************************}

{ This function will check whether a file/device with name 'Filename' exists.
  The function value expresses if this is so or not.
}

Var
  Fil: File;

Begin
  Assign(Fil, Filename);
  {$I-}
  Reset(Fil);
  Close(Fil);
  {$I+}
  Exist := (IOresult = 0);
End; {of function Exist }


{****************************************************************************}
Function RetrieveDeviceDriverName (base: integer): DriverNameType;
{****************************************************************************}

{ This Function returns the string of eight characters that come after offset
  0AH of the base address 'base', which ought to be the devive driver name.
}

Type
  Nametype = array [1..8] of char;
  NameptrType = ^Nametype;

Var
  Nameptr: NameptrType;

Begin
  Nameptr := Ptr(Base,10);
  RetrieveDeviceDriverName := Nameptr^;
End;

{****************************************************************************}
Procedure Beep;
{****************************************************************************}

{ This procedure produces a beep }

Begin
  sound(500);
  delay(500);
  nosound;
end;

{****************************************************************************}
Function CheckIntVector: UsePortType;
{****************************************************************************}

{ This procedure returns the value of the port which should be used.
  It does this by checking the interrupt vector.
  If the device driver uses interrupt 0CH, then port 1 should be used.
  If interrupt 0BH is used, then port 2 should be used. If both interrupts are
  ok, then the value 'both' is returned. In all other cases, the function
  returns zero.
}

Var
  Port1, Port2: boolean; {express whether they may be used or not }

Begin
  port1 := (RetrieveDeviceDriverName (MemW[00:$32] ) = 'REMOTECM');
  port2 := (RetrieveDeviceDriverName (MemW[00:$2C] ) = 'REMOTECM');
  if port1 and port2
  then CheckIntVector := both
  else
    if port1
    then CheckIntVector := one
    else
      if port2
      then CheckIntVector := two
      else CheckIntVector := none
End;

{***************************************************************************}
function EquipmentAvailable:boolean;

{ This procedure performs the function Are You There. The value of the
  function expresses whether the equipment is available or not.
}

{.cp11}
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

{.cp19}
Begin
  With EqavailRec do
  Begin
    fnid := $8101;
    { call the device driver and check the returned status }
    if  CallRemoteCM(EqAvailRec) =  0  then  Begin
      Writeln('Remote Control is possible');
      write('The Equipment Model Type = ');
      for i := 1 to 6 do write(Model[i]);
      writeln;
      write('The Version No. = ');
      for i := 1 to 6 do write(Version[i]);
      writeln;
      EquipmentAvailable := True
    end
    else
      EquipmentAvailable := False;
  End { of with statement }
End; { of procedure EquipmentAvailable. }

{****************************************************************************}
Procedure RetrieveIOctl(var Portno: byte; var baudrate: integer);
{****************************************************************************}

{ This function retrieves the used portno and baudrate. }

Var
  IOctl: Record
           fnid: integer;
           status: byte;
           portno: byte;
           baudrate: integer;
           T1: byte;
           T2: byte;
           T3: byte;
           rty: byte;
           Slave: byte;
         end; { of record }
Begin
  if OpenRemoteCM
  then { device driver opened now; perform IOctl }
  begin
    With IOctl do
    begin
      fnid := 00;
      portno := $FF;
      baudrate := $FFFF;
      T1 := $FF;
      T2 := $FF;
      T3 := $FF;
      Rty := $FF;
      Slave := $FF;
    end;

    if CallRemoteCM(IOctl) = 0
    then { Function performed correctly }
    begin
      portno := IOctl.portno;
      baudrate := IOctl.baudrate;
    end;

    CloseRemoteCM;
  end
  else { Device driver cannot be opened. Normally this cannot happen }
    Writeln('Unrecognizable error; please start program again.');
End;

{****************************************************************************}
Function BaudrateOk: boolean;
{****************************************************************************}

{ This function checks whether the baudrate is ok or not. }

Var
  Answer: char;
Begin
  Repeat
  Write('Is the baudrate on the microscope (Remote Control page) ',baudrate,' (Y/N)? ');
  Readln(Answer);
  if not (answer in ['Y','y','N','n'])
  then writeln('Please answer Y or N');
  until answer in ['Y','y','N','n'];
  BaudrateOk := (answer in  ['Y','y'] );
End;

{****************************************************************************}
Function Eqavail: boolean;
{****************************************************************************}

{ This function tests whether the equipment is available. }

Var
  hulp: boolean;

Begin
  Write('Testing if the microscope is remote controllable ... ');
  if OpenRemoteCM
  then
  begin
    hulp := EquipmentAvailable;
    CloseRemoteCM;
  end
  else hulp := false;

  if hulp
  then Writeln('Ok')
  else Writeln('Failed');

  Eqavail := hulp;
End;

{****************************************************************************}
Function Check1: boolean;
{****************************************************************************}

{ This function checks for the presence of the device driver. }

Var
  Ok: boolean;

Begin
  Write('Check #1... ');
  if Exist('REMOTECM')
  then
  begin
    Writeln('Ok.');
    Check1 := True;
  end
  else { the device driver is not loaded. Explain why: }
  Begin
    Writeln('Failed');
    Check1 := False;
    Writeln;
    Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    Writeln('³                                                                            ³');
    Writeln('³   The device driver is not present.                                        ³');
    Writeln('³   In the root directory of the disk you boot from is the file CONFIG.SYS.  ³');
    Writeln('³   This normal ASCII file must contain the following phrase:                ³');
    Writeln('³                                                                            ³');
    Writeln('³                         Device = RCM.SYS                                   ³');
    Writeln('³                                                                            ³');
    Writeln('³   If you do not wish to place the file RCM.SYS in the root directory, but  ³');
    Writeln('³   for example in the directory C:\RemoteCM, then this phrase must be:      ³');
    Writeln('³                                                                            ³');
    Writeln('³                     Device = C:\RemoteCM\RCM.SYS                           ³');
    Writeln('³                                                                            ³');
    Writeln('³   You can change the file config.sys with any normal ASCII text editor.    ³');
    Writeln('³   Please correct this, then boot again.                                    ³');
    Writeln('³                                                                            ³');
    Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  end;
End;

{****************************************************************************}
Function Check2: boolean;
{****************************************************************************}

{ This function checks whether the interrupt no. is used by another program. }

Var
  UsePortno: UsePortType;
Begin
  Write('Check #2... ');

  UsePortno := CheckIntVector;
  RetrieveIOCtl(Portno, Baudrate);
  if UsePortno <> none
  then
  begin
    Writeln('Ok.');
    Check2 := True;
  end
  else
  begin
    Writeln('Failed');
    Check2 := False;
    Writeln;
    Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    Writeln('³                                                                            ³');
    Writeln('³   The microscope cannot answer any question.                               ³');
    Writeln('³   When the microscope tries to answer a question it sends a character to   ³');
    Writeln('³   tell the PC that it wants to send a message. An interrupt is generated.  ³');
    Writeln('³                                                                            ³');
    Writeln('³   The interruptnumber for port #1 ought to be 12 (0CH),                    ³');
    Writeln('³                   and for port #2             11 (0BH).                    ³');
    Writeln('³                                                                            ³');
    Writeln('³   You want to make use of port no ',portno:1,'. the interrupt needed for              ³');
    Writeln('³   this port is already in use by some other program or expansion card.     ³');
    Writeln('³   You may try to use the other serial port, or disable the interfering     ³');
    Writeln('³   program/extension card.                                                  ³');
    Writeln('³                                                                            ³');
    Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  end
end; { of procedure check2 }

{****************************************************************************}
Function Check3: boolean;
{****************************************************************************}

{ This function checks whether the computer uses the right port addresses for
  the serial ports
}

Begin
  Write('Check #3... ');
  { check addresses: }
  if ( (portno = 1) and (Memw[00:$400] = $3F8) )
  or ( (portno = 2) and (Memw[00:$402] = $2F8) )
  then
  begin
    Writeln('Ok.');
    Check3 := True;
  end
  else
  begin
    Writeln('Failed.');
    Check3 := False;
    Writeln;
    Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    Writeln('³                                                                            ³');
    Writeln('³   The serial ports use the wrong port addresses.                           ³');
    Writeln('³   When the device driver wants to send a character it uses the addresses   ³');
    Writeln('³   1016 (03F8H) for port #1 and 760 (02F8H) for port #2, which are also     ³');
    Writeln('³   used by the IBM PC and most compatibles.                                 ³');
    Writeln('³                                                                            ³');
    Writeln('³   This computer uses address ',Memw[00:$400]:5,' for port #1                             ³');
    Writeln('³                          and ',Memw[00:$402]:5,' for port #2                             ³');
    Writeln('³                                                                            ³');

    if portno = 1
    then
      if Memw[00:$402] = $2F8
      then
      begin
        Writeln('³   You want to use port #1; As you can see, port 1 uses the wrong port      ³');
        Writeln('³   addresses. Please try to use port #2 or change the address of port #1    ³');
      end
      else
      begin
        Writeln('³   You want to use port #1; as you can see it wouldn''t help if you''d try to ³');
        Writeln('³   use port 2. Please try to change the addresses of one of the ports to    ³');
        Writeln('³   the values mentioned above.                                              ³')
      end
    else
      if Memw[00:$400] = $3F8
      then
      begin
        Writeln('³   You want to use port #2; As you can see, port 2 uses the wrong port      ³');
        Writeln('³   addresses. Please try to use port #1 or change the address of port #2    ³');
      end
      else
      begin
        Writeln('³   You want to use port #2; as you can see it wouldn''t help if you''d try to ³');
        Writeln('³   use port 1. Please try to change the addresses of one of the ports to    ³');
        Writeln('³   the values mentioned above.                                              ³')
      end;
    Writeln('³                                                                            ³');
    Writeln('³   The addresses of the ports used for port 1 and two are located in        ³');
    Writeln('³   0000:0400H resp. in 0000:0402H.                                          ³');
    Writeln('³                                                                            ³');
    Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  end;
end; { of procedure Check3 }

{****************************************************************************}
Function Check4: boolean;
{****************************************************************************}

{ This function checks if the cable is on the right serial port. }
Var
  connectedportno : byte;

Begin
  Writeln('Check to which serial port the communication cable is connected.');
  Write('To which port is the communication cable connected (1/2/..)? ');
  Readln(connectedportno);
  if connectedportno = Portno
  then
  begin
    Writeln('Check #4... Ok.');
    Check4 := true;
  end
  else
  begin
    Writeln('Check #4... Failed');
    Check4 := false;
    Writeln;
    Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    Writeln('³                                                                            ³');
    Writeln('³   The communication cable is connected to the wrong serial port.           ³');
    case connectedportno of
      1: begin
           Writeln('³   The device driver expects it to be on the secondary serial port,         ³');
           Writeln('³   while the communication cable is on the first one.                       ³');
         end;
      2: begin
           Writeln('³   The device driver expects it to be on the first serial port,             ³');
           Writeln('³   while the communication cable is on the second one.                      ³');
         end;
      else
      begin
         Writeln('³   The device driver expects the cable to be on port ',portno:2,',                    ³');
         Writeln('³   while the communication cable is connected to another port.              ³');
      end
    end; {of case statement }
    Writeln('³   Please correct this, then start this program again.                      ³');
    Writeln('³                                                                            ³');
    Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  end
End;

{****************************************************************************}
Function Check5: boolean;
{****************************************************************************}

Var
  i: integer;
  Answer: char;
  ier, lsr, thr: integer; { Interrupt Enable register, Line Status register,
                          Transmitter Holding register }
  SaveIer: byte; { the saved value of the interrupt enable register }

Begin
  Write('Check #5... ');
  {Try to send one character: DC1 (17) }
  if portno = 1
  then
  begin
    ier := $3F9;
    lsr := $3FD;
    thr := $3F8;
  end
  else
  begin
    ier := $2F9;
    lsr := $2FD;
    thr := $2F8;
  end;

  { disable the interrupt handling of the device driver: }
  SaveIer := port[ier];
  port[ier] := 00;

  { wait until Transmitter holding register empty: }

  repeat until (Port[lsr] and $20) <> 0;

  { send the character DC1: }
  Port[thr] := 17;

  { wait until a character has been received: }
  i := 0;
  repeat
    i := i + 1;
  until ( (Port[lsr] and $01) <> 0) or (i >= 10000);

  if (Port[lsr] and $01) <> 0
  then { a character has been received }
  begin
    if Port[thr] = 18 { = DC2 }
    then { the right character has been received; all is ok. }
    begin
      Writeln('Ok');
      Check5 := true;
    end
    else { a strange character has been received: cable ok;
           maybe the baudrate? }
    begin
      Writeln('Failed');
      Check5 := false;
      If not BaudrateOk
      then {incorrect baudrate}
      begin
        Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
        Writeln('³                                                                            ³');
        writeln('³   Please change the baudrate on the CM to ',baudrate:4,' and restart the program     ³');
        Writeln('³                                                                            ³');
        Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
      end
      else
      begin
        Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
        Writeln('³                                                                            ³');
        Writeln('³   I''ve established that it is possible to send and receive characters, but ³');
        Writeln('³   they are not received correctly. Maybe there is too much noise on the    ³');
        Writeln('³   connection cable.                                                        ³');
        Writeln('³                                                                            ³');
        Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
      end
    end { of strange character }
  end { of character received }
  else { nothing received }
  begin
    Writeln('Failed');
    Check5 := false;
    Repeat
      Write('Is the remote control switch on the microscope turned on (Y/N)? ');
      Readln(Answer);
      if not (answer in ['Y','y','N','n'] )
      then writeln('Please answer Y or N');
    until answer in ['Y','y','N','n'];
    if not (answer in  ['Y','y'] )
    then
    begin
      Writeln;
      Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
      Writeln('³                                                                            ³');
      writeln('³                Please turn it on and restart the program.                  ³');
      Writeln('³                                                                            ³');
      Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    end
    else
    begin { check baudrate }
      If not BaudrateOk
      then {incorrect baudrate}
      begin
        Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
        Writeln('³                                                                            ³');
        writeln('³   Please change the baudrate on the CM to ',baudrate:4,' and restart the program     ³');
        Writeln('³                                                                            ³');
        Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
      end
      else
      begin
        Writeln;
        Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
        Writeln('³                                                                            ³');
        Writeln('³   The pinout and the cable on the used serial ports should be as follows:  ³');
        Writeln('³                                                                            ³');
        Writeln('³ PC (pinned as DTE)                                  (pinned as a DTE) CM** ³');
        Writeln('³ pin                  Tension   cabling      tension                    pin ³');
        Writeln('³ 1  shield              0V    _____________     0V     shield            1  ³');
        Writeln('³                                                                            ³');
        Writeln('³ 2  transmitted data  >16V    _____  _____    >16V     transmitted data  2  ³');
        Writeln('³                                   \/                                       ³');
        Writeln('³ 3  received data       0V    _____/\_____      0V     received data     3  ³');
        Writeln('³                                                                            ³');
        Writeln('³ 7  signal ground       0V    _____________     0V     signal ground     7  ³');
        Writeln('³                                                                            ³');
        Writeln('³                                                                            ³');
        Writeln('³    Please check if the pinout and the cable are correct.                   ³');
        Writeln('³    If on one of both ends pin 2 and 3 are switched, then that side is      ³');
        Writeln('³    configured as a DCE instead of a DTE. Please see your installation      ³');
        Writeln('³    manual to see how the serial port can be changed into a DTE, or use     ³');
        Writeln('³    the other serial port.                                                  ³');
        Writeln('³                                                                            ³');
        Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
      end;
    end;
  end;

  { restore interrupt enable register }
  port[ier] := SaveIer;

End;

{****************************************************************************}
{ Main Program }
{****************************************************************************}
BEGIN
  Writeln('This program will test whether the microscope is remote controllable and if');
  Writeln('not, it will try to find out why and give suggestions to recover the errors.');
  Writeln;
  Writeln('(C)  1988   Copyright PHILIPS EXPORT B.V., All Rights Reserved');

  Writeln;

  Ok := Eqavail;

  if not Ok
  then
  { equipment not available; try to find why }
  begin

    Ok := Check1;  {Check for the presence of the device driver. }

    if OK
    then { check interrupt vector }
      Ok := Check2;

    if OK
    then { Check the port addresses. }
      Ok := Check3;

    if OK
    then { Check the connection of the cable }
      Ok := Check4;

    if OK
    then { Try to send one single character. }
      Ok := Check5
  end
END.