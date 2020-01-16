package ru.crystals.xquery.commands;

import org.basex.core.Context;
import org.basex.core.cmd.Set;
import org.basex.core.cmd.XQuery;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class RunXqScript extends ResourcesRelatedCommand {
    private String scriptPath;

    public RunXqScript(String scriptResourcePath) {
        scriptPath = scriptResourcePath;
    }

    @Override
    public void update() throws Exception {
        String scriptContent = readResource(scriptPath);
        Context context = new Context();
        new Set("EXPORTER", "method=xml, version=1.0, omit-xml-declaration=no, indents=8").execute(context);
        new Set("INTPARSE", "true").execute(context);
        new Set("WRITEBACK", "true").execute(context);
        new XQuery(scriptContent).execute(context);
    }

    @Override
    public void restore() {
        // nothing
    }

    private String readResource(String resourcePath) throws IOException {
        ClassLoader classLoader = getClass().getClassLoader();
        try (InputStream input = classLoader.getResourceAsStream(resourcePath)) {
            if (input == null) {
                throw new IOException("Cannot read from resource");
            }
            try (InputStreamReader reader = new InputStreamReader(input);
                 BufferedReader br = new BufferedReader(reader)) {
                String line;
                StringBuilder content = new StringBuilder();
                while ((line = br.readLine()) != null) {
                    content.append(line);
                }
                return content.toString();
            }
        }
    }
}