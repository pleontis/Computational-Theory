%{
    #include <stdlib.h>
    #include <stdarg.h>
    #include <stdio.h>
    #include <string.h>		
    #include "cgen.h"

	extern int yylex(void);
    extern int line_num;
%}

%union {
	char* str;
}

%nonassoc find_biggest

%token <str> TK_IDENT 
%token <str> TK_INT 
%token <str> TK_REAL 
%token <str> TK_STRING 

%token TK_ASSGN

%token KW_integer 
%token KW_scalar 
%token KW_str
%token KW_boolean 
%token KW_true 
%token KW_false 
%token KW_const 
%token KW_if 
%token KW_else 
%token KW_endif 
%token KW_for 
%token KW_in 
%token KW_endfor 
%token KW_while 
%token KW_endwhile 
%token KW_break 
%token KW_continue 
%token KW_not 
%token KW_and 
%token KW_or 
%token KW_def 
%token KW_enddef 
%token KW_main 
%token KW_return 
%token KW_comp 
%token KW_endcomp 

%token BIGGER_EQUAL_OP 
%token SMALLER_EQUAL_OP 
%token EQUAL_OP 
%token NOT_EQUAL_OP 
%token PLUS_SELF 
%token MINUS_SELF 
%token MULTIPLY_SELF 
%token DIVIDE_SELF 
%token MOD_SELF 

%token POWER_OP
%nonassoc EMPTY_DECL
%nonassoc NOT_ARRAY

%left TK_ASSGN PLUS_SELF MINUS_SELF MULTIPLY_SELF DIVIDE_SELF MOD_SELF
%left KW_or
%left KW_and
%right KW_not
%left EQUAL_OP NOT_EQUAL_OP
%left '>' '<' BIGGER_EQUAL_OP SMALLER_EQUAL_OP
%left '+' '-'
%left '*' '/' '%'
%right POWER_OP
%left '.' '(' ')' '[' ']'


%start input
%type <str> input


%type <str> main_func
%type <str> command_block
%type <str> one_comp
%type <str> comp_declarations
%type <str> comp_var_declarations
%type <str> one_var
%type <str> var_declarations
%type <str> same_line_var_declarations
%type <str> one_const
%type <str> const_declarations
%type <str> assgn_vars
%type <str> expression
%type <str> logic_exp
%type <str> arith_exp
%type <str> complex_exp
%type <str> function_input
%type <str> statement
%type <str> assgn
%type <str> if_state
%type <str> else_state
%type <str> for_state
%type <str> while_state
%type <str> func_state
%type <str> func_declarations 
%type <str> one_function
%type <str> func_arguments
%type <str> one_argument
%type <str> func_command_block
%type <str> return_type
%type <str> file_template
%type <str> statements_block

//NOT ELSE < KEYWORD ELSE
%nonassoc NOT_ELSE
%nonassoc KW_else

%%

input: 
    file_template{ $$ = template("%s",$1);
        if(yyerror_count==0)
        {
            FILE* filep=fopen("translatedFile.c","w");
            fputs(c_prologue,filep);
            fputs("#include <math.h>\n",filep);
            
            fprintf(filep,"\n%s\n", $1);           
            
            fclose(filep);
        }
    }
;

file_template:
    main_func                                                                           {$$=template("%s\n",$1);}
//---------------------------------------------------------------------------------------------------------------------------------------------
|   comp_declarations main_func                                                         {$$=template("%s\n%s\n",$1,$2);}   
|   const_declarations main_func                                                        {$$=template("%s\n%s\n",$1,$2);}
|   var_declarations main_func                                                          {$$=template("%s\n%s\n",$1,$2);}
|   func_declarations main_func                                                         {$$=template("%s\n%s\n",$1,$2);}
//---------------------------------------------------------------------------------------------------------------------------------------------
|   comp_declarations const_declarations main_func                                      {$$=template("%s\n%s\n%s\n",$1,$2,$3);}
|   comp_declarations const_declarations var_declarations main_func                     {$$=template("%s\n%s\n%s\n%s\n",$1,$2,$3,$4);}
|   comp_declarations const_declarations var_declarations func_declarations main_func   {$$=template("%s\n%s\n%s\n%s\n%s\n",$1,$2,$3,$4,$5);}
|   comp_declarations const_declarations func_declarations main_func                    {$$=template("%s\n%s\n%s\n%s\n",$1,$2,$3,$4);}
//---------------------------------------------------------------------------------------------------------------------------------------------
|   comp_declarations var_declarations main_func                                        {$$=template("%s\n%s\n%s\n",$1,$2,$3);}
|   comp_declarations var_declarations func_declarations main_func                      {$$=template("%s\n%s\n%s\n%s\n",$1,$2,$3,$4);}
|   comp_declarations func_declarations main_func                                       {$$=template("%s\n%s\n%s\n",$1,$2,$3);}
//---------------------------------------------------------------------------------------------------------------------------------------------
|   const_declarations var_declarations main_func                                       {$$=template("%s\n%s\n%s\n",$1,$2,$3);}
|   const_declarations var_declarations func_declarations main_func                     {$$=template("%s\n%s\n%s\n%s\n",$1,$2,$3,$4);}
//---------------------------------------------------------------------------------------------------------------------------------------------
|   const_declarations func_declarations main_func                                     {$$=template("%s\n%s\n%s\n",$1,$2,$3);}
|   var_declarations func_declarations main_func                                        {$$=template("%s\n%s\n%s\n",$1,$2,$3);}
;

