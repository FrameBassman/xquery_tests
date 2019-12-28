package ru.crystals.xquery.commands;

import org.basex.core.Context;
import org.basex.core.cmd.Set;
import org.basex.core.cmd.XQuery;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Objects;

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
        try {
            File file = new File((Objects.requireNonNull(classLoader.getResource(resourcePath))).getFile());
            return new String(Files.readAllBytes(file.toPath()));
        } catch (NullPointerException exception) {
            throw new FileNotFoundException(String.format("There is no resource with path: %s", resourcePath));
        }
    }
}
