

Program CMONITOR;

{ (C)  1988 Copyright PHILIPS EXPORT B.V., All Rights Reserved  }

{$IRCM.INC}
{$IREMOTE.INC}

type Window_Strings = array[1..14] of string[80];
     Stig_Choice_Type = (C2,Obj,Dif);
const
  Menu_Strings : Window_Strings =
   ('      Ctrl             Normal             Normal            Ctrl',
    '    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ   ÉÍÍÍÑÍÍÍ»  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',
    '    ³      ¿            Quit   ºF1 ³ F2º  Directory                  ³',
    '    ³      Ù                   ÇÄÄÄÅÄÄÄ¶                             ³',
    '    ³          Get Alignment   ºF3 ³ F4º  Set Alignment              ³',
    '    ³                          ÇÄÄÄÅÄÄÄ¶                    Ú        ³',
    '    ³          Get Stigmator   ºF5 ³ F6º  Set Stigmator     ³        ³',
    '    ³                          ÇÄÄÄÅÄÄÄ¶                    À        ³',
    '    ³               Get Mode   ºF7 ³ F8º  Set Mode                   ³',
    '    ³                          ÇÄÄÄÅÄÄÄ¶                             ³',
    '    ³      ¿   Logging:        ºF9 ³F10º  Print Logfile     Ú        ³',
    '    ³      Ù                   ÈÍÍÍÏÍÍÍ¼                    À        ³',
    '    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',
    '    [ HELP = Shift + Function Key ]       Choose a function  ..');

  F1_Strings : Window_Strings =
   ('',
    'HELP: Function of [F1] ...',
    '',
    '      Alone       :  Close all open files and quit program',
    '','',
    '      with [Ctrl] :  Select communication via port COM1 or',
    '                     COM2 of the PC',
    '','','','','',
    '                                            Press a key to continue ..');

  F2_Strings : Window_Strings =
   ('',
    'HELP: Function of [F2] ...                                             ',
    '',
    '                  :   Prompt for a path name.                           ',
    '                      If one is given change the current directory      ',
    '                      accordingly.                                      ',
    '',
    '                      Display the contents of the current directory.    ',
    '','','','','',
    '                                            Press a key to continue ..  ');

  F3_Strings : Window_Strings =
   ('',
    'HELP: Function of [F3] ...                                              ',
    '',
    '                  :   Prompt for an alignment file name.                ',
    '',
    '                      If one is given, change the default               ',
    '                      alignment file accordingly.                       ',
    '',
    '                      Get all alignment constants (excl. gun alignment) ',
    '                      from the microscope and write them into the       ',
    '                      default alignment file.                           ',
    '','',
    '                                            Press a key to continue ..  ');

  F4_Strings : Window_Strings =
   ('',
    'HELP: Function of [F4] ...                                             ',
    '',
    '                  :   Prompt for an alignment file name.                ',
    '',
    '                      If one is given, change the default               ',
    '                      alignment file accordingly.                       ',
    '',
    '                      Retrieve the alignment constants (excl. gun       ',
    '                      alignment) from the default alignment file        ',
    '                      and install them in the microscope.               ',
    '','',
    '                                            Press a key to continue ..  ');

  F5_Strings : Window_Strings =
   ('',
    'HELP: Function of [F5] ...                                              ',
    '',
    '                  :   Prompt for a stigmator file name.                 ',
    '',
    '                      If one is given, change the default               ',
    '                      stigmator file accordingly.                       ',
    '',
    '                      Get all stigmator settings                        ',
    '                      from the microscope and write them into the       ',
    '                      default stigmator file.                           ',
    '','',
    '                                            Press a key to continue ..  ');

  F6_Strings : Window_Strings =
   ('',
    'HELP: Function of [F6] ...                                             ',
    '',
    '      Alone       :   Prompt for a stigmator file name.                ',
    '',
    '                      If one is given, change the default               ',
    '                      stigmator file accordingly.                       ',
    '                      Retrieve the settings of a chosen stigmator       ',
    '                      from the default stigmator file                   ',
    '                      and install them in the microscope.               ',
    '',
    '      with [Ctrl] :   Choose C2, objective, or diffraction stigmator    ',
    '                      to be reinstalled.                                ',
    '                                            Press a key to continue ..  ');

  F7_Strings : Window_Strings =
   ('',
    'HELP: Function of [F7] ...                                              ',
    '',
    '                  :   Prompt for a mode file name.                      ',
    '',
    '                      If one is given, change the default               ',
    '                      mode file accordingly.                            ',
    '',
    '                      Get the mode descriptors                          ',
    '                      from the microscope and write them into the       ',
    '                      default mode file.                                ',
    '','',
    '                                            Press a key to continue ..  ');

  F8_Strings : Window_Strings =
   ('',
    'HELP: Function of [F8] ...                                              ',
    '',
    '                  :   Prompt for a mode file name.                      ',
    '',
    '                      If one is given, change the default               ',
    '                      mode file accordingly.                            ',
    '',
    '                      Retrieve the mode descriptors                     ',
    '                      from the default mode file                        ',
    '                      and install them in the microscope.               ',
    '','',
    '                                            Press a key to continue ..  ');

  F9_Strings : Window_Strings =

   ('HELP: Function of [F9] ...                                              ',
    '',
    '      Alone       :   If logging is OFF:                                ',
    '                         Prompt for a mode file name. If one is given   ',
    '                         change the default mode file accordingly.      ',
    '                         Start  data log using the default log file.    ',
    '                      If logging is ON:   Stop data logging.            ',
    '',
    '      with [Ctrl] :   Choose "Replace": An existing file with the same  ',
    '                                        name is erased by "Start".      ',
    '                          or "Append" : Data are appended to a file with',
    '                                        the same name, if one exists.   ',
    '',
    '                                            Press a key to continue ..  ');

  F10_Strings : Window_Strings =

   ('HELP: Function of [F10] ...                                             ',
    '',
    '                  :   If logging is OFF:                                ',
    '                         Prompt for a mode file name.                   ',
    '                         If one is given, change the default            ',
    '                         mode file accordingly.                         ',
    '                         Print the contents of the default data log file',
    '                         to the screen or to the line printer.          ',
    '',
    '                      If logging is ON:   No action.                    ',
    '',
    '      with [Ctrl] :   Choose "Screen" or "Printer"                      ',
    '',
    '                                            Press a key to continue ..  ');

  Confirm_Strings : Window_Strings =
   ('','','',
    '      C A U T I O N :                                                   ',
    '      ===============                                                   ',
    '',
    '          Executing this function will change the alignment             ',
    '          or the stigmator settings of the microscope.                  ',
    '',
    '          Are you sure ?   (Y/N)                                        ',
    '','','',
    '                                               Press [Y] to confirm ..  ');

  Abort_Strings : Window_Strings =
   ('','','','','',
    '              Function aborted                                          ',
    '','','','','','','',
    '                                            Press a key to continue ..  ');

  GetAlignment_Strings : Window_Strings =
   ('','','','','',
    '              Getting Alignments from Microscope into file:             ',
    '','','','','','','',
    '');

  SetAlignment_Strings : Window_Strings =
   ('','','','','',
    '              Setting Alignments into Microscope from file:             ',
    '','','','','','','',
    '');

  Get_Stigmator_Strings : Window_Strings =
   ('','','','','',
    '              Getting stigmator settings from microscope into file:     ',
    '','','','','','','',
    '');

  Set_Stigmator_Strings : Window_Strings =
   ('','','','','',
    '              Setting stigmator settings into microscope from file:     ',
    '','','','','','','',
    '');

  Get_Mode_Strings : Window_Strings =
   ('','','','','',
    '              Getting mode descriptors from microscope into file:       ',
    '','','','','','','',
    '');

  Set_Mode_Strings : Window_Strings =
   ('','','','','',
    '              Setting mode descriptors into microscope from file:       ',
    '','','','','','','',
    '');

  Ask_File_Strings : Window_Strings =
   ('','','','','',
    '              Enter file name to use for                                ',
    '','','','','','','',
    '');

  Logging_Strings : Window_Strings =
   ('','','',
    '       E R R O R                                                        ',
    '',
    '              Cannot perform this function                              ',
    '              because logging is in progress.                           ',
    '              First stop logging by pressing [F9].                      ',
    '','','','','',
    '                                       Press a key to continue ...      ');

  Printing_Strings : Window_Strings =
   ('','','','','',
    '              Printing log file:                                        ',
    '','','','','','','',
    '');

  AskDirectory_Strings : Window_Strings =
   ('','','','','',
    '              Enter new directory name:                                 ',
    '','','','','','','',
    '');

  FileReadError_Strings : Window_Strings =
   ('','','','','',
    '              Cannot read file:                                         ',
    '              (or wrong file type)',
    '','','','','','',
    '                                     Press a key to continue...         ');

  CommunicationError_Strings : Window_Strings =
   ('','','','','',
    '              Communication with microscope failed.                     ',
    '','','','','','','',
    '                                     Press a key to continue...         ');

  FileWriteError_Strings : Window_Strings =
   ('','','','','',
    '              Cannot write file:                                        ',
    '','','','','','','',
    '                                     Press a key to continue...         ');