//========================================================================================================================================================

main_func:
    KW_def KW_main '('')'':' command_block KW_enddef ';' {$$=template("void main(){\n%s}",$6);}
;

comp_declarations:
    one_comp                        {$$=template("%s", $1);}
|   comp_declarations one_comp      {$$=template("%s\n%s", $1,$2);}
;

one_comp:
    KW_comp TK_IDENT ':' comp_var_declarations KW_endcomp ';'                           {$$=template("typedef struct %s{\n%s \n} %s ;\n",$2,$4,$2);}
|   KW_comp TK_IDENT ':' func_declarations KW_endcomp ';'                               {$$=template("typedef struct %s{\n%s \n} %s ;\n",$2,$4,$2);}
|   KW_comp TK_IDENT ':' comp_var_declarations func_declarations KW_endcomp ';'         {$$=template("typedef struct %s{\n%s \n%s \n} %s ;\n",$2,$4,$5,$2);}

;

comp_var_declarations:
    one_var                             {$$=template("%s", $1);}
|   comp_var_declarations one_var       {$$=template("%s\n%s", $1,$2);}
;

var_declarations:
    one_var                     {$$=template("%s", $1);}
|   var_declarations one_var    {$$=template("%s \n%s", $1,$2);}
;

one_var:
    same_line_var_declarations ':' KW_integer ';'   {$$=template("int %s;", $1);}
|   same_line_var_declarations ':' KW_scalar ';'    {$$=template("double %s;", $1);}  
|   same_line_var_declarations ':' KW_str ';'       {$$=template("char* %s;", $1);}  
|   same_line_var_declarations ':' KW_boolean ';'   {$$=template("int %s;", $1);}  
|   same_line_var_declarations ':' TK_IDENT';'      {$$=template("struct %s %s;",$3,$1);}
|   same_line_var_declarations '['TK_INT']' ':' KW_integer';' {$$=template("int %s[%s];",$1,$3);}
|   same_line_var_declarations '['TK_INT']' ':' KW_scalar';' {$$=template("double %s[%s];",$1,$3);}
|   same_line_var_declarations '['TK_INT']' ':' KW_str';' {$$=template("char* %s[%s];",$1,$3);}
|   same_line_var_declarations '['TK_INT']' ':' KW_boolean';' {$$=template("int %s[%s];",$1,$3);}
|   same_line_var_declarations '['TK_INT']' ':' TK_IDENT';' {$$=template("struct[%s] %s;",$3,$1);}
;

const_declarations:
    one_const               {$$=template("%s",$1);}
|   const_declarations one_const {$$=template("%s\n%s",$1,$2);}
;

one_const:
    KW_const same_line_var_declarations ':' KW_integer ';'                      {$$=template("const int %s;",$2);}
|   KW_const same_line_var_declarations ':' KW_scalar ';'                       {$$=template("const double %s;",$2);}
|   KW_const same_line_var_declarations ':' KW_str ';'                          {$$=template("const char* %s;",$2);}
|   KW_const same_line_var_declarations ':' KW_boolean ';'                      {$$=template("const int %s;",$2);}
|   KW_const same_line_var_declarations '['TK_INT ']' ':' KW_integer';'         {$$=template("const int %s[%s];",$2,$4);}    
|   KW_const same_line_var_declarations '['TK_INT ']' ':' KW_scalar';'          {$$=template("const double %s[%s];",$2,$4);}    
|   KW_const same_line_var_declarations '['TK_INT ']' ':' KW_str';'             {$$=template("const char* %s[%s];",$2,$4);}    
|   KW_const same_line_var_declarations '['TK_INT ']' ':' KW_boolean';'         {$$=template("const int %s[%s];",$2,$4);}    

