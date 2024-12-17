all: parser lexer
	gcc -o parser y.tab.c lex.yy.c
lexer:  lex.yy.c
	flex token.l
parser: y.tab.c
	yacc calculator.y
