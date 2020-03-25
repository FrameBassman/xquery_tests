package ru.crystals.xquery;

import ru.crystals.xquery.commands.ChangeHomeDirectory;
import ru.crystals.xquery.commands.CommandsList;
import ru.crystals.xquery.commands.RunXqScript;

public class Application {
    private CommandsList commands;

    public Application() {
        commands = new CommandsList(
                new ChangeHomeDirectory("configs"),
                new RunXqScript("xq/xml_U_10.2.78.0_705.xq"),
                new RunXqScript("xq/xml_U_10.2.78.0_706.xq")
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
