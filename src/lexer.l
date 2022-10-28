%option noyywrap
%{
    /*
    * You will need to comment this line in lab5.
    */
    #include <string>
    #define ONLY_FOR_LEX
    #ifdef ONLY_FOR_LEX
    #include<vector>
    char curscope[50]="1";
    bool isdefined =0;
    typedef struct node { 
 
    	char id[50]; 
    	char scope[50];
    	/*
    	    here value is lineno first apper
    	*/
    	int value;
   	node(){
   		value =0;
    	}
    	node& operator=(const node&s){
    		strcpy(this->id,s.id);
    		strcpy(this->scope,s.scope);
    		this->value=s.value;
    		return *this;
    	}
    	bool operator==(const node&s){
    		return (strcmp(this->id,s.id)==0)&&(strcmp(this->scope,s.scope)==0);
    	}
    	node(const node&s){
    		strcpy(this->id,s.id);
    		strcpy(this->scope,s.scope);
    		this->value=s.value;
    	}
    }Node;
    struct scopenode{
    	char scope[50];
    	int num;
    	scopenode(){
   		num =0;
    	}
    	scopenode& operator=(const scopenode&s){
    		strcpy(this->scope,s.scope);
    		this->num=s.num;
    		return *this;
    	}
    	bool operator==(const scopenode&s){
    		return (strcmp(this->scope,s.scope)==0);
    	}
    	scopenode(const scopenode&s){
    		strcpy(this->scope,s.scope);
    		this->num=s.num;
    	}
    };
    std::vector<Node> symboltable;
    std::vector<scopenode> scopechild;
    void addscope(char* scope);
    int getnum(char* scope);
    void getfar(char* scope);
    void getchild(char* scope);
    void add(char *name,char *scope,int value);
    int find(char* name,char* scope);
    void getval(char* name,char* scope,char* getscope,int &value);
    #else
    #define YYSTYPE void *
    #include "parser.h"
    #endif

    #define YY_NO_UNPUT
    #define YY_NO_INPUT

    #ifdef ONLY_FOR_LEX
    #include <ostream>
    #include <fstream>
    using namespace std;
    extern FILE *yyin; 
    extern FILE *yyout;
    void DEBUG_FOR_LAB4(std::string s){
        std::string DEBUG_INFO = "[DEBUG LAB4]: \t" + s + "\n";
        fputs(DEBUG_INFO.c_str(), yyout);
    }
    void output(std::string token,std::string lexme,int lineno,std::string scope,int value){
        fprintf(yyout,"%10s\t%10s\t%6d\t%10s\t%10d\n",token.c_str(),lexme.c_str(),lineno,scope.c_str(),value);
    }
    void output(std::string token,std::string lexme,int lineno,std::string scope,float value){
        fprintf(yyout,"%10s\t%10s\t%6d\t%10s\t%10.7f\n",token.c_str(),lexme.c_str(),lineno,scope.c_str(),value);
    }
     void output(std::string token,std::string lexme,int lineno){
        fprintf(yyout,"%10s\t%10s\t%6d\n",token.c_str(),lexme.c_str(),lineno);
    }
    #endif
%}
DECIMAL ([1-9][0-9]*|0)
/*+ is one or more

*/
HEXADECIMAL (0[xX]([1-9a-fA-F][0-9a-fA-F]*|0))
OCTAL (0([1-7][0-7]*|0))
FLOATNUM (({DECIMAL}[.]{DECIMAL}([eE][+-]?{DECIMAL}))[f]?)
ID [a-zA-Z_][a-zA-Z0-9_]*
/*as newline
*/
EOL (\r\n|\n|\r)
WHITE [\t' ']
BLOCKCOMMENTBEGIN \/\*
BLOCKCOMMENTELEMENT .
BLOCKCOMMENTEND \*\/
/*is conisit of not \n
*/ 
LINECOMMENT \/\/[^\n]*
%x BLOCKCOMMENT

