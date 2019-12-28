package ru.crystals.xquery;

import org.basex.core.Context;
import org.basex.core.cmd.Set;
import org.basex.core.cmd.XQuery;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Objects;

public class Application {
    private ClassLoader classLoader;

    public Application() {
        classLoader = getClass().getClassLoader();
    }

    public static void main(String[] args) {
        Application application = new Application();
        application.run();
    }

    private void run() {
        String configDir = "/configs/d.romashov/projects/xquery_tests/home";
        String scriptPath = "xq/update.xq";

        runXQScript(configDir, scriptPath);
    }

    private void runXQScript(String homeDir, String scriptPath) {
        String currentHomeDir = System.getProperty("user.dir");
        try {
            System.setProperty("user.dir", new File(homeDir).getAbsolutePath());
            String scriptContent = readResource(scriptPath);
            Context context = new Context();
            new Set("EXPORTER", "method=xml, version=1.0, omit-xml-declaration=no, indents=8").execute(context);
            new Set("INTPARSE", "true").execute(context);
            new Set("WRITEBACK", "true").execute(context);
            new XQuery(scriptContent).execute(context);
        } catch (Exception e) {
            System.setProperty("user.dir", currentHomeDir);
            e.printStackTrace();
        }
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
