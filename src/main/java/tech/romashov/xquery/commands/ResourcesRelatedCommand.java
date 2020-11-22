package tech.romashov.xquery.commands;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public abstract class ResourcesRelatedCommand extends Command {
    protected ClassLoader classLoader;

    public ResourcesRelatedCommand() {
        classLoader = getClass().getClassLoader();
    }

    protected String readResource(String resourcePath) throws IOException {
        try (InputStream input = classLoader.getResourceAsStream(resourcePath)) {
            if (input == null) {
                throw new IOException("Cannot read from resource");
            }
            try (InputStreamReader reader = new InputStreamReader(input);
                 BufferedReader br = new BufferedReader(reader)) {
                String line;
                StringBuilder content = new StringBuilder();
                while ((line = br.readLine()) != null) {
                    content.append(line).append(System.lineSeparator());
                }
                return content.toString();
            }
        }
    }
}