%%
{LINECOMMENT} {} //do nothing
{BLOCKCOMMENTBEGIN} {BEGIN BLOCKCOMMENT;}//begin comment
<BLOCKCOMMENT>{BLOCKCOMMENTELEMENT} {}//'.' is all char except newline,newline is directed by EOL ,do nothing
<BLOCKCOMMENT>{EOL} {}
<BLOCKCOMMENT>{BLOCKCOMMENTEND} {BEGIN INITIAL;}//end comment
{DECIMAL} {
    #ifdef ONLY_FOR_LEX
        int temp;
        //yytext is char*
        sscanf(yytext,"%d",&temp);
    	output("DECIMAL",string(yytext),yylineno,"",temp);
    #else
        return DECIMAL;
    #endif
}
{OCTAL} {
    #ifdef ONLY_FOR_LEX
        int temp;
        //yytext is char*
        sscanf(yytext,"%o",&temp);
    	output("OCTAL",string(yytext),yylineno,"",temp);
    #else
        return OCTAL;
    #endif
}
{HEXADECIMAL} {
    #ifdef ONLY_FOR_LEX
        int temp;
        //yytext is char*
        sscanf(yytext,"%x",&temp);
    	output("HEXADECIMAL",string(yytext),yylineno,"",temp);
    #else
        return HEXADECIMAL;
    #endif
}
{FLOATNUM} {
    #ifdef ONLY_FOR_LEX
        float temp;
        //yytext is char*
        sscanf(yytext,"%f",&temp);
    	output("FLOATNUM",string(yytext),yylineno,"",temp);
    #else
        return FLOATNUM;
    #endif
}
"float" {
    #ifdef ONLY_FOR_LEX
        isdefined=1;
    	output("FLOAT","float",yylineno);
    #else
        return FLOAT;
    #endif
}
"const" {
    #ifdef ONLY_FOR_LEX
    	output("CONST","const",yylineno);
    #else
        return CONST;
    #endif
}
"int" {
    /*
    * Questions: 
    *   Q1: Why we need to return INT in further labs?
    *   Q2: What is "INT" actually?
    */
    #ifdef ONLY_FOR_LEX
        isdefined=1;
    	output("INT","int",yylineno);
    #else
        return INT;
    #endif
}
"void" {
    #ifdef ONLY_FOR_LEX
        isdefined=1;
        output("VOID","void",yylineno);
    #else
        return VOID;
    #endif 
}
"while" {
    #ifdef ONLY_FOR_LEX
    	output("WHILE","while",yylineno);
    #else
        return WHILE;
    #endif
}
"break"	{
    #ifdef ONLY_FOR_LEX
    	output("BREAK","break",yylineno);
    #else
        return BREAK;
    #endif
}
"continue" {
    #ifdef ONLY_FOR_LEX
    	output("CONTINUE","continue",yylineno);
    #else
        return CONTINUE;
    #endif
}
"if" {
    #ifdef ONLY_FOR_LEX
        output("IF","if",yylineno);
    #else
        return IF;
    #endif
};
"else" {
    #ifdef ONLY_FOR_LEX
        output("ELSE","else",yylineno);
    #else
        return ELSE;
    #endif
};
"return" {
    #ifdef ONLY_FOR_LEX
        output("RETURN","return",yylineno);
    #else
        return RETURN;
    #endif
}

