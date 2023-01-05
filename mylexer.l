%{
   #include <stdio.h>
   #include <string.h>
   #include "cgen.h"
   #include "myanalyzer.tab.h"
   
   int line_num = 1;
%}


ID      [a-zA-Z_][0-9a-zA-Z_]*
DIGIT   [0-9]
NUMBER  {DIGIT}{DIGIT}*
DECIMAL ("0""."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL    {DECIMAL}([eE][+-]?{NUMBER})?
CONS_STRING \"[^'\n]*\"
SYMBOL  [-+*/:_$%!#@&~^()]*
%%

integer   {printf("keyword integer: %s\n", yytext); return KW_integer; }
scalar    {printf("keyword scalar: %s\n", yytext); return KW_scalar; } 
str       {printf("keyword str: %s\n", yytext); return KW_str; }
boolean   {printf("keyword boolean: %s\n", yytext); return KW_boolean; }
True      {printf("keyword true: %s\n", yytext); return KW_true; }
False     {printf("keyword false: %s\n", yytext); return KW_false; }
const     {printf("keyword const: %s\n", yytext); return KW_const; }
if        {printf("keyword IF: %s\n", yytext); return KW_if; }
else      {printf("keyword ELSE: %s\n", yytext); return KW_else; }
endif     {printf("keyword endif: %s\n", yytext); return KW_endif; }
for       {printf("keyword for: %s\n", yytext); return KW_for; }
in        {printf("keyword in: %s\n", yytext); return KW_in; }
endfor    {printf("keyword endfor: %s\n", yytext); return KW_endfor; }
while     {printf("keyword while: %s\n", yytext); return KW_while; }
endwhile  {printf ("keyword endwhile: %s\n", yytext); return KW_endwhile; }
break     {printf ("keyword break: %s\n", yytext); return KW_break; }
continue  {printf ("keyword continue: %s\n", yytext); return KW_continue; }
not       {printf("keyword not: %s\n", yytext); return KW_not; }
and       {printf("keyword and: %s\n", yytext); return KW_and; }
or        {printf ("keyword or: %s\n", yytext); return KW_or; }
def       {printf("keyword def: %s\n", yytext); return KW_def; }
enddef    {printf ("keyword enddef: %s\n", yytext); return KW_enddef; }
main      {printf ("keyword main: %s\n", yytext); return KW_main; }
return    {printf ("keyword return: %s\n", yytext); return KW_return; }
comp      {printf ("keyword comp: %s\n", yytext); return KW_comp; }
endcomp   {printf ("keyword endcomp: %s\n", yytext); return KW_endcomp; }

{ID}        {yylval.str = strdup(yytext);printf ("token IDENTIFIER: %s\n", yytext); return TK_IDENT; }
{NUMBER}    {yylval.str = strdup(yytext);printf ("token CONST_INT: %s\n", yytext); return TK_INT; }
{REAL}      {yylval.str = strdup(yytext);printf ("token CONST_REAL: %s\n", yytext); return TK_REAL; }
{CONS_STRING} {yylval.str = strdup(yytext);printf("token CONS_STRING: %s\n", yytext); return TK_STRING; }

"."         {printf ("token MEMBER_ACCESS: %s\n",yytext); return '.'; }
","         {printf ("token COMMA: %s\n", yytext); return ','; }
":"         {printf ("token COLON: %s\n", yytext); return ':'; }
"["         {printf ("token BRACKET_OPEN: %s\n", yytext); return '['; }
"]"         {printf ("token BRACKET_CLOSE: %s\n", yytext); return ']'; }
"("			{printf("token PARENTHESIS_OPEN: %s\n", yytext); return '('; }
")"			{printf("token PARENTHESIS_CLOSE: %s\n", yytext); return ')'; }
"**"        printf("token POWER_OP: %s\n", yytext); return POWER_OP;        
";"         printf("token SEMICOLON: %s\n", yytext); return ';';
"="         printf("token ASSIGN_OP: %s\n", yytext); return TK_ASSGN;
"+"         printf("token PLUS_OP: %s\n", yytext); return '+';
"-"         printf("token MINUS_OP: %s\n", yytext); return '-';
"*"         printf("token MUL_OP: %s\n", yytext); return '*';
"/"         printf("token DIV_OP: %s\n", yytext); return '/';
"%"         printf("token MOD_OP: %s\n", yytext); return  '%';
"<"         printf("token SMALLER_OP: %s\n", yytext); return '<';
">"         printf("token BIGGER_OP: %s\n", yytext); return '>';
"<="        printf("token SMMALER_EQUAL_OP: %s\n", yytext); return SMALLER_EQUAL_OP;
">="        printf("token BIGGER_EQUAL_OP: %s\n", yytext); return BIGGER_EQUAL_OP;
"=="        printf("token EQUAL_OP: %s\n", yytext); return EQUAL_OP;
"!="        printf("token NOT_EQUAL_OP: %s\n", yytext); return NOT_EQUAL_OP;
"+="        printf("token PLUS_SELF: %s\n", yytext); return PLUS_SELF;
"-="        printf("token MINUS_SELF: %s\n", yytext); return MINUS_SELF;
"*="        printf("token MULTIPLY_SELF: %s\n", yytext); return MULTIPLY_SELF;
"/="        printf("token DIVIDE_SELF: %s\n", yytext); return DIVIDE_SELF;
"%="        printf("token MOD_SELF: %s\n", yytext); return MOD_SELF;
"#"         printf("token COMP_TYPE_VARIABLE: %s\n", yytext); return '#';

"--"[^\n]*  /*Skip comments*/

[ \r\t]			/* skip whitespace */
\n 					 ++line_num;

<<EOF>> 	return EOF;
.           {yyerror("Syntax error in line %s: unrecognized literal '%s'\n", line_num,yytext);}

%%