same_line_var_declarations:
    assgn_vars                                      {$$=template("%s", $1);}
|   '#' assgn_vars                                  {$$=template("%s", $2);}
|   assgn_vars ',' same_line_var_declarations       {$$=template("%s,%s",$1,$3);}
|   '#' assgn_vars ',' same_line_var_declarations   {$$=template("%s,%s",$2,$4);}
;

assgn_vars:
    TK_IDENT                        {$$=template("%s",$1);} %prec NOT_ARRAY
|   TK_IDENT '[' expression ']'     {$$=template("%s[(int)(%s)]",$1,$3); }                  
|   TK_IDENT TK_ASSGN expression    {$$=template("%s = %s",$1,$3);}
;

expression:
    logic_exp  {$$=template("%s",$1);}
;

//================================================================================================================

logic_exp:
    arith_exp                               {$$=template("%s",$1);}
|   logic_exp EQUAL_OP arith_exp            {$$=template("%s == %s",$1,$3);}
|   logic_exp NOT_EQUAL_OP arith_exp        {$$=template("%s != %s",$1,$3);}
|   logic_exp '>' arith_exp                 {$$=template("%s > %s",$1,$3);}
|   logic_exp '<' arith_exp                 {$$=template("%s < %s",$1,$3);}
|   logic_exp BIGGER_EQUAL_OP arith_exp     {$$=template("%s >= %s",$1,$3);}
|   logic_exp SMALLER_EQUAL_OP arith_exp    {$$=template("%s <= %s",$1,$3);}
|   logic_exp KW_and arith_exp              {$$=template("%s && %s",$1,$3);}
|   logic_exp KW_or arith_exp               {$$=template("%s || %s",$1,$3);}
|   KW_not arith_exp                        {$$=template("!%s",$2);}
;

arith_exp:
    complex_exp                     {$$=template("%s",$1);}
|   arith_exp '/' complex_exp       {$$ = template("%s / %s", $1, $3); }
|   arith_exp '*' complex_exp       {$$ = template("%s * %s", $1, $3); }
|   arith_exp '-' complex_exp       {$$ = template("%s - %s", $1, $3); } 
|   arith_exp '+' complex_exp       {$$ = template("%s + %s", $1, $3); } 
|   arith_exp '%' complex_exp       {$$ = template("fmod(%s,%s)", $1, $3); }
|   arith_exp POWER_OP complex_exp  {$$ = template("pow((double)%s,(double)%s)", $1, $3); }
;

complex_exp:
    TK_IDENT    {$$=template("%s",$1);}     %prec find_biggest
|   TK_INT      {$$=template("%s",$1);}     
|   TK_REAL     {$$=template("%s",$1);} 
|   TK_STRING   {$$=template("%s",$1);}
|   KW_true     {$$=template("1");}
|   KW_false    {$$=template("0");}
|   '(' expression ')'      {$$=template("(%s)",$2);}
|   '-' arith_exp      {$$=template("-%s",$2);} 
|   '+' arith_exp      {$$=template("+%s",$2);} 
|   TK_IDENT '[' expression ']'                {$$  = template("%s[(int)(%s)]",$1,$3); }
|   TK_IDENT '(' function_input')'           {$$=template("%s(%s)",$1,$3);}
;

//==================================================================================================================

statement:
    assgn                       {$$=template("%s",$1);}
|   if_state                    {$$=template("%s",$1);}
|   while_state                 {$$=template("%s",$1);}
|   for_state                   {$$=template("%s",$1);}
|   func_state                  {$$=template("%s",$1);}
|   KW_break ';'                {$$=template("break;");}
|   KW_continue';'              {$$=template("continue;");}
|   KW_return ';'               {$$=template("return;");}
|   KW_return expression ';'    {$$=template("return %s;",$2);}
;

assgn:
    TK_IDENT TK_ASSGN expression ';'                        {$$=template("%s=%s;",$1,$3);}
|   TK_IDENT '[' expression ']' TK_ASSGN expression ';'     {$$=template("%s[(int)(%s)]=%s;",$1,$3,$6);}
;

for_state:
    KW_for TK_IDENT KW_in '[' arith_exp ':' arith_exp ']' ':' command_block KW_endfor ';'                         {$$=template("for(int %s=%s;%s<=%s && %s>=-%s;%s+=1){\n%s\n}",$2,$5,$2,$7,$2,$7,$2,$10); }
