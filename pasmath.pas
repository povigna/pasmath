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

{$N+}
{$E+}
Program PASmath;
Uses Crt;
Const Cifre=['0'..'9','.'];
Cifre2=['0'..'9'];
Operators=['^','*','/','+','-'];
Brackets=['(',')','|','>'];
Operators2: Array[1..5] Of Char = ('^','*','/','+','-');
Colors: Array[1..5] Of Byte = (2,9,7,7,5);
Var Expr,Err: String;

Function Factorial(X: Extended): Extended; Forward;

Function Factorial(X: Extended): Extended;
Begin
If X<=0 Then Factorial:=1 Else Factorial:=X*Factorial(X-1);
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

Function NoSquare(Str: String): String;
Var I: Integer;
Begin
Repeat
I:=Pos('[',Str);
If I>0 Then Str[I]:='(';
Until I=0;
Repeat
I:=Pos(']',Str);
If I>0 Then Str[I]:=')';
Until I=0;
NoSquare:=Str;
End;

Function StrUpper(Str: String): String;
Var I: Integer;
Begin
For I:=1 To Length(Str) Do
Str[I]:=UpCase(Str[I]);
StrUpper:=Str;
End;

Function NoSpace(Str: String): String;
Var P: Integer;
Begin
P:=Pos(#32,Str);
While P>0 Do
Begin
Delete(Str,P,1);
P:=Pos(#32,Str);
End;
NoSpace:=Str;
End;

Function ExprOK(Expr: String): Boolean;
Var I,I2,BrCount1,BrCount2: Integer;
Res: Boolean;
VAbs: Array[0..100] Of Boolean;
Begin
(* ExprOK:=True;
Exit; *)
ExprOK:=False;
If Expr='' Then Exit;
If (Length(Expr)=1) And (Expr[1] In Operators+['!']) Then Exit;
If Expr[1] In (Operators-['+','-']+['!']) Then Exit;
If Expr[Length(Expr)]='.' Then Exit;
Res:=True;
BrCount1:=0; BrCount2:=0;
For I:=0 To 100 Do VAbs[I]:=True;
For I:=1 To Length(Expr) Do
Begin
If Expr[I]='|' Then
Begin
VAbs[BrCount1-BrCount2]:=Not VAbs[BrCount1-BrCount2];
If Vabs[BrCount1-BrCount2] Then
If Not(Expr[I-1] In (Cifre2+['!'])) Then
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
If Not VAbs[BrCount1-BrCount2] And ((Expr[I]=')') Or
(I=Length(Expr))) Then
Begin
Res:=False;
Break;
End;
If Not(Expr[I] In (Operators+Cifre+Brackets+['!'])) Then
Begin
Res:=False;
Break;
End;
If (Expr[I]='.') And (I<Length(Expr)) Then
If Not(Expr[I+1] In Cifre2) Then
Begin
Res:=False;
Break;
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
Var Expr,ReString,ExprLeft,ExprRight,Token1,Token2: String;
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
Pos1:=Pos('!',Expr);
If Pos1>0 Then
Begin
For Pos1B:=Pos1-1 DownTo 0 Do
If Pos1B>0 Then
If Not(Expr[Pos1B] In Cifre) Then Break;
Pos1B:=Pos1B+1;
Token1:=Copy(Expr,Pos1B,Pos1-Pos1B);
ExprLeft:=Copy(Expr,1,Pos1B-1);
ExprRight:=Copy(Expr,Pos1+1,Length(Expr));
Val(Token1,Num1,Err1);
If Num1<>Round(Num1) Then
Begin
Error:='Cannot calculate factorial.';
Solve_Exp:=True;
Exit;
End;
Result:=Factorial(Round(Num1));

If Result=Int(Result) Then Prec:=0 Else Prec:=2;
Str(Result:0:Prec,ReString);
If (ExprLeft<>'') And (Result>=0) Then
If Not (ExprLeft[Length(ExprLeft)] In Operators) Then
ExprLeft:=ExprLeft+'+';
Express:=ExprLeft+ReString+ExprRight;
Solve_Exp:=True;
Exit;
End;
For I:=1 To 5 Do
Begin
Pos1:=Pos(Operators2[I],Expr);
If (I=2) Or (I=4) Then
Begin
Pos1B:=Pos(Operators2[I+1],Expr);
If (Pos1B>0) And (Pos1B<Pos1) Then Pos1:=Pos1B;
End;
If Pos1>0 Then
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
Case Oper Of
#0: Begin
If Num1=Int(Num1) Then Prec:=0 Else Prec:=2;
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
Var SubExpr,ExprLeft,ExprRight,OldExpr: String;
Pos1,Pos2: Integer;
Abs: Boolean;
Begin
ExprLeft:=''; ExprRight:=''; Err:='';
Writeln(Expr);
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
TextColor(Colors[4]);
OldExpr:='';
While Solve_Exp(SubExpr,Err) Do
Begin
If Err<>'' Then
Begin
TextColor(Colors[5]);
Writeln('Error: ',Err);
Break;
End;
If OldExpr<>'' Then Writeln(NoSquare(OldExpr));

OldExpr:=Copy(Expr,1,Pos2)+SubExpr+Copy(Expr,Pos1,Length(Expr));
End;
If Err='' Then
Begin
ExprLeft:=Copy(Expr,1,Pos2-1);
ExprRight:=Copy(Expr,Pos1+1,Length(Expr));
If Pos1+1<=Length(Expr) Then
If (Expr[Pos1+1]='^') And (SubExpr[1]='-') And Not Abs
Then
SubExpr:='['+SubExpr+']';
If Abs And (SubExpr[1]='-') Then Delete(SubExpr,1,1);
If (ExprLeft<>'') And (SubExpr[1]='-') Then
Case ExprLeft[Length(ExprLeft)] Of
'+': ExprLeft:=Copy(ExprLeft,1,Length(ExprLeft)-1);
'-': Begin
ExprLeft:=Copy(ExprLeft,1,Length(ExprLeft)-1);
SubExpr[1]:='+';
End;
End;
Expr:=ExprLeft+SubExpr+ExprRight;
Writeln(NoSquare(Expr));
End;
End;
Until (Pos1=0) Or (Err<>'');
If Err='' Then
Begin
TextColor(Colors[4]);
While Solve_Exp(Expr,Err) Do
Begin
If Err<>'' Then
Begin
TextColor(Colors[5]);
Writeln('Error: ',Err);
Break;
End;
Writeln(NoSquare(Expr));
End;
End;
End;

BEGIN
Clrscr;
TextColor(Colors[1]);
Writeln('PAS Math, version 0.27 beta');
Writeln('Copyright (C) 2001 Michele Povigna, Carmelo Spiccia');
Writeln('This is free software with ABSOLUTELY NO WARRANTY.');
Writeln('Write QUIT to exit, HELP for more options.');
Window(1,6,80,25);
Repeat
TextColor(Colors[2]);
Write('PAS> ');
TextColor(Colors[3]);
Readln(Expr);
If NoSpace(StrUpper(Expr))='QUIT' Then Break;
If NoSpace(StrUpper(Expr))='CLS' Then
Begin
Clrscr;
Continue;
End;
If NoSpace(StrUpper(Expr))='HELP' Then
Begin
TextColor(Colors[5]);
Writeln('List of the commands: ');
TextColor(Colors[3]);
Writeln('CLS - Clear the screen.');
Writeln('HELP - Show this screen.');
Writeln('QUIT - Exit the program.');
Writeln;
Continue;
End;
Expr:=NoSpace(Expr);
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
NormVideo;
Clrscr;
END.
