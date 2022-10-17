package parser;
import java.util.*;

public record Rule(char lhs, List<Character> rhs) {
    private static List<Character> toListOfCharacter(String string) {
        List<Character> characters = new ArrayList<>();
        for(int i = 0; i < string.length(); i++) {
            characters.add(string.charAt(i));
        }
        return characters;
    }
    public Rule(char lhs, String rhs) {
        this(lhs, toListOfCharacter(rhs));
    }
    public boolean matches(String sequence) {
        return matches(toListOfCharacter(sequence));
    }
    public boolean matches(List<Character> sequence) {
        for(int i = 1; i <= rhs.size(); i++) {
            char a = rhs.get(rhs.size() - i);
            if(sequence.size() - i < 0) return false;
            char b = sequence.get(sequence.size() - i);
            if(a != b) return false;
        }
        return true;
    }
}