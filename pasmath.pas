{ This source is to be distributed under the terms of the GPL -
Gnu Public License.
Copyright (C) 2001 Michele Povigna, Carmelo Spiccia.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You can find a copy of this license at
http://www.gnu.org/licenses/gpl.txt }

{$N+,E+}
Program PASmath;
Uses Crt;
Const Cifre=['0'..'9','.'];
Cifre2=['0'..'9'];
Operators=['^','*','/','+','-'];
Brackets=['(',')'];
Operators2: Array[1..5] Of Char = ('^','*','/','+','-');
Colors: Array[1..5] Of Byte = (2,9,7,7,5);
Var Expr,OldExpr,Err: String;

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

Function StrUpper(Str: String): String;
Var I: Integer;
Begin
For I:=1 To Length(Str) Do
Str[I]:=UpCase(Str[I]);
StrUpper:=Str;
End;

Procedure DelSpace(Var Str: String);
Var P: Integer;
Begin
P:=Pos(#32,Str);
While P<>0 Do
Begin
Delete(Str,P,1);
P:=Pos(#32,Str);
End;
End;

Function ExprOK(Expr: String): Boolean;
Var I,I2,BrCount1,BrCount2: Integer;
Res: Boolean;
Begin
ExprOK:=False;
If Expr='' Then Exit;
If (Length(Expr)=1) And (Expr[1] In Operators) Then Exit;
If Expr[1] In (Operators-['+','-']) Then Exit;
If Expr[Length(Expr)]='.' Then Exit;
Res:=True;
BrCount1:=0; BrCount2:=0;
For I:=1 To Length(Expr) Do
Begin
If Not (Expr[I] In (Operators+Cifre+Brackets)) Then
Begin
Res:=False;
Break;
End;
If (I<>Length(Expr)) And (Expr[I]='.') Then
If Not (Expr[I+1] In Cifre2) Then
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
If Pos(Operators2[I]+Operators2[I2],Expr)<>0 Then Res:=False;
If Not Res Then Exit;
For I:=4 To 5 Do
For I2:=1 To 5 Do
If Pos(Operators2[I]+Operators2[I2],Expr)<>0 Then Res:=False;
ExprOK:=Res;
End;

Function Solve_Exp(Var Express,Error: String): Boolean;
Var Expr,ReString,ExprLeft,ExprRight,Token1,Token2: String;
I,I2,Err1,Err2,TokSign1,TokSign2,Pos1,Pos1B,Pos2: Integer;
Result,Num1,Num2: Extended;
Operator: Char;
Prec: Byte;
ExpSign: Boolean;
Begin
Expr:=Express;
Error:=''; ExpSign:=False;
ExprLeft:=''; ExprRight:=''; ReString:=''; Token1:='';
Token2:=''; Operator:=#0; TokSign1:=1; TokSign2:=1;
For I:=1 To 5 Do
Begin
Pos1:=Pos(Operators2[I],Expr);
If I=2 Then
Begin
Pos1B:=Pos(Operators2[3],Expr);
If (Pos1B>0) And (Pos1B<Pos1) Then Pos1:=Pos1B;
End;
If Pos1<>0 Then
Begin
If (I=1) And (Expr[Pos1-1]=']') Then
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
For I:=Pos2 To Length(Expr) Do
If Expr[I] In Cifre Then Token1:=Token1+Expr[I]
Else
If Expr[I] In Operators Then
Begin
Operator:=Expr[I];
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
If Expr[I2] In Cifre Then Token2:=Token2+Expr[I2]
Else
If (Expr[I2] In Operators) Or (I2=Length(Expr)) Then
Begin
ExprRight:=Copy(Expr,I2,Length(Expr));
I:=Length(Expr);
Break;
End;
Break;
End;
Val(Token1,Num1,Err1);
Val(Token2,Num2,Err2);
If ExpSign Then TokSign1:=-1;
Num1:=Num1*TokSign1;
Num2:=Num2*TokSign2;
Case Operator Of
#0: Begin
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
'^': If (Num1=0) And (Num2=0) Then
Begin
Result:=0;
Error:='Founded 0^0.';
End
Else
If Num2=Int(Num2) Then Result:=Esp(Num1,Num2)
Else Result:=Exp(Num2*Ln(Num1));
End;
If Result=Int(Result) Then Prec:=0 Else Prec:=2;
Str(Result:0:Prec,ReString);
If (ExprLeft<>'') And (Result>=0) Then
If Not (ExprLeft[Length(ExprLeft)] In Operators) Then
ExprLeft:=ExprLeft+'+';
Express:=ExprLeft+ReString+ExprRight;
Solve_Exp:=True;
End;

Procedure Solve_Brackets(Expr: String);
Var ReString,SubExpr,ExprLeft,ExprRight: String;
I,I2,Err1,Err2,TokSign1,TokSign2,Pos1,Pos2: Integer;
Result,Num1,Num2: Extended;
Operator: Char;
Prec: Byte;
Begin
ExprLeft:=''; ExprRight:=''; ReString:='';
Operator:=#0; TokSign1:=1; TokSign2:=1;
Writeln(Expr);
Repeat
Pos1:=Pos(')',Expr);
If Pos1<>0 Then
Begin
For Pos2:=Pos1-1 DownTo 1 Do
If Expr[Pos2]='(' Then Break;
SubExpr:=Copy(Expr,Pos2+1,Pos1-Pos2-1);
TextColor(Colors[4]);
While Solve_Exp(SubExpr,Err) Do
Begin
If Err<>'' Then
Begin
TextColor(Colors[5]);
Writeln('Error: ',Err);
Break;
End;

Writeln(Copy(Expr,1,Pos2),SubExpr,Copy(Expr,Pos1,Length(Expr)));
End;
If Pos1+1<=Length(Expr) Then
If (Expr[Pos1+1]='^') And (SubExpr[1]='-') Then

Expr:=Copy(Expr,1,Pos2-1)+'['+SubExpr+']'+Copy(Expr,Pos1+1,Length(Expr))
Else

Expr:=Copy(Expr,1,Pos2-1)+SubExpr+Copy(Expr,Pos1+1,Length(Expr))
Else

Expr:=Copy(Expr,1,Pos2-1)+SubExpr+Copy(Expr,Pos1+1,Length(Expr));
End;
Until Pos1=0;
TextColor(Colors[4]);
While Solve_Exp(Expr,Err) Do
Begin
If Err<>'' Then
Begin
TextColor(Colors[5]);
Writeln('Error: ',Err);
Break;
End;
Writeln(Expr);
End;
End;

BEGIN
Clrscr;
TextColor(Colors[1]);
Writeln('PAS Math, version 0.25 beta');
Writeln('Copyright (C) 2001 Michele Povigna, Carmelo Spiccia');
Writeln('This is free software with ABSOLUTELY NO WARRANTY.');
Writeln('Brackets () supported. Write QUIT to exit.');
Window(1,6,80,25);
Repeat
TextColor(Colors[2]);
Write('PAS> ');
TextColor(Colors[3]);
Readln(Expr);
If StrUpper(Expr)='QUIT' Then Break;
DelSpace(Expr);
If ExprOK(Expr) Then Solve_Brackets(Expr)
Else
If Expr<>'' Then
Begin
TextColor(Colors[5]);
Writeln('This is not a valid expression.');
End;
Writeln;
Until False;
Window(1,1,80,25);
END.
