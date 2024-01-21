{ This source is to be distributed under the terms
of the GPL - Gnu Public License.
Copyright (C) 2001-2002 Carmelo Spiccia, Michele Povigna.

This program is free software; you can redistribute it
and/or modify it under the terms of the GNU General
Public License as published by the Free Software
Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will
be useful, but WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License
for more details.

You can find a copy of this license at
http://www.gnu.org/licenses/gpl.txt }

{
----------------- ATTENTION -----------------
This is an alpha version, not fully tested.

----------- COMPILATION SUGGESTS ------------
This source is compatible with Turbo Pascal 7
and FreePascal compilers. FreePascal with $H+
directive is strongly raccomanded.

-------- NEW FEATURES SINCE V. 0.291 --------
+ SET: +=, -=, *=, /=, ^=, Var=, ALL+=3, ALL=ALL^2-1, ALL=
+ EXTENDED SINTAX: A++, A--, 4**5
+ FUNCTIONS: SIN, TAN, LN, ROUND, MEAN, COMB, DERIV, INT...
+ FILE OUTPUT: Text plain, XML/MathML (Presentation tags only)
+ PERCENT: 80%
+ DEGREE: 30¯10'15''
+ ADVANCED FACTORIAL: -0.5!=Pi^0.5; 0.5!=0.5*Pi^0.5; ...
+ MANY EXPRESSIONS AT THE SAME TIME: 4+3^2, 5+3-2 => 4+9, 8-2
+ MULTILINE INPUT: Can accept up to 234 characters
+ COMMANDS: New "Result only" mode
+ PAS MATH SCRIPT
}

{$H+}
{$M 65520, 0, 655360}
{$N+}
{$E+}
Program PASmath;
 Uses Crt;
 Type Punt = ^Element;
      Element = Record
                Name: String;
                Value: String;
                ForPt: Punt;
              End;
  Const Version = '0.4 alpha';
        HighPrecision = True;
        Cifre         = ['0'..'9','.'];
        Cifre2        = ['0'..'9'];
        Operators     = ['^','*','/','+','-'];
        UOperators    = ['!','%','¯',''''];
        Brackets      = ['(',')','|'];
        CommLength    = 11;
        Commands: Array[1..CommLength] Of String[10] = ('CLS','COLOR','DEC',
           'DELAY','EXIT','EXT','HELP','QUIT','RESULTONLY','SET','EXEC');
        FunLength     = 31; (* Order is important !!! *)
        Functions: Array[1..FunLength] Of String[5] = ('ASIN','SIN',
           'ACOS','COS','ATAN','TAN','ACOT','COT','ASEC','SEC','ACSC','CSC',
           'DEG','RAD','LN','LOG','EXP','SQRT','ABS','TRUNC','ROUND','MEAN',
           'COMBR','COMB','DISPR','DISP','PERM','RND','VAL','INT','DERIV');
        Operators2 : Array[1..5] Of Char = ('^','*','/','+','-');
        Colors     : Array[1..5] Of Byte = (2,9,7,5,6);
        DelTime    : Integer = 0;
        Decimals   : Integer = 4;
        ExprColors : Boolean = True;
        ExtSintax  : Boolean = False;
        FileWrite  : Boolean = False;
        FileName   : String = 'OUTPUT.TXT';
        XML        : Boolean = False;
        ResultOnly : Boolean = False;
        NoOutput   : Boolean = False;
        VMax=100;
        ipCaseUp = 1; ipNum = 2;    ipAlf = 4;    ipSpc = 8;
        ipVir = $10;  ipPto = $20;  ipUOp = $40;  ipOpe = $80;
        ipBrk = $100; ipAcc = $200; ipAll = $400; ipTab = $800;
        ipQMs = $1000; ipAltri = $2000; ipEverything = $FFFFFFFF;
  Var InpCar,Expr,Err: String;
      I,WX,WY,VLength,VPos,IPos: Byte;
      VExpr: Array[1..VMax] Of String;
      PC: Integer;
      BegPt: Punt;
      PMScript,OutFile,TmpFile: Text;

  Function StartToken(St: String; I: Integer): Integer;
    Var BrCount1,BrCount2: Integer;
    Begin
      If I<1 Then I:=1;
      If I>Length(St) Then I:=Length(St);
      If St[I]=')' Then
        Begin
          BrCount1:=0; BrCount2:=1;
          While I>0 Do
            Begin
              I:=I-1;
              If St[I]='(' Then BrCount1:=BrCount1+1;
              If St[I]=')' Then BrCount2:=BrCount2+1;
              If BrCount2=BrCount1 Then Break;
            End;
        End
                   Else
        While I>0 Do
          Begin
            If St[I] In (Operators+Brackets+UOperators) Then
              Begin
                I:=I+1;
                Break;
              End;
            I:=I-1;
          End;
      If I<1 Then I:=1;
      If I>Length(St) Then I:=Length(St);
      StartToken:=I;
    End;

  Function EndToken(St: String; I: Integer): Integer;
    Begin
      If I<1 Then I:=1;
      If I<Length(St) Then I:=I+1 Else I:=Length(St);
      While I<=Length(St) Do
        Begin
          If St[I] In (Operators+Brackets+UOperators) Then
            Begin
              I:=I-1;
              Break;
            End;
          If I=Length(St) Then Break;
          I:=I+1;
        End;
      EndToken:=I;
    End;

  Function ExprToMathML(St: String): String;
    Const NewLine = #13#10;
    Var Result,TmpSt: String;
        ISup,I,I2,TmpInt1,BaseStart,NSup,BrCount1,BrCount2: Integer;
        Funct,MRow,Sup: Boolean;
        TmpChar: Char;
    Begin
      Result:='<mrow>'+NewLine;
      I:=0; ISup:=0; MRow:=False; Sup:=False; NSup:=0; Funct:=True;
      While I<Length(St) Do
        Begin
          I:=I+1;
          If St[I] In ['A'..'Z','a'..'z'] Then
            Begin
              MRow:=True; Funct:=True;
              BaseStart:=Length(Result)+1;
              For I2:=I+1 To Length(St) Do
                If Not(St[I2] In ['A'..'Z','a'..'z']) Then Break;
              Result:=Result+'<mi>'+Copy(St,I,I2-I)+'</mi>'+NewLine
            ;(*    +'<mo>&ApplyFunction;</mo>'+NewLine; *)
              I:=I2;
            End;
          If St[I] In Cifre2 Then
            Begin
              MRow:=False;
              BaseStart:=Length(Result)+1;
              TmpInt1:=EndToken(St,I);
              Result:=Result+'<mn>'+Copy(St,I,TmpInt1-I+1)+'</mn>'+NewLine;
              I:=TmpInt1;
            End;
          If Sup And ((St[I] In (Operators-['^'])) And (ISup+1<I)
             Or (St[I] In ['*','/'])) Then
            Begin
              For I2:=1 To NSup Do
                Result:=Result+'</mrow>'+NewLine+'</msup>'+NewLine;
              Sup:=False; NSup:=0;
            End;
          If St[I] In UOperators Then MRow:=True;
          If St[I] In (Operators+UOperators-['^']) Then
            Begin
              If St[I]='¯' Then   (* #176 *)
                Result:=Result+'<mtext>o</mtext>'+NewLine
                           Else
                Result:=Result+'<mo>'+St[I]+'</mo>'+NewLine;
            End;
          If St[I] In ['(','|'] Then
            Begin
              If Not Funct Then
                Begin
                  MRow:=False;
                  BaseStart:=Length(Result)+1
                End
                           Else Funct:=False;
              If St[I]='(' Then
                Begin
                  TmpChar:=')';
                  TmpSt:='';
                End
                           Else
                Begin
                  TmpChar:='|';
                  TmpSt:=' open="|" close="|"';
                End;
              I2:=I;
              While I2<Length(St) Do
                Begin
                  I2:=I2+1;
                  If St[I2]=TmpChar Then Break;
                  If St[I2]='(' Then
                    Begin
                      BrCount1:=0; BrCount2:=1;
                      While I2<Length(St) Do
                        Begin
                          I2:=I2+1;
                          If St[I2]='(' Then BrCount2:=BrCount2+1;
                          If St[I2]=')' Then BrCount1:=BrCount1+1;
                          If BrCount1=BrCount2 Then Break;
                        End;
                    End;
                End;
              TmpInt1:=I2-I; BaseStart:=Length(Result)+1;
              Result:=Result+'<mfenced'+TmpSt+'>'+NewLine
                +ExprToMathML(Copy(St,I+1,TmpInt1-1))+
                +'</mfenced>'+NewLine;
              I:=I+TmpInt1;
            End;
          If St[I]='^' Then
            Begin
              Sup:=True; NSup:=NSup+1; ISup:=I;
              If MRow Then
                Begin
                  Insert('<mrow>'+NewLine,Result,BaseStart);
                  Result:=Result+'</mrow>'+NewLine;
                End;
              Insert('<msup>'+NewLine,Result,BaseStart);
              Result:=Result+'<mrow>'+NewLine;
            End;
        End;
      If Sup Then Result:=Result+'</mrow>'+NewLine+'</msup>'+NewLine;
      ExprToMathML:=Result+'</mrow>'+NewLine;
    End;

    Procedure WriteText(St: String; Separator: Boolean);
      Var FileOk: Boolean;
          TmpSt: String;
      Begin
        {$I-}
        Append(OutFile);
        {$I+}
        If IOResult<>0 Then ReWrite(OutFile);
        If XML Then
          Begin
            Assign(TmpFile,'PASMTEMP.TMP');
            Reset(OutFile);
            Rewrite(TmpFile);
            FileOk:=False;
            While Not Eof(OutFile) Do
              Begin
                Readln(OutFile,TmpSt);
                FileOk:=FileOk Or (Pos('<body>',TmpSt)>0);
                If Pos('</body>',TmpSt)>0 Then Break;
                Writeln(TmpFile,TmpSt);
              End;
            Close(OutFile);
            If Not FileOk Then
              Begin
                ReWrite(TmpFile);
                Writeln(TmpFile,'<?xml version="1.0"?>');
                Writeln(TmpFile,'<?xml-stylesheet type="text/xsl" href="pmathml.xsl"?>');
                Writeln(TmpFile,'<html xmlns="http://www.w3.org/1999/xhtml">');
                Writeln(TmpFile,'<head></head>');
                Writeln(TmpFile,'<body>');
              End;
            If Separator Then Writeln(TmpFile,'<p><hr></hr></p>');
            Writeln(TmpFile,'<p><math xmlns="http://www.w3.org/1998/Math/MathML">');
            Write(TmpFile,ExprToMathML(St));
            Writeln(TmpFile,'</math></p>');
            Writeln(TmpFile,'</body>');
            Write(TmpFile,'</html>');
            Close(TmpFile);
            Rename(OutFile,'OLDFILE.TMP');
            Rename(TmpFile,FileName);
            Erase(OutFile);
            Assign(OutFile,FileName);
          End
               Else
          Begin
            If Separator Then Writeln(OutFile,'----------------------');
            Writeln(OutFile,St);
            Close(OutFile);
          End;
      End;

    Procedure WriteExpr(St: String; Var BrCount1,BrCount2: Integer);
      Var I: Integer;
      Begin
        If NoOutput Then Exit;
        If Not ExprColors Then Write(St)
                          Else
          Begin
            BrCount1:=0; BrCount2:=0;
            For I:=1 To Length(St) Do
              Begin
                Textcolor(7);
                If St[I]='(' Then BrCount2:=BrCount2+1;
                If St[I] In Brackets-['|'] Then
                  Case ((BrCount2-BrCount1) Mod 3) Of
                    0: Textcolor(3);
                    1: Textcolor(2);
                    2: Textcolor(6);
                  End;
                If St[I]=')' Then BrCount1:=BrCount1+1;
                If St[I] In Cifre Then Textcolor(7);
                If St[I] In Operators Then Textcolor(5);
                If St[I]='!' Then Textcolor(5);
                If St[I]='|' Then Textcolor(9);
                If BrCount1>BrCount2 Then Textcolor(4);
                Write(St[I]);
              End;
          End;
      End;

    Procedure WritelnExpr(St: String; Var BrCount1,BrCount2: Integer);
      Begin
        If NoOutput Then Exit;
        If Not ExprColors Then Write(St) Else WriteExpr(St,BrCount1,BrCount2);
        Writeln;
      End;

    Function Input(Var Stringa: String; Var PCur: Integer; Var X,Y: Byte;
                   Max: Integer; Sfondo: Char; Attrib: Longint): String;
      Var Car: Char;
          Ris: String;
          K,K2,BrCount1,BrCount2,TmpNum,CX,CY,MX,MY: Integer;
          InsCar: Boolean;
      Begin (* Sfondo:='_'; *)
        Textcolor(7);
        BrCount1:=0; BrCount2:=0;
        If X<1 Then X:=1;
        If Y<1 Then Y:=1;
        If PCur>0 Then PCur:=0;
        If Length(Stringa)+PCur<0 Then PCur:=-Length(Stringa);
     (* If Max>(80-X) Then Max:=80-X; *)
        Gotoxy(X,Y);
        WriteExpr(Stringa,BrCount1,BrCount2);
        CX:=WhereX; CY:=WhereY; MX:=CX; MY:=CY;
        For K:=1 To Max-Length(Stringa) Do Write(Sfondo);
        K:=(Max-(80-X)) Div 80;
        K2:=(Length(Stringa)-(80-X)) Div 80;
        If Y+K>20 Then
          Begin
            Y:=Y-(Y+K-20);
            CY:=Y+K2;
          End;
        If Stringa='' Then MY:=CY;
        If VMax<=(80-X) Then
          If CY>=20 Then Begin CY:=CY-1; Y:=Y-1; MY:=MY-1; End;
        Gotoxy(CX,CY);
        Repeat
          Car:=Readkey;
          If ExprColors Then
            Begin
              If Car='(' Then BrCount2:=BrCount2+1;
              If Car In Brackets-['|'] Then
                Case ((BrCount2-BrCount1) Mod 3) Of
                  0: Textcolor(3);
                  1: Textcolor(2);
                  2: Textcolor(6);
                End;
              If Car=')' Then BrCount1:=BrCount1+1;
              If Car In Cifre Then Textcolor(7);
              If Car In Operators Then Textcolor(5);
              If Car='!' Then Textcolor(5);
              If Car='|' Then Textcolor(9);
              If (Attrib And ipCaseUp)>0 Then Car:=Upcase(Car);
              If BrCount1>BrCount2 Then Textcolor(4);
            End;
          InsCar:=False;
          Case Car Of
            ^C: Halt; (*** Per emergenza ***)
            '0'..'9': If (Length(Stringa)<Max) And ((Attrib And ipNum)>0) Then InsCar:=True;
            'a'..'z','A'..'Z': If (Length(Stringa)<Max) And ((Attrib And ipAlf)>0) Then InsCar:=True;
            ' ': If (Length(Stringa)<Max) And ((Attrib And ipSpc)>0) Then InsCar:=True;
            ',': If (Length(Stringa)<Max) And ((Attrib And ipVir)>0) Then InsCar:=True;
            '.': If (Length(Stringa)<Max) And ((Attrib And ipPto)>0) Then InsCar:=True;
            '!','%','¯','''': If (Length(Stringa)<Max) And ((Attrib And ipUOp)>0) Then InsCar:=True;
            '^','*','/','+','-','=':
                 If (Length(Stringa)<Max) And ((Attrib And ipOpe)>0) Then InsCar:=True;
            '(',')','|':
                 If (Length(Stringa)<Max) And ((Attrib And ipBrk)>0) Then InsCar:=True;
            'ä','Ç','ï','Ö','ó','ç':
                 If (Length(Stringa)<Max) And ((Attrib And ipAcc)>0) Then InsCar:=True;
            '"': If (Length(Stringa)<Max) And ((Attrib And ipQMs)>0) Then InsCar:=True;
            '<','>',';',':','_','\','ú','$','&',
            '?','ı','á','#','@','[',']':
                 If (Length(Stringa)<Max) And ((Attrib And ipAll)>0) Then InsCar:=True;
            #9: If ((Attrib And ipTab)>0) Then Begin Ris:=Car; Break; End;
            #13,#27: Begin Ris:=Car; Break; End;
            #8: If Length(Stringa)>0 Then
                      Begin
                        Delete(Stringa,Length(Stringa)+PCur,1);
                        Gotoxy(X,Y);
                        WriteExpr(Stringa,BrCount1,BrCount2);
                        MX:=WhereX; MY:=WhereY;
                        Write(Sfondo);
                        Gotoxy(MX,MY);
                        CX:=CX-1;
                      End;
            #0: Begin
                      Car:=Readkey;
                      If ((Attrib And ipAltri)>0) Then
                        Case Upcase(Car) Of
                          'M': If PCur<0 Then
                                 Begin
                                   PCur:=PCur+1;
                                   CX:=CX+1;
                                 End;
                          'K': If Length(Stringa)+PCur>0 Then
                                 Begin
                                   PCur:=PCur-1;
                                   CX:=CX-1;
                                 End;
                          'H': Begin Ris:='Up'; Break; End;
                          'P': Begin Ris:='Down'; Break; End;
                          '<': Begin Ris:='F2'; Break; End;
                          '=': Begin Ris:='F3'; Break; End;
                          '>': Begin Ris:='F4'; Break; End;
                          '?': Begin Ris:='F5'; Break; End;
                          '@': Begin Ris:='F6'; Break; End;
                          'A': Begin Ris:='F7'; Break; End;
                          'B': Begin Ris:='F8'; Break; End;
                          'C': Begin Ris:='F9'; Break; End;
                          'D': Begin Ris:='F10'; Break; End;
                          'O': Begin PCur:=0; CX:=MX; CY:=MY; End;
                          'R': Begin Ris:='Ins'; Break; End;
                          'S': If PCur<0 Then
                                 Begin
                                   If MX>1 Then MX:=MX-1
                                           Else Begin MX:=80; MY:=MY-1; End;
                                   Delete(Stringa,Length(Stringa)+PCur+1,1);
                                   Gotoxy(X+Length(Stringa),Y);
                                   Gotoxy(X,Y);
                                   WriteExpr(Stringa,BrCount1,BrCount2);
                                   Write(Sfondo);
                                   PCur:=PCur+1;
                                 End;
                          'G': Begin PCur:=-Length(Stringa); CX:=X; CY:=Y; End;
                          'I': Begin Ris:='Page Up'; Break; End;
                          'Q': Begin Ris:='Page Down'; Break; End;
                        End;
                    End;
          End;
        If InsCar Then
          Begin
            TmpNum:=Length(Stringa);
            Stringa:=Copy(Stringa,1,TmpNum+PCur)+Car+Copy(Stringa,TmpNum+PCur+1,TmpNum);
            Gotoxy(X,Y);
            WriteExpr(Stringa,BrCount1,BrCount2);
            MX:=WhereX; MY:=WhereY;
            CX:=CX+1;
          End;
        If CX>80 Then
          Begin
            CX:=1; CY:=CY+1;
            If CY>20 Then Begin CY:=CY-1; Y:=Y-1; MY:=MY-1; End;
          End;
        If CX<1 Then Begin CX:=80; CY:=CY-1; End;
        Gotoxy(CX,CY);
        Until False;
        Input:=Ris;
      End;

  Function Factorial(X: Extended): Extended;
    Var Result,I: Extended;
    Begin
      If (X=0) Or (X=1) Then
        Result:=1
                        Else
        If X<0 Then
          Result:=Sqrt(Pi)
               Else
          Begin
            Result:=X; I:=X;
            While I>1 Do
              Begin
                I:=I-1;
                Result:=Result*I;
              End;
            If I=0.5 Then Result:=Result*Sqrt(Pi);
          End;
      Factorial:=Result;
    End;

  Function Esp(Base,Esponente: Extended): Extended;
    Var Res: Extended;
        K,E: Longint;
    Begin
      Res:=1;
      E:=Round(Esponente);
      If Esponente<0 Then E:=-E;
      If Esponente=0 Then Res:=1
                     Else
        For K:=1 To E Do
          Res:=Res*Base;
      If Esponente<0 Then Res:=1/Res;
      Esp:=Res;
    End;

  Function NoScientNot(St: String): String;
    Var P1,P2,I,Err2: Integer;
        SubSt,TmpSt: String;
        Num,Esp: Extended;
        Prec: Byte;
    Begin
      P1:=Pos('[$',St);
      P2:=Pos('$]',St);
      While (P1<>0) And (P2<>0) Do
        Begin
          Prec:=Decimals;
          SubSt:=Copy(St,P1,P2-P1+2);
          Delete(SubSt,1,2);
          I:=Pos('$',SubSt);
          TmpSt:=Copy(SubSt,1,I-1);
          If TmpSt[1]='_' Then TmpSt[1]:='-';
          Delete(SubSt,1,I);
          If SubSt[1]='_' Then SubSt[1]:='-';
          Delete(SubSt,Length(SubSt)-1,2);
          Val(TmpSt,Num,Err2);
          Val(SubSt,Esp,Err2);
          If (Esp>=-Prec) And (Esp<=16) Then
            Begin
              Num:=Num*Exp(Esp*Ln(10));
              Esp:=0;
            End;
          If Num=Int(Num) Then Prec:=0;
          Str(Num:0:Prec,TmpSt);
          Str(Esp:0:0,SubSt);
          If Esp<>0 Then SubSt:='('+TmpSt+'*10^'+SubSt+')'
                    Else
            If Num>=0 Then SubSt:=TmpSt
                      Else
              Begin
                SubSt:='';
                If P2<Length(St) Then
                  If St[P2+2] In (['^']+UOperators) Then SubSt:='('+TmpSt+')';
                If SubSt='' Then
                  If P1=1 Then SubSt:=TmpSt
                          Else
                    If St[P1-1] In ['*','/'] Then SubSt:=TmpSt
                                             Else
                      If St[P1-1]='^' Then SubSt:='('+TmpSt+')'
                                      Else
                        If St[P1-1]='+' Then
                          Begin
                            St[P1]:='-';
                            SubSt:=Copy(TmpSt,2,Length(St));
                          End
                                        Else
                          If St[P1-1]='-' Then
                            Begin
                              St[P1]:='+';
                              SubSt:=Copy(TmpSt,2,Length(St));
                            End
                                          Else SubSt:='('+TmpSt+')';
              End;
          St:=Copy(St,1,P1-1)+SubSt+Copy(St,P2+2,Length(St)-P2-1);
          P1:=Pos('[$',St);
          P2:=Pos('$]',St);
        End;
      NoScientNot:=St;
    End;

  Function IntToStr(X: Integer): String;
    Var St: String;
    Begin
      Str(X,St);
      IntToStr:=St;
    End;

  Function NoSquare(St: String): String;
    Var I: Integer;
    Begin
      Repeat
        I:=Pos('[',St);
        If I>0 Then St[I]:='(';
      Until I=0;
      Repeat
        I:=Pos(']',St);
        If I>0 Then St[I]:=')';
      Until I=0;
      NoSquare:=St;
    End;

  Function ExtExpr(St: String): String;
    Var I: Integer;
    Begin
      I:=Pos('**',St);
      While I>0 Do
        Begin
          St[I]:='^';
          Delete(St,I+1,1);
          I:=Pos('**',St);
        End;
      I:=Pos('++++',St)+Pos('++--',St)+Pos('--++',St)+Pos('----',St);
      If I>0 Then
        Begin
          ExtExpr:=St;
          Exit
        End;
      I:=Pos('++',St);
      While I>0 Do
        Begin
          St[I]:='+';
          St[I+1]:='1';
       (* If I+2<=Length(St) Then
            If Not(St[I+2] In Operators+UOperators+Brackets) Then
              Begin *)
                Insert(')',St,I+2);
                If I>1 Then
                  If St[I-1] In UOperators Then I:=I-1;
                Insert('(',St,StartToken(St,I-1));
           (* End; *)
          I:=Pos('++',St);
        End;
      I:=Pos('--',St);
      While I>0 Do
        Begin
          St[I]:='-';
          St[I+1]:='1';
       (* If I+2<=Length(St) Then
            If Not(St[I+2] In Operators+UOperators+Brackets) Then
              Begin *)
                Insert(')',St,I+2);
                If I>1 Then
                  If St[I-1] In UOperators Then I:=I-1;
                Insert('(',St,StartToken(St,I-1));
           (* End; *)
          I:=Pos('--',St);
        End;
      ExtExpr:=St;
    End;

  Function Zero_Filter(St: String; ZeroBP,DecOnly: Boolean): String;
    Var I,I2,I3: Integer;
        Del: Boolean;
    Begin
      If Not DecOnly Then
        Begin
       (* Deletes plus before tokens *)
          I:=Pos('+',St);
          If I>0 Then
            Repeat
              I2:=I;
              If I=1 Then Delete(St,1,1)
                     Else
                If St[I-1] In Operators Then Delete(St,I,1);
              I:=I+Pos('+',Copy(St,I+1,Length(St)-I));
            Until I=I2;
          I:=0;
       (* Deletes zeros before tokens *)
          If ZeroBP And (St[1]='.') Then Insert('0',St,1);
          While I<Length(St)-1 Do
            Begin
              I:=I+1; Del:=True;
              If ZeroBP And (St[I]='.') And (I>1) Then
                If Not(St[I-1] In Cifre2) Then
                  Begin
                    Insert('0',St,I);
                    Continue;
                  End;
              While (St[I] In Cifre2) And (I<Length(St)-1) Do
                Begin
                  If I>1 Then If St[I-1]='.' Then Del:=False;
                  If Del And (St[I]='0') And ((St[I+1] In Cifre2)
                    Or ((St[I+1]='.') And Not ZeroBP)) Then
                    Delete(St,I,1) Else Begin Del:=False; I:=I+1; End;
                End;
            End;
        End;
   (* Deletes useless decimal zeros *)
      I:=Pos('.',St); I3:=0;
      While (I>I3) And (I<Length(St)) Do
        Begin
          I2:=EndToken(St,I);
          If I2>1 Then
            Begin
              While St[I2]='0' Do
                Begin
                  Delete(St,I2,1);
                  If I2=1 Then Break;
                  I2:=I2-1;
                End;
              If St[I2]='.' Then Delete(St,I2,1);
            End;
          I3:=I;
          I:=I+Pos('.',Copy(St,I+1,Length(St)-I));
        End;
      Zero_Filter:=St;
    End;

  Function StrUpper(St: String): String;
    Var I: Integer;
    Begin
      For I:=1 To Length(St) Do
        St[I]:=UpCase(St[I]);
      StrUpper:=St;
    End;

  Function NoSpace(St: String; Kind: Byte): String;
    Var P: Integer;
    Begin
      P:=Pos(#32,St);
      If Kind=1 Then
        While P>0 Do
          Begin
            Delete(St,P,1);
            P:=Pos(#32,St);
          End;
      If ((Kind Mod 2)=0) And (St<>'') Then
        While St[1]=#32 Do
          Begin
            Delete(St,1,1);
            If St='' Then Break
          End;
      If ((Kind Mod 3)=0) And (St<>'') Then
        While St[Length(St)]=#32 Do
          Begin
            Delete(St,Length(St),1);
            If St='' Then Break
          End;
      NoSpace:=St;
    End;

  Function ScientToNum(Token: String): Extended;
    Var TmpStr: String;
        I,Err: Integer;
        TmpNum,TmpNum2: Extended;
      Begin
        Val(Token,TmpNum,Err);
        If Err=0 Then
          Begin
            ScientToNum:=TmpNum;
            Exit;
          End;
        If Token[1]<>'[' Then
          Begin
            ScientToNum:=0;
            Exit;
          End;
        Delete(Token,1,2);
        I:=Pos('$',Token);
        TmpStr:=Copy(Token,1,I-1);
        If TmpStr[1]='_' Then TmpStr[1]:='-';
        Delete(Token,1,I);
        If Token[1]='_' Then Token[1]:='-';
        Delete(Token,Length(Token)-1,2);
        Val(TmpStr,TmpNum2,Err);
        Val(Token,TmpNum,Err);
        ScientToNum:=TmpNum2*Exp(TmpNum*Ln(10));
      End;

  Function NumToScient(Num: Extended): String;
    Var TmpStr,TmpStr2: String;
        I: Integer;
      Begin
        Str(Num,TmpStr);
        TmpStr:=NoSpace(TmpStr,1);
        If TmpStr[1]='+' Then Delete(TmpStr,1,1)
                         Else
          If TmpStr[1]='-' Then TmpStr[1]:='_';
        I:=Pos('E',TmpStr);
        TmpStr2:=Copy(TmpStr,I+1,Length(TmpStr)-I)+'$]';
        If TmpStr2[1]='+' Then Delete(TmpStr2,1,1)
                          Else
          If TmpStr2[1]='-' Then TmpStr2[1]:='_';
        NumToScient:=NoSpace('[$'+Copy(TmpStr,1,I-1)+'$'+TmpStr2,1);
      End;

  Function ImpMul_Yes(St: String): String;
    Var I,OldI,BrCount1,BrCount2: Integer;
        VAbs: Array[0..100] Of Boolean;
    Begin
      I:=Pos('*(',St);
      While I>0 Do
        Begin
          Delete(St,I,1);
          I:=Pos('*(',St);
        End;
      I:=0;
      Repeat
        OldI:=I;
        I:=I+Pos(')*',Copy(St,I+1,Length(St)-I));
        If I<>OldI Then
          If Not (St[I+2] In Operators) Then Delete(St,I+1,1);
      Until OldI=I;
      I:=0;
      Repeat
        OldI:=I;
        I:=I+Pos('!*',Copy(St,I+1,Length(St)-I));
        If I<>OldI Then
          If Not (St[I+2] In Operators) Then Delete(St,I+1,1);
      Until OldI=I;
      BrCount1:=0; BrCount2:=0;
      For I:=0 To 100 Do VAbs[I]:=True;
      I:=0;
      While I<Length(St) Do
        Begin
          I:=I+1;
          If (St[I] In ['A'..'Z','a'..'z']) And (I>2) Then
            If St[I-1]='*' Then
              Begin
                Delete(St,I-1,1);
                I:=I-1;
              End;
          If St[I]='(' Then BrCount1:=BrCount1+1;
          If St[I]=')' Then BrCount2:=BrCount2+1;
          If BrCount2>BrCount1 Then Break;
          If St[I]='|' Then
            Begin
              VAbs[BrCount1-BrCount2]:=Not VAbs[BrCount1-BrCount2];
              If Vabs[BrCount1-BrCount2] Then
                Begin
                  If I<Length(St)-1 Then
                    If (St[I+1]='*') And Not (St[I+2] In Operators) Then
                      Delete(St,I+1,1);
                End
                                         Else
                If I>1 Then
                  If (St[I-1]='*') Then
                    Begin
                      Delete(St,I-1,1);
                      I:=I-1;
                    End;
            End;
        End;
      ImpMul_Yes:=St;
    End;

  Function ImpMul_No(St: String): String;
    Var OldI,I,BrCount1,BrCount2: Integer;
        VAbs: Array[0..100] Of Boolean;
    Begin
      BrCount1:=0; BrCount2:=0;
      For I:=0 To 100 Do VAbs[I]:=True;
      I:=0;
      While I<Length(St) Do
        Begin
          I:=I+1;
          If (St[I] In ['A'..'Z','a'..'z']) And (I>1) Then
            If St[I-1] In Cifre+['¯',''''] Then
              Begin
                Insert('*',St,I);
                I:=I+1;
              End;
          If St[I]='(' Then BrCount1:=BrCount1+1;
          If St[I]=')' Then BrCount2:=BrCount2+1;
          If BrCount2>BrCount1 Then Break;
          If St[I]='|' Then
            Begin
              VAbs[BrCount1-BrCount2]:=Not VAbs[BrCount1-BrCount2];
              If Vabs[BrCount1-BrCount2] Then
                Begin
                  If I<Length(St) Then
                    If Not(St[I+1] In (Operators+[')',',']+UOperators)) Then
                      St:=Copy(St,1,I)+'*'+Copy(St,I+1,Length(St)-I);
                End
                                         Else
                If I>1 Then
                  If Not(St[I-1] In (Operators+['(',',','A'..'Z','a'..'z'])) Then
                    Begin
                      St:=Copy(St,1,I-1)+'*'+Copy(St,I,Length(St)-I+1);
                      I:=I+1;
                    End;
            End;
        End;
      I:=0;
      Repeat
        OldI:=I;
        I:=I+Pos(')',Copy(St,I+1,Length(St)-I));
        If (I>0) And (I<Length(St)) Then
          If Not(St[I+1] In (Operators+[')','|',',']+UOperators)) Then
            St:=Copy(St,1,I)+'*'+Copy(St,I+1,Length(St)-I);
      Until OldI=I;
      I:=0;
      Repeat
        OldI:=I;
        I:=I+Pos('(',Copy(St,I+1,Length(St)-I));
        If I>1 Then
          If Not(St[I-1] In (Operators+['(','|',',','A'..'Z','a'..'z'])) Then
            Begin
              St:=Copy(St,1,I-1)+'*'+Copy(St,I,Length(St)-I+1);
              I:=I+1;
            End;
      Until OldI=I;
      I:=0;
      Repeat
        OldI:=I;
        I:=I+Pos('!',Copy(St,I+1,Length(St)-I));
        If (I>0) And (I<Length(St)) Then
          If Not(St[I+1] In (Operators+[')','|']+UOperators)) Then
            St:=Copy(St,1,I)+'*'+Copy(St,I+1,Length(St)-I);
      Until OldI=I;
      I:=0;
      Repeat
        OldI:=I;
        I:=I+Pos('%',Copy(St,I+1,Length(St)-I));
        If (I>0) And (I<Length(St)) Then
          If Not(St[I+1] In (Operators+[')','|','!']+UOperators)) Then
            St:=Copy(St,1,I)+'*'+Copy(St,I+1,Length(St)-I);
      Until OldI=I;
      ImpMul_No:=St;
    End;

  Function ExprOK(Expr: String): Boolean;
    Var I,I2,Pos1,PosOld,BrCount1,BrCount2: Integer;
        AlredyPoint,Res: Boolean;
        VAbs: Array[0..100] Of Boolean;
    Begin
   (* ExprOK:=True; Exit; *)
      ExprOK:=False;
      If Expr='' Then Exit;
      (* Hides text within quotation marks *)
      Repeat
        I:=Pos('"',Expr);
        If I>0 Then
          Begin
            I2:=Pos('"',Copy(Expr,I+1,Length(Expr)));
            If I2=0 Then Exit;
            Expr[I+I2]:='0';
            Delete(Expr,I,I2);
          End;
      Until I=0;

      (* Hides functions *)
      For I:=1 To FunLength Do
        Begin
          I2:=Pos(Functions[I]+'(',StrUpper(Expr));
          While I2>0 Do
            Begin
              Delete(Expr,I2,Length(Functions[I]));
              I2:=Pos(Functions[I]+'(',Expr);
            End;
          I2:=Pos(Functions[I]+'|',StrUpper(Expr));
          While I2>0 Do
            Begin
              Delete(Expr,I2,Length(Functions[I]));
              I2:=Pos(Functions[I]+'|',Expr);
            End;
        End;
      Pos1:=0;

      (* Hides complex degree *)
      Repeat
        PosOld:=Pos1;
        Pos1:=Pos1+Pos('¯',Copy(Expr,Pos1+1,Length(Expr)));
        If (Pos1>0) And (Pos1<Length(Expr)) Then
          Begin
            For I:=Pos1+1 To Length(Expr) Do
              If Not(Expr[I] In Cifre) Then Break;
            If (Expr[I]='''') Then
              Begin
                Expr[Pos1]:='0';
                If I<Length(Expr) Then
                  If Expr[I+1]='''' Then
                    Begin
                      Expr[I]:='0';
                      Expr[I+1]:='%';
                    End
                                    Else
                    Begin
                      Expr[I]:='%';
                      If Expr[I+1] In Cifre Then
                        Begin
                          For I2:=I+1 To Length(Expr) Do
                            If Not(Expr[I2] In Cifre) Then Break;
                          If I2<Length(Expr) Then
                            If (Expr[I2]='''') And (Expr[I2+1]='''') Then
                              Begin
                                Expr[I]:='0';
                                Expr[I2]:='0';
                                Expr[I2+1]:='%';
                              End;
                        End;
                    End;
              End;
          End;
      Until Pos1=PosOld;
      Repeat
        PosOld:=Pos1;
        Pos1:=Pos1+Pos('''',Copy(Expr,Pos1+1,Length(Expr)));
        If (Pos1>0) And (Pos1<Length(Expr)) Then
          Begin
            If Expr[Pos1+1]='''' Then
              Begin
                Expr[Pos1]:='0';
                Expr[Pos1+1]:='%';
              End
                                 Else
              Begin
                For I:=Pos1+1 To Length(Expr) Do
                  If Not(Expr[I] In Cifre) Then Break;
                If I<Length(Expr) Then
                  If (Expr[I]='''') And (Expr[I+1]='''') Then
                    Begin
                      Expr[Pos1]:='0';
                      Expr[I]:='0';
                      Expr[I+1]:='%';
                     End;
              End;
          End;
      Until Pos1=PosOld;
      Pos1:=0;
      Repeat
        PosOld:=Pos1;
        Pos1:=Pos1+Pos('''''',Copy(Expr,Pos1+1,Length(Expr)));
        If Pos1>0 Then Delete(Expr,Pos1,1);
      Until Pos1=PosOld;

      If Expr[1]=',' Then Exit;
      (* Hides commas *)
      Pos1:=0;
      Repeat
        PosOld:=Pos1;
        Pos1:=Pos1+Pos(',',Copy(Expr,Pos1+1,Length(Expr)));
        If Pos1>0 Then Expr[Pos1]:='*';
      Until Pos1=PosOld;

      If (Length(Expr)=1) And (Expr[1] In Operators+UOperators) Then Exit;
      If Expr[1] In (Operators-['+','-']+UOperators) Then Exit;
      If Expr[Length(Expr)] In (Operators+['.']) Then Exit;
      Res:=True; AlredyPoint:=False;
      BrCount1:=0; BrCount2:=0;
      For I:=0 To 100 Do VAbs[I]:=True;
      For I:=1 To Length(Expr) Do
        Begin
          If Expr[I]='|' Then
            Begin
              VAbs[BrCount1-BrCount2]:=Not VAbs[BrCount1-BrCount2];
              If Vabs[BrCount1-BrCount2] Then
                If Not(Expr[I-1] In (Cifre2+[')']+UOperators)) Then
                  Begin
                    Res:=False;
                    Break;
                  End Else
                                         Else
                  If I<Length(Expr) Then
                    If (Expr[I+1] In UOperators+['*','/','^']) Then
                      Begin
                        Res:=False;
                       Break;
                     End;
            End;
          If Not VAbs[BrCount1-BrCount2] And ((Expr[I]=')') Or (I=Length(Expr))) Then
            Begin
              Res:=False;
              Break;
            End;
          If Not(Expr[I] In (Operators+Cifre+Brackets+UOperators)) Then
            Begin
              Res:=False;
              Break;
            End;
          If Not (Expr[I] In Cifre) Then AlredyPoint:=False;
          If (Expr[I]='.') And (I<Length(Expr)) Then
            Begin
              If (Not(Expr[I+1] In Cifre2)) Or AlredyPoint Then
                Begin
                  Res:=False;
                  Break;
                End;
              AlredyPoint:=True;
            End;
          If (Expr[I] In UOperators) And (I>1) Then
            If Not(Expr[I-1] In (Cifre2+[')','|'])) Then
              Begin
                Res:=False;
                Break;
              End;
          If (Expr[I] In UOperators) And (I<Length(Expr)) Then
            If Not(Expr[I+1] In (Operators+[')','|'])) Then
              Begin
                Res:=False;
                Break;
              End;
          If (Expr[I]='(') And (I>1) Then
            If Expr[I-1] In Cifre Then
              Begin
                Res:=False;
                Break;
              End;
          If (Expr[I]='(') And (I<Length(Expr)) Then
            If Expr[I+1] In ['*','/','^'] Then
              Begin
                Res:=False;
                Break;
              End;
          If (Expr[I]=')') And (I<Length(Expr)) Then
            If Expr[I+1] In Cifre Then
              Begin
                Res:=False;
                Break;
              End;
          If Expr[I]='(' Then BrCount1:=BrCount1+1;
          If Expr[I]=')' Then
            Begin
              BrCount2:=BrCount2+1;
              If BrCount1<BrCount2 Then
                Begin
                  Res:=False;
                  Break;
                End;
              If I>1 Then
                If Expr[I-1] In (Operators+['.','(']) Then
                  Begin
                    Res:=False;
                    Break;
                  End;
            End;
        End;
      If (Not Res) Or (BrCount1<>BrCount2) Then Exit;
      For I:=1 To 3 Do
        For I2:=1 To 3 Do
          If Pos(Operators2[I]+Operators2[I2],Expr)>0 Then Res:=False;
      If Not Res Then Exit;
      For I:=4 To 5 Do
        For I2:=1 To 5 Do
          If Pos(Operators2[I]+Operators2[I2],Expr)>0 Then Res:=False;
      ExprOK:=Res;
    End;

  Function Solve_Brackets(Expr: String; Var Err: String): String; Forward;
  Procedure GetParms(Var Expr,Err: String); Forward;
  Procedure SetParms(ParmName,ParmValue: String); Forward;

  Function Funct(St: String; X: Extended; Var Err: String): Extended;
    Var TmpSt: String;
        Result: Extended;
        TmpBool: Boolean;
    Begin
      SetParms('X',NumToScient(X));
      TmpSt:=St; Delete(TmpSt,1,1); Delete(TmpSt,Length(TmpSt),1);
      GetParms(TmpSt,Err);
      If Err='' Then
        If ExprOK(NoScientNot(ImpMul_No(TmpSt))) Then
          Begin
            TmpBool:=NoOutput;
            NoOutput:=True;
            Result:=ScientToNum(Solve_Brackets(ImpMul_Yes(TmpSt),Err));
            NoOutput:=TmpBool;
          End
                                                 Else
          Err:='This is not a valid expression.';
      Funct:=Result;
    End;

  Function ValFunct(Kind,Params: String; Ab: Boolean; Var Err: String): Extended;
    Var Num,Result,TmpNum1,TmpNum2: Extended;
        A,B,Y0,Ym,X,H: Extended;
        N: Longint;
        VParams: Array[1..100] Of Extended;
        I,VLen,VPos,VPosOld: Integer;
        St: String;
    Begin
      VLen:=0; VPosOld:=0;
      Repeat
        VLen:=VLen+1;
        VPos:=VPosOld+Pos(',',Copy(Params,VPosOld+1,Length(Params)));
        If VPos=VPosOld Then VPos:=Length(Params)+1;
        If VLen=1 Then St:=Copy(Params,VPosOld+1,VPos-VPosOld-1);
        VParams[VLen]:=ScientToNum(Copy(Params,VPosOld+1,VPos-VPosOld-1));
        VPosOld:=VPos;
      Until (VPos=Length(Params)+1) Or (VLen=100);
      Num:=VParams[1];
      If Ab Then Num:=Abs(Num);
      Err:=''; Result:=0;
      If Kind='SIN' Then Result:=Sin(Num);
      If Kind='ASIN' Then
        If (Num>=-1) And (Num<=1) Then
          Begin
            If Num=1 Then Result:=Pi/2
                     Else
              If Num=-1 Then Result:=Pi/2
                        Else Result:=ArcTan(Num/Sqrt(1-Sqr(Num)));
            If Num<0 Then Result:=Result+Pi;
          End
                     Else
          Err:='Error: ACOS: Argument must be within [-1,+1].';
      If Kind='COS' Then Result:=Cos(Num);
      If Kind='ACOS' Then
        If (Num>=-1) And (Num<=1) Then
          Begin
            If Num=0 Then Result:=0
                     Else Result:=ArcTan(Sqrt(1-Sqr(Num))/Num);
            If Num<0 Then Result:=Result+Pi;
          End
                     Else
          Err:='Error: ACOS: Argument must be within [-1,+1].';
      If Kind='ATAN' Then
        If (Num>=-1) And (Num<=1) Then
          Result:=ArcTan(Num)
                     Else
          Err:='Error: ATAN: Argument must be within [-1,+1].';
      If Kind='TAN' Then
        If Cos(Num)<>0 Then Result:=Sin(Num)/Cos(Num)
                       Else Err:='Error: Overflow.';
      If Kind='SEC' Then
        If Cos(Num)<>0 Then Result:=1/Cos(Num)
                       Else Err:='Error: Overflow.';
      If Kind='CSC' Then
        If Sin(Num)<>0 Then Result:=1/Sin(Num)
                       Else Err:='Error: Overflow.';
      If Kind='DEG' Then Result:=(Num*180)/Pi;
      If Kind='RAD' Then Result:=(Num*Pi)/180;
      If Kind='RND' Then
        Begin
          Randomize;
          Result:=Random(Trunc(Num));
        End;
      If Kind='LN' Then
        If Num>0 Then Result:=Ln(Num)
                 Else Err:='Error: Cannot calculate natural logarithm.';
      If Kind='LOG' Then
        If Num>=0 Then Result:=Ln(Num)/Ln(10)
                 Else Err:='Error: Cannot calculate decimal logarithm.';
      If Kind='EXP' Then Result:=Exp(Num);
      If Kind='SQRT' Then
        If Num>0 Then Result:=Sqrt(Num)
                 Else Err:='Error: Cannot calculate square root.';
      If Kind='ABS' Then Result:=Abs(Num);
      If Kind='TRUNC' Then Result:=Trunc(Num);
      If Kind='ROUND' Then Result:=Round(Num);
      If Kind='MEAN' Then
        Begin
          Result:=0;
          For I:=1 To VLen Do
            Result:=Result+VParams[I];
          Result:=Result/VLen;
        End;
      If Kind='DISPR' Then
        If (VLen=2) And (VParams[1]=Int(VParams[1]))
          And (VParams[2]=Int(VParams[2])) And (VParams[1]>=0)
          And (VParams[2]>=0) Then
               Result:=Exp(VParams[2]*Ln(VParams[1]))
          Else Err:='Error: Invalid argument for DISPR.';
      If Kind='DISP' Then
        If (VLen=2) And (VParams[1]=Int(VParams[1]))
          And (VParams[2]=Int(VParams[2])) And (VParams[1]>=VParams[2])
          And (VParams[2]>=0) Then
               Result:=Factorial(VParams[1])/Factorial(VParams[1]-VParams[2])
          Else Err:='Error: Invalid argument for DISP.';
      If Kind='COMBR' Then
        If (VLen=2) And (VParams[1]=Int(VParams[1]))
          And (VParams[2]=Int(VParams[2])) And (VParams[1]>=0)
          And (VParams[2]>=0) Then
               Result:=Factorial(VParams[1]+VParams[2]-1)/(Factorial(VParams[1]-1)*Factorial(VParams[2]))
          Else Err:='Error: Invalid argument for COMBR.';
      If Kind='COMB' Then
        If (VLen=2) And (VParams[1]=Int(VParams[1]))
          And (VParams[2]=Int(VParams[2])) And (VParams[1]>=VParams[2])
          And (VParams[2]>=0) Then
               Result:=Factorial(VParams[1])/(Factorial(VParams[1]-VParams[2])*Factorial(VParams[2]))
          Else Err:='Error: Invalid argument for COMB.';
      If Kind='PERM' Then
        Begin
          TmpNum1:=0; TmpNum2:=1;
          For I:=1 To VLen Do
            Begin
              If VParams[I]<>Int(VParams[I]) Then
                Begin Err:='Error: Invalid argument for PERM.'; Break; End;
              TmpNum1:=TmpNum1+VParams[I];
              TmpNum2:=TmpNum2*Factorial(VParams[I]);
            End;
          Result:=Factorial(TmpNum1)/TmpNum2;
        End;
      If Kind='VAL' Then Result:=Funct(St,VParams[2],Err);
      If Kind='INT' Then
        Begin
          A:=VParams[2]; B:=VParams[3];
          If VLen<4 Then N:=5000
                    Else
            If VParams[4]<1 Then N:=50
                            Else N:=Trunc(VParams[4]);
          If A>B Then Begin X:=A; A:=B; B:=X; End;
          H:=(B-A)/N; Result:=0;
          Y0:=Funct(St,A,Err);
          X:=A; I:=0; Ym:=0;
          While I<N-1 Do
            Begin
              I:=I+1;
              X:=X+H;
              Ym:=Ym+Funct(St,X,Err);
            End;
          Result:=H*((Y0+Funct(St,B,Err))/2+Ym);
        End;
      If Kind='DERIV' Then
        Begin
          If VLen<3 Then TmpNum1:=0.00001 Else TmpNum1:=VParams[3];
          Result:=(Funct(St,VParams[2]+TmpNum1,Err)
            -Funct(St,VParams[2]-TmpNum1,Err))/(2*TmpNum1);
        End;
      ValFunct:=Result;
    End;

  Function Solve_Exp(Var Express,Error: String): Boolean;
    Var Expr,ReString,ExprLeft,ExprRight,Token1,Token2,TmpSt,NewExpr,RealExpr,NumSt,DenSt: String;
        I,I2,Err1,Err2,TokSign1,TokSign2,Pos1,Pos1B,Pos2,VPos,VPosOld: Integer;
        Result,Num1,Num2: Extended;
        FNum,FDen: Longint;
        Oper: Char;
        Prec: Byte;
        ExpSign,PSolve_Exp: Boolean;
        Label Solved;
    Begin
      Expr:=Express;

      RealExpr:=Express;
      NewExpr:='';
      VPosOld:=0;
      Repeat
      VPos:=VPosOld+Pos(',',Copy(RealExpr,VPosOld+1,Length(RealExpr)));
      If VPos=VPosOld Then VPos:=Length(RealExpr)+1;
      Expr:=Copy(RealExpr,VPosOld+1,VPos-VPosOld-1);
      VPosOld:=VPos;

      Error:=''; ExpSign:=False;
      ExprLeft:=''; ExprRight:=''; ReString:=''; Token1:='';
      Token2:=''; Oper:=#0; TokSign1:=1; TokSign2:=1;

      If Expr[1]='"' Then
        Begin
          PSolve_Exp:=False;
          Goto Solved;
        End;

      (* --- Factorial --- *)
      Pos1:=Pos('!',Expr);
      If Pos1>0 Then
        Begin
          If Pos1>2 Then
            If (Expr[Pos1-1]=']') And (Expr[Pos1-2]<>'$') Then
              Begin
                For Pos1B:=Pos1-1 DownTo 0 Do
                  If Pos1B>0 Then
                    If Expr[Pos1B]='[' Then Break;
                Pos1B:=Pos1B+1;
                Token1:=Copy(Expr,Pos1B,Pos1-Pos1B-1);
                ExprLeft:=Copy(Expr,1,Pos1B-2);
                ExprRight:=Copy(Expr,Pos1+1,Length(Expr));
              End
                     Else Pos1B:=0;
          If Pos1B=0 Then
            Begin
              For Pos1B:=Pos1-1 DownTo 0 Do
                If Pos1B>0 Then
                  If Expr[Pos1B] In (Operators+Brackets+['!']) Then Break;
              Pos1B:=Pos1B+1;
              Token1:=Copy(Expr,Pos1B,Pos1-Pos1B);
              ExprLeft:=Copy(Expr,1,Pos1B-1);
              ExprRight:=Copy(Expr,Pos1+1,Length(Expr));
            End;
          If Token1[1]='[' Then Num1:=ScientToNum(Token1)
                           Else Val(Token1,Num1,Err1);
          If ((Num1<>Int(Num1)) And (Int(Num1+0.5)<>(Num1+0.5))) Or (Num1<-0.5) Then
            Begin
              Error:='Cannot calculate factorial.';
              PSolve_Exp:=True;
              Goto Solved;
            End;
          If Num1<1755 Then Result:=Factorial(Num1)
                       Else
            Begin
              Result:=0;
              Error:='Overflow';
            End;

          If Abs(Result)<Exp(17*Ln(10)) Then
            Begin
              If Result=Int(Result) Then Prec:=0 Else Prec:=Decimals;
              Str(Result:0:Prec,ReString)
            End
                     Else ReString:=NumToScient(Result);
          If (ExprLeft<>'') And (Result>=0) Then
            If Not (ExprLeft[Length(ExprLeft)] In Operators) Then ExprLeft:=ExprLeft+'+';
          If (ExprRight<>'') And (Result>=0) Then
            If Not (ExprRight[1] In Operators) Then ExprRight:='*'+ExprRight;
          Express:=ExprLeft+ReString+ExprRight;
          PSolve_Exp:=True;
          Goto Solved;
        End;
      (* --- Percent --- *)
      Pos1:=Pos('%',Expr);
      If Pos1>0 Then
        Begin
          For Pos1B:=Pos1-1 DownTo 0 Do
            If Pos1B>0 Then
              If Expr[Pos1B] In (Operators+Brackets+['%']) Then Break;
          Pos1B:=Pos1B+1;
          Token1:=Copy(Expr,Pos1B,Pos1-Pos1B);
          ExprLeft:=Copy(Expr,1,Pos1B-1);
          ExprRight:=Copy(Expr,Pos1+1,Length(Expr));
          If Token1[1]='[' Then Num1:=ScientToNum(Token1)
                           Else Val(Token1,Num1,Err1);
          Result:=Num1/100;

          ReString:=NumToScient(Result);
          If (ExprLeft<>'') And (Result>=0) Then
            If Not (ExprLeft[Length(ExprLeft)] In Operators) Then ExprLeft:=ExprLeft+'+';
          If (ExprRight<>'') And (Result>=0) Then
            If Not (ExprRight[1] In Operators) Then ExprRight:='*'+ExprRight;
          Express:=ExprLeft+ReString+ExprRight;
          PSolve_Exp:=True;
          Goto Solved;
        End;
      (* --- Degree --- *)
      Pos1:=Pos('¯',Expr);
      If Pos1>0 Then
        Begin
          For Pos1B:=Pos1-1 DownTo 0 Do
            If Pos1B>0 Then
              If Expr[Pos1B] In (Operators+Brackets+['¯']) Then Break;
          Pos1B:=Pos1B+1;
          Token1:=Copy(Expr,Pos1B,Pos1-Pos1B);
          Num1:=ScientToNum(Token1);
          Result:=(Num1/180)*Pi;
          I:=Pos1;
          If Pos1<Length(Expr) Then
            If Expr[Pos1+1] In Cifre Then
              Begin
                For I:=Pos1+1 To Length(Expr) Do
                  If Not(Expr[I] In Cifre) Then Break;
                If Expr[I]<>'''' Then
                  I:=Pos1
                                 Else
                  Begin
                    If I<Length(Expr) Then
                      If Expr[I+1]='''' Then
                        Begin
                          Token1:=Copy(Expr,Pos1+1,I-Pos1-1);
                          Num1:=ScientToNum(Token1);
                          Result:=Result+((Num1/3600)/180)*Pi;
                          I:=I+1;
                        End
                                        Else
                        Begin
                          Token1:=Copy(Expr,Pos1+1,I-Pos1-1);
                          Num1:=ScientToNum(Token1);
                          Result:=Result+((Num1/60)/180)*Pi;
                          If I<Length(Expr) Then
                            If Expr[I+1] In Cifre Then
                              Begin
                                For I2:=I+1 To Length(Expr) Do
                                  If Not(Expr[I2] In Cifre) Then Break;
                                If (Expr[I2]='''') And (I2<Length(Expr)) Then
                                  If Expr[I2+1]='''' Then
                                    Begin
                                      Token1:=Copy(Expr,I+1,I2-I-1);
                                      Num1:=ScientToNum(Token1);
                                      Result:=Result+((Num1/3600)/180)*Pi;
                                      I:=I2+1;
                                    End;
                              End;
                        End;
                  End
              End;
          ExprLeft:=Copy(Expr,1,Pos1B-1);
          ExprRight:=Copy(Expr,I+1,Length(Expr));

          ReString:=NumToScient(Result);
          If (ExprLeft<>'') And (Result>=0) Then
            If Not (ExprLeft[Length(ExprLeft)] In Operators) Then ExprLeft:=ExprLeft+'+';
          If (ExprRight<>'') And (Result>=0) Then
            If Not (ExprRight[1] In Operators) Then ExprRight:='*'+ExprRight;
          Express:=ExprLeft+ReString+ExprRight;
          PSolve_Exp:=True;
          Goto Solved;
        End;
      (* --- Primi e secondi --- *)
      Pos1:=Pos('''',Expr);
      If Pos1>0 Then
        Begin
          For Pos1B:=Pos1-1 DownTo 0 Do
            If Pos1B>0 Then
              If Expr[Pos1B] In (Operators+Brackets+['''']) Then Break;
          Pos1B:=Pos1B+1;
          Token1:=Copy(Expr,Pos1B,Pos1-Pos1B);
          Num1:=ScientToNum(Token1);
          Result:=((Num1/60)/180)*Pi;
          I:=Pos1;
          If Pos1<Length(Expr) Then
            If Expr[Pos1+1]='''' Then
              Begin
                Result:=Result/60;
                I:=Pos1+1;
              End
                                 Else
              If Expr[Pos1+1] In Cifre Then
                Begin
                  For I2:=Pos1+1 To Length(Expr) Do
                    If Not(Expr[I2] In Cifre) Then Break;
                  If (Expr[I2]='''') And (I2<Length(Expr)) Then
                    If Expr[I2+1]='''' Then
                      Begin
                        Token1:=Copy(Expr,Pos1+1,I2-Pos1-1);
                        Num1:=ScientToNum(Token1);
                        Result:=Result+((Num1/3600)/180)*Pi;
                        I:=I2+1;
                      End;
                End;
          ExprLeft:=Copy(Expr,1,Pos1B-1);
          ExprRight:=Copy(Expr,I+1,Length(Expr));

          ReString:=NumToScient(Result);
          If (ExprLeft<>'') And (Result>=0) Then
            If Not (ExprLeft[Length(ExprLeft)] In Operators) Then ExprLeft:=ExprLeft+'+';
          If (ExprRight<>'') And (Result>=0) Then
            If Not (ExprRight[1] In Operators) Then ExprRight:='*'+ExprRight;
          Express:=ExprLeft+ReString+ExprRight;
          PSolve_Exp:=True;
          Goto Solved;
        End;
      (* --- Binary Operators --- *)
      For I:=1 To 5 Do
        Begin
          If I>1 Then Pos1:=Pos(Operators2[I],Expr)
                 Else
            For Pos1:=Length(Expr) DownTo 0 Do
              If Pos1>0 Then
                If Expr[Pos1]='^' Then Break;
          If (I=2) Or (I=4) Then
            Begin
              Pos1B:=Pos(Operators2[I+1],Expr);
              If (Pos1B>0) And (Pos1B<Pos1) Then Pos1:=Pos1B;
            End;
          If Pos1>0 Then
            Begin
              If (I=1) And (Expr[Pos1-1]=']') Then
                If Expr[Pos1-2]<>'$' Then
                  Begin
                    For Pos1B:=Pos1-1 DownTo 1 Do
                      If Expr[Pos1B]='[' Then Break;
                    Delete(Expr,Pos1-1,1);
                    Delete(Expr,Pos1B,2);
                    Pos1:=Pos1-3;
                    ExpSign:=True;
                  End;
              Break;
            End;
        End;
      If Pos1=0 Then
        Begin
          PSolve_Exp:=False;
          Goto Solved;
        End;
      If Pos1=1 Then Pos2:=1
                Else
        For I:=Pos1-1 DownTo 1 Do
          Begin
            Pos2:=I+1;
            If Expr[I] In Operators Then Break Else Pos2:=1;
          End;
      If Pos2>1 Then
        If (Expr[Pos2-1]='-') And (Expr[Pos1]<>'^') Then Pos2:=Pos2-1;
      If Pos2>1 Then ExprLeft:=Copy(Expr,1,Pos2-1);
      If Expr[Pos2]='-' Then
        Begin
          Delete(Expr,1,1);
          TokSign1:=-1;
        End;
      If Expr[Pos2]='+' Then
        Begin
          Delete(Expr,1,1);
          TokSign1:=1;
        End;
      (* --- Tokens --- *)
      For I:=Pos2 To Length(Expr) Do
       If Not (Expr[I] In (Operators+Brackets+UOperators)) Then
         Token1:=Token1+Expr[I]
                              Else
         If Expr[I] In Operators Then
           Begin
             Oper:=Expr[I];
             If Expr[I+1]='-' Then
               Begin
                 Delete(Expr,I+1,1);
                 TokSign2:=-1;
               End;
             If Expr[I+1]='+' Then
               Begin
                 Delete(Expr,I+1,1);
                 TokSign2:=1;
               End;
             For I2:=I+1 To Length(Expr) Do
               If Not (Expr[I2] In (Operators+Brackets+UOperators)) Then
                 Token2:=Token2+Expr[I2]
                                       Else
                 If (Expr[I2] In Operators) Or (I2=Length(Expr)) Then
                   Begin
                     ExprRight:=Copy(Expr,I2,Length(Expr));
                     I:=Length(Expr);
                     Break;
                   End;
             Break;
           End;
       (* --- Result Evaluation --- *)
       If Token1[1]<>'[' Then
         Begin
           Val(Token1,Num1,Err1);
           If ExpSign Then TokSign1:=-1;
           Num1:=Num1*TokSign1;
         End
                         Else
         Num1:=ScientToNum(Token1)*TokSign1;
       If Token2[1]<>'[' Then
         Begin
           Val(Token2,Num2,Err2);
           Num2:=Num2*TokSign2;
         End
                         Else
         Num2:=ScientToNum(Token2)*TokSign2;
       Case Oper Of
         #0: Begin
            (* If Num1=Int(Num1) Then Prec:=0 Else Prec:=Decimals;
               Str(Num1:0:Prec,Express); *)
               Expr:=Express;
               PSolve_Exp:=False;
               Goto Solved;
             End;
         '+': Result:=Num1+Num2;
         '-': Result:=Num1-Num2;
         '*': Result:=Num1*Num2;
         '/': If Num2<>0 Then Result:=Num1/Num2
                         Else
                Begin
                  Result:=0;
                  Error:='Division by zero.';
                End;
         '^': If Num1=0 Then
                Begin
                  Result:=0;
                  If Num2<=0 Then Error:='Zero with bad esponent.';
                End
                                       Else
                If Num2=Int(Num2) Then Result:=Esp(Num1,Num2)
                                  Else
                    If Num1>=0 Then Result:=Exp(Num2*Ln(Num1))
                             Else
                    Begin
                      Str(Frac(Num2),TmpSt);
                      NumSt:=Copy(TmpSt,2,Pos('E',TmpSt)-2);
                      DenSt:=Copy(TmpSt,Pos('E',TmpSt)+2,Length(TmpSt)-Pos('E',TmpSt)-1);
                      Delete(NumSt,Pos('.',NumSt),1);
                      While Length(NumSt)>1 Do
                        If NumSt[Length(NumSt)]='0' Then
                          Delete(NumSt,Length(NumSt),1) Else Break;
                      Val(NumSt,FNum,Err1);
                      Val(DenSt,FDen,Err1);
                      FDen:=FDen+Length(NumSt)-1;
                      If (FNum Mod Trunc(Esp(2,FDen)))<>0 Then
                        Begin
                          Result:=0;
                          Error:='Cannot calculate exponential.';
                        End
                                                          Else
                        Result:=-Exp(Num2*Ln(-Num1));
                    End;
       End;
       If (Abs(Result)>=Exp(17*Ln(10)))
          Or ((Result<>Int(Result)) And HighPrecision) Then
         Begin
           If (Result<0) And (ExprLeft<>'') Then
             If Not (ExprLeft[Length(ExprLeft)] In Operators) Then
               Begin
                 ExprLeft:=ExprLeft+'-';
                 Result:=-Result;
               End;
           ReString:=NumToScient(Result)
         End
                                                       Else
         Begin
           If Result=Int(Result) Then Prec:=0 Else Prec:=Decimals;
           Str(Result:0:Prec,ReString);
         End;
       If (ExprLeft<>'') And (Result>=0) Then
         If Not (ExprLeft[Length(ExprLeft)] In Operators) Then ExprLeft:=ExprLeft+'+';
       Express:=ExprLeft+ReString+ExprRight;
       PSolve_Exp:=True;
       Solved:
       If Not PSolve_Exp Then Express:=Expr;
       If NewExpr='' Then NewExpr:=Express
                     Else NewExpr:=NewExpr+','+Express;
       Until (VPos=Length(RealExpr)+1) Or (Error<>'');
       Express:=NewExpr;
       Solve_Exp:=(RealExpr<>NewExpr);
     End;

  Function Solve_Brackets(Expr: String; Var Err: String): String;
    Var SubExpr,ExprLeft,ExprRight,OldExpr,TmpSt1,TmpOut: String;
        I,mPos,Pos1,Pos2,BC1,BC2,TmpInt: Integer;
        Abs,Funct: Boolean;
    Begin
      ExprLeft:=''; ExprRight:=''; Err:=''; Pos1:=0;
      TmpOut:=Zero_Filter(NoScientNot(Expr),True,True);
      If Not ResultOnly Then WritelnExpr(TmpOut,BC1,BC2);
      If FileWrite Then WriteText(TmpOut,True);
      Repeat
        Abs:=False; Funct:=False;
        mPos:=Pos('"',Copy(Expr,Pos1,Length(Expr)));
        If mPos>0 Then mPos:=mPos+Pos('"',Copy(Expr,mPos+1,Length(Expr)));
        Pos1:=mPos+Pos(')',Copy(Expr,mPos+1,Length(Expr)));
        If Pos1=mPos Then
          Begin
            Pos1:=mPos+Pos('|',Copy(Expr,mPos+1,Length(Expr)));
            Pos1:=Pos1+Pos('|',Copy(Expr,Pos1+1,Length(Expr)));
            If Pos1>mPos Then Abs:=True;
          End;
        If Pos1>mPos Then
          Begin
            Pos2:=Pos1;
         (* For Pos2:=Pos1-1 DownTo 1 Do *)
            While Pos2>1 Do
              Begin
                Pos2:=Pos2-1;
                If Expr[Pos2]='"' Then
                  Begin
                    For TmpInt:=Pos2-1 DownTo 1 Do
                      If Expr[TmpInt]='"' Then Break;
                    Pos2:=TmpInt;
                  End;
                If Expr[Pos2] In ['(','|'] Then Break;
              End;
            If (Expr[Pos2]='|') And (Expr[Pos1]<>'|') Then
              Begin
                Pos1:=Pos2;
             (* For Pos2:=Pos1-1 DownTo 1 Do
                  If Expr[Pos2]='|' Then Break; *)
                While Pos2>1 Do
                  Begin
                    Pos2:=Pos2-1;
                    If Expr[Pos2]='"' Then
                      Begin
                        For TmpInt:=Pos2-1 DownTo 1 Do
                          If Expr[TmpInt]='"' Then Break;
                        Pos2:=TmpInt;
                      End;
                    If Expr[Pos2]='|' Then Break;
                  End;
                Abs:=True;
              End;
            SubExpr:=Copy(Expr,Pos2+1,Pos1-Pos2-1);
            OldExpr:='';
            While Solve_Exp(SubExpr,Err) Do
              Begin
                If Err<>'' Then
                  Begin
                    Err:='Error: '+Err;
                    Break;
                  End;
                If OldExpr<>'' Then
                  Begin
                    Delay(DelTime);
                    TmpOut:=Zero_Filter(NoSquare(NoScientNot(OldExpr)),True,True);
                    If Not ResultOnly Then WritelnExpr(TmpOut,BC1,BC2);
                    If FileWrite Then WriteText(TmpOut,False);
                  End;
                OldExpr:=Copy(Expr,1,Pos2)+SubExpr+Copy(Expr,Pos1,Length(Expr));
              End;
            If Err='' Then
              Begin
                ExprLeft:=Copy(Expr,1,Pos2-1);
                ExprRight:=Copy(Expr,Pos1+1,Length(Expr));
                If ExprLeft<>'' Then
                  Begin
                    I:=Length(ExprLeft);
                    If ExprLeft[I] In ['A'..'Z','a'..'z'] Then
                      Begin
                        If OldExpr<>'' Then
                          Begin
                            Delay(DelTime);
                            TmpOut:=Zero_Filter(NoSquare(NoScientNot(Copy(Expr,1,Pos2)
                              +SubExpr+Copy(Expr,Pos1,Length(Expr)))),True,True);
                            If Not ResultOnly Then WritelnExpr(TmpOut,BC1,BC2);
                            If FileWrite Then WriteText(TmpOut,False);
                          End;
                        While I>=1 Do
                          If ExprLeft[I] In ['A'..'Z','a'..'z'] Then I:=I-1
                                                                Else
                          Begin I:=I+1; Break; End;
                        If I=0 Then I:=1;
                        TmpSt1:=StrUpper(Copy(ExprLeft,I,Length(ExprLeft)-I+1));
                     (* TmpNum:=ScientToNum(SubExpr); *)
                     (* If Abs And (TmpNum<0) Then SubExpr:=NumToScient(-ScientToNum(SubExpr)); *)
                        SubExpr:=NumToScient(ValFunct(TmpSt1,SubExpr,Abs,Err));
                        Funct:=(Err='');
                        Delete(ExprLeft,I,Length(ExprLeft));
                      End;
                  End;
                If Pos1<Length(Expr) Then
                  If (Expr[Pos1+1] In ['^','!']) And (SubExpr[1]='-') And Not Abs Then
                    SubExpr:='['+SubExpr+']';
                If ExprLeft<>'' Then
                  If Not (ExprLeft[Length(ExprLeft)] In Operators+Brackets+['¯','''',',']) Then ExprLeft:=ExprLeft+'*';
                If ExprRight<>'' Then
                  If Not (ExprRight[1] In Operators+Brackets+UOperators+[',']) Then ExprRight:='*'+ExprRight;
                If Abs And Not Funct Then
                  If (SubExpr[1]='-') Then Delete(SubExpr,1,1)
                                      Else
                    If Copy(SubExpr,1,3)='[$_' Then
                      Delete(SubExpr,3,1);
                If (ExprLeft<>'') And (SubExpr[1]='-') Then
                  Case ExprLeft[Length(ExprLeft)] Of
                    '+': ExprLeft:=Copy(ExprLeft,1,Length(ExprLeft)-1);
                    '-': Begin
                           ExprLeft:=Copy(ExprLeft,1,Length(ExprLeft)-1);
                           SubExpr[1]:='+';
                         End;
                  End;
                If (ExprLeft<>'') And (Copy(SubExpr,1,3)='[$_')
                  And Not (Expr[Pos1+1] In ['^','!']) Then
                  Case ExprLeft[Length(ExprLeft)] Of
                    '+': Begin
                           Delete(SubExpr,3,1);
                           ExprLeft[Length(ExprLeft)]:='-';
                         End;
                    '-': Begin
                           Delete(SubExpr,3,1);
                           ExprLeft[Length(ExprLeft)]:='+';
                         End;
                  End;
                Expr:=ExprLeft+SubExpr+ExprRight;
                If Abs Or ( (OldExpr<>'') Or ( (Pos(')',Expr)=Pos('|',Expr))
                   And (Pos('[',Expr)=0) ) ) Or Funct Then
                     Begin
                       Delay(DelTime);
                       TmpOut:=Zero_Filter(NoSquare(NoScientNot(Expr)),True,True);
                       If Not ResultOnly Then WritelnExpr(TmpOut,BC1,BC2);
                       If FileWrite Then WriteText(TmpOut,False);
                     End;
              End;
          End;
      Until (Pos1=mPos) Or (Err<>'');
      If Err='' Then
        Begin
          While Solve_Exp(Expr,Err) Do
            Begin
              If Err<>'' Then
                Begin
                  Err:='Error: '+Err;
                  Break;
                End;
              Delay(DelTime);
              TmpOut:=Zero_Filter(NoSquare(NoScientNot(Expr)),True,True);
              If Not ResultOnly Then WritelnExpr(TmpOut,BC1,BC2);
              If FileWrite Then WriteText(TmpOut,False);
            End;
        End;
      If ResultOnly And (Err='') Then
        WritelnExpr(Zero_Filter(NoSquare(NoScientNot(Expr)),True,True),BC1,BC2);
      Solve_Brackets:=Expr;
    End;

  Procedure GetParms(Var Expr,Err: String);
    Var I,J,Pos1,Pos2: Integer;
        SubExpr,TmpSt: String;
        EndExpr,Founded: Boolean;
        CurPt: Punt;
    Begin
      I:=1; Err:='';
      While (I<=Length(Expr)) And (Err='') Do
        Begin
          If Expr[I]='"' Then
            I:=I+1+Pos('"',Copy(Expr,I+1,Length(Expr)));
          If Upcase(Expr[I]) In ['A'..'Z'] Then
            Begin
              Pos1:=I; EndExpr:=True;
              For J:=1 To Length(Expr)-Pos1 Do
                If Not (Upcase(Expr[Pos1+J]) In ['A'..'Z']) Then
                  Begin EndExpr:=False; Break; End;
              If EndExpr Then J:=J+1;
              Pos2:=Pos1+J;
              SubExpr:=StrUpper(Copy(Expr,Pos1,J));
              CurPt:=BegPt;
              Founded:=False;
              While (CurPt<>Nil) And Not(Founded) Do
                With CurPt^ Do
                  If Name=SubExpr Then
                    Begin
                      TmpSt:=NoScientNot(Value);
                      If TmpSt[1]='-' Then TmpSt:='('+Value+')'
                                      Else
                        Begin
                          TmpSt:=Value;
                          If Pos1>1 Then
                            If Expr[Pos1-1] In Cifre Then TmpSt:='*'+TmpSt;
                          If Pos2<=Length(Expr) Then
                            If Expr[Pos2] In Cifre Then TmpSt:=TmpSt+'*';
                        End;
                      Expr:=Copy(Expr,1,Pos1-1)+TmpSt+
                        Copy(Expr,Pos2,Length(Expr)-Pos2+1);
                      CurPt:=Nil;
                      J:=Length(TmpSt);
                      Founded:=True;
                    End
                                  Else CurPt:=ForPt;
              If Not Founded Then
                Begin
                  Err:='Error: Variable "'+SubExpr+'" undefined.';
                  For I:=1 To FunLength Do
                    If SubExpr=Functions[I] Then
                      Begin
                        Err:='';
                        Break;
                      End;
                End;
              I:=Pos1+J;
            End;
          I:=I+1;
        End;
    End;

  Procedure SetParms(ParmName,ParmValue: String);
    Var ParmExist: Boolean;
        LastPt,CurPt: Punt;
    Begin
      ParmExist:=False;
      ParmName:=StrUpper(ParmName);
      CurPt:=BegPt;
      While CurPt<>Nil Do
        With CurPt^ Do
          If Name=ParmName Then
            Begin
              Value:=ParmValue;
              ParmExist:=True;
              CurPt:=Nil;
            End
                           Else
          Begin
            LastPt:=CurPt;
            CurPt:=ForPt;
          End;
      IF Not ParmExist Then
        Begin
          New(CurPt);
          With CurPt^ Do
            Begin
              Name:=ParmName;
              Value:=ParmValue;
              ForPt:=Nil;
            End;
          If BegPt=Nil Then BegPt:=CurPt
                       Else LastPt^.ForPt:=CurPt;
        End;
    End;

  Procedure DelParms(ParmName: String);
    Var CurPt,OldPt: Punt;
    Begin
      ParmName:=StrUpper(ParmName);
      CurPt:=BegPt;
      While CurPt<>Nil Do
        Begin
          If CurPt^.Name=ParmName Then
            Begin
              If CurPt=BegPt Then BegPt:=CurPt^.ForPt
                             Else OldPt^.ForPt:=CurPt^.ForPt;
              Dispose(CurPt);
              Exit;
            End;
          OldPt:=CurPt;
          CurPt:=CurPt^.ForPt;
        End;
    End;

  Function ExCommand(St: String): Byte;
    Var A,B,I,TmpInt,ConvErr: Integer;
        Result,OutputColor: Byte;
        TmpSt1,TmpSt2,TmpSt3,Error,OutputSt: String;
        TmpNum1,TmpNum2: Extended;
        TmpBool,TmpBool2,TmpBool3: Boolean;
        TmpChar: Char;
        CurPt: Punt;
    Begin
      Result:=0; OutputSt:=''; OutputColor:=Colors[5];
      St:=NoSpace(StrUpper(St),6);
      If (St='QUIT') Or (St='EXIT') Then Result:=2;
      If St='DEC' Then
        Begin
          OutputSt:='Current decimals to show: '+IntToStr(Decimals)+'.';
          Result:=1;
        End;
      If Copy(St,1,4)='DEC ' Then
        Begin
          TmpSt1:=NoSpace(Copy(St,5,Length(St)-4),4);
          Val(TmpSt1,TmpInt,ConvErr);
          If (ConvErr<>0) Or (TmpInt<0) Then
            Begin
              OutputColor:=Colors[4];
              OutputSt:='Error: Invalid argument for DEC.';
              Result:=1;
            End
                  Else
            Begin
              Decimals:=TmpInt;
              OutputSt:='Current decimals to show are now '+IntToStr(Decimals)+'.';
              Result:=1;
            End
        End;
      If St='COLOR' Then
        Begin
          If ExprColors Then OutputSt:='Expression colors are ON.'
                        Else OutputSt:='Expression colors are OFF.';
          Result:=1;
        End;
      If Copy(St,1,6)='COLOR ' Then
        Begin
          If NoSpace(Copy(St,7,Length(St)-6),6)='OFF' Then
            Begin
              ExprColors:=False;
              OutputSt:='Expression colors are OFF.';
              Result:=1;
            End;
          If NoSpace(Copy(St,7,Length(St)-6),6)='ON' Then
            Begin
              ExprColors:=True;
              OutputSt:='Expression colors are ON.';
              Result:=1;
            End;
          If Result=0 Then
            Begin
              OutputColor:=Colors[4];
              OutputSt:='Error: Invalid argument for COLOR.';
              Result:=1;
            End;
        End;
      If St='DELAY' Then
        Begin
          If DelTime=0 Then OutputSt:='Delay is OFF ('+IntToStr(DelTime)+' ms).'
                       Else OutputSt:='Delay is ON ('+IntToStr(DelTime)+' ms).';
          Result:=1;
        End;
      If Copy(St,1,6)='DELAY ' Then
        Begin
          If NoSpace(Copy(St,7,Length(St)-6),6)='OFF' Then
            Begin
              DelTime:=0;
              OutputSt:='Delay is OFF ('+IntToStr(DelTime)+' ms).';
              Result:=1;
            End;
          If NoSpace(Copy(St,7,Length(St)-6),6)='ON' Then
            Begin
              DelTime:=700;
              OutputSt:='Delay is ON ('+IntToStr(DelTime)+' ms).';
              Result:=1;
            End;
          If Result=0 Then
            Begin
              Val(Copy(St,7,Length(St)-6),TmpInt,ConvErr);
              If TmpInt<0 Then ConvErr:=1;
              If ConVerr<>0 Then
                Begin
                  OutputColor:=Colors[4];
                  OutputSt:='Error: Invalid argument for DELAY.';
                End
                            Else
                Begin
                  DelTime:=TmpInt;
                  If DelTime=0 Then OutputSt:='Delay is OFF ('+IntToStr(DelTime)+' ms).'
                               Else OutputSt:='Delay is ON ('+IntToStr(DelTime)+' ms).';
                End;
              Result:=1;
            End;
        End;
      If St='EXT' Then
        Begin
          If ExtSintax Then OutputSt:='Extended Sintax is ON.'
                       Else OutputSt:='Extended Sintax is OFF.';
          Result:=1;
        End;
      If Copy(St,1,4)='EXT ' Then
        Begin
          If NoSpace(Copy(St,5,Length(St)-4),4)='OFF' Then
            Begin
              ExtSintax:=False;
              OutputSt:='Extended sintax is OFF.';
              Result:=1;
            End;
          If NoSpace(Copy(St,5,Length(St)-4),4)='ON' Then
            Begin
              ExtSintax:=True;
              OutputSt:='Extended sintax is ON.';
              Result:=1;
            End;
          If Result=0 Then
            Begin
              OutputColor:=Colors[4];
              OutputSt:='Error: Invalid argument for EXT.';
              Result:=1;
            End;
        End;
      If St='SET' Then
        Begin
          CurPt:=BegPt;
          While CurPt<>Nil Do
            With CurPt^ Do
              Begin
                TextColor(Colors[3]); Write(Name);
                TextColor(Colors[5]); Write(' = ');
                TextColor(Colors[3]); WritelnExpr(Zero_Filter(NoScientNot(Value),True,False),A,B);
                CurPt:=ForPt;
              End;
          Writeln;
          Result:=1;
        End;
      If Copy(St,1,4)='SET ' Then
        Begin
          TmpSt1:=NoSpace(Copy(St,5,Length(St)-4),4);
          Error:=''; TmpChar:=#0; TmpBool:=False;
          TmpInt:=Pos('=',TmpSt1);
          If TmpInt>1 Then
            If TmpSt1[TmpInt-1] In Operators Then
              Begin
                TmpChar:=TmpSt1[TmpInt-1];
                Delete(TmpSt1,TmpInt-1,1);
                TmpInt:=TmpInt-1;
              End;
          If TmpInt=0 Then
            Begin
              Error:='Error: Variable "'+TmpSt1+'" undefined.';
              CurPt:=BegPt;
              While CurPt<>Nil Do
                With CurPt^ Do
                  If Name=TmpSt1 Then
                    Begin
                      Error:='';
                      TmpSt2:=Value;
                      CurPt:=Nil;
                    End
                                  Else CurPt:=ForPt;
              If Error='' Then
                If Not NoOutput Then
                  Begin
                    TextColor(Colors[3]); Write(TmpSt1);
                    TextColor(Colors[5]); Write(' = ');
                    TextColor(Colors[3]); WritelnExpr(Zero_Filter(NoScientNot(TmpSt2),True,False),A,B);
                    Writeln;
                  End
                          Else
                Begin
                  OutputColor:=Colors[4];
                  OutputSt:=Error;
                End;
            End
                      Else
            Begin
              If TmpInt<=1 Then Error:='Error: Variable name required.'
                           Else
                Begin
                  TmpSt2:=NoSpace(Copy(TmpSt1,1,TmpInt-1),1);
                  If TmpSt2<>'ALL' Then
                    Begin
                      For I:=1 To Length(TmpSt2) Do
                        If Not(TmpSt2[I] In ['A'..'Z']) Then
                          Begin Error:='Error: Invalid variable name.'; Break; End;
                      If (Error='') Then
                        For I:=1 To CommLength Do
                          If TmpSt2=Commands[I] Then
                            Begin
                              Error:='Error: '+TmpSt2+' is a reserved word.';
                              Break;
                            End;
                      If (Error='') Then
                        For I:=1 To FunLength Do
                          If TmpSt2=Functions[I] Then
                            Begin
                              Error:='Error: '+TmpSt2+' is a reserved word.';
                              Break;
                            End;
                    End;
                  TmpSt3:=NoSpace(Copy(TmpSt1,TmpInt+1,Length(TmpSt1)),1);
                  If TmpChar<>#0 Then
                    If ((TmpChar='+') And (TmpSt3[1]='-')) Or
                       ((TmpChar='-') And (TmpSt3[1]='+')) Then
                     TmpSt3:=TmpSt2+TmpSt3
                                                    Else
                     TmpSt3:=TmpSt2+TmpChar+TmpSt3;
                End;
              If TmpSt2='ALL' Then
                Begin
                  CurPt:=BegPt;
                  If CurPt=Nil Then Error:='Error: No variables defined.';
                End
                              Else CurPt:=Nil;
              TmpBool2:=NoOutput; TmpBool3:=True;
              Repeat
              If CurPt<>Nil Then
                Begin
                  NoOutput:=True; TmpBool3:=False;
                  If CurPt<>BegPt Then TmpSt3:=TmpSt1;
                  TmpSt2:=CurPt^.Name;
                  CurPt:=CurPt^.ForPt;
                  TmpSt1:=TmpSt3;
                  I:=Pos('ALL',TmpSt3);
                  While I>0 Do
                    Begin
                      Delete(TmpSt3,I,3);
                      Insert(TmpSt2,TmpSt3,I);
                      I:=Pos('ALL',TmpSt3);
                    End;
                End;
              If Error='' Then
                Begin
                  TmpSt3:=NoSpace(TmpSt3,1);
                  GetParms(TmpSt3,Err);
                  If Err<>'' Then
                    Error:=Err+#13#10+'Error: Cannot set variable.'
                              Else
                    Begin
                      If ExtSintax Then TmpSt3:=ExtExpr(TmpSt3);
                      If ExprOK(NoScientNot(ImpMul_No(TmpSt3))) Then
                        Begin
                          TmpSt3:=Solve_Brackets(Zero_Filter(ImpMul_Yes(TmpSt3),True,True),Err);
                          If Err<>'' Then
                              Error:=Err+#13#10+'Error: Cannot set variable.';
                        End
                                                                Else
                        If TmpSt3<>'' Then
                          Error:='This is not a valid expression.'
                                 +#13#10+'Error: Cannot set variable.'
                                      Else TmpBool:=True;
                    End;
                End;
              If Error='' Then
                If TmpBool Then
                  Begin
                    DelParms(TmpSt2);
                    TextColor(Colors[5]);
                    If TmpBool3 Then OutputSt:='Variable '+TmpSt2+' removed.'
                                Else OutputSt:='All variables removed.';
                  End
                           Else
                  Begin
                    SetParms(TmpSt2,TmpSt3);
                    TextColor(Colors[5]);
                    If TmpBool3 Then OutputSt:='Variable '+TmpSt2+' setted.'
                                Else OutputSt:='All variables setted.';
                  End
                    Else
                Begin
                  OutputColor:=Colors[4];
                  OutputSt:=Error;
                End;
              Until CurPt=Nil;
              NoOutput:=TmpBool2;
            End;
          Result:=1;
        End;
      If St='REWRITE' Then
        Begin
          ReWrite(OutFile);
          TextColor(Colors[5]);
          Writeln('Output file rewritten (',FileName,').');
          Writeln;
          Result:=1;
        End;
      If St='FILE' Then
        Begin
          TextColor(Colors[5]);
          Write('Current output file is ',FileName,' ');
          If XML Then Writeln('(XML/MathML).') Else Writeln('(Text plain).');
          Writeln;
          Result:=1;
        End;
      If Copy(St,1,5)='FILE ' Then
        Begin
          TmpSt1:=NoSpace(Copy(St,6,Length(St)-5),6);
          If Copy(TmpSt1,1,4)='XML ' Then
            Begin
              Delete(TmpSt1,1,4);
              TmpSt1:=NoSpace(TmpSt1,6);
              XML:=True;
            End
                                     Else
            XML:=False;
          FileName:=TmpSt1;
          Assign(OutFile,FileName);
          TextColor(Colors[5]);
          Write('Output file is assumed as ',FileName,' ');
          If XML Then Writeln('(XML/MathML).') Else Writeln('(Text plain).');
          Writeln;
          Result:=1;
        End;
      If St='WRITE' Then
        Begin
          TextColor(Colors[5]);
          If FileWrite Then Writeln('Output to file is ON (',FileName,').')
                       Else Writeln('Output to file is OFF (',FileName,').');
          Writeln;
          Result:=1;
        End;
      If Copy(St,1,6)='WRITE ' Then
        Begin
          If NoSpace(Copy(St,7,Length(St)-6),6)='OFF' Then
            Begin
              FileWrite:=False;
              TextColor(Colors[5]);
              Writeln('Output to file is OFF (',FileName,').');
              Writeln;
              Result:=1;
            End;
          If NoSpace(Copy(St,7,Length(St)-6),6)='ON' Then
            Begin
              FileWrite:=True;
              TextColor(Colors[5]);
              Writeln('Output to file is ON (',FileName,').');
              Writeln;
              Result:=1;
            End;
          If Result=0 Then
            Begin
              FileWrite:=True;
              TmpSt1:=NoSpace(Copy(St,7,Length(St)-6),1);
              GetParms(TmpSt1,Error);
              If Error<>'' Then
                Begin
                  TextColor(Colors[4]);
                  Writeln(Error);
                End
                            Else
                Begin
                  If ExtSintax Then TmpSt1:=ExtExpr(TmpSt1);
                  If ExprOK(NoScientNot(ImpMul_No(TmpSt1))) Then
                    Begin
                      TmpSt1:=Solve_Brackets(Zero_Filter(ImpMul_Yes(TmpSt1),True,False),Error);
                      If Error='' Then
                        SetParms('ANS',TmpSt1)
                                  Else
                        Begin
                          TextColor(Colors[4]);
                          Writeln(Error);
                          If FileWrite Then WriteText(Error,False);
                        End;
                    End
                                                          Else
             (* If TmpSt1<>'' Then *)
                    Begin
                      TextColor(Colors[4]);
                      Writeln('This is not a valid expression.');
                    End;
                End;
              FileWrite:=False;
              Writeln;
              Result:=1;
            End;
        End;
      If St='CLS' Then
        Begin
          Clrscr;
          Result:=1;
        End;
      If St='RESULTONLY' Then
        Begin
          OutputColor:=Colors[4];
          If ResultOnly Then OutputSt:='Result only mode is ON.'
                        Else OutputSt:='Result only mode is OFF.';
          Result:=1;
        End;
      If Copy(St,1,11)='RESULTONLY ' Then
        Begin
          If NoSpace(Copy(St,12,Length(St)-11),6)='OFF' Then
            Begin
              ResultOnly:=False;
              OutputSt:='Result only mode is OFF.';
              Result:=1;
            End;
          If NoSpace(Copy(St,12,Length(St)-11),6)='ON' Then
            Begin
              ResultOnly:=True;
              OutputSt:='Result only mode is ON.';
              Result:=1;
            End;
          If Result=0 Then
            Begin
              OutputColor:=Colors[4];
              OutputSt:='Error: Invalid argument for RESULTONLY.';
              Result:=1;
            End;
        End;
      If Copy(St,1,5)='EXEC ' Then
        Begin
          TmpSt1:=NoSpace(Copy(St,6,Length(St)-5),6);
          Assign(PMScript,TmpSt1);
          Reset(PMScript);
          NoOutput:=True;
          While Not Eof(PMScript) Do
            Begin
              Readln(PMScript,TmpSt3);
              TmpSt3:=NoSpace(TmpSt3,6);
              If TmpSt3[1] In ['''',':'] Then Continue;
              TmpInt:=Pos('INPUT$',StrUpper(TmpSt3));
              While TmpInt>0 Do
                Begin
                  Textcolor(Colors[3]); Readln(TmpSt1);
                  Delete(TmpSt3,TmpInt,6);
                  Insert(TmpSt1,TmpSt3,TmpInt);
                  TmpInt:=Pos('INPUT$',StrUpper(TmpSt3));
                End;
              TmpInt:=Pos('KEY$',StrUpper(TmpSt3));
              While TmpInt>0 Do
                Begin
                  Textcolor(Colors[3]); TmpSt1:=Readkey;
                  Delete(TmpSt3,TmpInt,4);
                  Insert(TmpSt1,TmpSt3,TmpInt);
                  TmpInt:=Pos('KEY$',StrUpper(TmpSt3));
                End;
              TmpBool:=(StrUpper(Copy(TmpSt3,1,6))='PRINT ');
              If (StrUpper(Copy(TmpSt3,1,5))='ECHO ') Or TmpBool Then
                Begin
                  If TmpBool Then TmpSt1:=Copy(TmpSt3,7,Length(TmpSt3))
                             Else TmpSt1:=Copy(TmpSt3,6,Length(TmpSt3));
                  If TmpSt1[1]='"' Then
                    Begin
                      TmpSt1:=NoSpace(TmpSt1,6);
                      TextColor(Colors[3]);
                      Write(Copy(TmpSt1,2,Length(TmpSt1)-2));
                    End
                                   Else
                    Begin
                      GetParms(TmpSt1,TmpSt2);
                      NoOutput:=False;
                      WriteExpr(TmpSt1,A,B);
                      NoOutput:=True;
                    End;
                  If Not TmpBool Then Writeln;
                  Continue;
                End;
              TmpSt3:=StrUpper(TmpSt3);
              If TmpSt3='END' Then Break;
              If Copy(TmpSt3,1,3)='IF ' Then
                Begin
                  TmpInt:=Pos('=',TmpSt3);
                  If TmpInt=0 Then TmpInt:=Pos('>',TmpSt3);
                  If TmpInt=0 Then TmpInt:=Pos('<',TmpSt3);
                  TmpSt1:=NoSpace(Copy(TmpSt3,3,TmpInt-3),1);
                  GetParms(TmpSt1,TmpSt2);
                  If ExtSintax Then TmpSt3:=ExtExpr(TmpSt1);
                  TmpSt1:=Solve_Brackets(Zero_Filter(ImpMul_Yes(TmpSt1),True,False),TmpSt2);
                  TmpNum1:=ScientToNum(TmpSt1);

                  I:=Pos('GOTO',TmpSt3);
                  TmpSt1:=NoSpace(Copy(TmpSt3,TmpInt+1,I-TmpInt-1),1);
                  GetParms(TmpSt1,TmpSt2);
                  If ExtSintax Then TmpSt3:=ExtExpr(TmpSt1);
                  TmpSt1:=Solve_Brackets(Zero_Filter(ImpMul_Yes(TmpSt1),True,False),TmpSt2);
                  TmpNum2:=ScientToNum(TmpSt1);
                  If TmpSt3[TmpInt]='=' Then TmpBool:=(TmpNum1=TmpNum2);
                  If TmpSt3[TmpInt]='>' Then TmpBool:=(TmpNum1>TmpNum2);
                  If TmpSt3[TmpInt]='<' Then TmpBool:=(TmpNum1<TmpNum2);
                  If TmpBool Then
                    Begin
                      TmpSt1:=NoSpace(Copy(TmpSt3,I+4,Length(TmpSt3)),1);
                      Reset(PMScript);
                      Readln(PMScript,TmpSt3);
                      While (NoSpace(StrUpper(TmpSt3),1)<>':'+TmpSt1)
                            And Not Eof(PMScript) Do
                        Readln(PMScript,TmpSt3);
                    End;
                  Continue;
                End;
              If Copy(TmpSt3,1,5)='GOTO ' Then
                Begin
                  TmpSt1:=NoSpace(Copy(TmpSt3,6,Length(TmpSt3)),1);
                  Reset(PMScript);
                  Readln(PMScript,TmpSt3);
                  While (NoSpace(StrUpper(TmpSt3),1)<>':'+TmpSt1)
                        And Not Eof(PMScript) Do
                    Readln(PMScript,TmpSt3);
                  Continue;
                End;
              Case ExCommand(TmpSt3) Of
                1: Continue;
                2: Exit;
              End;
              TmpSt3:=NoSpace(TmpSt3,1);
              GetParms(TmpSt3,TmpSt2);
              If ExtSintax Then TmpSt3:=ExtExpr(TmpSt3);
              TmpSt1:=Solve_Brackets(Zero_Filter(ImpMul_Yes(TmpSt3),True,False),TmpSt2);
              If TmpSt2='' Then
                SetParms('ANS',TmpSt1)
                           Else
                Begin
                  TextColor(Colors[4]);
                  Writeln(TmpSt2);
                  If FileWrite Then WriteText(TmpSt2,False);
                End;
            End;
          NoOutput:=False;
          Close(PMScript);
          Writeln;
          Result:=1;
        End;
      If Copy(St,1,4)='HELP' Then
        Begin
          If NoSpace(Copy(St,5,Length(St)-4),4)<>'FUNCTIONS' Then
            Begin
              TextColor(Colors[5]);
              Writeln('List of the commands: ');
              TextColor(Colors[3]);
              Writeln('CLS                           - Clear the screen.');
              Writeln('COLOR [ON | OFF]              - Enable / Disable expression colors.');
              Writeln('DEC [Number]                  - Set decimals to show.');
              Writeln('DELAY [ON | OFF | Number]     - Enable / Disable / Set delay.');
              Writeln('EXEC Filename                 - Execute a PAS MAth Script.');
              Writeln('EXIT                          - Exit the program.');
              Writeln('EXT [ON | OFF]                - Enable / Disable extended sintax.');
              Writeln('FILE [[XML] Filename]         - View / Change current output file name.');
              Writeln('HELP [FUNCTIONS]              - Show this screen / all the supported functions.');
              Writeln('QUIT                          - Exit the program.');
              Writeln('REWRITE                       - Rewrite current output file.');
              Writeln('RESULTONLY [ON | OFF]         - Enable / Disable result only mode.');
              Writeln('SET [Variable[=Expression]]   - Set / Show variables.');
              Writeln('WRITE [ON | OFF]              - Enable / Disable output to file.');
              Writeln('WRITE Expression              - Calculate expression and append output to file.');
              Writeln;
            End
          Else
            Begin
              TextColor(Colors[5]);
              Writeln('List of all the supported functions: ');
              TextColor(Colors[3]);
              Writeln('ABS(x)                    - Returns the absolute value of the argument.');
              Writeln('ACOS(x)                   - Returns the arc-cosine of the argument.');
              Writeln('ACOT(x)                   - Returns the arc-cotangent of the argument.');
              Writeln('ACSC(x)                   - Returns the arc-cosecant of the argument.');
              Writeln('ASEC(x)                   - Returns the arc-secant of the argument.');
              Writeln('ASIN(x)                   - Returns the arc-sine of the argument.');
              Writeln('ATAN(x)                   - Returns the arc-tangent of the argument.');
              Writeln('COMBR(n,k)                - Calculates combinations with ripetition.');
              Writeln('COMB(n,k)                 - Calculates simple combinations.');
              Writeln('COS(x)                    - Returns the cosine of the argument.');
              Writeln('COT(x)                    - Returns the cotangent of the argument.');
              Writeln('CSC(x)                    - Returns the cosecant of the argument.');
              Writeln('DEG(x)                    - Converts radians to degrees.');
              Writeln('EXP(x)                    - Returns the exponential of the argument.');
              Writeln('DERIV("function",x[,n])   - Calculates the derivate of a function in x.');
              Writeln('DISPR(n,k)                - Calculates dispositions with ripetition.');
              Writeln('DISP(n,k)                 - Calculates simple dispositions.');
              Writeln('INT("function",xi,xs[,n]) - Calculates the definite integral of a function.');
              TextColor(Colors[5]); TmpInt:=WhereY;
              Write('- Press a key to continue -');
              TmpChar:=ReadKey; If TmpChar=#0 Then ReadKey;
              DelLine; Gotoxy(1,TmpInt);
              TextColor(Colors[3]);
              Writeln('LN(x)                     - Returns the natural logarithm of the argument.');
              Writeln('LOG(x)                    - Returns the natural decimal of the argument.');
              Writeln('MEAN(x1,x2, ... xn)       - Returns the arithmetic mean of the arguments.');
              Writeln('PERM(j1,j2, ... jn)       - Calculates permutations.');
              Writeln('RAD(x)                    - Converts degrees to radians.');
              Writeln('RND(x)                    - Returns a random integer within the range [ 0, X [.');
              Writeln('ROUND(x)                  - Rounds the argument to an integer value.');
              Writeln('SEC(x)                    - Returns the secant of the argument.');
              Writeln('SIN(x)                    - Returns the sine of the argument.');
              Writeln('SQRT(x)                   - Returns the square root of the argument.');
              Writeln('TAN(x)                    - Returns the tangent of the argument.');
              Writeln('TRUNC(x)                  - Returns the integer part of the argument.');
              Writeln('VAL("function",x)         - Calculates the value of a function in x.');
              Writeln;
            End;
          Result:=1;
        End;
      If (OutputSt<>'') And Not NoOutput Then
        Begin
          TextColor(OutputColor);
          Writeln(OutputSt);
          Writeln;
        End;
      ExCommand:=Result;
    End;

  BEGIN
    Clrscr;
    TextColor(Colors[1]);
    Writeln('PAS Math, version ',Version);
    Writeln('Copyright (C) 2001-2002 Carmelo Spiccia, Michele Povigna');
    Writeln('This is free software with ABSOLUTELY NO WARRANTY.');
    Writeln('Write QUIT to exit, HELP for more options.');
    Window(1,6,80,25);
    BegPt:=Nil;
    Assign(OutFile,FileName);
    SetParms('ANS','0');
    SetParms('PI',NumToScient(Pi));
    If ParamCount>0 Then
      Begin
        I:=ExCommand('EXEC '+ParamStr(1));
        Repeat Until KeyPressed;
      End
                    Else
      Begin
        VLength:=1;
        For I:=1 To VMax Do VExpr[I]:='';
        Repeat
          TextColor(Colors[2]);
          Write('PAS> ');
          Expr:='';
          WX:=WhereX; WY:=WhereY;
          PC:=0; VPos:=VLength;
          Repeat
            InpCar:=Input(Expr,PC,WX,WY,234,#32,ipEverything Xor ipCaseUp Xor ipAcc Xor ipAll Xor ipTab);
            If InpCar=#27 Then Expr:='';
            If InpCar='Up' Then
              Begin
                If VPos=VLength Then VExpr[VPos]:=Expr;
                If VPos>1 Then VPos:=VPos-1;
                Expr:=VExpr[VPos]; PC:=0;
              End;
            If (InpCar='Down') And (VPos<VLength) Then
              Begin
                VPos:=VPos+1;
                Expr:=VExpr[VPos]; PC:=0;
              End;
          Until (InpCar=#13) And (NoSpace(Expr,1)<>'');
          VExpr[VLength]:=Expr;
          If VLength<VMax Then VLength:=VLength+1
                          Else
            Begin
              For IPos:=1 To 9 Do
                VExpr[IPos]:=VExpr[IPos+1];
              VExpr[VLength]:='';
            End;
          Writeln;

          Case ExCommand(Expr) Of
            1: Continue;
            2: Exit;
          End;
          Expr:=NoSpace(Expr,1);
          GetParms(Expr,Err);
          If Err<>'' Then
            Begin
              TextColor(Colors[4]);
              Writeln(Err);
            End
                     Else
            Begin
              If ExtSintax Then Expr:=ExtExpr(Expr);
              If ExprOK(NoScientNot(ImpMul_No(Expr))) Then
                Begin
                  Expr:=Solve_Brackets(Zero_Filter(ImpMul_Yes(Expr),True,False),Err);
                  If Err='' Then
                    SetParms('ANS',Expr)
                            Else
                    Begin
                      TextColor(Colors[4]);
                      Writeln(Err);
                      If FileWrite Then WriteText(Err,False);
                    End;
                End
                                                      Else
         (* If Expr<>'' Then *)
                Begin
                  TextColor(Colors[4]);
                  Writeln('This is not a valid expression.');
                End;
            End;
          Writeln;
        Until False;
        Close(OutFile);
      End;
    Window(1,1,80,25);
    NormVideo;
    Clrscr;
  END.
