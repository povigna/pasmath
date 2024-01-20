{ This source is to be distributed under the terms
of the GPL - Gnu Public License.
Copyright (C) 2001 Michele Povigna, Carmelo Spiccia.

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

{$H+}
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
Const HighPrecision=True;
Cifre=['0'..'9','.'];
Cifre2=['0'..'9'];
Operators=['^','*','/','+','-'];
Brackets=['(',')','|'];
Operators2: Array[1..5] Of Char = ('^','*','/','+','-');
Colors: Array[1..5] Of Byte = (2,9,7,5,6);
DelTime: Integer = 0;
ExprColors: Boolean = True;
VMax=100;
ipCaseUp = 1; ipNum =2; ipAlf = 4; ipSpc = 8;
ipVir = $10; ipPto = $20; ipFct = $40; ipOpe = $80;
ipBrk = $100; ipAcc = $200; ipAll = $400; ipTab = $800;
ipAltri = $1000; ipEverything = $FFFFFFFF;
Decimals: Integer = 4;
Var InpCar,Expr,Err: String;
I,WX,WY,VLength,VPos,IPos: Byte;
VExpr: Array[1..VMax] Of String;
PC: Integer;
BegPt,OldPt: Punt;

Procedure WriteExpr(St: String; Var BrCount1,BrCount2: Integer);
Var I: Integer;
Begin
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
If Not ExprColors Then Write(St) Else WriteExpr(St,BrCount1,BrCount2);
Writeln;
End;

Function Input(Var Stringa: String; Var PCur: Integer; X,Y,Max: Integer;
Sfondo: Char; Attrib: Longint): String;
Var Car: Char;
Ris: String;
K,BrCount1,BrCount2,TmpNum: Integer;
InsCar: Boolean;
Begin
BrCount1:=0; BrCount2:=0;
If X<1 Then X:=1;
If Y<1 Then Y:=1;
If PCur>0 Then PCur:=0;
If Length(Stringa)+PCur<0 Then PCur:=-Length(Stringa);
If Max>(80-X) Then Max:=80-X;
Gotoxy(X,Y);
WriteExpr(Stringa,BrCount1,BrCount2);
For K:=1 To Max-Length(Stringa) Do Write(Sfondo);
Gotoxy(X+Length(Stringa),Y);
Repeat
Gotoxy(X+Length(Stringa)+PCur,Y);
Textcolor(7);
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
'!': If (Length(Stringa)<Max) And ((Attrib And ipFct)>0) Then InsCar:=True;
'^','*','/','+','-','=':
If (Length(Stringa)<Max) And ((Attrib And ipOpe)>0) Then InsCar:=True;
'(',')','|':
If (Length(Stringa)<Max) And ((Attrib And ipBrk)>0) Then InsCar:=True;
'Š','‚','•','…','—',' ':
If (Length(Stringa)<Max) And ((Attrib And ipAcc)>0) Then InsCar:=True;
'<','>',';',':','_','\','"','œ','$','%','&',
'?','õ','ø','‡','#','@','[',']','''':
If (Length(Stringa)<Max) And ((Attrib And ipAll)>0) Then InsCar:=True;
#9: If ((Attrib And ipTab)>0) Then Begin Ris:=Car; Break; End;
#13,#27: Begin Ris:=Car; Break; End;
#8: If Length(Stringa)>0 Then
Begin
Delete(Stringa,Length(Stringa)+PCur,1);
Gotoxy(X+Length(Stringa),Y);
Gotoxy(X,Y);
WriteExpr(Stringa,BrCount1,BrCount2);
Write(Sfondo);
End;
#0: Begin
Car:=Readkey;
If ((Attrib And ipAltri)>0) Then
Case Upcase(Car) Of
'M': If PCur<0 Then PCur:=PCur+1;
'K': If Length(Stringa)+PCur>0 Then PCur:=PCur-1;
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
'O': PCur:=0;
'R': Begin Ris:='Ins'; Break; End;
'S': If PCur<0 Then
Begin
Delete(Stringa,Length(Stringa)+PCur+1,1);
Gotoxy(X+Length(Stringa),Y);
Gotoxy(X,Y);
WriteExpr(Stringa,BrCount1,BrCount2);
Write(Sfondo);
PCur:=PCur+1;
End;
'G': PCur:=-Length(Stringa);
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
End;
Until False;
Input:=Ris;
End;

Function Factorial(X: Extended): Extended;
Var Result: Extended;
I: Longint;
Begin
If X<=1 Then Result:=1
Else
Begin
Result:=X;
For I:=1 To Round(X-1) Do
Result:=Result*I;
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

Function EndToken(St: String; I: Integer): Integer;
Begin
If I<1 Then I:=1;
If I<Length(St) Then I:=I+1 Else I:=Length(St);
While I<=Length(St) Do
Begin
If St[I] In (Operators+Brackets+['!']) Then
Begin
I:=I-1;
Break;
End;
If I=Length(St) Then Break;
I:=I+1;
End;
EndToken:=I;
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
If (Esp>=-2) And (Esp<=16) Then
Begin
Num:=Num*Exp(Esp*Ln(10));
Esp:=0;
End;
If Num=Int(Num) Then Prec:=0;
Str(Num:0:Prec,TmpSt);
Str(Esp:0:0,SubSt);
If Esp=0 Then SubSt:=TmpSt
Else SubSt:='('+TmpSt+'*10^'+SubSt+')';
St:=Copy(St,1,P1-1)+SubSt+Copy(St,P2+2,Length(St)-P2-1);
P1:=Pos('[$',St);
P2:=Pos('$]',St);
End;
NoScientNot:=St;
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
If St[I]='(' Then BrCount1:=BrCount1+1;
If St[I]=')' Then BrCount2:=BrCount2+1;
If BrCount2>BrCount1 Then Break;
If St[I]='|' Then
Begin
VAbs[BrCount1-BrCount2]:=Not VAbs[BrCount1-BrCount2];
If Vabs[BrCount1-BrCount2] Then
Begin
If I<Length(St) Then
If Not(St[I+1] In (Operators+[')','!'])) Then
St:=Copy(St,1,I)+'*'+Copy(St,I+1,Length(St)-I);
End
Else
If I>1 Then
If Not(St[I-1] In (Operators+['('])) Then
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
If Not(St[I+1] In (Operators+[')','|','!'])) Then
St:=Copy(St,1,I)+'*'+Copy(St,I+1,Length(St)-I);
Until OldI=I;
I:=0;
Repeat
OldI:=I;
I:=I+Pos('(',Copy(St,I+1,Length(St)-I));
If I>1 Then
If Not(St[I-1] In (Operators+['(','|'])) Then
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
If Not(St[I+1] In (Operators+[')','|'])) Then
St:=Copy(St,1,I)+'*'+Copy(St,I+1,Length(St)-I);
Until OldI=I;
ImpMul_No:=St;
End;

Function ExprOK(Expr: String): Boolean;
Var I,I2,BrCount1,BrCount2: Integer;
AlredyPoint,Res: Boolean;
VAbs: Array[0..100] Of Boolean;
Begin
ExprOK:=False;
If Expr='' Then Exit;
If (Length(Expr)=1) And (Expr[1] In Operators+['!']) Then Exit;
If Expr[1] In (Operators-['+','-']+['!']) Then Exit;
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
If Not(Expr[I-1] In (Cifre2+['!',')'])) Then
Begin
Res:=False;
Break;
End Else
Else
If I<Length(Expr) Then
If (Expr[I+1]='!') Then
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
If Not(Expr[I] In (Operators+Cifre+Brackets+['!'])) Then
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
If (Expr[I]='!') And (I>1) Then
If Not(Expr[I-1] In (Cifre2+[')','|'])) Then
Begin
Res:=False;
Break;
End;
If (Expr[I]='!') And (I<Length(Expr)) Then
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

Function Solve_Exp(Var Express,Error: String): Boolean;
Var Expr,ReString,ExprLeft,ExprRight,Token1,Token2,TmpSt: String;
I,I2,Err1,Err2,TokSign1,TokSign2,Pos1,Pos1B,Pos2: Integer;
Result,Num1,Num2: Extended;
Oper: Char;
Prec: Byte;
ExpSign: Boolean;
Begin
Expr:=Express;
Error:=''; ExpSign:=False;
ExprLeft:=''; ExprRight:=''; ReString:=''; Token1:='';
Token2:=''; Oper:=#0; TokSign1:=1; TokSign2:=1;
(* --- Factorial --- *)
Pos1:=Pos('!',Expr);
If Pos1>0 Then
Begin
If Pos1>2 Then
If (Expr[Pos1-1]=']') And (Expr[Pos1-2]<>'$') Then
Begin
Error:='Cannot calculate factorial.';
Solve_Exp:=True;
Exit;
End;
For Pos1B:=Pos1-1 DownTo 0 Do
If Pos1B>0 Then
If Expr[Pos1B] In (Operators+Brackets+['!']) Then Break;
Pos1B:=Pos1B+1;
Token1:=Copy(Expr,Pos1B,Pos1-Pos1B);
ExprLeft:=Copy(Expr,1,Pos1B-1);
ExprRight:=Copy(Expr,Pos1+1,Length(Expr));
If Token1[1]='[' Then Num1:=ScientToNum(Token1)
Else Val(Token1,Num1,Err1);
If Num1<>Int(Num1) Then
Begin
Error:='Cannot calculate factorial.';
Solve_Exp:=True;
Exit;
End;
If Num1<1755 Then Result:=Factorial(Int(Num1))
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
Solve_Exp:=True;
Exit;
End;
(* --- Other Operators --- *)
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
Solve_Exp:=False;
Exit;
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
If Not (Expr[I] In (Operators+Brackets+['!'])) Then
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
If Not (Expr[I2] In (Operators+Brackets+['!'])) Then
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
Num1:=ScientToNum(Token1);
If Token2[1]<>'[' Then
Begin
Val(Token2,Num2,Err2);
Num2:=Num2*TokSign2;
End
Else
Num2:=ScientToNum(Token2);
Case Oper Of
#0: Begin
If Num1=Int(Num1) Then Prec:=0 Else Prec:=Decimals;
Str(Num1:0:Prec,Express);
Solve_Exp:=False;
Exit;
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
'^': If (Num1=0) And (Num2<=0) Then
Begin
Result:=0;
Error:='Zero with bad esponent.';
End
Else
If Num2=Int(Num2) Then Result:=Esp(Num1,Num2)
Else
If Num1>=0 Then Result:=Exp(Num2*Ln(Num1))
Else
Begin
Str(1/(Frac(Num2)),TmpSt);
TmpSt:=Copy(TmpSt,1,Pos('E',TmpSt)-1);
While Length(TmpSt)>1 Do
If TmpSt[Length(TmpSt)]='0' Then
Delete(TmpSt,Length(TmpSt),1) Else Break;
If TmpSt[Length(TmpSt)]='.' Then
Delete(TmpSt,Length(TmpSt),1);
(* If (Round(1/(Frac(Num2)) Mod 2)=0 Then *)
(* If (Token2[Length(Token2)]='5') Or
(Token2[Length(Token2)] In ['2','4','6','8']) Or
(Copy(Token2,Length(Token2)-1,2)='50') Then *)
If TmpSt[Length(TmpSt)] In ['0','2','4','6','8'] Then
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
Solve_Exp:=True;
End;

Procedure SetParms(ParmName,ParmValue: String); Forward;

Function Solve_Brackets(Expr: String; Var Err: String): String;
Var SubExpr,ExprLeft,ExprRight,OldExpr: String;
Pos1,Pos2,BC1,BC2: Integer;
Abs: Boolean;
Begin
ExprLeft:=''; ExprRight:=''; Err:='';
WritelnExpr(Zero_Filter(NoScientNot(Expr),True,True),BC1,BC2);
Repeat
Abs:=False;
Pos1:=Pos(')',Expr);
If Pos1=0 Then
Begin
Pos1:=Pos('|',Expr);
Pos1:=Pos1+Pos('|',Copy(Expr,Pos1+1,Length(Expr)-Pos1));
If Pos1>0 Then Abs:=True;
End;
If Pos1>0 Then
Begin
For Pos2:=Pos1-1 DownTo 1 Do
If Expr[Pos2] In ['(','|'] Then Break;
If (Expr[Pos2]='|') And (Expr[Pos1]<>'|') Then
Begin
Pos1:=Pos2;
For Pos2:=Pos1-1 DownTo 1 Do
If Expr[Pos2]='|' Then Break;
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
WritelnExpr(Zero_Filter(NoSquare(NoScientNot(OldExpr)),True,True),BC1,BC2);
End;
OldExpr:=Copy(Expr,1,Pos2)+SubExpr+Copy(Expr,Pos1,Length(Expr));
End;
If Err='' Then
Begin
ExprLeft:=Copy(Expr,1,Pos2-1);
ExprRight:=Copy(Expr,Pos1+1,Length(Expr));
If Pos1<Length(Expr) Then
If (Expr[Pos1+1] In ['^','!']) And (SubExpr[1]='-') And Not Abs Then
SubExpr:='['+SubExpr+']';
If ExprLeft<>'' Then
If Not (ExprLeft[Length(ExprLeft)] In Operators+Brackets) Then ExprLeft:=ExprLeft+'*';
If ExprRight<>'' Then
If Not (ExprRight[1] In Operators+Brackets+['!']) Then ExprRight:='*'+ExprRight;
If Abs Then
If (SubExpr[1]='-') Then Delete(SubExpr,1,1)
Else
If Copy(SubExpr,1,3)='[$_' Then Delete(SubExpr,3,1);
If (ExprLeft<>'') And (SubExpr[1]='-') Then
Case ExprLeft[Length(ExprLeft)] Of
'+': ExprLeft:=Copy(ExprLeft,1,Length(ExprLeft)-1);
'-': Begin
ExprLeft:=Copy(ExprLeft,1,Length(ExprLeft)-1);
SubExpr[1]:='+';
End;
End;
If (ExprLeft<>'') And (Copy(SubExpr,1,3)='[$_') Then
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
And (Pos('[',Expr)=0) ) ) Then
Begin
Delay(DelTime);
WritelnExpr(Zero_Filter(NoSquare(NoScientNot(Expr)),True,True),BC1,BC2);
End;
End;
End;
Until (Pos1=0) Or (Err<>'');
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
WritelnExpr(Zero_Filter(NoSquare(NoScientNot(Expr)),True,True),BC1,BC2);
End;
End;
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
If Not Founded Then Err:='Error: Variable "'+SubExpr+'" undefinded.';
I:=Pos1+J;
End;
I:=I+1;
End;
End;

Procedure SetParms(ParmName,ParmValue: String);
Var ParmExist: Boolean;
CurPt: Punt;
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
Else CurPt:=ForPt;
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
Else OldPt^.ForPt:=CurPt;
OldPt:=CurPt;
End;
End;

Function ExCommand(St: String): Byte;
Var A,B,I,TmpInt,ConvErr: Integer;
Result: Byte;
TmpSt1,TmpSt2,TmpSt3,Error: String;
CurPt: Punt;
Begin
Result:=0;
St:=NoSpace(StrUpper(Expr),6);
If (St='QUIT') Or (St='EXIT') Then Result:=2;
If St='DEC' Then
Begin
TextColor(Colors[5]);
Writeln('Current decimals to show: ',Decimals,'.');
Writeln;
Result:=1;
End;
If Copy(St,1,4)='DEC ' Then
Begin
TmpSt1:=NoSpace(Copy(St,5,Length(St)-4),4);
Val(TmpSt1,TmpInt,ConvErr);
If (ConvErr<>0) Or (TmpInt<0) Then
Begin
TextColor(Colors[4]);
Writeln('Error: Invalid argument for DEC.');
Writeln;
Result:=1;
End
Else
Begin
Decimals:=TmpInt;
TextColor(Colors[5]);
Writeln('Current decimals to show are now ',Decimals,'.');
Writeln;
Result:=1;
End
End;
If St='COLOR' Then
Begin
TextColor(Colors[5]);
If ExprColors Then Writeln('Expression colors are ON.')
Else Writeln('Expression colors are OFF.');
Writeln;
Result:=1;
End;
If Copy(St,1,6)='COLOR ' Then
Begin
If NoSpace(Copy(St,7,Length(St)-6),6)='OFF' Then
Begin
ExprColors:=False;
TextColor(Colors[5]);
Writeln('Expression colors are OFF.');
Writeln;
Result:=1;
End;
If NoSpace(Copy(St,7,Length(St)-6),6)='ON' Then
Begin
ExprColors:=True;
TextColor(Colors[5]);
Writeln('Expression colors are ON.');
Writeln;
Result:=1;
End;
If Result=0 Then
Begin
TextColor(Colors[4]);
Writeln('Error: Invalid argument for COLOR.');
Writeln;
Result:=1;
End;
End;
If St='DELAY' Then
Begin
TextColor(Colors[5]);
If DelTime=0 Then Writeln('Delay is OFF (',DelTime,' ms).')
Else Writeln('Delay is ON (',DelTime,' ms).');
Writeln;
Result:=1;
End;
If Copy(St,1,6)='DELAY ' Then
Begin
If NoSpace(Copy(St,7,Length(St)-6),6)='OFF' Then
Begin
DelTime:=0;
TextColor(Colors[5]);
Writeln('Delay is OFF (',DelTime,' ms).');
Writeln;
Result:=1;
End;
If NoSpace(Copy(St,7,Length(St)-6),6)='ON' Then
Begin
DelTime:=700;
TextColor(Colors[5]);
Writeln('Delay is ON (',DelTime,' ms).');
Writeln;
Result:=1;
End;
If Result=0 Then
Begin
Val(Copy(St,7,Length(St)-6),TmpInt,ConvErr);
If TmpInt<0 Then ConvErr:=1;
If ConVerr<>0 Then
Begin
TextColor(Colors[4]);
Writeln('Error: Invalid argument for DELAY.');
End
Else
Begin
TextColor(Colors[5]);
DelTime:=TmpInt;
If DelTime=0 Then Writeln('Delay is OFF (',DelTime,' ms).')
Else Writeln('Delay is ON (',DelTime,' ms).');
End;
Writeln;
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
TextColor(Colors[3]); WritelnExpr(NoScientNot(Value),A,B);
CurPt:=ForPt;
End;
Writeln;
Result:=1;
End;
If Copy(St,1,4)='SET ' Then
Begin
TmpSt1:=NoSpace(Copy(St,5,Length(St)-4),4);
Error:='';
TmpInt:=Pos('=',TmpSt1);
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
Begin
TextColor(Colors[3]); Write(TmpSt1);
TextColor(Colors[5]); Write(' = ');
TextColor(Colors[3]); WritelnExpr(NoScientNot(TmpSt2),A,B);
End
Else
Begin
TextColor(Colors[4]);
Writeln(Error);
End;
End
Else
Begin
If TmpInt<=1 Then Error:='Error: Variable name required.'
Else
Begin
TmpSt2:=NoSpace(Copy(TmpSt1,1,TmpInt-1),1);
For I:=1 To Length(TmpSt2) Do
If Not(TmpSt2[I] In ['A'..'Z']) Then
Begin Error:='Error: Invalid variable name.'; Break; End;
TmpSt3:=NoSpace(Copy(TmpSt1,TmpInt+1,Length(TmpSt1)),1);
End;
If Error='' Then
Begin
TmpSt3:=NoSpace(TmpSt3,1);
GetParms(TmpSt3,Err);
If Err<>'' Then
Error:=Err+#13#10+'Error: Cannot set variable.'
Else
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
Else
Error:='Error: Expression required';
End;
If Error='' Then
Begin
SetParms(TmpSt2,TmpSt3);
TextColor(Colors[5]);
Writeln('Variable ',TmpSt2,' setted.');
End
Else
Begin
TextColor(Colors[4]);
Writeln(Error);
End;
End;
Writeln;
Result:=1;
End;
If St='CLS' Then
Begin
Clrscr;
Result:=1;
End;
If St='HELP' Then
Begin
TextColor(Colors[5]);
Writeln('List of the commands: ');
TextColor(Colors[3]);
Writeln('CLS - Clear the screen.');
Writeln('COLOR [ON | OFF] - View / Change expression colors state.');
Writeln('DEC [Number] - View / Change decimals to show.');
Writeln('DELAY [ON | OFF | Number] - View / Change the delay state.');
Writeln('EXIT - Exit the program.');
Writeln('HELP - Show this screen.');
Writeln('QUIT - Exit the program.');
Writeln('SET [Variable[=Expression]] - Set / Show variables.');
Writeln;
Result:=1;
End;
ExCommand:=Result;
End;

BEGIN
Clrscr;
TextColor(Colors[1]);
Writeln('PAS Math, version 0.291 alpha');
Writeln('Copyright (C) 2001 Michele Povigna, Carmelo Spiccia');
Writeln('This is free software with ABSOLUTELY NO WARRANTY.');
Writeln('Write QUIT to exit, HELP for more options.');
Window(1,6,80,25);
BegPt:=Nil;
SetParms('ANS','0');
VLength:=1;
For I:=1 To VMax Do VExpr[I]:='';
Repeat
TextColor(Colors[2]);
Write('PAS> ');
Expr:='';
WX:=WhereX; WY:=WhereY;
PC:=0; VPos:=VLength;
Repeat
InpCar:=Input(Expr,PC,WX,WY,255,#32,ipEverything Xor ipCaseUp Xor ipAcc Xor ipAll Xor ipTab);
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
If ExprOK(NoScientNot(ImpMul_No(Expr))) Then
Begin
Expr:=Solve_Brackets(Zero_Filter(ImpMul_Yes(Expr),True,False),Err);
If Err='' Then
SetParms('ANS',Expr)
Else
Begin
TextColor(Colors[4]);
Writeln(Err);
End;
End
Else
(* If Expr<>'' Then *)
Begin
TextColor(Colors[4]);
Writeln('This is not a valid expression.');
End;
Writeln;
Until False;
Window(1,1,80,25);
NormVideo;
Clrscr;
END.
