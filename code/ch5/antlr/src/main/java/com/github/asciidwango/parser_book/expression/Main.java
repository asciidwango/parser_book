package com.github.asciidwango.parser_book.expression;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.TokenStream.*;

import java.io.IOException;
import java.io.StringReader;

public class Main {
    public static CommonTokenStream streamFrom(String input) throws IOException {
        var antlrStream = new ANTLRInputStream(new StringReader(input));
        var lexer       = new ExpressionLexer(antlrStream);
        return new CommonTokenStream(lexer);
    }
    public static void main(String[] args) throws Exception {
        var parser = new ExpressionParser(streamFrom("(1 + 2) * 4 / 3"));
        System.out.println(parser.expression().e);
    }
}
