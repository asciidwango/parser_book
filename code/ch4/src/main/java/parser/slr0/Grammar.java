package parser.slr0;
import java.util.List;

public record Grammar(String start, List<Rule> rules) {}
