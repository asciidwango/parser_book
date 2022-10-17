package parser;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class Dyck {
    private String input;
    private int position;
    private final List<Rule> rules;

    private List<Character> symbols;

    public Dyck() {
        this.rules = List.of(
                new Rule('D', "$P$"),
                new Rule('P', "()"),
                new Rule('P', "(P)")
        );
    }

    private Optional<Rule> findRule() {
        return rules.stream().filter(r -> r.matches(symbols)).findFirst();
    }

    private void shift() {
        symbols.add(input.charAt(position));
        position++;
    }

    private void reduce(Rule rule) {
        for(int i = 1; i <= rule.rhs().size(); i++) {
            symbols.remove(symbols.size() - 1);
        }
        symbols.add(rule.lhs());
    }

    public boolean parse(String source) {
        this.input = "$" + source + "$";
        this.position = 0;
        this.symbols = new ArrayList<>();

        while(true) {
            var optRule = findRule();
            if(optRule.isPresent()) {
                reduce(optRule.get());
                if(symbols.size() == 1) return true;
            } else {
                if(position >= input.length()) return false;
                shift();
            }
        }
    }
}
