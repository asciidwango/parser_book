%{
#include "y.tab.h"
%}

%%
[0-9]+      { yylval = atoi(yytext); return NUM; }
[-+*/()]    { return yytext[0]; }
[ \t]       { /* ignore whitespce */ }
"\r\n"      { return EOL; }
"\r"        { return EOL; }
"\n"        { return EOL; }
.           { printf("Invalid character: %s\n", yytext); }
%%
