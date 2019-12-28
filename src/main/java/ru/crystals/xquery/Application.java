package ru.crystals.xquery;

import org.basex.core.Context;
import org.basex.core.cmd.Set;
import org.basex.core.cmd.XQuery;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;

public class Application {
    public static void main(String[] args) {
        String configDir = "/home/d.romashov/projects/xquery_tests/home";
        String scriptPath = "/home/d.romashov/projects/xquery_tests/src/main/resources/xq/update.xq";

        Application application = new Application();
        application.runXQScript(configDir, scriptPath);
    }

    private void runXQScript(String homeDir, String scriptPath) {
        String currentHomeDir = System.getProperty("user.dir");
        try {
            System.setProperty("user.dir", new File(homeDir).getAbsolutePath());
            String scriptContent = new String(Files.readAllBytes(Paths.get(scriptPath)));
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
}
