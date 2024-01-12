{This program is to be distributed under the terms of the GPL -
Gnu Public License.
Copyright (C) 2001 Michele Povigna, Carmelo Spiccia.
This program came with ABSOLUTELY NO WARRANTY. }
{$N+,E+}
Program PASmath;
Uses Crt;
Const Cifre=['0'..'9','.'];
Cifre2=['0'..'9'];
Operators=['^','*','/','+','-'];
Operators2: Array[1..5] Of Char = ('^','*','/','+','-');
Colors: Array[1..5] Of Byte = (2,9,7,7,5);
Var Expr: String;

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
Var I,I2: Integer;
Res: Boolean;
Begin
ExprOK:=False;
If Expr='' Then Exit;
If (Length(Expr)=1) And (Expr[1] In Operators) Then Exit;
If Expr[1] In (Operators-['+','-']) Then Exit;
If Expr[Length(Expr)]='.' Then Exit;
Res:=True;
For I:=1 To Length(Expr) Do
Begin
If Not (Expr[I] In (Operators+Cifre)) Then
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
End;
If Not Res Then Exit;
For I:=1 To 3 Do
For I2:=1 To 3 Do
If Pos(Operators2[I]+Operators2[I2],Expr)<>0 Then Res:=False;
If Not Res Then Exit;
For I:=4 To 5 Do
For I2:=1 To 5 Do
If Pos(Operators2[I]+Operators2[I2],Expr)<>0 Then Res:=False;
ExprOK:=Res;
End;

Function Solve_exp(Var Expr: String): Boolean;
Var ReString,ExprLeft,ExprRight,Token1,Token2: String;
I,I2,Err1,Err2,TokSign1,TokSign2,Pos1,Pos2: Integer;
Result,Num1,Num2: Extended;
Operator: Char;
Prec: Byte;
Begin
ExprLeft:=''; ExprRight:=''; ReString:=''; Token1:='';
Token2:=''; Operator:=#0; TokSign1:=1; TokSign2:=1;
For I:=1 To 5 Do
Begin
Pos1:=Pos(Operators2[I],Expr);
If Pos1<>0 Then Break;
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
'/': If Num2<>0 Then Result:=Num1/Num2 Else Result:=0;
'^': If Num2=Int(Num2) Then Result:=Esp(Num1,Num2)
Else Result:=Exp(Num2*Ln(Num1));
End;
If Result=Int(Result) Then Prec:=0 Else Prec:=2;
Str(Result:0:Prec,ReString);
If (ExprLeft<>'') And (Result>=0) Then
If Not (ExprLeft[Length(ExprLeft)] In Operators) Then
ExprLeft:=ExprLeft+'+';
Expr:=ExprLeft+ReString+ExprRight;
Solve_Exp:=True;
End;

BEGIN
Clrscr;
TextColor(Colors[1]);
Writeln('PAS Math, version 0.22');
Writeln('Copyright (C) 2001 Michele Povigna, Carmelo Spiccia');
Writeln('This is free software with ABSOLUTELY NO WARRANTY.');
Writeln('Brackets () unsupported. Write QUIT to exit.');
Window(1,6,80,25);
Repeat
TextColor(Colors[2]);
Write('PAS> ');
TextColor(Colors[3]);
Readln(Expr);
If StrUpper(Expr)='QUIT' Then Break;
DelSpace(Expr);
If ExprOK(Expr) Then
Begin
TextColor(Colors[4]);
Writeln(Expr);
While Solve_exp(Expr) Do Writeln(Expr);
End
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