{.pa}
  Algn_Filename : WrkString = 'ALIGNMNT.RCM';
  Stig_Filename : WrkString = 'STIGMATR.RCM';
  Mode_Filename : WrkString = 'MODE    .RCM';
  Log_Filename  : WrkString = 'LOG     .RCM';

  Stig_Choice   : Stig_Choice_Type = Obj;
  Printer       : boolean          = False;
  Replace       : boolean          = False;
  Logging       : boolean          = False;
  Update        : boolean          = True;
  Port2         : boolean          = False;

var
  i         : integer;
  choice,ch : char;
  Input_String : string[80];

  procedure Wait;
    begin for i := 1 to 32767 do  ;  end;

{.cp5}
  procedure Invert_Video;
  begin  Textbackground(White); Textcolor(Black) end;

  procedure Normal_Video;
  begin  Textbackground(Black); Textcolor(White) end;

{.cp28}
  procedure Show_Toggles;
    begin
      Window(3,12,77,25);
      if Port2 then Invert_Video else Normal_Video;
      GotoXY(7,4); Write('COM2');
      if not Port2 then Invert_Video else Normal_Video;
      GotoXY(7,3); Write('COM1');
      if printer then Invert_Video else Normal_Video;
      GotoXY(63,11); Write('LPT');
      if Printer then normal_Video else Invert_Video;
      GotoXY(63,12); Write('SCR');
      if Stig_Choice = C2   then Invert_Video else Normal_Video;
      GotoXY(63,6);Write('C2 ');
      if Stig_Choice = Obj  then Invert_Video else Normal_Video;
      GotoXY(63,7);Write('Obj');
      if Stig_Choice = Dif  then Invert_Video else Normal_Video;
      GotoXY(63,8);Write('Dif');
      if Replace then Invert_Video else Normal_Video;
      GotoXY(7,11);Write('Repl');
      if not Replace then Invert_Video else Normal_Video;
      GotoXY(7,12);Write('Appd');
      if not Logging then Invert_Video else Normal_Video;
      GotoXY(25,11);Write('OFF');
      if Logging then Invert_Video else Normal_Video;
      GotoXY(25,12);Write('ON ');
      Normal_Video;
      GotoXY(75,25);
    end;

