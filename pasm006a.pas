{This program is to be distributed under the terms of the GPL -
Gnu Public License.
Copyright (C) 2001 Michele Povigna.
This program came with ABSOLUTELY NO WARRANTY. }

program PASmath;
const cifre=['1','2','3','4','5','6','7','8','9','0'];
operators=['+','-'];
var command,newcommand: string;

function solve_exp(command: string): string;
var restring,token1,token2,operator: string;
i,i2,num1,num2,err,err2,result,toksign,begtok: integer;
begin
newcommand:='';restring:='';token1:='';token2:='';operator:='';
toksign:=1;
if command[1]='-' then
begin
delete(command,1,1);
toksign:=-1;
end else if command[1]='0' then
begin
delete(command,1,1);
toksign:=-1;
end;
for i := 1 to length(command) do
if command[i] in cifre then token1:=token1+command[i] else
if command[i] in operators then
begin
operator:=command[i];
i2:=i;
repeat
i2:=i2+1;
if command[i2] in cifre then token2:=token2+command[i2]
else
if command[i2] in operators then
begin
newcommand:=copy(command,i2,length(command));
i:=length(command);
end;
until command[i2] in operators;
end;
val(token1,num1,err);
val(token2,num2,err2);
if operator='' then result:=(num1*toksign);
if operator='+' then result:=(num1*toksign)+num2;
if operator='-' then result:=(num1*toksign)-num2;
str(result,restring);
solve_exp:=restring+newcommand;
end;

begin
writeln('PAS Math, version 0.06a');
writeln('Copyright (C) 2001 Michele Povigna');
writeln('This is free software with ABSOLUTELY NO WARRANTY.');
write('Pas> ');
read(command);
writeln('');
writeln(command);
repeat
if command <> solve_exp(command) then
begin
command:=solve_exp(command);
writeln(command);
end;
until newcommand='';
writeln('PAS> ');
