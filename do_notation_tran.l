%option noyywrap nodefault yylineno

%x DO_M

%{
//initializing
#include <stdio.h>
#include <string.h>
#include <assert.h>
long gdepth=0;
long gmdepth=0;
char * gmodule=NULL;
char * gv=NULL;
char *dup1stword(const char* text);
char *dupunboxedname(const char* text, long length);
%}

%%

[a-z][a-zA-Z0-9_]*[\t ]+"do"[\t ]+ { BEGIN(DO_M); gmodule=dup1stword(yytext); printf("%s:bind( ( fun()->",gmodule); ++gmdepth; }
<DO_M>"{" { ++gdepth; if(gdepth>1){ ECHO; } }
<DO_M>"}" { --gdepth; if(0!=gdepth){ ECHO;} else { printf(" end()), fun %s:return/1)\n", gmodule); --gmdepth; while(gmdepth>0){printf("end)\n");--gmdepth;} BEGIN(INITIAL); free(gmodule); gmodule=NULL;} }
<DO_M>.*"<<" { gv=dupunboxedname(yytext, yyleng); }
<DO_M>";;" { printf(" end()\n), fun( (%s) )-> ",gv?gv:"_"); free(gv); gv=NULL; printf("%s:bind( ( fun()->",gmodule); ++gmdepth; }
<DO_M>.|\n { ECHO; }
.|\n { ECHO; }

%%

char *dupunboxedname(const char* text, long length){
	const char *tail=text+length-1;
	const char* p=text;
	while(*p && isspace(*p))++p;
	while(tail!=text && '<'==*tail){--tail;}
	while(tail!=text && isspace(*tail)){--tail;}
	char *r=NULL;
	r=malloc(tail-p+2);
	assert(r);
	memcpy(r,p,tail-p+1);
	r[tail-p+1]='\0';
	return r;
}

char *dup1stword(const char* text){
	const char* p=text;
	while(*p && isspace(*p))++p;
	while(*p && (isalnum(*p) || '_'==*p)){++p;}
	char *d=NULL;
	d=malloc(p-text+1);
	assert(d);
	memcpy(d,text,p-text);
	d[p-text]='\0';
	return d;
}

int main(int argc, char* argv[]){
	yylex();
	return 0;
}