|   KW_for TK_IDENT KW_in '[' arith_exp ':' arith_exp ':' arith_exp ']' ':' command_block KW_endfor ';'           {$$=template("for(int %s=%s;%s<=%s && %s>=-%s;%s+=%s){\n%s\n}",$2,$5,$2,$7,$2,$7,$2,$9,$12); }    
;

while_state:
   KW_while '(' expression ')' ':' command_block KW_endwhile ';'       {$$ = template("while(%s){\n\t%s\t}",$3,$6);}
;

else_state:
    KW_else ':' command_block   {$$ = template("else{\n\t%s\n}",$3); } //final else (optional)
;

if_state:
    KW_if '(' expression ')' ':' command_block KW_endif ';'             {$$ = template("if(%s){\n\t%s\n\t}",$3,$6); }  %prec NOT_ELSE   
|   KW_if '(' expression ')' ':' command_block else_state KW_endif ';'  {$$ = template("if(%s){\n\t%s\t}%s",$3,$6,$7); }
;

command_block:
    statement command_block     {$$ = template("\t%s\n%s",$1,$2);}
|   one_var command_block       {$$ = template("\t%s\n%s",$1,$2);}
|   one_const command_block     {$$ = template("\t%s\n%s",$1,$2);}
|   %empty                      {$$ = template("");}
;

//==============================================================================================================================================================================

func_state:
    TK_IDENT '(' function_input ')' ';'   {$$=template("%s(%s);",$1,$3);}
;

function_input:
    %empty                              {$$=template("");}
|   function_input ',' expression       {$$ = template("%s , %s", $1,$3);}
|   expression                          {$$ = template("%s", $1);}
;

func_declarations:
    one_function                        {$$=template("%s",$1);}
|   func_declarations one_function      {$$=template("%s\n%s",$1,$2);}
;

one_function:
    KW_def TK_IDENT '(' func_arguments ')' return_type ':' func_command_block  KW_enddef ';'    {$$=template("%s %s(%s){\n%s\n}",$6,$2,$4,$8);} 
;

func_arguments:
    one_argument                        {$$=template("%s",$1);}
|   one_argument ',' func_arguments     {$$=template("%s,%s",$1,$3);}
;

one_argument:
    %empty                              {$$=template("");}
|   TK_IDENT ':' KW_integer             {$$=template("int %s",$1);}
|   TK_IDENT ':' KW_scalar              {$$=template("double %s",$1);}
|   TK_IDENT ':' KW_str                 {$$=template("char* %s",$1);}
|   TK_IDENT ':' KW_boolean             {$$=template("int %s",$1);}
|   TK_IDENT '[' ']' ':' KW_integer     {$$=template("int %s[]",$1);}
|   TK_IDENT '[' ']' ':' KW_scalar      {$$=template("double %s[]",$1);}
|   TK_IDENT '[' ']' ':' KW_str         {$$=template("char* %s[]",$1);}
|   TK_IDENT '[' ']' ':' KW_boolean     {$$=template("int %s[]",$1);}
|   TK_IDENT '['TK_INT']'':' KW_integer {$$=template("int %s[%s]",$1,$3);}
|   TK_IDENT '['TK_INT']'':' KW_scalar  {$$=template("double %s[%s]",$1,$3);}
|   TK_IDENT '['TK_INT']'':' KW_str     {$$=template("char* %s[%s]",$1,$3);}
|   TK_IDENT '['TK_INT']'':' KW_boolean {$$=template("int %s[%s]",$1,$3);}
;

return_type:    
    %empty                      {$$=template("void");}
|   '-''>' KW_integer           {$$=template("int");}
|   '-''>' KW_str               {$$=template("char*");}
|   '-''>' KW_scalar            {$$=template("double");}
|   '-''>' KW_boolean           {$$=template("int");}
;

func_command_block:
    var_declarations const_declarations statements_block    {$$=template("\t%s\n\t%s\n\t%s",$1,$2,$3);}
|   var_declarations statements_block                       {$$=template("\t%s\n\t%s",$1,$2);}
|   const_declarations statements_block                     {$$=template("\t%s\n%\ts",$1,$2);}
|   statements_block                                        {$$=template("\t%s",$1);}
;

statements_block:
    statement                       {$$=template("%s",$1);}
|   statement statements_block      {$$=template("%s\n\t%s",$1,$2);}  
;

%%
int main ()
{
   if ( yyparse() == 0 )
		printf("Your program is syntactically correct!\n");
	else
		printf("\nRejected!\n");
}