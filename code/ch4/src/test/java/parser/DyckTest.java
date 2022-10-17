package parser;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class DyckTest {
    @Test
    public void testDyck1Works() {
        var dyck = new Dyck();
        assertTrue(dyck.parse("()"));
    }

    @Test
    public void testDyck2Works() {
        var dyck = new Dyck();
        assertTrue(dyck.parse("(())"));
    }

    @Test
    public void testDyck3Works() {
        var dyck = new Dyck();
        assertTrue(dyck.parse("((()))"));
    }

    @Test
    public void testDyck10Works() {
        var dyck = new Dyck();
        assertTrue(dyck.parse("(((((((((())))))))))"));
    }
}
