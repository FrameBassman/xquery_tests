package tech.romashov.xquery;

import org.slf4j.Logger;

public class ConsoleLogger {
    private final Logger logger;

    public ConsoleLogger(Logger origin) {
        logger = origin;
    }

    public void info(String message) {
        logger.info(message);
    }

    public void error(String message) {
        logger.error(message);
    }

    public void error(Exception e) {
        logger.error("Exception here:", e);
    }
}
