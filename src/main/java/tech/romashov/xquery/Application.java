package tech.romashov.xquery;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import tech.romashov.xquery.commands.ChangeHomeDirectory;
import tech.romashov.xquery.commands.CommandsList;
import tech.romashov.xquery.commands.RunXqScripts;

public class Application {
    private CommandsList commands;
    protected Logger logger = LoggerFactory.getLogger(Application.class);

    public Application() {
        ConsoleLogger log = new ConsoleLogger(logger);
        commands = new CommandsList(
                new ChangeHomeDirectory(log, "crystal-cash"),
                new RunXqScripts(log)
        );
    }

    public static void main(String[] args) {
        Application application = new Application();
        application.run();
    }

    private void run() {
        try {
            commands.update();
        } catch (Exception e) {
            e.printStackTrace();
            commands.restore();
        }
    }
}
