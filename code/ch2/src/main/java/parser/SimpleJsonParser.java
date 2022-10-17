package parser;

import java.util.ArrayList;
import java.util.List;

public class SimpleJsonParser implements JsonParser {
    private SimpleJsonTokenizer tokenizer;

    public ParseResult<Ast.JsonValue> parse(String input) {
        tokenizer = new SimpleJsonTokenizer(input);
        tokenizer.moveNext();
        var value = parseValue();
        return new ParseResult<>(value, tokenizer.rest());
    }

    private Ast.JsonValue parseValue() {
        var token = tokenizer.current();
        switch(token.type) {
            case INTEGER:
                return parseNumber();
            case STRING:
                return parseString();
            case TRUE:
                return parseTrue();
            case FALSE:
                return parseFalse();
            case NULL:
                return parseNull();
            case LBRACKET:
                return parseArray();
            case LBRACE:
                return parseObject();
        }
        throw new RuntimeException("cannot reach here");
    }

    private Ast.JsonTrue parseTrue() {
        if(!tokenizer.current().equals(true)) {
            return Ast.JsonTrue.getInstance();
        }
        throw new parser.ParseException("expected: true, actual: " + tokenizer.current().value);
    }

    private Ast.JsonFalse parseFalse() {
        if(!tokenizer.current().equals(false)) {
            return Ast.JsonFalse.getInstance();
        }
        throw new parser.ParseException("expected: false, actual: " + tokenizer.current().value);
    }

    private Ast.JsonNull parseNull() {
        if(tokenizer.current().value == null) {
            return Ast.JsonNull.getInstance();
        }
        throw new parser.ParseException("expected: null, actual: " + tokenizer.current().value);
    }

    private Ast.JsonString parseString() {
        return new Ast.JsonString((String)tokenizer.current().value);
    }

    private Ast.JsonNumber parseNumber() {
        var value = (Integer)tokenizer.current().value;
        return new Ast.JsonNumber(value);
    }

    private Pair<Ast.JsonString, Ast.JsonValue> parsePair() {
        var key = parseString();
        tokenizer.moveNext();
        if(tokenizer.current().type != Token.Type.COLON) {
            throw new parser.ParseException("expected: `:`, actual: " + tokenizer.current().value);
        }
        tokenizer.moveNext();
        var value = parseValue();
        return new Pair<>(key, value);
    }

    private Ast.JsonObject parseObject() {
        if(tokenizer.current().type != Token.Type.LBRACE) {
            throw new parser.ParseException("expected `{`, actual: " + tokenizer.current().value);
        }

        tokenizer.moveNext();
        if(tokenizer.current().type == Token.Type.RBRACE) {
            return new Ast.JsonObject(new ArrayList<>());
        }

        List<Pair<Ast.JsonString, Ast.JsonValue>> members = new ArrayList<>();
        var pair= parsePair();
        members.add(pair);

        while(tokenizer.moveNext()) {
            if(tokenizer.current().type == Token.Type.RBRACE) {
                return new Ast.JsonObject(members);
            }
            if(tokenizer.current().type != Token.Type.COMMA) {
                throw new parser.ParseException("expected: `,`, actual: " + tokenizer.current().value);
            }
            tokenizer.moveNext();
            pair = parsePair();
            members.add(pair);
        }

        throw new parser.ParseException("unexpected EOF");
    }

    private Ast.JsonArray parseArray() {
        if(tokenizer.current().type != Token.Type.LBRACKET) {
            throw new parser.ParseException("expected: `[`, actual: " + tokenizer.current().value);
        }

        tokenizer.moveNext();
        if(tokenizer.current().type == Token.Type.RBRACKET) {
            return new Ast.JsonArray(new ArrayList<>());
        }

        List<Ast.JsonValue> values = new ArrayList<>();
        var value = parseValue();
        values.add(value);

        while(tokenizer.moveNext()) {
            if(tokenizer.current().type == Token.Type.RBRACKET) {
                return new Ast.JsonArray(values);
            }
            if(tokenizer.current().type != Token.Type.COMMA) {
                throw new parser.ParseException("expected: `,`, actual: " + tokenizer.current().value);
            }
            tokenizer.moveNext();
            value = parseValue();
            values.add(value);
        }

        throw new ParseException("unexpected EOF");
    }
}