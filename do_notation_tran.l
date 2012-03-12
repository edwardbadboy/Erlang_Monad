%option noyywrap nodefault yylineno

%s DO_M

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
void pushparsestate(void);
void popparsestate(void);

typedef struct _parseS {
	long gdepth;
	long gmdepth;
	char *gmodule;
	char *gv;
	struct _parseS *next;
}parseS;

parseS * S=NULL;

%}

%%

[a-z][a-zA-Z0-9_]*[\t ]+"do"[\t ]*/"{" { pushparsestate(); BEGIN(DO_M); gmodule=dup1stword(yytext); printf("%s:bind( ( fun()->",gmodule); ++gmdepth; }
<DO_M>"{" { ++gdepth; if(gdepth>1){ ECHO; } }
<DO_M>"}" { --gdepth; if(0!=gdepth){ ECHO;} else { printf(" end()), fun %s:return/1)\n", gmodule); --gmdepth; while(gmdepth>0){printf("end)\n");--gmdepth;} free(gmodule); gmodule=NULL; popparsestate(); if(S==NULL){ BEGIN(INITIAL); } } }
<DO_M>.*"<<" { gv=dupunboxedname(yytext, yyleng); }
<DO_M>";;" { printf(" end()\n), fun( (%s) )-> ",gv?gv:"_"); free(gv); gv=NULL; printf("%s:bind( ( fun()->",gmodule); ++gmdepth; }
.|\n { ECHO; }

%%

void pushparsestate(void){
	parseS *ps=malloc(sizeof(*ps));
	assert(ps);
	ps->gdepth=gdepth;
	ps->gmdepth=gmdepth;
	ps->gmodule=gmodule;
	ps->gv=gv;
	ps->next=S;
	gdepth=0;gmdepth=0;gmodule=NULL;gv=NULL;
	S=ps;
	return;
}

void popparsestate(void){
	assert(S);
	gdepth=S->gdepth;
	gmdepth=S->gmdepth;
	gmodule=S->gmodule;
	gv=S->gv;
	parseS *next=S->next;
	free(S);
	S=next;
	return;
}

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
