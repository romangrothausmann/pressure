{*************************************************************************}
{*************************************************************************}
{                                                                         }
{                             R C M . I N C                               }
{                                                                         }
{   Include File for the basic CM microscope Remote Control functions     }
{                                                                         }
{   (C)  1988  Copyright PHILIPS EXPORT B.V., All Rights Reserved         }
{                                                                         }
{*************************************************************************}
{*************************************************************************}

VAR
  RemoteCMHandle: integer;
    { contains the handle of the opened REMOTECM device driver. }

{**************************************************************************}
Function OpenRemoteCM: boolean;

{ This function tries to open the REMOTECM device driver. The value of the
  function expresses whether this could be done or not.
}
CONST
  Remotecm: Array [0..8] of char = ('R','E','M','O','T','E','C','M',#0);

TYPE
  RegisterType = record    { used to call the Turbo Pascal procedure MSDOS }
    ax, bx, cx, dx, bp, si, di, ds, es, flags: integer
  end;

var
  result : boolean;
  registers : RegisterType;

begin
  with registers do
  begin
    ax := $3D01;
    ds := seg(RemoteCM);
    dx := ofs(RemoteCM);
    msdos(registers);
    result := (flags and $01) = 0;
    if result then RemoteCMHandle := ax;
    OpenRemoteCM := result;
  end; {with statement }
end; { of procedure openremotecm }

{**************************************************************************}
Function CallRemoteCM(var Instruction): byte;

{ This function calls the RemoteCm device driver (which must already be
  opened) with a reference to the formal parameter 'Instruction' and returns
  the status. A value of $FF means the driver is not open yet,
}
  Type
    InstructionType = Record    { the standard instruction form. }
     fnid:   integer;
     status: byte;
  end;
  RegisterType = record    { used to call the Turbo Pascal procedure MSDOS }
    ax, bx, cx, dx, bp, si, di, ds, es, flags: integer
  end;

Var
  Instr: InstructionType absolute Instruction;
  registers: RegisterType;

begin
  with registers do
  begin
    { fill the registers: }
    ax := $4000;
    bx := RemoteCMHandle;
    ds := seg(Instr);
    dx := ofs(Instr);
    cx := 1;

    { call msdos: }
    msdos(Registers);

    { evaluate the answer: }
    if (flags and $01) = 0
    then { message is written to device driver; return status: }
      CallRemoteCM := Instr.Status
    else { device driver is not open. }
      CallRemoteCM := $FF;
  end; { with statement }
end; {of procedure callremotecm }


{**************************************************************************}
procedure CloseRemoteCM;

{ this function closes the device remotecmhandle refers to. }
type
  RegisterType = record    { used to call the Turbo Pascal procedure MSDOS }
    ax, bx, cx, dx, bp, si, di, ds, es, flags: integer
  end;
var
  registers: RegisterType;

Begin
  with registers do
  begin
    ax := $3E00;
    BX := RemoteCMHandle;
    msdos(registers);
  end;
end;
