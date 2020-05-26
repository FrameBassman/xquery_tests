package ru.crystals.xquery;

import ru.crystals.xquery.commands.ChangeHomeDirectory;
import ru.crystals.xquery.commands.CommandsList;
import ru.crystals.xquery.commands.RunXqScripts;

public class Application {
    private CommandsList commands;

    public Application() {
        commands = new CommandsList(
                new ChangeHomeDirectory("config"),
                new RunXqScripts()
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
