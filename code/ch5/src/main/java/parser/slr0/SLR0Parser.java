package parser.slr0;

import java.util.*;

public class SLR0Parser {
    private final Grammar grammar;
    private final List<LR0ItemSet> states;
    private final Map<LR0ItemSet, Map<Expression, LR0ItemSet>> transitions;

    public SLR0Parser(Grammar grammar) {
        List<Rule> extendedRules = new ArrayList<>(grammar.rules());
        String newStart = grammar.start() + "'";
        extendedRules.add(0, new Rule(newStart, List.of(new Expression.NonTerminal(grammar.start()))));
        this.grammar = new Grammar(newStart, extendedRules);
        this.states = new ArrayList<>();
        this.transitions = new HashMap<>();
        buildStates();
    }

    private void buildStates() {
        Rule startRule = grammar.rules().get(0);
        System.out.println("startRule: " + startRule);
        LR0Item startItem = new LR0Item(startRule, 0);
        LR0ItemSet startState = new LR0ItemSet(Set.of(startItem)).closure(grammar);
        states.add(startState);

        Queue<LR0ItemSet> worklist = new ArrayDeque<>();
        worklist.add(startState);

        while (!worklist.isEmpty()) {
            LR0ItemSet state = worklist.poll();
            Map<Expression, LR0ItemSet> stateTransitions = new HashMap<>();
            for (LR0Item item : state.items()) {
                Expression next = item.nextSymbol();
                if (next != null) {
                    LR0ItemSet nextState = new LR0ItemSet(Set.of(item.advance())).closure(grammar);
                    if (!states.contains(nextState)) {
                        states.add(nextState);
                        worklist.add(nextState);
                    }
                    stateTransitions.put(next, nextState);
                }
            }
            transitions.put(state, stateTransitions);
        }
    }

    public boolean parse(List<Expression> input) {
        Stack<LR0ItemSet> stack = new Stack<>();
        stack.push(states.get(0));

        int index = 0;
        while (index <= input.size()) {
            LR0ItemSet currentState = stack.peek();
            Expression currentSymbol = index < input.size() ? input.get(index) : null;

            System.out.println("Current State: " + currentState);
            System.out.println("Current Symbol: " + currentSymbol);

            Map<Expression, LR0ItemSet> stateTransitions = transitions.get(currentState);

            if (currentSymbol != null && stateTransitions != null && stateTransitions.containsKey(currentSymbol)) {
                System.out.println("Shifting: " + currentSymbol);
                stack.push(stateTransitions.get(currentSymbol));
                index++;
            } else {
                boolean reduced = false;
                for (LR0Item item : currentState.items()) {
                    if (item.nextSymbol() == null) {  // A completed item
                        System.out.println("Reducing by rule: " + item.rule());
                        for (int i = 0; i < item.rule().body().size(); i++) {
                            stack.pop();
                        }
                        LR0ItemSet gotoState = transitions.get(stack.peek()).get(new Expression.NonTerminal(item.rule().name()));
                        if (gotoState != null) {
                            stack.push(gotoState);
                            System.out.println("Goto state: " + gotoState);
                            reduced = true;
                            break;
                        } else if (item.rule().name().equals(grammar.start()) && stack.size() == 1 && index == input.size()) {
                            // 受理状態に達し、かつすべての入力が消費された場合
                            System.out.println("Accepting state reached with full input consumption.");
                            return true;
                        } else {
                            System.out.println("No Goto state found.");
                            return false;
                        }
                    }
                }
                if (!reduced) {
                    return false;
                }
            }
        }

        return false;
    }
}