{.cp17}
  procedure Show_Defaults;
    var dir_string : string[30];
    begin
      Window(29,2,77,8);
      Normal_Video;
      GotoXY(1,1);
      GetDir(0,dir_string);
      While Length(Dir_String) < 24 do
        Dir_String := Dir_String + ' ';
      ClrEOL; Writeln('Current Directory:   ',dir_string);
      ClrEOL; Writeln;
      ClrEOL; Writeln('Default Alignment File: ',Algn_Filename);
      ClrEOL; Writeln(' "      Stigmator File: ',Stig_Filename);
      ClrEOL; Writeln(' "      Mode      File: ',Mode_Filename);
      ClrEOL; Writeln(' "      Log       File: ',Log_Filename);
      ClrEOL;
    end;

{.cp17}
procedure Show_Screen;
  begin
    ClrScr;
    Normal_Video;
    Window(1,1,80,25);
    GotoXY(1,1);
writeln('ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»');
writeln('º                      º                                                      º');
writeln('º    ÛÛÛÛ   ÛÛ   ÛÛ    º                                                      º');
writeln('º   Û       Û Û Û Û    º                                                      º');
writeln('º   Û       Û  Û  Û    º                                                      º');
writeln('º   Û       Û     Û    º                                                      º');
writeln('º    ÛÛÛÛ   Û     Û    º                                                      º');
writeln('º                      º                                                      º');
writeln('º  M O N I T O R  1.0  º                                                      º');
writeln('ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼');
  end;

{.cp7}
  procedure Beep;
    var i:integer;
    begin
      Sound(1000);
      Wait;
      NoSound;
    end;

{.cp22}
  function Show_Window(w:Window_Strings;return_char,Toggles:boolean):char;
    var i : integer; c:char;
    begin
      if Update then begin
        Window(3,12,77,25);
        ClrSCr;
        GotoXY(1,1);
        for i := 1 to 13 do
          Writeln(w[i]);
        Write(w[14]);
        if Toggles then
          Show_Toggles;
        Update := False;
      end;
      if return_char then begin
        read(Kbd,c);
        Show_Window := UpCase(c)
      end
      else begin
        Show_Window := #0;
      end
    end;