"=" {
    #ifdef ONLY_FOR_LEX
        output("ASSIGN","=",yylineno);
    #else
        return ASSIGN;
    #endif
}
"+" {
    #ifdef ONLY_FOR_LEX
        output("ADD","+",yylineno);
    #else
        return ADD;
    #endif
}
"-" {
    #ifdef ONLY_FOR_LEX
    	output("SUB","-",yylineno);
    #else
        return SUB;
    #endif
}
"*" {
   #ifdef ONLY_FOR_LEX
    	output("MUL","*",yylineno);
    #else
        return MUL;
    #endif
}
"/" {
    #ifdef ONLY_FOR_LEX
    	output("DIV","/",yylineno);
    #else
        return DIV;
    #endif
}
"%" {
    #ifdef ONLY_FOR_LEX
    	output("SUR","%",yylineno);
    #else
        return SUR;
    #endif
}
"==" {
    #ifdef ONLY_FOR_LEX
    	output("EQUAL","==",yylineno);
    #else
        return EQUAL;
    #endif
}
"!=" {
    #ifdef ONLY_FOR_LEX
    	output("NEQU","!=",yylineno);
    #else
        return NEUQ;
    #endif
}
">" {
    #ifdef ONLY_FOR_LEX
    	output("MORE",">",yylineno);
    #else
        return MORE;
    #endif
}
"<" {
    #ifdef ONLY_FOR_LEX 	
        output("LESS","<",yylineno);
    #else
        return LESS;
    #endif

}
">=" {
    #ifdef ONLY_FOR_LEX
    	output("MOE",">=",yylineno);
    #else
        return MOE;
    #endif
}
"<=" {
    #ifdef ONLY_FOR_LEX
    	output("LOE","<=",yylineno);
    #else
        return LOE;
    #endif
}
"&&" {
    #ifdef ONLY_FOR_LEX
    	output("AND","&&",yylineno);
    #else
        return AND;
    #endif
}
"||" {
    #ifdef ONLY_FOR_LEX
    	output("OR","||",yylineno);
    #else
        return OR;
    #endif
}
"!" {
    #ifdef ONLY_FOR_LEX
    	output("NOR","!",yylineno);
    #else
        return NOR;
    #endif
}
"," {
    #ifdef ONLY_FOR_LEX
    	output("COMMA",",",yylineno);
    #else
        return COMMA;
    #endif
}
";" {
    #ifdef ONLY_FOR_LEX
        output("SEMICOLON",";",yylineno);
        isdefined=0;
    #else
        return SEMICOLON;
    #endif
}
"(" {
    #ifdef ONLY_FOR_LEX
        output("LPAREN","(",yylineno);
    #else
        return LPAREN;
    #endif
}
")" {
    #ifdef ONLY_FOR_LEX
        output("RPAREN",")",yylineno);
    #else
    return RPAREN;
    #endif
}
"[" {
    #ifdef ONLY_FOR_LEX
    	output("LBRACKET","[",yylineno);
    #else
        return LBRACKET;
    #endif
}
"]" {
    #ifdef ONLY_FOR_LEX
    	output("RBRACKET","]",yylineno);
    #else
        return RBRACKET;
    #endif
}
"{" {
    #ifdef ONLY_FOR_LEX
        output("LBRACE","{",yylineno);
        int num=getnum(curscope);
        strcat(curscope,"-");
        char str[20];
        sprintf(str,"%d",num);
        strcat(curscope,str);
        addscope(curscope);
    #else
        return LBRACE;
    #endif
}
"}" {
    #ifdef ONLY_FOR_LEX
        output("RBRACE","}",yylineno);
        getfar(curscope);
    #else
        return RBRACE;
    #endif
}
{ID} {
    #ifdef ONLY_FOR_LEX
        if(isdefined){
        	add(yytext,curscope,yylineno);
        	output("ID",string(yytext),yylineno,string(curscope),yylineno);
        }
        else{
        	char getscope[50];
        	int value=0;
        	getval(yytext,curscope,getscope,value);
        	output("ID",string(yytext),yylineno,string(getscope),value);
        }
    #else
        return ID;
    #endif
}

{EOL} yylineno++;
{WHITE} {}
%%

#ifdef ONLY_FOR_LEX
int main(int argc, char **argv){
    yylineno=1;
    if(argc != 5){
        fprintf(stderr, "Argument Not Enough");
        exit(EXIT_FAILURE);
    }

    if(!(yyin = fopen(argv[1], "r"))){
        fprintf(stderr, "No such file or directory: %s", argv[1]);
        exit(EXIT_FAILURE);
    }

    if(!(yyout = fopen(argv[3], "w"))){
        fprintf(stderr, "No such file or directory: %s", argv[3]);
        exit(EXIT_FAILURE);
    }
    addscope(curscope);
    fprintf(yyout,"%10s\t%10s\t%6s\t%10s\t%10s\n","token","lexme","lineno","scope","value");
    yylex();
    return 0;
}
    void addscope(char* scope){
    	scopenode newnode;
    	strcpy(newnode.scope,scope);
    	scopechild.push_back(newnode);
    }
    int getnum(char* scope){
    	int i;
    	int size=scopechild.size();
    	for(i=0;i<size;i++){
    		if(strcmp(scope,scopechild[i].scope)==0){
    			scopechild[i].num++;
    			return scopechild[i].num;
    		}
    	}
    	return 0;
    }
    void getfar(char* scope){
    	if(strcmp(scope,"1")==0){
  		scope[0]='\0';  	
    	}
    	else{
    		int len=strlen(scope);
    		int j;
    		for( j=len-1;scope[j]!='-';j--){}
    		scope[j]='\0';
    	}
    }
    void add(char *name,char *scope,int value){
	Node newnode;
	strcpy(newnode.id,name);
	strcpy(newnode.scope,scope);
	newnode.value=value;
	symboltable.push_back(newnode);
    }
    int find(char* name,char* scope){
	int i=0;
	char copyscope[50];
	strcpy(copyscope,scope);
	int size=symboltable.size();
	while(copyscope[0]!='\0'){
		for(i=0;i<size;i++){
			if((strcmp(symboltable[i].id,name)==0)&&(strcmp(symboltable[i].scope,copyscope)==0))
				return i;
		}
		getfar(copyscope);
	}
	return i;
    }
    void getval(char* name,char* scope,char* getscope,int &value){
	int adder=find(name,scope);
	int size=symboltable.size();
	if(adder<size){
		strcpy(getscope,symboltable[adder].scope);
		value = symboltable[adder].value;
	}
	else{
		strcpy(getscope,"undefined");
		value = 0;
	}
    }
#endif
