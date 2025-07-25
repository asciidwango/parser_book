package parser.lr0;

public sealed interface Expression permits Expression.NonTerminal, Expression.Terminal {
    record NonTerminal(String name) implements Expression {}
    record Terminal(String value) implements Expression {}
}