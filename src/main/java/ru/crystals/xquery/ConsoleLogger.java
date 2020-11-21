package ru.crystals.xquery;

import java.util.Arrays;

public class ConsoleLogger {
    public void info(String message) {
        System.out.println("INFO: " + message);
    }

    public void error(String message) {
        System.out.println("ERROR: " + message);
    }

    public void error(Exception e) {
        System.out.println("ERROR: " + e.getMessage());
        e.printStackTrace();
    }
}
