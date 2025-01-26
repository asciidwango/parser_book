package parser.slr0;

import java.util.ArrayList;
import java.util.List;

public class Main {
    private static List<Expression> toExpressions(String input) {
        List<Expression> result = new ArrayList<>();
        for(int i = 0; i < input.length(); i++) {
            result.add(new Expression.Terminal(input.substring(i, i + 1)));
        }
        return result;
    }
    public static void main(String[] args) {
        Grammar grammar = new Grammar(
                "E",
                List.of(
                        new Rule("E", List.of(new Expression.NonTerminal("T"), new Expression.NonTerminal("E'"))),
                        new Rule("E'", List.of(new Expression.Terminal("+"), new Expression.NonTerminal("T"), new Expression.NonTerminal("E'"))),
                        new Rule("E'", List.of()),  // ε (空生成)
                        new Rule("T", List.of(new Expression.NonTerminal("F"), new Expression.NonTerminal("T'"))),
                        new Rule("T'", List.of(new Expression.Terminal("*"), new Expression.NonTerminal("F"), new Expression.NonTerminal("T'"))),
                        new Rule("T'", List.of()),  // ε (空生成)
                        new Rule("F", List.of(new Expression.Terminal("("), new Expression.NonTerminal("E"), new Expression.Terminal(")"))),
                        new Rule("F", List.of(new Expression.Terminal("x")))
                )
        );

        SLR0Parser parser = new SLR0Parser(grammar);
        boolean result = parser.parse(toExpressions("((x+(x*x)))"));

        System.out.println("Parsing result: " + result);
    }
}