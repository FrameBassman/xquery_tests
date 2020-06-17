package ru.crystals.xquery;

import java.util.Arrays;

public class ConsoleLogger {
    public void info(String message) {
        System.out.println("INFO: " + message);
    }

    public void error(StackTraceElement[] stackTrace) {
        System.out.println("ERROR: " + Arrays.toString(stackTrace));
    }
}