{.cp17}
  function Main_Menu:char;
    { Shows the options and gets the choice of the user as a function key
      character }
  var Funckey:boolean; ch:char;
  begin
    repeat begin
      FuncKey := False;
        ch := Show_Window(Menu_Strings,True,True);
        if (ch = #27) and Keypressed then begin
          Read(KBd,ch);
          FuncKey := True;
        end
        else
          Beep;
    end until FuncKey and (ch in [#59..#68,#84..#113]);
    Main_menu := ch;
  end;

{.cp15}
procedure Show_Dir;
  var ch: char; Dir_String: string[80]; i:integer;

  Procedure DirList;
  { This Program lists out the directory of the current
    (logged) drive.
    Source: Turbo Pascal Tutor, Sample Program 20.2, page 20-4
  }
    type
      charl2arr    = array[1..12] of char;
      string20     = string[20];
      RegRec  =
        record
          AX,BX,CX,DX,BP,SI,DI,DS,ES,Flags : Integer;
        end;

{.cp6}
    var
      Regs         : RegRec;
      DTA          : array[1..43] of Byte;
      Mask         : Charl2arr;
      Namr         : string20;
      Error,I      : Integer;

{.cp4}
    begin                                 { of subprocedure DirList }
      FillChar(DTA,SizeOf(DTA),0);        { Initialize the DTA Buffer }
      FillChar(Mask,SizeOf(Mask),0);      { Initialize the mask }
      FillChar(NamR,SizeOf(NamR),0);      { Initialize the file name }

{.cp11}
      Regs.AX := $1A00;                   { Function used to set the DTA }
      Regs.DS := Seg(DTA);                { store the parameter segment in DS }
      Regs.DX := Ofs(DTA);                { "     "   "         offset in DX }
      MSDos(Regs);                        { Set DTA location }
      Mask := '????????.RCM';             { Use global search }
      Regs.AX := $4E00;                   { Get first directory entry }
      Regs.DS := Seg(Mask);               { Point to the file Mask }
      Regs.DX := Ofs(Mask);
      Regs.CX := 22;                      { Store the option }
      MSDos(Regs);                        { Execute MSDOS call }
      Error := Regs.AX and $FF;           { Get Error return }

{.cp11}
      I := 1;                             { initialize 'I' to the first element }
      if (Error =0) then begin
        repeat
          NamR[i] := Chr(Mem[Seg(DTA):Ofs(DTA)+29+I]);
          I := I+1;
        until not (NamR[I-1] in [' '..'~']) or (I > 20 );
        NamR[0] := Chr(I-1);                { set string length because asigning }
        while Length(NamR) < 15 do          { by element does not set length }
          NamR := NamR + ' ';
        Write(NamR)
      end;
{.cp19}
      While (Error = 0) do begin
        Error := 0;
        Regs.AX := $4F00;                 { Function used to get the next }
                                          { directory entry }
        Regs.CX := 22;                    { set the filk option }
        MSDos(Regs);                      { Call MSDos }
        Error := Regs.AX and $FF;         { get the Error return }
        I := 1;
        repeat
          NamR[I] := Chr(Mem[Seg(DTA):Ofs(DTA)+29+I]);
          I := I+1;
        until not (NamR[I-1] in [' '..'~']) or (I>20);
        NamR[0] := Chr(I-1);
        while Length(NamR) < 15 do
          NamR := NamR + #$20;
        if(Error = 0)
          then Write(NamR);
      end;
   end;                                   { of procedure Dirlist }

{.cp12}
  begin                                   { of procedure Show_Dir }
    Window(3,12,77,25);
    GetDir(0,Dir_String);
    ClrScr;
    writeln('Current directory: ',Dir_String);
    writeln;
    Dirlist;
    writeln;
    Writeln('No (more) .RCM files present.          Press a key to return to menu..');
    repeat ; until keypressed; Read(KBd,ch);
    Update := True;
  end;

{.cp8}
  procedure Show_File(Window:Window_Strings;Filename:WrkString);
    var ch:char;
    begin
      Update := True;
      ch := Show_Window(Window,False,False);
      GotoXY(60,10);Write(Filename);
      Update := True;
    end;

{.cp21}
  function Ask_Filename(Prompt_String:WrkString):WrkString;
    var stin,stout:WrkString; ch:char;  i : integer;
    begin
      Update := True;
      ch := Show_Window(Ask_File_Strings,False,False);
      GotoXY(50,7);Write(Prompt_String);
      GotoXY(50,9);Readln(stin);
      stout := '';
      if Length(stin) > 0 then begin
        i := 1;
        while (i <= Length(stin)) and (stin[i]<>'.') and (i<9) do begin
          stout := stout + Upcase(stin[i]);
          i := i+1;
        end;
        stout := stout + '.RCM';
        while Length(stout) < 12 do
          stout := stout + ' ';
      end;
      Ask_Filename := stout;
      Update := True;
    end;

{.cp10}
  procedure Show_FileReadError(filename:WrkString);
  var ch:char;
    begin
      Update := True;
      ch := Show_Window(FileReadError_Strings,False,False);
      GotoXY(50,6);
      write(Filename);
      update := True;
      repeat ; until keypressed;
    end;

{.cp10}
  procedure Show_FileWriteError(filename:WrkString);
  var ch:char;
    begin
      Update := True;
      ch := Show_Window(FileWriteError_Strings,False,False);
      GotoXY(50,6);
      write(Filename);
      update := True;
      repeat ; until keypressed;
    end;

{.cp8}
  procedure Show_CommunicationError;
  var ch:char;
    begin
      Update := True;
      ch := Show_Window(CommunicationError_Strings,False,False);
      update := True;
      repeat ; until keypressed;
    end;

{.pa}
{ ************************ The Remote Control Functions ******************* }

  procedure GetAlignment;
  { Get the alignments from the microscope and put them into the file
    with the name <Algn_Filename>. The data are preceeded by the string
    'CMONITOR-ALIGNMENT'. }
    type  Check_String_Type = String[18];
          Alignment_Set_Type = record
                                 Check_String : Check_String_Type;
                                 Alignments   : AlignmentsType;
                               end;
    var
      Alignment_Set : Alignment_Set_Type;
      AlignmentsFile: File of Alignment_Set_Type;
      ok : boolean;
    begin
      if GetAlignments(Alignment_Set.Alignments) then begin
{$I-}
        assign(Alignmentsfile,Algn_Filename );
        ok := (IOResult=0);
        if ok then begin
          rewrite(Alignmentsfile);
          ok := (IOResult = 0);
          if ok then begin
            Alignment_Set.Check_String := 'CMONITOR-ALIGNMENT';
            write(Alignmentsfile, Alignment_Set);
            ok := (IOResult = 0);
          end
        end;
        close(Alignmentsfile);
{$I+}
        if not ok then
          Show_FilewriteError(Algn_Filename);
      end
      else
        Show_CommunicationError;
    end;


{.cp13}
  procedure SetAlignment;
  { Retrieve the alignments into the microscope out of the file
    with the name <Algn_Filename>. It is checked whether the data
    are preceeded by the string 'CMONITOR-ALIGNMENT'. }
    type  Check_String_Type = String[18];
          Alignment_Set_Type = record
                                 Check_String : Check_String_Type;
                                 Alignments   : AlignmentsType;
                               end;
    var
      Alignment_Set : Alignment_Set_Type;
      AlignmentsFile: File of Alignment_Set_Type;
      ok : boolean;
{.cp15}
    begin
{$I-}
      assign(Alignmentsfile,Algn_Filename );
      ok := (IOResult = 0);
      if ok then begin
        reset(Alignmentsfile);
        ok := (IOResult = 0);
        if ok then begin
          read(Alignmentsfile,Alignment_Set);
          ok := (IOResult = 0) and
                (Alignment_Set.Check_String = 'CMONITOR-ALIGNMENT');
        end
      end;
      close(Alignmentsfile);
{$I+}
{.cp18}
      { The following commands make sure that the retrieved settings
        get active }
      if ok then begin
        ok := Pushbutton(29,0);                          { ALGN OFF }
      if ok then
        ok := SetAlignments(Alignment_Set.Alignments);
      if ok then
        ok := Pushbutton(63,1);                          { WBL ON }
      if ok then
        ok := Pushbutton(03,1);                          { D   ON }
      if ok then
        ok := Pushbutton(63,0);                          { WBL OFF }
      if ok then
        ok := Pushbutton(03,0);                          { D   OFF }
      if ok then
        ok := InstrumentMode(08);                        { TEM }
      if not ok then
        Show_CommunicationError
      end
      else
        Show_FileReadError(Algn_Filename);
    end;

{.cp13}
  procedure Get_Stigmator;
  { Get the stigmator settings from the microscope and put them into the file
    with the name <Stig_Filename>. The data are preceeded by the string
    'CMONITOR-STIGMATOR'. }
    type  Check_String_Type = String[18];
          Stigmator_Set_Type = record
                                 Check_String : Check_String_Type;
                                 StigRec      : StigType;
                               end;
    var
      Stigmator_Set : Stigmator_Set_Type;
      StigFile      : File of Stigmator_Set_Type;
      ok : boolean;
{.cp16}
    begin
      if GetStigmator(Stigmator_Set.StigRec) then begin
{$I-}
        assign(Stigfile,Stig_Filename );
        ok := (IOResult = 0);
        if ok then begin
          rewrite(Stigfile);
          ok := (IOResult = 0);
          if ok then begin
            Stigmator_Set.Check_String := 'CMONITOR-STIGMATOR';
            write(Stigfile, Stigmator_Set);
            ok := (IOResult = 0);
          end
        end;
        close(Stigfile);
{$I+}
{.cp6}
        if not ok then
          Show_FilewriteError(Stig_Filename);
      end
      else
        Show_CommunicationError
    end;

{.cp14}
  procedure Set_Stigmator;
  { Retrieve the stigmator settings into the microscope out of the file
    with the name <Stig_Filename>. It is checked whether the data
    are preceeded by the string 'CMONITOR-STIGMATOR'. }
    type  Check_String_Type = String[18];
          Stigmator_Set_Type = record
                                 Check_String : Check_String_Type;
                                 StigRec      : StigType;
                               end;
    var
      Stigmator_Set : Stigmator_Set_Type;
      StigFile      : File of Stigmator_Set_Type;
      ok : boolean;
      StigNr : integer;
{.cp15}
    begin
{$I-}
      assign(Stigfile,Stig_Filename );
      ok := (IOResult =0);
      if ok then begin
        reset(Stigfile);
        ok := (IOResult =0);
        if ok then begin
          read(Stigfile,Stigmator_Set);
          ok := (IOResult =0) and
                (Stigmator_Set.Check_String = 'CMONITOR-STIGMATOR');
        end;
      end;
      close(Stigfile);
{$I+}
{.cp8}
      StigNr := Ord(Stig_Choice);
      if ok then begin
        if not SetStigmator(Stigmator_Set.StigRec,StigNr) then
          Show_CommunicationError
      end
      else
        Show_FileReadError(Stig_Filename);
    end;

{.cp13}
  procedure Get_Mode;
  { Get the mode descriptors from the microscope and put them into the file
    with the name <Mode_Filename>. The data are preceeded by the string
    'CMONITOR-MODE'. }
    type  Check_String_Type = String[13];
          Mode_Set_Type = record
                            Check_String : Check_String_Type;
                            ModeRec      : ModeType;
                           end;
    var
      Mode_Set      : Mode_Set_Type;
      ModeFile      : File of Mode_Set_Type;
      ok : boolean;
{.cp16}
    begin
    if GetMode(Mode_Set.ModeRec) then begin
{$I-}
      assign(Modefile,Mode_Filename );
      ok := (IOResult = 0);
      if ok then begin
        rewrite(Modefile);
        ok := (IOResult = 0);
        if ok then begin
          Mode_Set.Check_String := 'CMONITOR-MODE';
          write(Modefile,Mode_Set);
          ok := (IOResult = 0);
        end
      end;
      close(Modefile);
{$I+}
{.cp6}
      if not ok then
        Show_FilewriteError(Mode_Filename);
    end
    else
      Show_CommunicationError;
    end;

{.cp13}
  procedure Set_Mode;
  { Retrieve the mode descriptors into the microscope out of the file
    with the name <Mode_Filename>. It is checked whether the data
    are preceeded by the string 'CMONITOR-MODE'. }
    type  Check_String_Type = String[13];
          Mode_Set_Type = record
                            Check_String : String[13];
                            ModeRec      : ModeType;
                           end;
    var
      Mode_Set      : Mode_Set_Type;
      ModeFile      : File of Mode_Set_Type;
      ok : boolean;
{.cp15}
    begin
{$I-}
      assign(Modefile,Mode_Filename );
      ok := (IOResult =0);
      if ok then begin
        reset(Modefile);
        ok := (IOResult =0);
        if ok then begin
          read(Modefile, Mode_Set);
          ok := (IOResult =0) and
                (Mode_Set.Check_String = 'CMONITOR-MODE');
        end
      end;
      close(modefile);
{$I+}
{.cp7}
      if ok then begin
        if not SetMode(Mode_Set.ModeRec) then
          Show_CommunicationError
      end
      else
        Show_FileReadError(Mode_Filename);
    end;

{.cp17}
  procedure StartStopLog;
  { If logging is True, stop logging closing the file <Log_Filename>.
    If logging is False, start logging in <Log_Filename>.
    iF Replace = True, the file is rewritten, otherwise simply opened
    to write, after a check whether it is present. }
    begin
     if not logging then
       if StartDisplInfo(Log_filename,not replace) then
         logging := True
       else
         Show_CommunicationError
     else
       if StopDisplInfo then
         logging := False
       else
         Show_CommunicationError;
    end;

{.cp11}
  function Print_Log:boolean;
  { Prints the contents of file <Log_Filename> on the screen in full format
    if printer = False, or on the default line printer }
    var ok        : boolean;
        IO_File   : Text;
    begin
      if not printer then begin
        Window(1,1,80,25);
        ClrScr;
        Normal_Video;
      end;
{.cp23}
{$I-}
      Assign(IO_File,Log_Filename);
      ok := (IOResult = 0);
      if ok then begin
        Reset(IO_File);
        ok := (IOResult=0);
      end;
      if ok then
        While not EOF(IO_File) do begin
          Read(IO_File,ch);
          if printer then
            Write(LST,ch)
          else
            Write(output,ch);
        end;
      ok := ok and (IOResult = 0);
      if ok then
        Close(IO_File);
{$I+}
      if not ok then
        Show_FileReadError(log_Filename);
      Print_Log := ok;
    end;

{.pa}
{ ********************** Main Program **************************** }

begin
  Show_Screen;
  Show_Defaults;
  if (not OpenRemoteCM) or (not EquipmentAvailable) then
    Show_CommunicationError;
  repeat begin
    Choice := Main_menu;
    case Choice of
      #59: begin                               { F1: QUIT }
             if logging then
               logging := StopDisplInfo;
             Window(1,1,80,25);
             ClrScr;
           end;
{.cp10}
      #60: begin                               { F2: DIR  }
             Update := True;
             ch := Show_Window(Askdirectory_Strings,False,False);
             GotoXY(50,6);
             Readln(Input_String);
             if Length(Input_String) > 0 then
               ChDir(Input_String);
             Show_Defaults;
             Show_Dir;
           end;
{.cp9}
      #61: begin                                { F3: GET ALGN }
             Input_String := Ask_Filename('Alignments');
             if Length(Input_String) > 0 then begin
               Algn_Filename := Input_String;
               Show_Defaults;
             end;
             Show_File(GetAlignment_Strings,Algn_Filename);
             GetAlignment;
           end;
{.cp16}
      #62: begin                                 { F4: SET ALGN }
             Input_String := Ask_Filename('Alignments');
             if Length(Input_String) > 0 then begin
               Algn_Filename := Input_String;
               Show_Defaults;
             end;
             ch := Show_Window(Confirm_Strings,True,False);
             Update := True;
             if ch <> 'Y' then
               ch := Show_Window(Abort_Strings,False,False)
             else begin
               Show_File(SetAlignment_Strings,Algn_Filename);
               SetAlignment;
             end;
             Update := True
           end;
{.cp9}
      #63: begin                                  {      F5: GET STIG DEF }
             Input_String := Ask_Filename('Stigmator');
             if Length(Input_String) > 0 then begin
               Stig_Filename := Input_String;
               Show_Defaults;
             end;
             Show_File(Get_Stigmator_Strings,Stig_Filename);
             Get_Stigmator;
           end;
{.cp16}
      #64: begin                                   { F6: SET STIG }
             Input_String := Ask_Filename('Stigmator');
             if Length(Input_String) > 0 then begin
               Stig_Filename := Input_String;
               Show_Defaults;
             end;
             ch := Show_Window(Confirm_Strings,True,False);
             Update := True;
             if ch <> 'Y' then
               ch := Show_Window(Abort_Strings,False,False)
             else begin
               Show_File(Set_Stigmator_Strings,Stig_Filename);
               Set_Stigmator;
             end;
             Update := True;
           end;
{.cp10}
      #65: begin                                    { F7: GET MODE }
             Input_String := Ask_Filename('Mode setting');
             if Length(Input_String) > 0 then begin
               Mode_Filename := Input_String;
               Show_Defaults;
             end;
             Show_File(Get_Mode_Strings,Mode_Filename);
             Get_Mode;
             Update := True;
           end;
{.cp10}
      #66: begin                                     { F8: SET MODE DEF }
             Input_String := Ask_Filename('Mode setting');
             if Length(Input_String) > 0 then begin
               Mode_Filename := Input_String;
               Show_Defaults;
             end;
             Show_File(Set_Mode_Strings,Mode_Filename);
             Set_Mode;
             Update := True;
           end;
{.cp14}
      #67: begin                                { F9: START DATA LOG }
             if logging then begin
               StartStopLog;
               Show_Toggles;
             end
             else begin
               Input_String := Ask_Filename('Logging');
               if Length(Input_String) > 0 then begin
                 Log_Filename := Input_String;
                 Show_Defaults;
               end;
               StartStopLog;
             end
           end;
{.cp33}
      #68: begin                                { F10: PRINT DATA LOG }
             if logging then begin
               Update := True;
               ch := Show_Window(Logging_Strings,True,False);
               Update := True;
             end
             else begin
               Input_String := Ask_Filename('Log Printing');
               if Length(Input_String) > 0 then begin
                 log_Filename := Input_String;
                 Show_Defaults;
               end;
               if printer then begin
                 Update := True;
                 ch := Show_Window(Printing_Strings,False,False);
                 GotoXY(50,6);Write(Log_Filename);
                 Update := True;
               end;
               if Print_Log and (not printer) then begin
                 writeln;writeln;
                 Invert_Video;
                 write('End of log file                       Press a key to continue..');
                 Normal_Video;
                 repeat ; until keypressed;
               end;
               if not printer then begin
                 Show_Screen;
                 Show_Defaults;
                 Show_Toggles;
                 Update := True;
               end
             end
           end;
{.cp5}
      #84: begin
             Update := True;
             ch := Show_Window(F1_Strings,True,False); { Sh   F1: HELP }
             Update := True;
           end;
{.cp5}
      #85: begin
             Update := True;
             ch := Show_Window(F2_Strings,True,False); { Sh   F2: HELP }
             Update := True;
           end;
{.cp5}
      #86: begin
             Update := True;
             ch := Show_Window(F3_Strings,True,False); { Sh   F3: HELP }
             Update := True;
           end;
{.cp5}
      #87: begin
             Update := True;
             ch := Show_Window(F4_Strings,True,False); { Sh   F4: HELP }
             Update := True;
           end;
{.cp5}
      #88: begin
             Update := True;
             ch := Show_Window(F5_Strings,True,False); { Sh   F5: HELP }
             Update := True;
           end;
{.cp5}
      #89: begin
             Update := True;
             ch := Show_Window(F6_Strings,True,False); { Sh   F6: HELP }
             Update := True;
           end;
{.cp5}
      #90: begin
             Update := True;
             ch := Show_Window(F7_Strings,True,False); { Sh   F7: HELP }
             Update := True;
           end;
{.cp5}
      #91: begin
             Update := True;
             ch := Show_Window(F8_Strings,True,False); { Sh   F8: HELP }
             Update := True;
           end;
{.cp5}
      #92: begin
             Update := True;
             ch := Show_Window(F9_Strings,True,False); { Sh   F9: HELP }
             Update := True;
           end;
{.cp5}
      #93: begin
             Update := True;
             ch := Show_Window(F10_Strings,True,False); { Sh   F10: HELP }
             Update := True;
           end;
{.cp8}
       #94:begin                       { Ctrl F1: Toggle Port 1/2   }
             Port2 := not Port2;
             Show_Toggles;
             if Port2 then i := 2 else i := 1;
             if (not IOCtl(9600,i)) or
                (not OpenRemoteCM) or (not EquipmentAvailable) then
                Show_CommunicationError;
           end;
{.cp9}
       #99:begin                       { Ctrl F6: Toggle C2/OBJ/DIF }
             if (Stig_Choice = C2) then
               Stig_Choice := Obj
             else if (Stig_Choice = Obj) then
               Stig_Choice := Dif
             else
               Stig_Choice := C2;
             Show_Toggles;
           end;
{.cp4}
      #102:begin                    { Ctrl F9: Toggle Append/Replace }
             Replace := not Replace;
             Show_Toggles;
           end;
{.cp8}
      #103:begin                          { Ctrl F10: Toggle LPT/CRT }
             Printer := not Printer;
             Show_Toggles;
           end;
      else Beep;
    end  { case }
  end until Choice = #59;                                       { F1 }
end.




