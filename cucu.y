%{
#include <stdio.h>
int yylex(void);

FILE *forParser, *forLexer;
extern int inLEX=0;
%}
%code provides {
    void yyerror(char *);
}

%union{
    char name[20];
    int typeNUM;
}

%token TYPE ID retTOK errorLEX andTOKEN orTOKEN ASSIGN SEMIC ADDR SUBTR MULTIPLIER NUMBER ifTok elseTok whileTok OPPAR1 OPPAR2 OPPAR3 CLPAR1 CLPAR2 CLPAR3 comparator commaToken QUOTIENT tokenCOM
%type  <name> TYPE
%type <name> ID
%type <name> comparator
%type <name> errorLEX
%type <typeNUM> NUMBER

%%
prog: bodySTMT
    ;

bodySTMT:
        |
        assignStatement bodySTMT
        |
        ctrlSTMT bodySTMT
        |
        functionDec bodySTMT
        |
        functionCall bodySTMT
        |
        functionDef bodySTMT
        |
        tokenCOM bodySTMT
        |
        returnSTMT bodySTMT
        |
        error_lex bodySTMT
        ;

returnSTMT:
            retTOK expr SEMIC {fprintf(forParser, "<-return\n");}
            ;
ctrlSTMT:
    ifSTMT 
    |
    whileSTMT
    ;

functionDec: TYPE ID OPPAR1 funcARGS_dec CLPAR1 SEMIC {fprintf(forParser, "function declaration: %s\n", $2);}
            |
            TYPE ID OPPAR1  CLPAR1 SEMIC {fprintf(forParser, "function declaration(no args): %s\n", $2);}
            ;

functionDef: TYPE ID OPPAR1 funcARGS_dec CLPAR1 OPPAR2 bodySTMT CLPAR2 {fprintf(forParser, "function def: %s\n", $2);}
            |
            TYPE ID OPPAR1  CLPAR1 OPPAR2 bodySTMT CLPAR2 {fprintf(forParser, "function def(no args): %s\n", $2);}
            ;

functionCall: ID  OPPAR1 funcARGS_call CLPAR1 SEMIC {fprintf(forParser, "\nfunction call: %s\n", $1);}
            |
            ID  OPPAR1 CLPAR1 SEMIC {fprintf(forParser, "\nfunction call(no arguements): %s\n", $1);}
            ;

funcARGS_dec: 
            TYPE ID commaToken funcARGS_dec {fprintf(forParser, "function arguement: %s\n",$2);}
            |
            TYPE ID {fprintf(forParser, "function arguement: %s, ", $2);}
            ;

funcARGS_call:
            expr {fprintf(forParser, "<-funcCallArg ");}
            |
            condSTMT {fprintf(forParser, "<-funcCallArg ");}
            |
            funcARGS_call commaToken expr {fprintf(forParser, "<-funcCallArg ");}
            |
            funcARGS_call commaToken condSTMT {fprintf(forParser, "<-funcCallArg ");}
            ;

ifSTMT: ifTok OPPAR1 condSTMT CLPAR1 OPPAR2 bodySTMT CLPAR2 {fprintf(forParser, "if stmt\n");}
        |
        ifTok OPPAR1 condSTMT CLPAR1 OPPAR2 bodySTMT CLPAR2 elseTok OPPAR2 bodySTMT CLPAR2 {fprintf(forParser, "ifelse\n");}
        ;

whileSTMT: whileTok OPPAR1 condSTMT CLPAR1 OPPAR2 bodySTMT CLPAR2  {fprintf(forParser, "while loop\n");}
        ;

condSTMT:
        expr
        |
        expr andTOKEN condSTMT
        |
        expr orTOKEN condSTMT
        |
         expr comparator expr {fprintf(forParser, " %s ", $2);}
        |
        expr comparator expr andTOKEN condSTMT  {fprintf(forParser, " %s ", $2);}
        |
        expr comparator expr orTOKEN condSTMT   {fprintf(forParser, " %s ", $2);}
        ;


assignStatement: TYPE ID ASSIGN expr SEMIC {fprintf(forParser, "assignVariableLHS: %s\n",$2);}
                |
                TYPE ID SEMIC {fprintf(forParser, "assignVariableLHS: %s\n",$2);}
                |
                ID ASSIGN expr SEMIC {fprintf(forParser, "assignVariableLHS: %s\n",$1);}
                ;

expr:
    OPPAR1 ID opr expr CLPAR1 {fprintf(forParser, "variable:%s ",$2);}
    |
    OPPAR1 ID opr expr CLPAR1 opr expr{fprintf(forParser, "variable:%s ",$2);}
    |
    ID opr expr {fprintf(forParser, "variable:%s ",$1);}
    |
    OPPAR1 ID CLPAR1 {fprintf(forParser, "variable:%s ",$2);}
    |
    ID {fprintf(forParser, "variable:%s ",$1);}
    |
    OPPAR1 NUMBER CLPAR1 {fprintf(forParser, "constant:%d ",$2);}
    |
    NUMBER {fprintf(forParser, "constant:%d ",$1);}
    |
    OPPAR1 NUMBER opr expr CLPAR1 {fprintf(forParser, "constant:%d ",$2);}
    |
    OPPAR1 NUMBER opr expr CLPAR1 opr expr{fprintf(forParser, "constant:%d ",$2);}
    |
    NUMBER opr expr {fprintf(forParser, "constant:%d  ",$1);}
    |
    OPPAR1 ID OPPAR3 expr CLPAR3 CLPAR1 {fprintf(forParser, " var:%s [] ",$2);}
    |
    ID OPPAR3 expr CLPAR3 {fprintf(forParser, " var:%s [] ",$1);}
    |
    OPPAR1 ID OPPAR3 expr CLPAR3 opr expr CLPAR1 {fprintf(forParser, " var:%s [] ",$2);}
    |
    OPPAR1 ID OPPAR3 expr CLPAR3 opr expr CLPAR1 opr expr{fprintf(forParser, " var:%s [] ",$2);}
    |
    ID OPPAR3 expr CLPAR3 opr expr {fprintf(forParser, " var:%s [] ",$1);}
    ;

opr: ADDR {fprintf(forParser, "op:+ ");}
    |
    SUBTR {fprintf(forParser, "op:- ");}
    |
    MULTIPLIER {fprintf(forParser, "op:* ");}
    |
    QUOTIENT {fprintf(forParser, "op:\\ ");}
    ;
error_lex:  errorLEX {inLEX =1; yyerror($1);}

%%
 
int yywrap(){
    return 1;
}


int main(int argc, char **argv){
    extern FILE *yyin, *yyout;
    yyin = fopen(argv[1], "r");
    yyout = fopen("Lexer.txt", "w");
    forLexer = yyout;
    forParser = fopen("Parser.txt", "w");
    yyparse();    
    return 0;
}

void yyerror(char *s){
        
        if(inLEX==0){
            printf("Syntax error (also displayed in Parser.txt)\n");
            {fprintf(forParser, "%s", s);}
        }
        else
        {   printf("Lexical error (also displayed in Lexer.txt)\n");
            {fprintf(forLexer, "LEXICAL ERROR: %s-----------------------------------------\n", s);}
            inLEX=0;
        }
        return;
}

  