package tech.romashov.xquery.commands;

import org.basex.core.Context;
import org.basex.core.cmd.Set;
import org.basex.core.cmd.XQuery;
import tech.romashov.xquery.ConsoleLogger;

public class RunXqScript extends ResourcesRelatedCommand {
    private ConsoleLogger log;
    private String scriptPath;
    private Context context;

    public RunXqScript(ConsoleLogger logger, String scriptResourcePath) {
        log = logger;
        scriptPath = scriptResourcePath;
        context = new Context();
    }

    @Override
    public void update() throws Exception {
        String scriptContent = readResource(scriptPath);
        new Set("EXPORTER", "method=xml, version=1.0, omit-xml-declaration=no, indents=4").execute(context);
        new Set("INTPARSE", "true").execute(context);
        new Set("WRITEBACK", "true").execute(context);
        try {
            log.info(String.format("Start %s", scriptPath));
            String output = new XQuery(scriptContent).execute(context);
            log.info("\nOutput from XQuery:\n" + output);
        } catch (Exception e) {
            log.error(e);
        } finally {
            log.info(String.format("Finish %s", scriptPath));
        }

    }

    @Override
    public void restore() {
        // nothing
    }
}
